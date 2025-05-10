leaderboard = {}

-- Données simulées du classement (tu peux les remplacer par une requête réseau)
local scores = {
    { rank = 1, name = "GrokMaster", score = 1500 },
    { rank = 2, name = "ChessWizard", score = 1200 },
    { rank = 3, name = "PawnSlayer", score = 900 },
    { rank = 4, name = "Knightmare", score = 750 },
    { rank = 5, name = "RookRuler", score = 600 }
}

-- Dimensions et positions
local tableX = 40
local tableY = 150
local tableWidth = 400
local rowHeight = 40
local headerHeight = 50
local buttonWidth = 100
local buttonHeight = 40
local buttonX = (480 - buttonWidth) / 2
local buttonY = 500

local font = love.graphics.newFont(16)

function leaderboard.load()
    -- Initialisation des polices si nécessaire
    if not menu.buttonFont then
        menu.buttonFont = font
    end
end

function leaderboard.update(dt)
    -- Rien à mettre à jour pour l'instant
end

function leaderboard.draw()
    -- Titre
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(menu.buttonFont)

    -- En-tête du tableau
    love.graphics.setColor(0.2, 0.3, 0.5) -- Bleu foncé pour l'en-tête
    love.graphics.rectangle("fill", tableX, tableY, tableWidth, headerHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Rang", tableX, tableY + 10, 80, "center")
    love.graphics.printf("Pseudo", tableX + 80, tableY + 10, 200, "center")
    love.graphics.printf("Score", tableX + 280, tableY + 10, 120, "center")

    -- Lignes du tableau (alternance de couleurs)
    for i, entry in ipairs(scores) do
        local y = tableY + headerHeight + (i - 1) * rowHeight
        -- Couleur alternée pour les lignes
        if i % 2 == 0 then
            love.graphics.setColor(0.8, 0.8, 0.8) -- Gris clair
        else
            love.graphics.setColor(0.9, 0.9, 0.9) -- Blanc cassé
        end
        love.graphics.rectangle("fill", tableX, y, tableWidth, rowHeight)
        -- Texte
        love.graphics.setColor(0, 0, 0) -- Noir pour le texte
        love.graphics.printf(tostring(entry.rank), tableX, y + 10, 80, "center")
        love.graphics.printf(entry.name, tableX + 80, y + 10, 200, "center")
        love.graphics.printf(tostring(entry.score), tableX + 280, y + 10, 120, "center")
    end

    -- Bordures du tableau
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", tableX, tableY, tableWidth, headerHeight + #scores * rowHeight)
end

function leaderboard.mousepressed(x, y, button)
    -- Bouton Retour
    if button == 1 then -- Clic gauche
        if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
            -- Retour au menu principal (à implémenter dans main.lua ou menu.lua)
            menu.currentView = "main"
        end
    end
end

return leaderboard