combat = {}

combat.board = require("src.components.board.board")
combat.network = require("src.components.network.network")
combat.pieces = require("src.components.pieces.pieces")
combat.turn = require("src.components.turn.turn")
combat.render = require("src.components.render.render")
combat.input = require("src.components.input.input")

combat.playerPieces = {}
combat.enemyPieces = {}

function combat.load()
    combat.board.init()
    combat.turn.init(combat.playerPieces, combat.enemyPieces, combat.board)
    combat.pieces.loadSprites()
end

function combat.enterCombat()
    local success, errorMsg = combat.network.connectAndFetchState(combat.playerPieces, combat.enemyPieces, combat.board, combat.turn)
    if not success then
        combat.input.setErrorMessage(errorMsg)
    else
        for _, piece in ipairs(combat.playerPieces) do
            combat.pieces.assignSprite(piece, false)
        end
        for _, piece in ipairs(combat.enemyPieces) do
            combat.pieces.assignSprite(piece, true)
        end
    end
end

function combat.update(dt)
    combat.turn.update(dt, combat)
end

function combat.updateState(pions)
    -- Vider les tableaux existants
    while #combat.playerPieces > 0 do table.remove(combat.playerPieces) end
    while #combat.enemyPieces > 0 do table.remove(combat.enemyPieces) end
    for i = 1, combat.board.getSize() do
        for j = 1, combat.board.getSize() do
            combat.board.clearTile(i, j)
        end
    end
    -- Remplir avec les nouveaux pions
    for _, piece in ipairs(pions) do
        if piece.type == "player" then
            table.insert(combat.playerPieces, piece)
        else
            table.insert(combat.enemyPieces, piece)
        end
        combat.board.setTile(piece.x, piece.y, piece)
    end
    -- Réassigner les sprites
    for _, piece in ipairs(combat.playerPieces) do
        combat.pieces.assignSprite(piece, false)
    end
    for _, piece in ipairs(combat.enemyPieces) do
        combat.pieces.assignSprite(piece, true)
    end
end

function combat.draw()
    combat.render.draw(combat.board, combat.playerPieces, combat.enemyPieces, combat.input.getErrorMessage(), combat.input.getActionMode(), combat.turn)
end

function combat.mousepressed(x, y, button)
    combat.input.mousepressed(x, y, button, combat.board, combat.playerPieces, combat.enemyPieces, combat.network, combat.pieces, combat.turn)
end

return combat