local avatar = {}

function avatar.load()
    avatar.image = love.graphics.newImage("src/assets/images/avatar/avatar.png")
end

function avatar.draw()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("fill", 35, 35, 25)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("line", 35, 35, 25)
    love.graphics.stencil(function()
        love.graphics.circle("fill", 35, 35, 25)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(avatar.image, 10, 10, 0, 50 / avatar.image:getWidth(), 50 / avatar.image:getHeight())
    love.graphics.setStencilTest()
end

return avatar