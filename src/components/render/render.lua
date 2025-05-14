local render = {}

function render.draw(board, playerPieces, enemyPieces, errorMessage, actionMode, turn)
    local boardSize = board.getSize()
    local tileSize = board.getTileSize()
    local boardX, boardY = board.getOffset()

    local boardImage = love.graphics.newImage("assets/images/board/board.png")
    local totalSize = boardSize * tileSize
    local scale = totalSize / boardImage:getWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(boardImage, boardX, boardY, 0, scale, scale)

    for _, piece in ipairs(playerPieces) do
        if piece.hp > 0 then
            local spriteWidth, spriteHeight = piece.sprite:getWidth(), piece.sprite:getHeight()
            local scale = (tileSize - 10) / math.max(spriteWidth, spriteHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(piece.sprite, boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, 0, scale, scale)
            love.graphics.setColor(1, 1, 1)
            local text = "HP: " .. math.floor(piece.hp) .. "/3"
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end

    for _, piece in ipairs(enemyPieces) do
        if piece.hp > 0 then
            local spriteWidth, spriteHeight = piece.sprite:getWidth(), piece.sprite:getHeight()
            local scale = (tileSize - 10) / math.max(spriteWidth, spriteHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(piece.sprite, boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, 0, scale, scale)
            love.graphics.setColor(1, 1, 1)
            local text = "HP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end

    if errorMessage then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf(errorMessage, 0, 50, 480, "center")
    end
    if actionMode then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("Mode action : " .. actionMode, 0, 70, 480, "center")
    end
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("Tour actuel : " .. (turn.getCurrentTurn() == "player" and "Joueur" or "Ennemi"), 0, 90, 480, "center")
end

return render