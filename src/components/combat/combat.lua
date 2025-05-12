combat = {}

-- Charger les modules
combat.board = require("src.components.board.board")
combat.network = require("src.components.network.network")
combat.pieces = require("src.components.pieces.pieces")
combat.turn = require("src.components.turn.turn")
combat.render = require("src.components.render.render")
combat.input = require("src.components.input.input")

-- Variables globales
combat.playerPieces = {}
combat.enemyPieces = {}

function combat.load()
    combat.board.init()
    combat.turn.init(combat.playerPieces, combat.enemyPieces, combat.board)
    -- Charger les sprites des pions
    combat.pieces.loadSprites()
end

function combat.enterCombat()
    local success, errorMsg = combat.network.connectAndFetchState(combat.playerPieces, combat.enemyPieces, combat.board, combat.turn)
    if not success then
        combat.input.setErrorMessage(errorMsg)
    else
        -- Assigner les sprites à chaque pion après avoir récupéré les données
        for _, piece in ipairs(combat.playerPieces) do
            combat.pieces.assignSprite(piece, false) -- Alliés
        end
        for _, piece in ipairs(combat.enemyPieces) do
            combat.pieces.assignSprite(piece, true) -- Ennemis
        end
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