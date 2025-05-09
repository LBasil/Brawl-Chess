-- display.lua : Gère l'affichage du plateau, des pions, et des messages

local display = {}

-- Dessiner le plateau, les pions, et les messages
function display.draw(combat)
    -- Dessiner le plateau 8x8 avec cases alternées
    for i = 1, combat.boardSize do
        for j = 1, combat.boardSize do
            if (i + j) % 2 == 0 then
                love.graphics.setColor(1, 1, 1)  -- Case blanche
            else
                love.graphics.setColor(0.5, 0.5, 0.5)  -- Case grise
            end
            love.graphics.rectangle("fill", combat.boardX + (i-1) * combat.tileSize, combat.boardY + (j-1) * combat.tileSize, combat.tileSize, combat.tileSize)
        end
    end

    -- Dessiner les pions du joueur
    for _, piece in ipairs(combat.playerPieces) do
        if piece.hp > 0 then
            if piece.name == "Wall" then
                love.graphics.setColor(0.3, 0.3, 0.3)  -- Couleur pour Mur
            else
                love.graphics.setColor(0, 0, 1)  -- Couleur pour autres pions
            end
            love.graphics.rectangle("fill", combat.boardX + (piece.x-1) * combat.tileSize + 5, combat.boardY + (piece.y-1) * combat.tileSize + 5, combat.tileSize - 10, combat.tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            local text = piece.name .. "\nHP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, combat.boardX + (piece.x-1) * combat.tileSize, combat.boardY + (piece.y-1) * combat.tileSize, combat.tileSize, "center")
        end
    end

    -- Dessiner les pions ennemis
    for _, piece in ipairs(combat.enemyPieces) do
        if piece.hp > 0 then
            love.graphics.setColor(1, 0, 0)  -- Couleur rouge pour ennemis
            love.graphics.rectangle("fill", combat.boardX + (piece.x-1) * combat.tileSize + 5, combat.boardY + (piece.y-1) * combat.tileSize + 5, combat.tileSize - 10, combat.tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            local text = piece.name .. "\nHP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, combat.boardX + (piece.x-1) * combat.tileSize, combat.boardY + (piece.y-1) * combat.tileSize, combat.tileSize, "center")
        end
    end

    -- Afficher les messages d'erreur
    if combat.errorMessage then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf(combat.errorMessage, 0, 50, 480, "center")
    end

    -- Afficher le mode d'action
    if combat.actionMode then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("Mode action : " .. combat.actionMode, 0, 70, 480, "center")
    end

    -- Afficher le tour actuel
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("Tour actuel : " .. (combat.currentTurn == "player" and "Joueur" or "Ennemi"), 0, 90, 480, "center")
end

return display