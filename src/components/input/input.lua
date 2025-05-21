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

    -- Bouton Action : position et taille
    local buttonX = boardX + (boardSize * tileSize) / 2 - 50
    local buttonY = boardY + boardSize * tileSize + 20
    local buttonWidth = 100
    local buttonHeight = 40

    -- Vérifier si le clic est sur le bouton Action
    if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
        if combat.actionButtonActive and turn.getCurrentTurn() == "player" then
            if actionMode then
                -- Désélectionner si on re-clique sur le bouton en mode action
                combat.selectedPiece = nil
                combat.actionButtonActive = false
                actionMode = nil
                combat.actionMode = nil
                errorMessage = nil
            else
                actionMode = "attack"
                combat.actionMode = actionMode
                errorMessage = nil
            end
        end
        return
    end

    -- Convertir les coordonnées de l'écran en coordonnées de la grille
    local gridX = math.floor((x - boardX) / tileSize) + 1
    local gridY = math.floor((y - boardY) / tileSize) + 1

    -- Vérifier si le clic est dans les limites du plateau
    if gridX >= 1 and gridX <= boardSize and gridY >= 1 and gridY <= boardSize then
        if turn.getCurrentTurn() == "player" then
            if actionMode == "attack" then
                local piece = combat.selectedPiece
                if piece and piece.name ~= "Tourelle" and not piece.hasUsedAction then -- Exclure la Tourelle
                    local response, newTurn = network.sendAction(piece, "attack", gridX, gridY, turn.getCurrentTurn())
                    if response.success then
                        turn.setCurrentTurn(newTurn)
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
                    -- Activer le bouton Action uniquement si le pion n'est pas une Tourelle et peut agir
                    combat.actionButtonActive = (piece.name ~= "Tourelle" and not piece.hasUsedAction and piece.hp > 0)
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