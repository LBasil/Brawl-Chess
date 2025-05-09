-- input.lua : Gère les interactions utilisateur (clics de souris)

local input = {}
local network = require("network")

-- Convertir les coordonnées de la souris en case du plateau
local function getBoardPosition(combat, x, y)
    local boardCol = math.floor((x - combat.boardX) / combat.tileSize) + 1
    local boardRow = math.floor((y - combat.boardY) / combat.tileSize) + 1
    if boardCol >= 1 and boardCol <= combat.boardSize and boardRow >= 1 and boardRow <= combat.boardSize then
        return boardCol, boardRow
    end
    return nil, nil
end

-- Gérer les clics de souris
function input.mousepressed(combat, x, y, button)
    if combat.currentTurn ~= "player" then
        combat.errorMessage = "Ce n'est pas votre tour !"
        return
    end

    local boardCol, boardRow = getBoardPosition(combat, x, y)
    if not boardCol then return end  -- Clic hors du plateau

    if button == 1 then  -- Clic gauche : sélectionner/déplacer
        if combat.actionMode then
            local targetPiece = combat.board[boardCol][boardRow]
            if combat.selectedPiece then
                if combat.actionMode == "attack" and (combat.selectedPiece.name == "Sniper" or combat.selectedPiece.name == "Kamikaze") then
                    if targetPiece and targetPiece.type == "enemy" then
                        local distance = math.abs(combat.selectedPiece.x - boardCol) + math.abs(combat.selectedPiece.y - boardRow)
                        if combat.selectedPiece.name == "Kamikaze" and distance ~= 1 then
                            combat.errorMessage = "Kamikaze : cible trop loin (1 case max)"
                        else
                            local response = network.sendAction(combat, combat.selectedPiece, "attack", boardCol, boardRow)
                            if response.success then
                                targetPiece.hp = targetPiece.hp - 1
                                if combat.selectedPiece.name == "Kamikaze" then
                                    combat.board[combat.selectedPiece.x][combat.selectedPiece.y] = nil
                                    for i, p in ipairs(combat.playerPieces) do
                                        if p == combat.selectedPiece then
                                            table.remove(combat.playerPieces, i)
                                            break
                                        end
                                    end
                                end
                                if targetPiece.hp <= 0 then
                                    combat.board[boardCol][boardRow] = nil
                                    for i, e in ipairs(combat.enemyPieces) do
                                        if e == targetPiece then
                                            table.remove(combat.enemyPieces, i)
                                            break
                                        end
                                    end
                                end
                                combat.selectedPiece.hasUsedAction = true
                            end
                        end
                    else
                        combat.errorMessage = "Cible invalide : doit être un ennemi"
                    end
                elseif combat.actionMode == "shield" and combat.selectedPiece.name == "Bouclier" then
                    if targetPiece and targetPiece.type == "player" then
                        local response = network.sendAction(combat, combat.selectedPiece, "shield", boardCol, boardRow)
                        if response.success then
                            targetPiece.shield = (targetPiece.shield or 0) + 1
                        end
                    else
                        combat.errorMessage = "Cible invalide : doit être un allié"
                    end
                elseif combat.actionMode == "deploy" and combat.selectedPiece.name == "Mur" then
                    local response = network.sendAction(combat, combat.selectedPiece, "deploy", boardCol, boardRow)
                    if response.success then
                        combat.selectedPiece.hasUsedAction = true
                        for _, wall in ipairs(response.wallPieces or {}) do
                            local newPiece = {
                                name = wall.name,
                                type = wall.type,
                                x = wall.x,
                                y = wall.y,
                                hp = wall.hp,
                                maxHP = wall.maxHP
                            }
                            table.insert(combat.playerPieces, newPiece)
                            combat.board[wall.x][wall.y] = newPiece
                        end
                    end
                end
                combat.actionMode = nil
                combat.selectedPiece = nil
            end
        else
            if combat.selectedPiece then
                local response = network.sendMove(combat, combat.selectedPiece, boardCol, boardRow)
                if response.success then
                    combat.board[combat.selectedPiece.x][combat.selectedPiece.y] = nil
                    combat.selectedPiece.x = response.piece.x
                    combat.selectedPiece.y = response.piece.y
                    combat.board[combat.selectedPiece.x][combat.selectedPiece.y] = combat.selectedPiece
                    if combat.selectedPiece.name == "Tourelle" then
                        combat.selectedPiece.hasMoved = true
                    end
                    combat.selectedPiece = nil
                else
                    combat.selectedPiece = nil
                end
            else
                for _, piece in ipairs(combat.playerPieces) do
                    if piece.x == boardCol and piece.y == boardRow and piece.hp > 0 then
                        combat.selectedPiece = piece
                        break
                    end
                end
            end
        end
    elseif button == 2 then  -- Clic droit : choisir une action
        for _, piece in ipairs(combat.playerPieces) do
            if piece.x == boardCol and piece.y == boardRow and piece.hp > 0 then
                if piece.name == "Sniper" or piece.name == "Kamikaze" then
                    if not piece.hasUsedAction then
                        combat.actionMode = "attack"
                        combat.selectedPiece = piece
                    else
                        combat.errorMessage = "Action déjà utilisée"
                    end
                elseif piece.name == "Bouclier" then
                    combat.actionMode = "shield"
                    combat.selectedPiece = piece
                elseif piece.name == "Mur" and not piece.hasUsedAction then
                    combat.actionMode = "deploy"
                    combat.selectedPiece = piece
                end
                break
            end
        end
    end
end

return input