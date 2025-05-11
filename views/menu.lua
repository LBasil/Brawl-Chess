require("src.combat.combat")
require("views.combat_menu")
require("views.boutique")
require("views.collection")
require("views.social")
require("views.leaderboard")

menu = {}

-- Initialiser directement sur l'onglet "Combat" (menu d'accueil)
local currentScreen = "combat"
local hoverButton = nil

-- Liste des onglets avec leurs icônes
local buttons = {
    {name = "Boutique", icon = "assets/images/boutique_icon.png"},
    {name = "Collection", icon = "assets/images/collection_icon.png"},
    {name = "Combat", icon = "assets/images/combat_icon.png"},
    {name = "Social", icon = "assets/images/social_icon.png"},
    {name = "Leaderboard", icon = "assets/images/leaderboard_icon.png"}
}

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.2, 0.4)
    menu.titleFont = love.graphics.newFont(36)
    menu.buttonFont = love.graphics.newFont(20)
    menu.smallFont = love.graphics.newFont(16)
    -- Charger les icônes pour chaque onglet
    for _, btn in ipairs(buttons) do
        btn.image = love.graphics.newImage(btn.icon)
    end
    -- Charger l'avatar PNG
    menu.avatarImage = love.graphics.newImage("assets/images/avatar/avatar.png")
    -- Initialiser les modules des onglets
    combat.load()
    combat_menu.load()
    boutique.load()
    collection.load()
    social.load()
    leaderboard.load()
end

function menu.update(dt)
    hoverButton = nil
    local buttonWidth = 480 / #buttons
    for i, btn in ipairs(buttons) do
        btn.x = (i-1) * buttonWidth
        btn.y = 720
        btn.width = buttonWidth
        btn.height = 80
        local mx, my = love.mouse.getPosition()
        if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
            hoverButton = btn
        end
    end
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

    -- Haut gauche : Avatar rond et barre d'XP
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("fill", 35, 35, 25)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("line", 35, 35, 25)
    -- Dessiner l'avatar avec un masque circulaire
    love.graphics.stencil(function()
        love.graphics.circle("fill", 35, 35, 25)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menu.avatarImage, 10, 10, 0, 50 / menu.avatarImage:getWidth(), 50 / menu.avatarImage:getHeight())
    love.graphics.setStencilTest()
    -- Barre d'XP
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 70, 25, 150, 20, 5, 5)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 70, 25, 150 * 0.7, 20, 5, 5)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", 70, 25, 150, 20, 5, 5)

    -- Haut droit : Argent normal et payant
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 300, 10, 100, 30, 5, 5)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("fill", 315, 25, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.smallFont)
    love.graphics.printf("1000", 335, 15, 60, "center")
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", 300, 10, 100, 30, 5, 5)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 410, 10, 60, 30, 5, 5)
    love.graphics.setColor(0.6, 0, 1)
    love.graphics.polygon("fill", 425, 25, 435, 15, 445, 25, 435, 35)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("50", 445, 15, 25, "center")
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", 410, 10, 60, 30, 5, 5)

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

    -- Barre du bas
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 720, 480, 80)

    -- Onglets avec icônes
    for _, button in ipairs(buttons) do
        if hoverButton == button or currentScreen == string.lower(button.name) then
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

function menu.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                currentScreen = string.lower(btn.name)
            end
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