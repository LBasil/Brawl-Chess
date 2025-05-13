local xpBar = {}

local xpProgress = 0
local xpTarget = 0.7
local xpAnimationTime = 2
local xpAnimationTimer = 0

function xpBar.load()
    -- Charger l'image du cadre
    xpBar.borderImage = love.graphics.newImage("assets/images/xpBar/button_rectangle_depth_border.png")
end

function xpBar.update(dt)
    if xpAnimationTimer < xpAnimationTime then
        xpAnimationTimer = xpAnimationTimer + dt
        local t = math.min(xpAnimationTimer / xpAnimationTime, 1)
        xpProgress = t * xpTarget
    end
end

function xpBar.draw()
    local barX, barY, barWidth, barHeight = 70, 25, 150, 20

    -- Dessiner le cadre rectangulaire
    love.graphics.setColor(1, 1, 1)
    local borderWidth = barWidth + 20 -- Marge de 10 pixels de chaque côté
    local borderHeight = barHeight + 20
    local borderX = barX - 10
    local borderY = barY - 10
    local scaleX = borderWidth / xpBar.borderImage:getWidth()
    local scaleY = borderHeight / xpBar.borderImage:getHeight()
    love.graphics.draw(xpBar.borderImage, borderX, borderY, 0, scaleX, scaleY)

    -- Dessiner la barre d'XP
    love.graphics.setColor(0.85, 0.75, 0.65)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight, 5, 5)
    local progressWidth = barWidth * xpProgress
    for x = 0, progressWidth - 1 do
        local t = x / barWidth
        love.graphics.setColor(0, 1 - t, t)
        love.graphics.rectangle("fill", barX + x, barY, 1, barHeight, 5, 5)
    end
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight, 5, 5)
    love.graphics.circle("fill", barX, barY, 5)
    love.graphics.circle("fill", barX + barWidth, barY, 5)
    love.graphics.circle("fill", barX, barY + barHeight, 5)
    love.graphics.circle("fill", barX + barWidth, barY + barHeight, 5)
end

return xpBar