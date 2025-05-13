local avatar = {}

function avatar.load()
    avatar.image = love.graphics.newImage("assets/images/avatar/avatar.png")
    local id = math.random(5)
    avatar.border = love.graphics.newImage("assets/images/avatar/circle/" .. id .. ".png")
end

function avatar.draw()
    -- Dessiner le cadre (button_round_depth_border.png)
    love.graphics.setColor(1, 1, 1)
    local borderSize = 60 -- Diamètre du cadre (ajusté pour entourer l'avatar)
    local scale = borderSize / avatar.border:getWidth()
    local borderX = 35 - (borderSize / 2) -- Centré sur x=35
    local borderY = 35 - (borderSize / 2) -- Centré sur y=35
    love.graphics.draw(avatar.border, borderX, borderY, 0, scale, scale)

    -- Dessiner le fond de l'avatar
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("fill", 35, 35, 25)

    -- Dessiner la bordure dorée
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("line", 35, 35, 25)

    -- Dessiner l'avatar avec un masque circulaire
    love.graphics.stencil(function()
        love.graphics.circle("fill", 35, 35, 25)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(avatar.image, 10, 10, 0, 50 / avatar.image:getWidth(), 50 / avatar.image:getHeight())
    love.graphics.setStencilTest()
end

return avatar