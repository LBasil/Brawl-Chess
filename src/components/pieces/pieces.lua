local pieces = {}

-- Mapping des types de pions aux indices de sprites (de 1 à 14)
local spriteMapping = {
    Soldat = 1,
    Tourelle = 2,
    Sniper = 3,
    Bouclier = 4,
    Kamikaze = 5,
    Mur = 6,
}

-- Table pour stocker les images chargées
local sprites = {
    blue = {}, -- Sprites des alliés
    red = {}   -- Sprites des ennemis
}

function pieces.loadSprites()
    for i = 1, 14 do
        sprites.blue[i] = love.graphics.newImage("assets/images/pieces/blue/blue_sprite_" .. i .. ".png")
    end
    for i = 1, 14 do
        sprites.red[i] = love.graphics.newImage("assets/images/pieces/red/red_sprite_" .. i .. ".png")
    end
end

function pieces.assignSprite(piece, isEnemy)
    local pieceType = piece.name
    local spriteIndex = spriteMapping[pieceType] or 1
    piece.sprite = isEnemy and sprites.red[spriteIndex] or sprites.blue[spriteIndex]
end

function pieces.updateAfterMove(piece, targetX, targetY, board)
    -- Mise à jour passive, le serveur gère tout
    board.clearTile(piece.x, piece.y)
    piece.x = targetX
    piece.y = targetY
    board.setTile(piece.x, piece.y, piece)
end

function pieces.updateAfterAction(piece, action, targetPiece, playerPieces, enemyPieces, board)
    -- Mise à jour passive, le serveur gère tout
    if action == "attack" and piece.name == "Tourelle" then
        targetPiece.hp = targetPiece.hp - 1
        piece.hp = piece.hp - 1
        if targetPiece.hp <= 0 then
            board.clearTile(targetPiece.x, targetPiece.y)
            for i, e in ipairs(enemyPieces) do
                if e == targetPiece then
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
end

function pieces.automaticAction(playerPieces, enemyPieces, board, network)
    -- Pas d'action automatique côté client, serveur gère
end

return pieces