require("combat")

menu = {}

-- Initialiser directement sur l'onglet "Combat" (menu d'accueil)
local currentScreen = "combat"
local hoverButton = nil
local subScreen = nil -- Sous-écran pour le bouton "Battle"

-- Liste des onglets avec leurs icônes
local buttons = {
    {name = "Boutique", icon = "boutique_icon.png"},
    {name = "Collection", icon = "collection_icon.png"},
    {name = "Combat", icon = "combat_icon.png"},
    {name = "Social", icon = "social_icon.png"},
    {name = "Leaderboard", icon = "leaderboard_icon.png"}
}
local battleButton = {x = 170, y = 350, width = 140, height = 80} -- Bouton "Battle"

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.2, 0.4) -- Fond bleu foncé
    menu.titleFont = love.graphics.newFont(36) -- Police pour le titre
    menu.buttonFont = love.graphics.newFont(20) -- Police pour le texte
    menu.smallFont = love.graphics.newFont(16) -- Police pour les barres d'argent
    -- Charger les icônes pour chaque onglet
    for _, btn in ipairs(buttons) do
        btn.image = love.graphics.newImage(btn.icon)
    end
    combat.load() -- Initialiser le mode Combat
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
    -- Vérifier si la souris survole le bouton "Battle"
    local mx, my = love.mouse.getPosition()
    if mx >= battleButton.x and mx <= battleButton.x + battleButton.width and my >= battleButton.y and my <= battleButton.y + battleButton.height then
        hoverButton = {name = "battle"}
    end
    -- Mettre à jour le mode Combat uniquement si on est dans le sous-écran "battle"
    if currentScreen == "combat" and subScreen == "battle" then
        combat.update(dt)
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
    -- Avatar (cercle pour l'instant)
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

    -- Titre "Brawl Chess" (déplacé plus bas pour laisser de la place)
    love.graphics.setFont(menu.titleFont)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.printf("Brawl Chess", 0, 70, 480, "center")

    -- Afficher l'écran actuel
    love.graphics.setFont(menu.buttonFont)
    love.graphics.setColor(1, 1, 1)
    if currentScreen == "combat" then
        if subScreen == nil then
            -- Menu d'accueil avec bouton "Battle"
            love.graphics.setColor(1, 0.84, 0)
            love.graphics.rectangle("fill", battleButton.x - 10, battleButton.y - 10, battleButton.width + 20, battleButton.height + 20, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Battle", battleButton.x, battleButton.y + 30, battleButton.width, "center")
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.circle("fill", 100, 150, 30)
            love.graphics.rectangle("fill", 350, 150, 40, 40)
        elseif subScreen == "battle" then
            combat.draw() -- Afficher le plateau
        end
    elseif currentScreen == "collection" then
        love.graphics.printf("Collection", 0, 300, 480, "center")
    elseif currentScreen == "boutique" then
        love.graphics.printf("Boutique", 0, 300, 480, "center")
    elseif currentScreen == "social" then
        love.graphics.printf("Social", 0, 300, 480, "center")
    elseif currentScreen == "leaderboard" then
        love.graphics.printf("Classement", 0, 300, 480, "center")
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
                if currentScreen == "combat" then
                    subScreen = nil -- Réinitialiser le sous-écran (pas d'appel au serveur ici)
                end
            end
        end
        -- Vérifier si le bouton "Battle" est cliqué
        if currentScreen == "combat" and subScreen == nil then
            if x >= battleButton.x and x <= battleButton.x + battleButton.width and y >= battleButton.y and y <= battleButton.y + battleButton.height then
                subScreen = "battle"
                combat.enterCombat() -- Appeler le serveur uniquement ici
            end
        elseif currentScreen == "combat" and subScreen == "battle" then
            combat.mousepressed(x, y, button)
        end
    end
end