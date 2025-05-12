collection = {}

function collection.load()
    -- Rien à charger pour l'instant
end

function collection.update(dt)
    -- Rien à mettre à jour pour l'instant
end

function collection.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.buttonFont)
    love.graphics.printf("Collection", 0, 300, 480, "center")
end

function collection.mousepressed(x, y, button)
    -- Rien à gérer pour l'instant
end