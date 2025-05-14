local input = {}

function input.mousepressed(x, y, button, board, playerPieces, enemyPieces, network, pieces, turn)
    if turn.getCurrentTurn() ~= "player" then
        input.errorMessage = "Ce n'est pas votre tour !"
        return
    end

    local boardSize = board.getSize()
    local tileSize = board.getTileSize()
    local boardX, boardY = board.getOffset()
    local boardCol = math.floor((x - boardX) / tileSize) + 1
    local boardRow = math.floor((y - boardY) / tileSize) + 1

    if boardCol < 1 or boardCol > boardSize or boardRow < 1 or boardRow > boardSize then
        return
    end

    if button == 1 then -- Clic gauche : sélectionner/déplacer
        if input.actionMode then
            if input.selectedPiece then
                local targetPiece = board.getTile(boardCol, boardRow)
                if input.actionMode == "attack" and input.selectedPiece.name == "Tourelle" then
                    local distance = math.abs(input.selectedPiece.x - boardCol) + math.abs(input.selectedPiece.y - boardRow)
                    if distance ~= 1 then
                        input.errorMessage = "Cible doit être à 1 case"
                    else
                        local response = network.sendAction(input.selectedPiece, "attack", boardCol, boardRow, turn.getCurrentTurn())
                        if response.success then
                            pieces.updateAfterAction(input.selectedPiece, "attack", targetPiece, playerPieces, enemyPieces, board)
                            turn.setCurrentTurn(response.currentTurn)
                        else
                            input.errorMessage = response.error or "Erreur lors de l'attaque"
                        end
                    end
                end
                input.actionMode = nil
                input.selectedPiece = nil
            end
        else
            if input.selectedPiece then
                local response = network.sendMove(input.selectedPiece, boardCol, boardRow, turn.getCurrentTurn())
                if response.success then
                    pieces.updateAfterMove(input.selectedPiece, response.piece.x, response.piece.y, board)
                    turn.setCurrentTurn(response.currentTurn)
                    input.selectedPiece = nil
                else
                    input.errorMessage = response.error or "Erreur lors du déplacement"
                    input.selectedPiece = nil
                end
            else
                for _, piece in ipairs(playerPieces) do
                    if piece.x == boardCol and piece.y == boardRow and piece.hp > 0 then
                        input.selectedPiece = piece
                        break
                    end
                end
            end
        end
    elseif button == 2 then -- Clic droit : choisir une action
        for _, piece in ipairs(playerPieces) do
            if piece.x == boardCol and piece.y == boardRow and piece.hp > 0 and not piece.hasMoved and not piece.hasUsedAction then
                if piece.name == "Tourelle" then
                    input.actionMode = "attack"
                    input.selectedPiece = piece
                end
                break
            end
        end
    end
end

function input.getErrorMessage()
    return input.errorMessage
end

function input.setErrorMessage(msg)
    input.errorMessage = msg
end

function input.getActionMode()
    return input.actionMode
end

function input.clearActionMode()
    input.actionMode = nil
end

function input.getSelectedPiece()
    return input.selectedPiece
end

function input.clearSelectedPiece()
    input.selectedPiece = nil
end

return input