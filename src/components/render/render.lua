local render = {}

function render.draw(board, playerPieces, enemyPieces, errorMessage, actionMode, turn, selectedPiece, actionButtonActive)
    local boardSize = board.getSize()
    local tileSize = board.getTileSize()
    local boardX, boardY = board.getOffset()

    local boardImage = love.graphics.newImage("assets/images/board/board.png")
    local totalSize = boardSize * tileSize
    local scale = totalSize / boardImage:getWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(boardImage, boardX, boardY, 0, scale, scale)

    if playerPieces and type(playerPieces) == "table" then
        for _, piece in ipairs(playerPieces) do
            if piece and piece.hp > 0 then
                local spriteWidth, spriteHeight = piece.sprite:getWidth(), piece.sprite:getHeight()
                local scale = (tileSize - 10) / math.max(spriteWidth, spriteHeight)
                if selectedPiece and piece == selectedPiece then
                    love.graphics.setColor(0, 1, 0, 0.5) -- Vert pour sélection
                    if piece.shield and piece.shield > 0 then
                        love.graphics.setColor(0, 1, 1, 0.5) -- Vert + Violet (cyan)
                    end
                else
                    if piece.shield and piece.shield > 0 then
                        love.graphics.setColor(0.5, 0, 0.5, 1) -- Violet pour bouclier
                    else
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                end
                love.graphics.draw(piece.sprite, boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, 0, scale, scale)
                love.graphics.setColor(1, 1, 1, 1)
                local text = "HP: " .. math.floor(piece.hp) .. "/3"
                if piece.shield and piece.shield > 0 then
                    text = text .. "\nShield: " .. piece.shield
                end
                love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
            end
        end
    end

    if enemyPieces and type(enemyPieces) == "table" then
        for _, piece in ipairs(enemyPieces) do
            if piece and piece.hp > 0 then
                local spriteWidth, spriteHeight = piece.sprite:getWidth(), piece.sprite:getHeight()
                local scale = (tileSize - 10) / math.max(spriteWidth, spriteHeight)
                if piece.shield and piece.shield > 0 then
                    love.graphics.setColor(0.5, 0, 0.5, 1) -- Violet pour bouclier
                else
                    love.graphics.setColor(1, 1, 1, 1)
                end
                love.graphics.draw(piece.sprite, boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, 0, scale, scale)
                love.graphics.setColor(1, 1, 1, 1)
                local text = "HP: " .. math.floor(piece.hp)
                if piece.shield and piece.shield > 0 then
                    text = text .. "\nShield: " .. piece.shield
                end
                love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
            end
        end
    end

    local buttonX = boardX + (boardSize * tileSize) / 2 - 50
    local buttonY = boardY + boardSize * tileSize + 20
    local buttonWidth = 100
    local buttonHeight = 40
    if actionButtonActive then
        love.graphics.setColor(0, 1, 0, 1)
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Action", buttonX, buttonY + 10, buttonWidth, "center")

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