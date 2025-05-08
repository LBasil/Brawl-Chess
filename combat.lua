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
local actionMode = nil -- "attack", "shield", "deploy"
local turnStarted = false

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
                            if piece.type == "player" then
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
        type = "move",
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
    love.timer.sleep(0.1)
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

function combat.sendAction(piece, action, targetX, targetY)
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
        type = "action",
        piece = { name = piece.name, x = piece.x, y = piece.y },
        action = action
    }
    if targetX and targetY then
        request.target = { x = targetX, y = targetY }
    end
    local requestJson = json.encode(request)
    local sent, sendErr = tcp:send(requestJson .. "\n")
    if not sent then
        errorMessage = "Erreur d'envoi au serveur : " .. (sendErr or "inconnu")
        tcp:close()
        return { success = false, error = errorMessage }
    end
    love.timer.sleep(0.1)
    local answer, recvErr = tcp:receive("*l")
    print("Réponse reçue (sendAction): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
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

function combat.startTurn()
    -- Actions automatiques au début du tour (ex. Tourelle)
    for _, piece in ipairs(playerPieces) do
        if piece.name == "Tourelle" and piece.hp > 0 then
            for _, enemy in ipairs(enemyPieces) do
                if enemy.hp > 0 then
                    local distance = math.abs(piece.x - enemy.x) + math.abs(piece.y - enemy.y)
                    if distance <= piece.range then
                        local response = combat.sendAction(piece, "attack", enemy.x, enemy.y)
                        if response.success then
                            enemy.hp = enemy.hp - piece.damage
                            piece.hp = piece.hp - 1 -- Tourelle perd 1 PV après chaque attaque
                            if enemy.hp <= 0 then
                                board[enemy.x][enemy.y] = nil
                                for i, e in ipairs(enemyPieces) do
                                    if e == enemy then
                                        table.remove(enemyPieces, i)
                                        break
                                    end
                                end
                            end
                            if piece.hp <= 0 then
                                board[piece.x][piece.y] = nil
                                for i, p in ipairs(playerPieces) do
                                    if p == piece then
                                        table.remove(playerPieces, i)
                                        break
                                    end
                                end
                            end
                        end
                        break -- Tourelle attaque une seule cible par tour
                    end
                end
            end
        end
    end
    turnStarted = true
end

function combat.update(dt)
    if not turnStarted then
        combat.startTurn()
    end
    -- Pas d'autres mises à jour automatiques pour l'instant
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
            if piece.name == "Wall" then
                love.graphics.setColor(0.3, 0.3, 0.3)
            else
                love.graphics.setColor(0, 0, 1)
            end
            love.graphics.rectangle("fill", boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, tileSize - 10, tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            local text = piece.name .. "\nHP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end
    for _, piece in ipairs(enemyPieces) do
        if piece.hp > 0 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", boardX + (piece.x-1) * tileSize + 5, boardY + (piece.y-1) * tileSize + 5, tileSize - 10, tileSize - 10)
            love.graphics.setColor(1, 1, 1)
            local text = piece.name .. "\nHP: " .. math.floor(piece.hp)
            if piece.shield and piece.shield > 0 then
                text = text .. "\nShield: " .. piece.shield
            end
            love.graphics.printf(text, boardX + (piece.x-1) * tileSize, boardY + (piece.y-1) * tileSize, tileSize, "center")
        end
    end
    if errorMessage then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf(errorMessage, 0, 50, 480, "center")
    end
    if actionMode then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("Mode action : " .. actionMode, 0, 70, 480, "center")
    end
end

function combat.mousepressed(x, y, button)
    if button == 1 then -- Clic gauche : sélectionner/déplacer
        local boardCol = math.floor((x - boardX) / tileSize) + 1
        local boardRow = math.floor((y - boardY) / tileSize) + 1
        if boardCol >= 1 and boardCol <= boardSize and boardRow >= 1 and boardRow <= boardSize then
            if actionMode then
                -- Exécuter une action
                if selectedPiece then
                    local targetPiece = board[boardCol][boardRow]
                    if actionMode == "attack" and (selectedPiece.name == "Sniper" or selectedPiece.name == "Kamikaze") then
                        if targetPiece and targetPiece.type == "enemy" then
                            local distance = math.abs(selectedPiece.x - boardCol) + math.abs(selectedPiece.y - boardRow)
                            if selectedPiece.name == "Kamikaze" and distance ~= 1 then
                                errorMessage = "Kamikaze : cible trop loin (1 case max)"
                            else
                                local response = combat.sendAction(selectedPiece, "attack", boardCol, boardRow)
                                if response.success then
                                    targetPiece.hp = targetPiece.hp - 1
                                    if selectedPiece.name == "Kamikaze" then
                                        board[selectedPiece.x][selectedPiece.y] = nil
                                        for i, p in ipairs(playerPieces) do
                                            if p == selectedPiece then
                                                table.remove(playerPieces, i)
                                                break
                                            end
                                        end
                                    end
                                    if targetPiece.hp <= 0 then
                                        board[boardCol][boardRow] = nil
                                        for i, e in ipairs(enemyPieces) do
                                            if e == targetPiece then
                                                table.remove(enemyPieces, i)
                                                break
                                            end
                                        end
                                    end
                                    selectedPiece.hasUsedAction = true
                                end
                            end
                        else
                            errorMessage = "Cible invalide : doit être un ennemi"
                        end
                    elseif actionMode == "shield" and selectedPiece.name == "Bouclier" then
                        if targetPiece and targetPiece.type == "player" then
                            local response = combat.sendAction(selectedPiece, "shield", boardCol, boardRow)
                            if response.success then
                                targetPiece.shield = (targetPiece.shield or 0) + 1
                            end
                        else
                            errorMessage = "Cible invalide : doit être un allié"
                        end
                    elseif actionMode == "deploy" and selectedPiece.name == "Mur" then
                        local response = combat.sendAction(selectedPiece, "deploy", boardCol, boardRow)
                        if response.success then
                            selectedPiece.hasUsedAction = true
                            local wallPieces = response.wallPieces
                            for _, wall in ipairs(wallPieces) do
                                local newPiece = {
                                    name = wall.name,
                                    type = wall.type,
                                    x = wall.x,
                                    y = wall.y,
                                    hp = wall.hp,
                                    maxHP = wall.maxHP
                                }
                                table.insert(playerPieces, newPiece)
                                board[wall.x][wall.y] = newPiece
                            end
                        end
                    end
                    actionMode = nil
                    selectedPiece = nil
                end
            else
                if selectedPiece then
                    local response = combat.sendMove(selectedPiece, boardCol, boardRow)
                    if response.success then
                        board[selectedPiece.x][selectedPiece.y] = nil
                        selectedPiece.x = response.piece.x
                        selectedPiece.y = response.piece.y
                        board[selectedPiece.x][selectedPiece.y] = selectedPiece
                        if selectedPiece.name == "Tourelle" then
                            selectedPiece.hasMoved = true
                        end
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
    elseif button == 2 then -- Clic droit : choisir une action
        local boardCol = math.floor((x - boardX) / tileSize) + 1
        local boardRow = math.floor((y - boardY) / tileSize) + 1
        if boardCol >= 1 and boardCol <= boardSize and boardRow >= 1 and boardRow <= boardSize then
            for _, piece in ipairs(playerPieces) do
                if piece.x == boardCol and piece.y == boardRow and piece.hp > 0 then
                    if piece.name == "Sniper" or piece.name == "Kamikaze" then
                        if not piece.hasUsedAction then
                            actionMode = "attack"
                            selectedPiece = piece
                        else
                            errorMessage = "Action déjà utilisée"
                        end
                    elseif piece.name == "Bouclier" then
                        actionMode = "shield"
                        selectedPiece = piece
                    elseif piece.name == "Mur" and not piece.hasUsedAction then
                        actionMode = "deploy"
                        selectedPiece = piece
                    end
                    break
                end
            end
        end
    end
end