require("combat")

menu = {}

local currentScreen = "menu"
local hoverButton = nil

local buttons = {
    {name = "Combat", x = 20, y = 680, width = 140, height = 80},
    {name = "Collection", x = 170, y = 680, width = 140, height = 80},
    {name = "Boutique", x = 320, y = 680, width = 140, height = 80}
}

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    menu.titleFont = love.graphics.newFont(36)
    menu.buttonFont = love.graphics.newFont(20)
    combat.load() -- Initialiser le mode Combat
end

function menu.update(dt)
    hoverButton = nil
    for _, btn in ipairs(buttons) do
        local mx, my = love.mouse.getPosition()
        if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
            hoverButton = btn
        end
    end
    if currentScreen == "combat" then
        combat.update(dt) -- Mettre à jour le mode Combat
    end
end

function menu.draw()
    love.graphics.setFont(menu.titleFont)
    love.graphics.setColor(1, 0.7, 0)
    love.graphics.printf("Brawl Chess", 0, 100, 480, "center")

    love.graphics.setFont(menu.buttonFont)
    love.graphics.setColor(1, 1, 1)
    if currentScreen == "menu" then
        love.graphics.printf("Bienvenue dans Brawl Chess !", 0, 300, 480, "center")
    elseif currentScreen == "combat" then
        combat.draw() -- Afficher le plateau
    elseif currentScreen == "collection" then
        love.graphics.printf("Collection", 0, 300, 480, "center")
    elseif currentScreen == "boutique" then
        love.graphics.printf("Boutique", 0, 300, 480, "center")
    end

    for _, button in ipairs(buttons) do
        if hoverButton == button or currentScreen == string.lower(button.name) then
            love.graphics.setColor(0.3, 0.7, 1)
        else
            love.graphics.setColor(0.2, 0.4, 0.7)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 10, 10)
        love.graphics.setFont(menu.buttonFont)
        love.graphics.printf(button.name, button.x, button.y + 30, button.width, "center")
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                currentScreen = string.lower(btn.name)
            end
        end
        if currentScreen == "combat" then
            combat.mousepressed(x, y, button) -- Passer les clics au mode Combat
        end
    end
end