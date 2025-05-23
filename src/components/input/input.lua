local input = {}

local errorMessage = nil
local actionMode = nil

function input.setErrorMessage(message)
    errorMessage = message
end

function input.getErrorMessage()
    return errorMessage
end

function input.getActionMode()
    return actionMode
end

function input.mousepressed(x, y, button, board, playerPieces, enemyPieces, network, pieces, turn, combat)
    local boardSize = board.getSize()
    local tileSize = board.getTileSize()
    local boardX, boardY = board.getOffset()

    local buttonX = boardX + (boardSize * tileSize) / 2 - 50
    local buttonY = boardY + boardSize * tileSize + 20
    local buttonWidth = 100
    local buttonHeight = 40

    if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
        if combat.actionButtonActive and turn.getCurrentTurn() == "player" then
            if actionMode then
                combat.selectedPiece = nil
                combat.actionButtonActive = false
                actionMode = nil
                combat.actionMode = nil
                errorMessage = nil
            else
                if combat.selectedPiece then
                    if combat.selectedPiece.name == "Bouclier" then
                        actionMode = "shield"
                    elseif combat.selectedPiece.name == "Mur" then
                        actionMode = "deployWall"
                    else
                        actionMode = "attack"
                    end
                end
                combat.actionMode = actionMode
                errorMessage = nil
            end
        end
        return
    end

    local gridX = math.floor((x - boardX) / tileSize) + 1
    local gridY = math.floor((y - boardY) / tileSize) + 1

    if gridX >= 1 and gridX <= boardSize and gridY >= 1 and gridY <= boardSize then
        if turn.getCurrentTurn() == "player" then
            if actionMode == "shield" or actionMode == "attack" or actionMode == "deployWall" then
                local piece = combat.selectedPiece
                if piece and piece.name ~= "Tourelle" and not piece.hasUsedAction and not (piece.name == "Sniper" and piece.hasUsedAttackInGame) and not (piece.name == "Mur" and piece.hasUsedWallInGame) then
                    local action = actionMode
                    local response, newTurn = network.sendAction(piece, action, gridX, gridY, turn.getCurrentTurn())
                    if response.success then
                        turn.setCurrentTurn(newTurn)
                        if piece.name == "Kamikaze" then
                            for i, p in ipairs(playerPieces) do
                                if p == piece then
                                    table.remove(playerPieces, i)
                                    break
                                end
                            end
                        elseif piece.name == "Sniper" then
                            piece.hasUsedAttackInGame = true
                        elseif piece.name == "Mur" then
                            piece.hasUsedWallInGame = true
                        end
                        actionMode = nil
                        combat.actionMode = nil
                        combat.selectedPiece = nil
                        combat.actionButtonActive = false
                    else
                        errorMessage = response.error
                    end
                else
                    errorMessage = "Action invalide ou déjà utilisée"
                end
            else
                local piece = nil
                for _, p in ipairs(playerPieces) do
                    if p.x == gridX and p.y == gridY and p.hp > 0 then
                        piece = p
                        break
                    end
                end
                if piece then
                    combat.selectedPiece = piece
                    combat.actionButtonActive = (piece.name ~= "Tourelle" and not piece.hasUsedAction and not (piece.name == "Sniper" and piece.hasUsedAttackInGame) and not (piece.name == "Mur" and piece.hasUsedWallInGame) and piece.hp > 0)
                    errorMessage = nil
                else
                    if combat.selectedPiece then
                        local response, newTurn = network.sendMove(combat.selectedPiece, gridX, gridY, turn.getCurrentTurn())
                        if response.success then
                            turn.setCurrentTurn(newTurn)
                            combat.selectedPiece = nil
                            combat.actionButtonActive = false
                        else
                            errorMessage = response.error
                        end
                    end
                end
            end
        else
            errorMessage = "Ce n'est pas votre tour !"
        end
    else
        combat.selectedPiece = nil
        combat.actionButtonActive = false
        actionMode = nil
        combat.actionMode = nil
        errorMessage = nil
    end
end

return input