-- combat.lua : Point d'entrée pour le module de combat de Brawl Chess
-- Gère les variables globales et coordonne les autres modules (réseau, plateau, affichage, entrées)

-- Dépendances
local json = require("lib.dkjson")
local socket = require("socket")
local network = require("network")
local board = require("board")
local display = require("display")
local input = require("input")

-- Variables globales du jeu
combat = {}
combat.boardSize = 8           -- Taille du plateau (8x8)
combat.tileSize = 50          -- Taille d'une case en pixels
combat.boardX = (480 - combat.boardSize * combat.tileSize) / 2  -- Position X du plateau (centré)
combat.boardY = 200            -- Position Y du plateau
combat.playerPieces = {}       -- Liste des pions du joueur
combat.enemyPieces = {}        -- Liste des pions ennemis
combat.selectedPiece = nil     -- Pion actuellement sélectionné (ou nil)
combat.actionMode = nil        -- Mode d'action actif ("attack", "shield", "deploy", ou nil)
combat.currentTurn = "player"  -- Tour actuel ("player" ou "enemy")
combat.enemyTurnTimer = 0      -- Timer pour le tour ennemi
combat.enemyTurnDuration = 1   -- Durée du tour ennemi (1 seconde)
combat.errorMessage = nil      -- Message d'erreur à afficher (ou nil)

-- Fonction principale pour initialiser le combat
function combat.load()
    board.init(combat.boardSize)  -- Initialiser le plateau
end

-- Fonction pour entrer en combat (connexion au serveur)
function combat.enterCombat()
    network.enterCombat(combat)  -- Charger les pions depuis le serveur
end

-- Fonction pour mettre à jour le jeu
function combat.update(dt)
    board.update(combat, dt)  -- Gérer les tours et actions automatiques
end

-- Fonction pour dessiner le plateau et les pions
function combat.draw()
    display.draw(combat)  -- Afficher le plateau, les pions, et les messages
end

-- Fonction pour gérer les clics de souris
function combat.mousepressed(x, y, button)
    input.mousepressed(combat, x, y, button)  -- Traiter les interactions utilisateur
end