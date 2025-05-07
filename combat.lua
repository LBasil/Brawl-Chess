combat = {}

-- Plateau 8x8
local board = {}
local boardSize = 8
local tileSize = 50 -- Taille des cases (adaptée à 480x800)
local boardX = (480 - boardSize * tileSize) / 2 -- Centrer le plateau
local boardY = 200

-- Pions
local playerPieces = {
    {name = "Tourelle", type = "simple", x = 1, y = 1, hp = 3, maxHP = 3, range = 2, damage = 1}
}
local enemyPieces = {
    {name = "Soldat", type = "simple", x = 7, y = 7, hp = 3, maxHP = 3}
}
local selectedPiece = nil

function combat.load()
    -- Initialiser le plateau
    for i = 1, boardSize do
        board[i] = {}
        for j = 1, boardSize do
            board[i][j] = nil
        end
    end
    -- Placer les pions
    for _, piece in ipairs(playerPieces) do
        board[piece.x][piece.y] = piece
    end
    for _, piece in ipairs(enemyPieces) do
        board[piece.x][piece.y] = piece
    end
end

function combat.update(dt)
    -- Tourelle attaque les ennemis à portée
    for _, piece in ipairs(playerPieces) do
        if piece.name == "Tourelle" and piece.hp > 0 then
            for _, enemy in ipairs(enemyPieces) do
                if enemy.hp > 0 then
                    local distance = math.abs(piece.x - enemy.x) + math.abs(piece.y - enemy.y)
                    if distance <= piece.range then
                        enemy.hp = enemy.hp - piece.damage * dt -- Dégâts par seconde
                        if enemy.hp <= 0 then
                            board[enemy.x][enemy.y] = nil
                        end
                    end
                end
            end
        end
    end
end

function combat.draw()
    -- Dessiner le plateau
    for i = 1, boardSize do
        for j = 1, boardSize do
            if (i + j) % 2 == 0 then
                love.graphics.setColor(1, 1, 1) -- Blanc
            else
                love.graphics.setColor(0.5, 0.5, 0.5) -- Gris
            end
            love.graphics.rectangle("fill", boardX + (i-1) * tileSize, boardY + (j-1) * tileSize, tileSize, tileSize)
        end
    end
    -- Dessiner les pions
    for _, piece in ipairs(playerPieces) do
        if piece.hp > 0 then
            love.graphics.setColor(0, 0, 1) -- Bleu pour la Tourelle
            love.graphics.rectangle("fill", boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, tileSize - 10, tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(piece.name .. "\n" .. math.floor(piece.hp), boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end
    for _, piece in ipairs(enemyPieces) do
        if piece.hp > 0 then
            love.graphics.setColor(1, 0, 0) -- Rouge pour l'ennemi
            love.graphics.rectangle("fill", boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, tileSize - 10, tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(piece.name .. "\n" .. math.floor(piece.hp), boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end
end

function combat.mousepressed(x, y, button)
    if button == 1 then
        local boardCol = math.floor((x - boardX) / tileSize) + 1
        local boardRow = math.floor((y - boardY) / tileSize) + 1
        if boardCol >= 1 and boardCol <= boardSize and boardRow >= 1 and boardRow <= boardSize then
            if selectedPiece then
                if board[boardCol][boardRow] == nil then
                    board[selectedPiece.x][selectedPiece.y] = nil
                    selectedPiece.x = boardCol
                    selectedPiece.y = boardRow
                    board[boardCol][boardRow] = selectedPiece
                    selectedPiece = nil
                else
                    selectedPiece = nil
                end
            else
                for _, piece in ipairs(playerPieces) do
                    if piece.x == boardCol and piece.y == boardRow and piece.hp > 0 then
                        selectedPiece = piece
                        break
                    end
                end
            end
        end
    end
end