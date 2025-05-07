require("combat")

combat_menu = {}

local battleButton = {x = 170, y = 480, width = 140, height = 80} -- Bouton "Battle"
local subScreen = nil
local hoverButton = nil

function combat_menu.load()
    -- Rien à charger pour l'instant (polices dans menu.lua)
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
        -- Échiquier stylisé (8x8 cases, 40x40 pixels chacune)
        local boardSize = 320 -- 8 cases * 40 pixels
        local boardX = (480 - boardSize) / 2 -- Centré : (480-320)/2 = 80
        local boardY = 150 -- Positionné après le titre et les éléments en haut
        -- Bordure dorée autour de l'échiquier
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.rectangle("fill", boardX - 5, boardY - 5, boardSize + 10, boardSize + 10)
        -- Dessiner les cases
        for i = 1, 8 do
            for j = 1, 8 do
                if (i + j) % 2 == 0 then
                    love.graphics.setColor(1, 1, 1) -- Case blanche
                else
                    love.graphics.setColor(0, 0, 0) -- Case noire
                end
                love.graphics.rectangle("fill", boardX + (i-1) * 40, boardY + (j-1) * 40, 40, 40)
            end
        end

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