local background = {}

function background.load()
    background.image = love.graphics.newImage("assets/images/background/background.png")
end

function background.draw()
    love.graphics.setColor(1, 1, 1)
    local scaleX = 480 / background.image:getWidth()
    local scaleY = 800 / background.image:getHeight()
    love.graphics.draw(background.image, 0, 0, 0, scaleX, scaleY)
end

return background