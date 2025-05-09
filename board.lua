-- board.lua : Gère le plateau et la logique de jeu (initialisation, tours, actions automatiques)

local board = {}
local network = require("network")

-- Initialiser le plateau 8x8
function board.init(boardSize)
    board.data = {}
    for i = 1, boardSize do
        board.data[i] = {}
        for j = 1, boardSize do
            board.data[i][j] = nil  -- Case vide
        end
    end
end

-- Actions automatiques au début du tour (ex. Tourelle)
function board.startTurn(combat)
    if combat.currentTurn == "player" then
        for _, piece in ipairs(combat.playerPieces) do
            if piece.name == "Tourelle" and piece.hp > 0 then
                for _, enemy in ipairs(combat.enemyPieces) do
                    if enemy.hp > 0 then
                        local distance = math.abs(piece.x - enemy.x) + math.abs(piece.y - enemy.y)
                        if distance <= piece.range then
                            local response = network.sendAction(combat, piece, "attack", enemy.x, enemy.y)
                            if response.success then
                                enemy.hp = enemy.hp - piece.damage
                                piece.hp = piece.hp - 1  -- Tourelle perd 1 PV
                                if enemy.hp <= 0 then
                                    combat.board[enemy.x][enemy.y] = nil
                                    for i, e in ipairs(combat.enemyPieces) do
                                        if e == enemy then
                                            table.remove(combat.enemyPieces, i)
                                            break
                                        end
                                    end
                                end
                                if piece.hp <= 0 then
                                    combat.board[piece.x][piece.y] = nil
                                    for i, p in ipairs(combat.playerPieces) do
                                        if p == piece then
                                            table.remove(combat.playerPieces, i)
                                            break
                                        end
                                    end
                                end
                            end
                            break  -- Tourelle attaque une seule cible
                        end
                    end
                end
            end
        end
    end
    combat.turnStarted = true
end

-- Mettre à jour la logique du jeu
function board.update(combat, dt)
    if not combat.turnStarted then
        board.startTurn(combat)
    end
    if combat.currentTurn == "enemy" and combat.enemyTurnTimer > 0 then
        combat.enemyTurnTimer = combat.enemyTurnTimer - dt
        if combat.enemyTurnTimer <= 0 then
            local response = network.sendEndEnemyTurn(combat)
            if response.success then
                print("Tour de l'ennemi terminé")
            end
        end
    end
end

return board