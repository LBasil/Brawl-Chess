require("src.components.combat.combat")

combatMenu = {}

local battleButton = {x = 170, y = 490, width = 140, height = 40} -- Bouton "Battle" plus rectangulaire
local subScreen = nil
local hoverButton = nil

function combatMenu.load()
    -- Charger l'image du plateau
    combatMenu.boardImage = love.graphics.newImage("assets/images/board/board.png")
    -- Charger l'image du bouton
    combatMenu.buttonImage = love.graphics.newImage("assets/images/buttons/button_rectangle_gradient.png")
end

function combatMenu.update(dt)
    -- Vérifier si la souris survole le bouton "Battle"
    if subScreen == nil then
        local mx, my = love.mouse.getPosition()
        if mx >= battleButton.x and mx <= battleButton.x + battleButton.width and my >= battleButton.y and my <= battleButton.y + battleButton.height then
            hoverButton = {name = "battle"}
        else
            hoverButton = nil
        end
    end
    -- Mettre à jour le mode Combat si on est dans le sous-écran "battle"
    if subScreen == "battle" then
        combat.update(dt)
    end
end

function combatMenu.draw()
    if subScreen == nil then
        -- Afficher l'image du plateau
        local boardSize = 320 -- Taille du plateau (320x320)
        local boardX = (480 - boardSize) / 2 -- Centré horizontalement
        local boardY = 150 -- Positionné après les éléments en haut
        love.graphics.setColor(1, 1, 1)
        local scale = boardSize / combatMenu.boardImage:getWidth()
        love.graphics.draw(combatMenu.boardImage, boardX, boardY, 0, scale, scale)

        -- Bouton "Battle" pile en dessous du plateau
        local buttonScaleX = (battleButton.width + 20) / combatMenu.buttonImage:getWidth()
        local buttonScaleY = (battleButton.height + 20) / combatMenu.buttonImage:getHeight()
        love.graphics.setColor(1, 1, 1)
        if hoverButton and hoverButton.name == "battle" then
            love.graphics.setColor(0.8, 0.8, 0.8) -- Légère atténuation au survol
        end
        love.graphics.draw(combatMenu.buttonImage, battleButton.x - 10, battleButton.y - 10, 0, buttonScaleX, buttonScaleY)
        love.graphics.setColor(1, 1, 1) -- Texte en blanc pour lisibilité
        love.graphics.printf("Battle", battleButton.x, battleButton.y + 10, battleButton.width, "center")
    elseif subScreen == "battle" then
        combat.draw() -- Afficher le plateau
    end
end

function combatMenu.mousepressed(x, y, button)
    if button == 1 and subScreen == nil then
        -- Vérifier si le bouton "Battle" est cliqué
        if x >= battleButton.x and x <= battleButton.x + battleButton.width and y >= battleButton.y and y <= battleButton.y + battleButton.height then
            subScreen = "battle"
            combat.enterCombat() -- Appeler le serveur
        end
    elseif subScreen == "battle" then
        combat.mousepressed(x, y, button)
    end
end

return combatMenu