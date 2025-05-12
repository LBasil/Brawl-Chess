local pieces = {}

-- Mapping des types de pions aux indices de sprites (de 1 à 14)
local spriteMapping = {
    Soldat = 1,
    Tourelle = 2,
    Sniper = 3,
    Bouclier = 4,
    Kamikaze = 5,
    Mur = 6,
    -- Ajoute d'autres types si nécessaire (jusqu'à 14)
}

-- Table pour stocker les images chargées
local sprites = {
    blue = {}, -- Sprites des alliés
    red = {}   -- Sprites des ennemis
}

function pieces.loadSprites()
    -- Charger les sprites pour les alliés (blue)
    for i = 1, 14 do
        sprites.blue[i] = love.graphics.newImage("src/assets/images/pieces/blue/blue_sprite_" .. i .. ".png")
    end
    -- Charger les sprites pour les ennemis (red)
    for i = 1, 14 do
        sprites.red[i] = love.graphics.newImage("src/assets/images/pieces/red/red_sprite_" .. i .. ".png")
    end
end

function pieces.assignSprite(piece, isEnemy)
    -- Déterminer le type de pion et son camp
    local pieceType = piece.name
    local spriteIndex = spriteMapping[pieceType] or 1 -- Par défaut, utiliser le sprite 1 si non mappé
    piece.sprite = isEnemy and sprites.red[spriteIndex] or sprites.blue[spriteIndex]
end

function pieces.updateAfterMove(piece, targetX, targetY, board)
    board.clearTile(piece.x, piece.y)
    piece.x = targetX
    piece.y = targetY
    board.setTile(piece.x, piece.y, piece)
    if piece.name == "Tourelle" then
        piece.hasMoved = true
    end
end

function pieces.updateAfterAction(piece, action, targetPiece, playerPieces, enemyPieces, board)
    if action == "attack" then
        targetPiece.hp = targetPiece.hp - 1
        if piece.name == "Kamikaze" then
            board.clearTile(piece.x, piece.y)
            for i, p in ipairs(playerPieces) do
                if p == piece then
                    table.remove(playerPieces, i)
                    break
                end
            end
        end
        if targetPiece.hp <= 0 then
            board.clearTile(targetPiece.x, targetPiece.y)
            for i, e in ipairs(enemyPieces) do
                if e == targetPiece then
                    table.remove(enemyPieces, i)
                    break
                end
            end
        end
        piece.hasUsedAction = true
    elseif action == "shield" then
        targetPiece.shield = (targetPiece.shield or 0) + 1
    elseif action == "deploy" then
        piece.hasUsedAction = true
    end
end

function pieces.automaticAction(playerPieces, enemyPieces, board, network)
    for _, piece in ipairs(playerPieces) do
        if piece.name == "Tourelle" and piece.hp > 0 then
            for _, enemy in ipairs(enemyPieces) do
                if enemy.hp > 0 then
                    local distance = math.abs(piece.x - enemy.x) + math.abs(piece.y - enemy.y)
                    if distance <= piece.range then
                        local response = network.sendAction(piece, "attack", enemy.x, enemy.y)
                        if response.success then
                            enemy.hp = enemy.hp - piece.damage
                            piece.hp = piece.hp - 1
                            if enemy.hp <= 0 then
                                board.clearTile(enemy.x, enemy.y)
                                for i, e in ipairs(enemyPieces) do
                                    if e == enemy then
                                        table.remove(enemyPieces, i)
                                        break
                                    end
                                end
                            end
                            if piece.hp <= 0 then
                                board.clearTile(piece.x, piece.y)
                                for i, p in ipairs(playerPieces) do
                                    if p == piece then
                                        table.remove(playerPieces, i)
                                        break
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

return pieces