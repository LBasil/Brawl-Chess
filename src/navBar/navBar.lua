local navBar = {}

local buttons = {
    {name = "Boutique", icon = "assets/images/boutique_icon.png"},
    {name = "Collection", icon = "assets/images/collection_icon.png"},
    {name = "Combat", icon = "assets/images/combat_icon.png"},
    {name = "Social", icon = "assets/images/social_icon.png"},
    {name = "Leaderboard", icon = "assets/images/leaderboard_icon.png"}
}

function navBar.load()
    for _, btn in ipairs(buttons) do
        btn.image = love.graphics.newImage(btn.icon)
    end
end

function navBar.update(dt)
    navBar.hoverButton = nil
    local buttonWidth = 480 / #buttons
    for i, btn in ipairs(buttons) do
        btn.x = (i-1) * buttonWidth
        btn.y = 720
        btn.width = buttonWidth
        btn.height = 80
        local mx, my = love.mouse.getPosition()
        if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
            navBar.hoverButton = btn
        end
    end
end

function navBar.draw(currentScreen)
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 720, 480, 80)
    for _, button in ipairs(buttons) do
        if navBar.hoverButton == button or currentScreen == string.lower(button.name) then
            love.graphics.setColor(0.3, 0.7, 1)
        else
            love.graphics.setColor(0.2, 0.4, 0.7)
        end
        love.graphics.rectangle("fill", button.x, 720, button.width, button.height)
        love.graphics.setColor(1, 1, 1)
        if button.image then
            local scale = math.min(button.width * 0.6 / button.image:getWidth(), button.height * 0.6 / button.image:getHeight())
            local newWidth = button.image:getWidth() * scale
            local newHeight = button.image:getHeight() * scale
            local iconX = button.x + (button.width - newWidth) / 2
            local iconY = 720 + (button.height - newHeight) / 2
            love.graphics.draw(button.image, iconX, iconY, 0, scale, scale)
        end
    end
end

function navBar.getClickedButton(x, y)
    for _, btn in ipairs(buttons) do
        if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
            return string.lower(btn.name)
        end
    end
    return nil
end

return navBar