package com.brawlchess.server;

import org.json.JSONObject;

public class Board {
    private String[][] board;
    private static final int BOARD_SIZE = 8;
    private GameState gameState;

    public Board(GameState gameState) {
        this.board = new String[BOARD_SIZE][BOARD_SIZE];
        this.gameState = gameState;
        // Initialiser le plateau à null
        for (int i = 0; i < BOARD_SIZE; i++) {
            for (int j = 0; j < BOARD_SIZE; j++) {
                board[i][j] = null;
            }
        }
    }

    public String[][] getBoard() {
        return board;
    }

    public boolean isValidMove(String pieceName, int currentX, int currentY, int targetX, int targetY) {
        // Vérifier les limites du plateau
        if (targetX < 0 || targetX >= BOARD_SIZE || targetY < 0 || targetY >= BOARD_SIZE) {
            return false;
        }
        // Vérifier si la case cible est vide
        if (board[targetX][targetY] != null) {
            return false;
        }
        // Vérifier si la case actuelle contient un pion
        if (board[currentX][currentY] == null) {
            return false;
        }

        // Trouver le pion dans gameState
        JSONObject piece = gameState.findPiece(pieceName, currentX + 1, currentY + 1);
        if (piece == null) {
            return false;
        }

        // Vérifier si le pion peut encore se déplacer
        if (pieceName.equals("Tourelle") && piece.getBoolean("hasMoved")) {
            return false;
        }
        if ((pieceName.equals("Sniper") || pieceName.equals("Mur")) && piece.getBoolean("hasUsedAction")) {
            return false;
        }

        // Règles de déplacement selon le type de pion
        if (pieceName.equals("Tourelle")) {
            // Tourelle : peut se déplacer sur n'importe quelle case vide (une fois)
            return true;
        } else if (pieceName.equals("Sniper") || pieceName.equals("Bouclier") || pieceName.equals("Kamikaze")) {
            // Sniper, Bouclier, Kamikaze : 1 case vers l'avant (y-1 pour joueur, y+1 pour ennemi)
            String pieceType = piece.getString("type");
            if (pieceType.equals("player")) {
                return targetX == currentX && targetY == currentY - 1;
            } else {
                return targetX == currentX && targetY == currentY + 1;
            }
        } else if (pieceName.equals("Mur")) {
            // Mur : 1 case dans toutes les directions
            int dx = Math.abs(targetX - currentX);
            int dy = Math.abs(targetY - currentY);
            return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
        } else {
            // Soldat (ennemi) : 1 case vers l'avant (y+1)
            return targetX == currentX && targetY == currentY + 1;
        }
    }
}