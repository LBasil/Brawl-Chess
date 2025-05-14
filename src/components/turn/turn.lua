local turn = {}

local turnStarted = false
local enemyTurnTimer = 0
local enemyTurnDuration = 1

function turn.start(combat)
    if turn.currentTurn == "player" then
        combat.pieces.automaticAction(combat.playerPieces, combat.enemyPieces, combat.board, combat.network)
    end
    turnStarted = true
end

function turn.update(dt, combat)
    if not turnStarted then
        turn.start(combat)
    end
    if turn.currentTurn == "enemy" and enemyTurnTimer > 0 then
        enemyTurnTimer = enemyTurnTimer - dt
        if enemyTurnTimer <= 0 then
            local response, newTurn = combat.network.sendEndEnemyTurn(turn.currentTurn)
            if response.success then
                print("Tour de l'ennemi terminé")
                turn.setCurrentTurn(newTurn)
            end
        end
    end
end

function turn.setEnemyTurn()
    enemyTurnTimer = enemyTurnDuration
end

function turn.init(playerPieces, enemyPieces, board)
    turn.playerPieces = playerPieces
    turn.enemyPieces = enemyPieces
    turn.board = board
    turn.currentTurn = "player"
end

function turn.getCurrentTurn()
    return turn.currentTurn
end

function turn.setCurrentTurn(newTurn)
    turn.currentTurn = newTurn
    if turn.currentTurn == "enemy" then
        turn.setEnemyTurn()
    end
end

return turn