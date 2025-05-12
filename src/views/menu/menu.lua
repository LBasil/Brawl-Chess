require("src.components.combat.combat")
require("src.views.combat_menu.combat_menu")
require("src.views.boutique.boutique")
require("src.views.collection.collection")
require("src.views.social.social")
require("src.views.leaderboard.leaderboard")
local avatar = require("src.components.avatar.avatar")
local xpBar = require("src.components.xpBar.xpBar")
local currencyBar = require("src.components.currencyBar.currencyBar")
local navBar = require("src.components.navBar.navBar")

menu = {}

local currentScreen = "combat"

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.2, 0.4)
    menu.titleFont = love.graphics.newFont(36)
    menu.buttonFont = love.graphics.newFont(20)
    menu.smallFont = love.graphics.newFont(16)
    -- Charger les composants
    avatar.load()
    xpBar.load()
    currencyBar.load(menu.smallFont)
    navBar.load()
    -- Charger les modules des onglets
    combat.load()
    combat_menu.load()
    boutique.load()
    collection.load()
    social.load()
    leaderboard.load()
end

function menu.update(dt)
    navBar.update(dt)
    xpBar.update(dt)
    if currentScreen == "combat" then
        combat_menu.update(dt)
    elseif currentScreen == "boutique" then
        boutique.update(dt)
    elseif currentScreen == "collection" then
        collection.update(dt)
    elseif currentScreen == "social" then
        social.update(dt)
    elseif currentScreen == "leaderboard" then
        leaderboard.update(dt)
    end
end

function menu.draw()
    love.graphics.setColor(0.2, 0.3, 0.5)
    for i = 0, 480, 40 do
        for j = 0, 800, 40 do
            love.graphics.rectangle("fill", i, j, 20, 20)
        end
    end

    -- Dessiner les composants
    avatar.draw()
    xpBar.draw()
    currencyBar.draw()

    -- Titre "Brawl Chess"
    love.graphics.setFont(menu.titleFont)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.printf("Brawl Chess", 0, 70, 480, "center")

    -- Afficher l'écran actuel
    love.graphics.setFont(menu.buttonFont)
    love.graphics.setColor(1, 1, 1)
    if currentScreen == "combat" then
        combat_menu.draw()
    elseif currentScreen == "boutique" then
        boutique.draw()
    elseif currentScreen == "collection" then
        collection.draw()
    elseif currentScreen == "social" then
        social.draw()
    elseif currentScreen == "leaderboard" then
        leaderboard.draw()
    end

    -- Barre de navigation
    navBar.draw(currentScreen)
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        local clickedScreen = navBar.getClickedButton(x, y)
        if clickedScreen then
            currentScreen = clickedScreen
        end
        if currentScreen == "combat" then
            combat_menu.mousepressed(x, y, button)
        elseif currentScreen == "boutique" then
            boutique.mousepressed(x, y, button)
        elseif currentScreen == "collection" then
            collection.mousepressed(x, y, button)
        elseif currentScreen == "social" then
            social.mousepressed(x, y, button)
        elseif currentScreen == "leaderboard" then
            leaderboard.mousepressed(x, y, button)
        end
    end
end