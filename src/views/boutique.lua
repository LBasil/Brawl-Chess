boutique = {}

function boutique.load()
    -- Rien à charger pour l'instant
end

function boutique.update(dt)
    -- Rien à mettre à jour pour l'instant
end

function boutique.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.buttonFont)
    love.graphics.printf("Boutique", 0, 300, 480, "center")
end

function boutique.mousepressed(x, y, button)
    -- Rien à gérer pour l'instant
end