require("src.views.menu.menu")

function love.load()
    -- Appeler la fonction load du menu
    menu.load()
end

function love.update(dt)
    -- Appeler la fonction update du menu
    menu.update(dt)
end

function love.draw()
    -- Appeler la fonction draw du menu
    menu.draw()
end

function love.mousepressed(x, y, button)
    -- Appeler la fonction mousepressed du menu
    menu.mousepressed(x, y, button)
end