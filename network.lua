-- network.lua : Gère la communication réseau avec le serveur Java
-- Centralise les connexions TCP, envoi/reception JSON, et gestion des erreurs

local json = require("lib.dkjson")
local socket = require("socket")

local network = {}

-- Configuration du serveur
local HOST = "localhost"
local PORT = 50000
local TIMEOUT = 10  -- Timeout en secondes
local MAX_ATTEMPTS = 3  -- Nombre maximum de tentatives de connexion

-- Fonction interne pour envoyer une requête au serveur
local function sendRequest(request)
    local tcp = socket.tcp()
    if not tcp then
        return { success = false, error = "Erreur : impossible de créer la socket" }
    end
    tcp:settimeout(TIMEOUT)
    local ok, err = tcp:connect(HOST, PORT)
    if not ok then
        tcp:close()
        return { success = false, error = "Erreur de connexion : " .. (err or "inconnu") }
    end
    local requestJson = json.encode(request)
    local sent, sendErr = tcp:send(requestJson .. "\n")
    if not sent then
        tcp:close()
        return { success = false, error = "Erreur d'envoi : " .. (sendErr or "inconnu") }
    end
    love.timer.sleep(0.1)  -- Attendre 100ms pour la réponse
    local answer, recvErr = tcp:receive("*l")
    tcp:close()
    if not answer then
        return { success = false, error = "Erreur : aucune réponse : " .. (recvErr or "inconnu") }
    end
    local response, pos, decodeErr = json.decode(answer)
    if not response then
        return { success = false, error = "Erreur de décodage JSON : " .. (decodeErr or "inconnu") }
    end
    return response
end

-- Connexion initiale pour charger les pions
function network.enterCombat(combat)
    for attempt = 1, MAX_ATTEMPTS do
        local response = sendRequest({})  -- Requête vide pour initialiser
        if response.success then
            combat.errorMessage = nil
            combat.playerPieces = {}
            combat.enemyPieces = {}
            for i = 1, combat.boardSize do
                for j = 1, combat.boardSize do
                    combat.board[i][j] = nil
                end
            end
            for _, piece in ipairs(response.pions) do
                if piece.type == "player" then
                    table.insert(combat.playerPieces, piece)
                else
                    table.insert(combat.enemyPieces, piece)
                end
                combat.board[piece.x][piece.y] = piece
            end
            combat.currentTurn = response.currentTurn or "player"
            return
        else
            combat.errorMessage = "Tentative " .. attempt .. "/" .. MAX_ATTEMPTS .. " : " .. response.error
            if attempt < MAX_ATTEMPTS then
                love.timer.sleep(1)  -- Attendre avant de réessayer
            end
        end
    end
end

-- Envoi d'une requête de déplacement
function network.sendMove(combat, piece, targetX, targetY)
    local request = {
        type = "move",
        piece = { name = piece.name, x = piece.x, y = piece.y },
        target = { x = targetX, y = targetY }
    }
    local response = sendRequest(request)
    combat.errorMessage = response.error or nil
    if response.currentTurn then
        combat.currentTurn = response.currentTurn
        if combat.currentTurn == "enemy" then
            combat.enemyTurnTimer = combat.enemyTurnDuration
        end
    end
    return response
end

-- Envoi d'une requête d'action
function network.sendAction(combat, piece, action, targetX, targetY)
    local request = {
        type = "action",
        piece = { name = piece.name, x = piece.x, y = piece.y },
        action = action
    }
    if targetX and targetY then
        request.target = { x = targetX, y = targetY }
    end
    local response = sendRequest(request)
    combat.errorMessage = response.error or nil
    if response.currentTurn then
        combat.currentTurn = response.currentTurn
        if combat.currentTurn == "enemy" then
            combat.enemyTurnTimer = combat.enemyTurnDuration
        end
    end
    return response
end

-- Fin du tour ennemi
function network.sendEndEnemyTurn(combat)
    local request = { type = "endEnemyTurn" }
    local response = sendRequest(request)
    combat.errorMessage = response.error or nil
    if response.currentTurn then
        combat.currentTurn = response.currentTurn
    end
    return response
end

return network