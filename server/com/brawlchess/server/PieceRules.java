package com.brawlchess.server;

import org.json.JSONObject;

public class PieceRules {
    public static boolean isValidMove(String pieceName, JSONObject piece, int currentX, int currentY, int targetX, int targetY, String[][] board) {
        if (targetX < 0 || targetX >= 8 || targetY < 0 || targetY >= 8) {
            return false;
        }
        if (board[targetX][targetY] != null) {
            return false;
        }
        if (board[currentX][currentY] == null) {
            return false;
        }

        if (pieceName.equals("Tourelle")) {
            if (piece.getBoolean("hasMoved")) {
                return false;
            }
            return true;
        }
        return false;
    }

    public static JSONObject handleAction(String pieceName, String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState) {
        JSONObject response = new JSONObject();
        if (!pieceName.equals("Tourelle")) {
            response.put("success", false);
            response.put("error", "Action non reconnue pour ce pion");
            return response;
        }

        if (action.equals("attack")) {
            if (piece.getBoolean("hasUsedAction")) {
                response.put("success", false);
                response.put("error", "Action déjà utilisée ce tour");
                return response;
            }
            if (targetX < 0 || targetY < 0 || targetX >= 8 || targetY >= 8) {
                response.put("success", false);
                response.put("error", "Cible hors du plateau");
                return response;
            }
            int distance = Math.abs(pieceX - targetX) + Math.abs(pieceY - targetY);
            if (distance != 1) {
                response.put("success", false);
                response.put("error", "Cible doit être à 1 case");
                return response;
            }
            JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
            if (targetPiece == null || targetPiece.getString("type").equals("player")) {
                response.put("success", false);
                response.put("error", "Cible doit être un ennemi");
                return response;
            }
            // Réduire les HP de l'ennemi
            int targetHp = targetPiece.getInt("hp") - 1;
            targetPiece.put("hp", targetHp);
            System.out.println("HP de l'ennemi après attaque : " + targetHp);
            if (targetHp <= 0) {
                board[targetX][targetY] = null;
                gameState.removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
                System.out.println("Ennemi retiré à (" + (targetX + 1) + "," + (targetY + 1) + ")");
            }
            // Réduire les HP de la Tourelle
            int towerHp = piece.getInt("hp") - 1;
            piece.put("hp", towerHp);
            System.out.println("HP de la Tourelle après attaque : " + towerHp);
            if (towerHp <= 0) {
                board[pieceX][pieceY] = null;
                gameState.removePiece(pieceName, pieceX + 1, pieceY + 1);
                System.out.println("Tourelle retirée à (" + (pieceX + 1) + "," + (pieceY + 1) + ")");
            }
            piece.put("hasUsedAction", true);
            response.put("success", true);
        } else {
            response.put("success", false);
            response.put("error", "Action non reconnue");
        }
        return response;
    }
}