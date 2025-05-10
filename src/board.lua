local board = {}

local boardSize = 8
local tileSize = 50
local boardX = (480 - boardSize * tileSize) / 2
local boardY = 200

function board.init()
    board.tiles = {}
    for i = 1, boardSize do
        board.tiles[i] = {}
        for j = 1, boardSize do
            board.tiles[i][j] = nil
        end
    end
end

function board.getTile(x, y)
    if x >= 1 and x <= boardSize and y >= 1 and y <= boardSize then
        return board.tiles[x][y]
    end
    return nil
end

function board.setTile(x, y, piece)
    if x >= 1 and x <= boardSize and y >= 1 and y <= boardSize then
        board.tiles[x][y] = piece
    end
end

function board.clearTile(x, y)
    if x >= 1 and x <= boardSize and y >= 1 and y <= boardSize then
        board.tiles[x][y] = nil
    end
end

function board.getSize()
    return boardSize
end

function board.getTileSize()
    return tileSize
end

function board.getOffset()
    return boardX, boardY
end

return board