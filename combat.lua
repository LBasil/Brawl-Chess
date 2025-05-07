local json = require("lib.dkjson")

combat = {}

local board = {}
local boardSize = 8
local tileSize = 50
local boardX = (480 - boardSize * tileSize) / 2
local boardY = 200
local playerPieces = {}
local enemyPieces = {}
local selectedPiece = nil
local socket = require("socket")
local errorMessage = nil

function combat.load()
    for i = 1, boardSize do
        board[i] = {}
        for j = 1, boardSize do
            board[i][j] = nil
        end
    end
end

function combat.enterCombat()
    local host, port = "localhost", 50000
    local maxAttempts = 3
    local attempt = 1
    while attempt <= maxAttempts do
        local tcp = socket.tcp()
        if not tcp then
            errorMessage = "Erreur : impossible de créer la socket"
            return
        end
        tcp:settimeout(10) -- Timeout de 10 secondes
        local ok, err = tcp:connect(host, port)
        if not ok then
            errorMessage = "Erreur de connexion au serveur (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (err or "inconnu")
            tcp:close()
        else
            -- Envoyer une requête vide pour déclencher la réponse du serveur
            local sent, sendErr = tcp:send("\n")
            if not sent then
                errorMessage = "Erreur d'envoi au serveur (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (sendErr or "inconnu")
                tcp:close()
            else
                love.timer.sleep(0.1) -- Attendre 100ms pour s'assurer que le serveur a lu la requête
                local answer, recvErr = tcp:receive("*l") -- Lire une ligne complète
                print("Réponse reçue (tentative " .. attempt .. "): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
                tcp:close()
                if not answer then
                    errorMessage = "Erreur : aucune réponse du serveur (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (recvErr or "inconnu")
                else
                    local pions, pos, decodeErr = json.decode(answer)
                    if not pions then
                        errorMessage = "Erreur de décodage JSON (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (decodeErr or "inconnu")
                    else
                        errorMessage = nil
                        playerPieces = {}
                        enemyPieces = {}
                        for i = 1, boardSize do
                            for j = 1, boardSize do
                                board[i][j] = nil
                            end
                        end
                        for _, piece in ipairs(pions) do
                            if piece.name == "Tourelle" then
                                table.insert(playerPieces, piece)
                            else
                                table.insert(enemyPieces, piece)
                            end
                            board[piece.x][piece.y] = piece
                        end
                        return -- Succès, sortir de la boucle
                    end
                end
            end
        end
        attempt = attempt + 1
        if attempt <= maxAttempts then
            love.timer.sleep(1) -- Attendre 1 seconde avant de réessayer
        end
    end
end

function combat.sendMove(piece, targetX, targetY)
    local host, port = "localhost", 50000
    local tcp = socket.tcp()
    if not tcp then
        errorMessage = "Erreur : impossible de créer la socket"
        return { success = false, error = errorMessage }
    end
    tcp:settimeout(10)
    local ok, err = tcp:connect(host, port)
    if not ok then
        errorMessage = "Erreur de connexion au serveur : " .. (err or "inconnu")
        tcp:close()
        return { success = false, error = errorMessage }
    end
    local request = {
        action = "move",
        piece = { name = piece.name, x = piece.x, y = piece.y },
        target = { x = targetX, y = targetY }
    }
    local requestJson = json.encode(request)
    local sent, sendErr = tcp:send(requestJson .. "\n")
    if not sent then
        errorMessage = "Erreur d'envoi au serveur : " .. (sendErr or "inconnu")
        tcp:close()
        return { success = false, error = errorMessage }
    end
    love.timer.sleep(0.1) -- Attendre 100ms pour s'assurer que le serveur a lu la requête
    local answer, recvErr = tcp:receive("*l")
    print("Réponse reçue (sendMove): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
    tcp:close()
    if not answer then
        errorMessage = "Erreur : aucune réponse du serveur : " .. (recvErr or "inconnu")
        return { success = false, error = errorMessage }
    end
    local response, pos, decodeErr = json.decode(answer)
    if not response then
        errorMessage = "Erreur de décodage JSON : " .. (decodeErr or "inconnu")
        return { success = false, error = errorMessage }
    end
    errorMessage = response.error or nil
    return response
end

function combat.update(dt)
    for _, piece in ipairs(playerPieces) do
        if piece.name == "Tourelle" and piece.hp > 0 then
            for _, enemy in ipairs(enemyPieces) do
                if enemy.hp > 0 then
                    local distance = math.abs(piece.x - enemy.x) + math.abs(piece.y - enemy.y)
                    if distance <= piece.range then
                        enemy.hp = enemy.hp - piece.damage * dt
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
    for i = 1, boardSize do
        for j = 1, boardSize do
            if (i + j) % 2 == 0 then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("fill", boardX + (i-1) * tileSize, boardY + (j-1) * tileSize, tileSize, tileSize)
        end
    end
    for _, piece in ipairs(playerPieces) do
        if piece.hp > 0 then
            love.graphics.setColor(0, 0, 1)
            love.graphics.rectangle("fill", boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, tileSize - 10, tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(piece.name .. "\n" .. math.floor(piece.hp), boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end
    for _, piece in ipairs(enemyPieces) do
        if piece.hp > 0 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, tileSize - 10, tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(piece.name .. "\n" .. math.floor(piece.hp), boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end
    if errorMessage then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf(errorMessage, 0, 50, 480, "center")
    end
end

function combat.mousepressed(x, y, button)
    if button == 1 then
        local boardCol = math.floor((x - boardX) / tileSize) + 1
        local boardRow = math.floor((y - boardY) / tileSize) + 1
        if boardCol >= 1 and boardCol <= boardSize and boardRow >= 1 and boardRow <= boardSize then
            if selectedPiece then
                local response = combat.sendMove(selectedPiece, boardCol, boardRow)
                if response.success then
                    board[selectedPiece.x][selectedPiece.y] = nil
                    selectedPiece.x = response.piece.x
                    selectedPiece.y = response.piece.y
                    board[selectedPiece.x][selectedPiece.y] = selectedPiece
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