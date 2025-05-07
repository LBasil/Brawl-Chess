leaderboard = {}

function leaderboard.load()
    -- Rien à charger pour l'instant
end

function leaderboard.update(dt)
    -- Rien à mettre à jour pour l'instant
end

function leaderboard.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.buttonFont)
    love.graphics.printf("Classement", 0, 300, 480, "center")
end

function leaderboard.mousepressed(x, y, button)
    -- Rien à gérer pour l'instant
end