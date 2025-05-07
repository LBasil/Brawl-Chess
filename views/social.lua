social = {}

function social.load()
    -- Rien à charger pour l'instant
end

function social.update(dt)
    -- Rien à mettre à jour pour l'instant
end

function social.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.buttonFont)
    love.graphics.printf("Social", 0, 300, 480, "center")
end

function social.mousepressed(x, y, button)
    -- Rien à gérer pour l'instant
end