require("src.components.combat.combat")
local avatar = require("src.components.avatar.avatar")
local xpBar = require("src.components.xpBar.xpBar")
local currencyBar = require("src.components.currencyBar.currencyBar")
local navBar = require("src.components.navBar.navBar")
local background = require("src.components.background.background")
local screens = require("src.components.screens.screens")
local resources = require("src.components.resources.resources")

menu = {}

local currentScreen = "combat"

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.2, 0.4)
    -- Charger les ressources globales
    resources.load()
    -- Charger les composants
    avatar.load()
    xpBar.load()
    currencyBar.load(resources.smallFont)
    navBar.load()
    screens.load()
    -- Charger le module combat (requis pour combatMenu)
    combat.load()
end

function menu.update(dt)
    navBar.update(dt)
    xpBar.update(dt)
    screens.update(dt, currentScreen)
end

function menu.draw()
    background.draw()
    avatar.draw()
    xpBar.draw()
    currencyBar.draw()
    love.graphics.setFont(resources.buttonFont)
    love.graphics.setColor(1, 1, 1)
    screens.draw(currentScreen)
    navBar.draw(currentScreen)
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        local clickedScreen = navBar.getClickedButton(x, y)
        if clickedScreen then
            currentScreen = clickedScreen
        end
        screens.mousepressed(x, y, button, currentScreen)
    end
end

return menu;