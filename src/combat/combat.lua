combat = {}

-- Charger les modules
combat.board = require("src.board.board")
combat.network = require("src.network.network")
combat.pieces = require("src.pieces.pieces")
combat.turn = require("src.turn.turn")
combat.render = require("src.render.render")
combat.input = require("src.input.input")

-- Variables globales
combat.playerPieces = {}
combat.enemyPieces = {}

function combat.load()
    combat.board.init()
    combat.turn.init(combat.playerPieces, combat.enemyPieces, combat.board)
end

function combat.enterCombat()
    local success, errorMsg = combat.network.connectAndFetchState(combat.playerPieces, combat.enemyPieces, combat.board, combat.turn)
    if not success then
        combat.input.setErrorMessage(errorMsg)
    end
end

function combat.update(dt)
    combat.turn.update(dt, combat)
end

function combat.draw()
    combat.render.draw(combat.board, combat.playerPieces, combat.enemyPieces, combat.input.getErrorMessage(), combat.input.getActionMode(), combat.turn)
end

function combat.mousepressed(x, y, button)
    combat.input.mousepressed(x, y, button, combat.board, combat.playerPieces, combat.enemyPieces, combat.network, combat.pieces, combat.turn)
end

return combat