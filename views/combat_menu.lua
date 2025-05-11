require("src.combat.combat")

combat_menu = {}

local battleButton = {x = 170, y = 480, width = 140, height = 80} -- Bouton "Battle"
local subScreen = nil
local hoverButton = nil

function combat_menu.load()
    -- Charger l'image du plateau
    combat_menu.boardImage = love.graphics.newImage("assets/images/board/board.png")
end

function combat_menu.update(dt)
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

function combat_menu.draw()
    if subScreen == nil then
        -- Afficher l'image du plateau
        local boardSize = 320 -- Réduit à 280x280 (7 cases de 40px)
        local boardX = (480 - boardSize) / 2 -- Centré horizontalement
        local boardY = 150 -- Positionné après les éléments en haut
        love.graphics.setColor(1, 1, 1)
        -- Redimensionner l'image à 280x280 pixels
        local scale = boardSize / combat_menu.boardImage:getWidth()
        love.graphics.draw(combat_menu.boardImage, boardX, boardY, 0, scale, scale)

        -- Bouton "Battle" en dessous de l'échiquier, centré
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.rectangle("fill", battleButton.x - 10, battleButton.y - 10, battleButton.width + 20, battleButton.height + 20, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Battle", battleButton.x, battleButton.y + 30, battleButton.width, "center")
    elseif subScreen == "battle" then
        combat.draw() -- Afficher le plateau
    end
end

function combat_menu.mousepressed(x, y, button)
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