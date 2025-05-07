require("combat")
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
    {name = "Boutique", icon = "assets/boutique_icon.png"},
    {name = "Collection", icon = "assets/collection_icon.png"},
    {name = "Combat", icon = "assets/combat_icon.png"},
    {name = "Social", icon = "assets/social_icon.png"},
    {name = "Leaderboard", icon = "assets/leaderboard_icon.png"}
}

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.2, 0.4) -- Fond bleu foncé
    menu.titleFont = love.graphics.newFont(36) -- Police pour le titre
    menu.buttonFont = love.graphics.newFont(20) -- Police pour le texte
    menu.smallFont = love.graphics.newFont(16) -- Police pour les barres d'argent
    -- Charger les icônes pour chaque onglet
    for _, btn in ipairs(buttons) do
        btn.image = love.graphics.newImage(btn.icon)
    end
    -- Initialiser les modules des onglets
    combat.load()
    combat_menu.load()
    boutique.load()
    collection.load()
    social.load()
    leaderboard.load()
end

function menu.update(dt)
    hoverButton = nil -- Réinitialiser le bouton survolé
    local buttonWidth = 480 / #buttons -- Largeur de chaque bouton (480 / 5 onglets = 96px)
    -- Positionner chaque bouton dans la barre en bas
    for i, btn in ipairs(buttons) do
        btn.x = (i-1) * buttonWidth -- Position x (0, 96, 192, 288, 384)
        btn.y = 720 -- Position y de la barre
        btn.width = buttonWidth -- Largeur (96px)
        btn.height = 80 -- Hauteur de la barre
        -- Vérifier si la souris survole le bouton
        local mx, my = love.mouse.getPosition()
        if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
            hoverButton = btn
        end
    end
    -- Déléguer la mise à jour au module correspondant
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
    -- Fond avec motif en losanges
    love.graphics.setColor(0.2, 0.3, 0.5)
    for i = 0, 480, 40 do
        for j = 0, 800, 40 do
            love.graphics.rectangle("fill", i, j, 20, 20)
        end
    end

    -- Haut gauche : Avatar et barre d'XP
    love.graphics.setColor(0.8, 0.8, 0.8) -- Gris clair pour le fond
    love.graphics.circle("fill", 35, 35, 25) -- Cercle de 50px de diamètre à x=10, y=10
    love.graphics.setColor(1, 0.8, 0) -- Bordure dorée
    love.graphics.circle("line", 35, 35, 25)
    -- Barre d'XP
    love.graphics.setColor(0.5, 0.5, 0.5) -- Fond gris
    love.graphics.rectangle("fill", 70, 25, 150, 20, 5, 5)
    love.graphics.setColor(0, 1, 0) -- Jauge verte (70% remplie)
    love.graphics.rectangle("fill", 70, 25, 150 * 0.7, 20, 5, 5)
    love.graphics.setColor(1, 0.8, 0) -- Bordure dorée
    love.graphics.rectangle("line", 70, 25, 150, 20, 5, 5)

    -- Haut droit : Argent normal (pièces) et argent payant (gemmes)
    -- Argent normal (pièces)
    love.graphics.setColor(0.3, 0.3, 0.3) -- Fond gris foncé
    love.graphics.rectangle("fill", 300, 10, 100, 30, 5, 5)
    love.graphics.setColor(1, 0.8, 0) -- Icône de pièce (cercle jaune)
    love.graphics.circle("fill", 315, 25, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.smallFont)
    love.graphics.printf("1000", 335, 15, 60, "center") -- Exemple : 1000 pièces
    love.graphics.setColor(1, 0.8, 0) -- Bordure dorée
    love.graphics.rectangle("line", 300, 10, 100, 30, 5, 5)
    -- Argent payant (gemmes)
    love.graphics.setColor(0.3, 0.3, 0.3) -- Fond gris foncé
    love.graphics.rectangle("fill", 410, 10, 60, 30, 5, 5)
    love.graphics.setColor(0.6, 0, 1) -- Icône de gemme (losange violet)
    love.graphics.polygon("fill", 425, 25, 435, 15, 445, 25, 435, 35)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.smallFont)
    love.graphics.printf("50", 445, 15, 25, "center") -- Exemple : 50 gemmes
    love.graphics.setColor(1, 0.8, 0) -- Bordure dorée
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

    -- Barre du bas (toute la largeur)
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
        -- Vérifier si un onglet est cliqué
        for _, btn in ipairs(buttons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                currentScreen = string.lower(btn.name)
            end
        end
        -- Déléguer les clics au module correspondant
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