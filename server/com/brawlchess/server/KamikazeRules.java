package com.brawlchess.server;

import org.json.JSONObject;

public class KamikazeRules implements PieceRules {
    @Override
    public boolean isValidMove(JSONObject piece, int currentX, int currentY, int targetX, int targetY, String[][] board) {
        if (targetX < 0 || targetX >= 8 || targetY < 0 || targetY >= 8) {
            return false;
        }
        if (board[targetX][targetY] != null) {
            return false;
        }
        if (board[currentX][currentY] == null) {
            return false;
        }
        if (piece.getBoolean("hasMoved")) {
            return false;
        }
        int deltaX = targetX - currentX;
        int deltaY = targetY - currentY;
        return (deltaX == 0 && deltaY == 1); // 1 case vers l’avant (bas)
    }

    @Override
    public JSONObject handleAction(String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState) {
        JSONObject response = new JSONObject();
        if (!action.equals("attack")) {
            response.put("success", false);
            response.put("error", "Action non reconnue");
            return response;
        }
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
        // Vérifier si la cible est adjacente (corps à corps)
        int distance = Math.abs(pieceX - targetX) + Math.abs(pieceY - targetY);
        if (distance != 1) {
            response.put("success", false);
            response.put("error", "Cible doit être adjacente");
            return response;
        }
        JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
        if (targetPiece == null || targetPiece.getString("type").equals("player")) {
            response.put("success", false);
            response.put("error", "Cible doit être un ennemi adjacent");
            return response;
        }
        // Enlever 1 HP à la cible
        int targetHp = targetPiece.getInt("hp") - 1;
        targetPiece.put("hp", targetHp);
        System.out.println("HP de la cible après attaque du Kamikaze : " + targetHp);
        if (targetHp <= 0) {
            board[targetX][targetY] = null;
            gameState.removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
            System.out.println("Cible retirée à (" + (targetX + 1) + "," + (targetY + 1) + ")");
        }
        // Détruire le Kamikaze
        board[pieceX][pieceY] = null;
        gameState.removePiece(piece.getString("name"), pieceX + 1, pieceY + 1);
        System.out.println("Kamikaze détruit à (" + (pieceX + 1) + "," + (pieceY + 1) + ")");
        piece.put("hasUsedAction", true); // Pour marquer l'action comme utilisée (bien que la pièce soit déjà supprimée)
        response.put("success", true);
        return response;
    }
}