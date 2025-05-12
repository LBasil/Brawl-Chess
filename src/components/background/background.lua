local background = {}

function background.draw()
    love.graphics.setColor(0.2, 0.3, 0.5)
    for i = 0, 480, 40 do
        for j = 0, 800, 40 do
            love.graphics.rectangle("fill", i, j, 20, 20)
        end
    end
end

return background