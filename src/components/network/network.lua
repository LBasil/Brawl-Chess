local network = {}
local json = require("lib.dkjson")
local socket = require("socket")
local turn = require("src.components.turn.turn")

function network.fetchLeaderboard()
    local host, port = "localhost", 50000
    local tcp = socket.tcp()
    if not tcp then
        return false, "Erreur : impossible de créer la socket"
    end
    tcp:settimeout(10)
    local ok, err = tcp:connect(host, port)
    if not ok then
        tcp:close()
        return false, "Erreur de connexion au serveur : " .. (err or "inconnu")
    end
    local request = {
        type = "leaderboard"
    }
    local requestJson = json.encode(request)
    local sent, sendErr = tcp:send(requestJson .. "\n")
    if not sent then
        tcp:close()
        return false, "Erreur d'envoi au serveur : " .. (sendErr or "inconnu")
    end
    love.timer.sleep(0.1)
    local answer, recvErr = tcp:receive("*l")
    print("Réponse reçue (fetchLeaderboard): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
    tcp:close()
    if not answer then
        return false, "Erreur : aucune réponse du serveur : " .. (recvErr or "inconnu")
    end
    local response, pos, decodeErr = json.decode(answer)
    if not response then
        return false, "Erreur de décodage JSON : " .. (decodeErr or "inconnu")
    end
    return true, response.scores or {}
end

function network.connectAndFetchState(playerPieces, enemyPieces, board, turn)
    local host, port = "localhost", 50000
    local maxAttempts = 3
    local attempt = 1
    local errorMessage = nil

    while attempt <= maxAttempts do
        local tcp = socket.tcp()
        if not tcp then
            errorMessage = "Erreur : impossible de créer la socket"
            return false, errorMessage
        end
        tcp:settimeout(10)
        local ok, err = tcp:connect(host, port)
        if not ok then
            errorMessage = "Erreur de connexion au serveur (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (err or "inconnu")
            tcp:close()
        else
            local sent, sendErr = tcp:send("\n")
            if not sent then
                errorMessage = "Erreur d'envoi au serveur (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (sendErr or "inconnu")
                tcp:close()
            else
                love.timer.sleep(0.1)
                local answer, recvErr = tcp:receive("*l")
                print("Réponse reçue (tentative " .. attempt .. "): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
                tcp:close()
                if not answer then
                    errorMessage = "Erreur : aucune réponse du serveur (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (recvErr or "inconnu")
                else
                    local response, pos, decodeErr = json.decode(answer)
                    if not response then
                        errorMessage = "Erreur de décodage JSON (tentative " .. attempt .. "/" .. maxAttempts .. ") : " .. (decodeErr or "inconnu")
                    else
                        combat.updateState(response.pions)
                        return true, response.currentTurn or "player"
                    end
                end
            end
        end
        attempt = attempt + 1
        if attempt <= maxAttempts then
            love.timer.sleep(1)
        end
    end
    return false, errorMessage
end

function network.sendMove(piece, targetX, targetY, currentTurn)
    local host, port = "localhost", 50000
    local tcp = socket.tcp()
    if not tcp then
        return { success = false, error = "Erreur : impossible de créer la socket" }
    end
    tcp:settimeout(10)
    local ok, err = tcp:connect(host, port)
    if not ok then
        tcp:close()
        return { success = false, error = "Erreur de connexion au serveur : " .. (err or "inconnu") }
    end
    local request = {
        type = "move",
        piece = { name = piece.name, x = piece.x, y = piece.y },
        target = { x = targetX, y = targetY }
    }
    local requestJson = json.encode(request)
    local sent, sendErr = tcp:send(requestJson .. "\n")
    if not sent then
        tcp:close()
        return { success = false, error = "Erreur d'envoi au serveur : " .. (sendErr or "inconnu") }
    end
    love.timer.sleep(0.1)
    local answer, recvErr = tcp:receive("*l")
    print("Réponse reçue (sendMove): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
    tcp:close()
    if not answer then
        return { success = false, error = "Erreur : aucune réponse du serveur : " .. (recvErr or "inconnu") }
    end
    local response, pos, decodeErr = json.decode(answer)
    if not response then
        return { success = false, error = "Erreur de décodage JSON : " .. (decodeErr or "inconnu") }
    end
    if response.pions then
        combat.updateState(response.pions)
    end
    return response, response.currentTurn or currentTurn
end

function network.sendAction(piece, action, targetX, targetY, currentTurn)
    local host, port = "localhost", 50000
    local tcp = socket.tcp()
    if not tcp then
        return { success = false, error = "Erreur : impossible de créer la socket" }
    end
    tcp:settimeout(10)
    local ok, err = tcp:connect(host, port)
    if not ok then
        tcp:close()
        return { success = false, error = "Erreur de connexion au serveur : " .. (err or "inconnu") }
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
        tcp:close()
        return { success = false, error = "Erreur d'envoi au serveur : " .. (sendErr or "inconnu") }
    end
    love.timer.sleep(0.1)
    local answer, recvErr = tcp:receive("*l")
    print("Réponse reçue (sendAction): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
    tcp:close()
    if not answer then
        return { success = false, error = "Erreur : aucune réponse du serveur : " .. (recvErr or "inconnu") }
    end
    local response, pos, decodeErr = json.decode(answer)
    if not response then
        return { success = false, error = "Erreur de décodage JSON : " .. (decodeErr or "inconnu") }
    end
    if response.pions then
        combat.updateState(response.pions)
    end
    return response, response.currentTurn or currentTurn
end

function network.sendEndEnemyTurn(currentTurn)
    local host, port = "localhost", 50000
    local tcp = socket.tcp()
    if not tcp then
        return { success = false, error = "Erreur : impossible de créer la socket" }
    end
    tcp:settimeout(10)
    local ok, err = tcp:connect(host, port)
    if not ok then
        tcp:close()
        return { success = false, error = "Erreur de connexion au serveur : " .. (err or "inconnu") }
    end
    local request = {
        type = "endEnemyTurn"
    }
    local requestJson = json.encode(request)
    local sent, sendErr = tcp:send(requestJson .. "\n")
    if not sent then
        tcp:close()
        return { success = false, error = "Erreur d'envoi au serveur : " .. (sendErr or "inconnu") }
    end
    love.timer.sleep(0.1)
    local answer, recvErr = tcp:receive("*l")
    print("Réponse reçue (sendEndEnemyTurn): " .. (answer or "nil") .. " (erreur: " .. (recvErr or "aucune") .. ")")
    tcp:close()
    if not answer then
        return { success = false, error = "Erreur : aucune réponse du serveur : " .. (recvErr or "inconnu") }
    end
    local response, pos, decodeErr = json.decode(answer)
    if not response then
        return { success = false, error = "Erreur de décodage JSON : " .. (decodeErr or "inconnu") }
    end
    if response.pions then
        combat.updateState(response.pions)
    end
    return response, response.currentTurn or currentTurn
end

return network