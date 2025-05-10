leaderboard = {}

-- Données du classement (initialement vide, sera rempli via le réseau)
local scores = {}

-- Dimensions et positions
local tableX = 40
local tableY = 100 -- Déplacé plus haut pour occuper plus d'espace sans titre
local tableWidth = 400
local rowHeight = 40
local headerHeight = 50

-- Police pour le texte
local font = love.graphics.newFont(16)

-- Couleurs thématiques (style médiéval)
local headerColor = {0.15, 0.25, 0.4} -- Bleu foncé profond
local rowColor1 = {0.85, 0.75, 0.65} -- Beige clair (parchemin)
local rowColor2 = {0.75, 0.65, 0.55} -- Beige plus foncé
local textColor = {0.1, 0.1, 0.1} -- Presque noir
local borderColor = {0.3, 0.2, 0.1} -- Marron foncé
local highlightColor = {1, 0.8, 0.4} -- Doré pour le joueur actuel

-- Variable pour gérer le survol
local hoveredRow = nil

-- Pseudo du joueur actuel (à définir lors de la connexion, simulé ici)
local currentPlayerName = "ChessWizard" -- Remplace par le vrai pseudo du joueur

function leaderboard.load()
    -- Initialisation des polices si nécessaire
    if not menu.buttonFont then
        menu.buttonFont = font
    end

    -- Charger les scores depuis le serveur
    local success, data = combat.network.fetchLeaderboard()
    if success then
        scores = data
    else
        -- Données de secours si le serveur échoue
        scores = {
            { rank = 1, name = "GrokMaster", score = 1500 },
            { rank = 2, name = "ChessWizard", score = 1200 }
        }
    end
end

function leaderboard.update(dt)
    -- Détecter la ligne survolée
    local mouseX, mouseY = love.mouse.getPosition()
    hoveredRow = nil
    for i, entry in ipairs(scores) do
        local y = tableY + headerHeight + (i - 1) * rowHeight
        if mouseX >= tableX and mouseX <= tableX + tableWidth and mouseY >= y and mouseY <= y + rowHeight then
            hoveredRow = i
            break
        end
    end
end

function leaderboard.draw()
    love.graphics.setFont(menu.buttonFont)

    -- En-tête du tableau
    love.graphics.setColor(headerColor)
    love.graphics.rectangle("fill", tableX, tableY, tableWidth, headerHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Rang", tableX, tableY + 10, 80, "center")
    love.graphics.printf("Pseudo", tableX + 80, tableY + 10, 200, "center")
    love.graphics.printf("Score", tableX + 280, tableY + 10, 120, "center")

    -- Lignes du tableau
    for i, entry in ipairs(scores) do
        local y = tableY + headerHeight + (i - 1) * rowHeight
        -- Couleur de la ligne
        if i == hoveredRow then
            love.graphics.setColor(highlightColor) -- Surlignage au survol
        elseif entry.name == currentPlayerName then
            love.graphics.setColor(highlightColor) -- Surlignage pour le joueur actuel
        else
            love.graphics.setColor(i % 2 == 0 and rowColor2 or rowColor1)
        end
        love.graphics.rectangle("fill", tableX, y, tableWidth, rowHeight)
        -- Texte
        love.graphics.setColor(textColor)
        love.graphics.printf(tostring(entry.rank), tableX, y + 10, 80, "center")
        love.graphics.printf(entry.name, tableX + 80, y + 10, 200, "center")
        love.graphics.printf(tostring(entry.score), tableX + 280, y + 10, 120, "center")
    end

    -- Bordures du tableau
    love.graphics.setColor(borderColor)
    love.graphics.rectangle("line", tableX, tableY, tableWidth, headerHeight + #scores * rowHeight)
    -- Séparations verticales
    love.graphics.line(tableX + 80, tableY, tableX + 80, tableY + headerHeight + #scores * rowHeight)
    love.graphics.line(tableX + 280, tableY, tableX + 280, tableY + headerHeight + #scores * rowHeight)
end

function leaderboard.mousepressed(x, y, button)
    -- Rien à gérer pour l'instant (pas de bouton Retour)
end

return leaderboard