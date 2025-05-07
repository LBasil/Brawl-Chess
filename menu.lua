require("combat")

menu = {}

local currentScreen = "menu" -- Écran actuel (menu, combat, collection, boutique)
local hoverButton = nil -- Bouton survolé par la souris
local subScreen = nil -- Sous-écran (pour le bouton "Battle" dans l'onglet Combat)

-- Liste des onglets avec leurs icônes
local buttons = {
    {name = "Combat", icon = "combat_icon.png"},
    {name = "Collection", icon = "collection_icon.png"},
    {name = "Boutique", icon = "boutique_icon.png"}
}
local battleButton = {x = 170, y = 350, width = 140, height = 80} -- Bouton "Battle" dans le menu d'accueil

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.2, 0.4) -- Fond bleu foncé inspiré de Clash
    menu.titleFont = love.graphics.newFont(36) -- Police pour le titre
    menu.buttonFont = love.graphics.newFont(20) -- Police pour le texte
    -- Charger les icônes pour chaque onglet
    for _, btn in ipairs(buttons) do
        btn.image = love.graphics.newImage(btn.icon)
    end
    combat.load() -- Initialiser le mode Combat
end

function menu.update(dt)
    hoverButton = nil -- Réinitialiser le bouton survolé
    local buttonWidth = 480 / #buttons -- Calculer la largeur de chaque bouton (480 pixels / nombre d'onglets)
    -- Positionner chaque bouton dans la barre en bas
    for i, btn in ipairs(buttons) do
        btn.x = (i-1) * buttonWidth -- Position x (0, 160, 320 pour 3 onglets)
        btn.y = 750 -- Position y de la barre (fenêtre 800px - 50px pour la barre)
        btn.width = buttonWidth -- Largeur (160px pour 3 onglets)
        btn.height = 80 -- Hauteur de la barre (fixée à 80 pixels)
        -- Vérifier si la souris survole le bouton
        local mx, my = love.mouse.getPosition()
        if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
            hoverButton = btn
        end
    end
    -- Vérifier si la souris survole le bouton "Battle" dans le menu d'accueil
    local mx, my = love.mouse.getPosition()
    if mx >= battleButton.x and mx <= battleButton.x + battleButton.width and my >= battleButton.y and my <= battleButton.y + battleButton.height then
        hoverButton = {name = "battle"}
    end
    -- Mettre à jour le mode Combat si on est dans cet écran
    if currentScreen == "combat" and subScreen == "battle" then
        combat.update(dt)
    end
end

function menu.draw()
    -- Dessiner le fond avec un motif en losanges
    love.graphics.setColor(0.2, 0.3, 0.5)
    for i = 0, 480, 40 do
        for j = 0, 800, 40 do
            love.graphics.rectangle("fill", i, j, 20, 20)
        end
    end

    -- Dessiner le titre "Brawl Chess"
    love.graphics.setFont(menu.titleFont)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.printf("Brawl Chess", 0, 50, 480, "center")

    -- Dessiner le contenu de l'écran actuel
    love.graphics.setFont(menu.buttonFont)
    love.graphics.setColor(1, 1, 1)
    if currentScreen == "menu" then
        love.graphics.printf("Bienvenue !", 0, 200, 480, "center")
    elseif currentScreen == "combat" then
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
    end

    -- Dessiner la barre du bas (toute la largeur de 480 pixels)
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 720, 480, 80) -- Déplacer la barre à y=720 pour qu'elle soit bien visible (800-80)

    -- Dessiner les onglets avec leurs icônes
    for _, button in ipairs(buttons) do
        -- Mettre en surbrillance si survolé ou actif
        if hoverButton == button or currentScreen == string.lower(button.name) then
            love.graphics.setColor(0.3, 0.7, 1)
        else
            love.graphics.setColor(0.2, 0.4, 0.7)
        end
        -- Dessiner le fond du bouton
        love.graphics.rectangle("fill", button.x, 720, button.width, button.height) -- Ajuster la position y à 720

        -- Dessiner l'icône (PNG) avec redimensionnement et centrage
        love.graphics.setColor(1, 1, 1)
        if button.image then
            -- Calculer l'échelle pour que l'icône s'adapte au bouton (max 80x80 pixels)
            local scale = math.min(button.width * 0.6 / button.image:getWidth(), button.height * 0.6 / button.image:getHeight()) -- Réduire à 60% de la taille du bouton
            local newWidth = button.image:getWidth() * scale
            local newHeight = button.image:getHeight() * scale
            -- Centrer l'icône horizontalement et verticalement dans le bouton
            local iconX = button.x + (button.width - newWidth) / 2 -- Centrer en x
            local iconY = 720 + (button.height - newHeight) / 2 -- Centrer en y (720 + (80 - newHeight) / 2)
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
                    subScreen = nil
                end
            end
        end
        -- Vérifier si le bouton "Battle" est cliqué dans le menu d'accueil
        if currentScreen == "combat" and subScreen == nil then
            if x >= battleButton.x and x <= battleButton.x + battleButton.width and y >= battleButton.y and y <= battleButton.y + battleButton.height then
                subScreen = "battle"
                combat.enterCombat()
            end
        elseif currentScreen == "combat" and subScreen == "battle" then
            combat.mousepressed(x, y, button)
        end
    end
end