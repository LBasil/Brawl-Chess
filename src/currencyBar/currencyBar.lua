local currencyBar = {}

function currencyBar.load(smallFont)
    currencyBar.smallFont = smallFont
end

function currencyBar.draw()
    -- Argent normal (pièces)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 300, 10, 100, 30, 5, 5)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("fill", 315, 25, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(currencyBar.smallFont)
    love.graphics.printf("1000", 335, 15, 60, "center")
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", 300, 10, 100, 30, 5, 5)
    -- Argent payant (gemmes)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 410, 10, 60, 30, 5, 5)
    love.graphics.setColor(0.6, 0, 1)
    love.graphics.polygon("fill", 425, 25, 435, 15, 445, 25, 435, 35)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("50", 445, 15, 25, "center")
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", 410, 10, 60, 30, 5, 5)
end

return currencyBar