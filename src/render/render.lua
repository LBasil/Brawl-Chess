local render = {}

function render.draw(board, playerPieces, enemyPieces, errorMessage, actionMode, turn)
    local boardSize = board.getSize()
    local tileSize = board.getTileSize()
    local boardX, boardY = board.getOffset()

    -- Dessiner le plateau
    for i = 1, boardSize do
        for j = 1, boardSize do
            if (i + j) % 2 == 0 then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("fill", boardX + (i-1) * tileSize, boardY + (j-1) * tileSize, tileSize, tileSize)
        end
    end

    -- Dessiner les pions du joueur (alliés)
    for _, piece in ipairs(playerPieces) do
        if piece.hp > 0 then
            -- Dessiner le sprite
            local spriteWidth, spriteHeight = piece.sprite:getWidth(), piece.sprite:getHeight()
            local scale = (tileSize - 10) / math.max(spriteWidth, spriteHeight) -- Redimensionner pour tenir dans la tuile
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                piece.sprite,
                boardX + (piece.x-1) * tileSize + 5,
                boardY + (piece.y-1) * tileSize + 5,
                0, -- Rotation
                scale, -- Échelle X
                scale  -- Échelle Y
            )
            -- Dessiner le texte (nom, HP, bouclier)
            love.graphics.setColor(1, 1, 1)
            local text = piece.name .. "\nHP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end

    -- Dessiner les pions ennemis
    for _, piece in ipairs(enemyPieces) do
        if piece.hp > 0 then
            -- Dessiner le sprite
            local spriteWidth, spriteHeight = piece.sprite:getWidth(), piece.sprite:getHeight()
            local scale = (tileSize - 10) / math.max(spriteWidth, spriteHeight) -- Redimensionner pour tenir dans la tuile
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                piece.sprite,
                boardX + (piece.x-1) * tileSize + 5,
                boardY + (piece.y-1) * tileSize + 5,
                0, -- Rotation
                scale, -- Échelle X
                scale  -- Échelle Y
            )
            -- Dessiner le texte (nom, HP, bouclier)
            love.graphics.setColor(1, 1, 1)
            local text = piece.name .. "\nHP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end

    -- Afficher les messages d'erreur et d'état
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