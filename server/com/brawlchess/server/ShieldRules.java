package com.brawlchess.server;

import org.json.JSONObject;

public class ShieldRules implements PieceRules {
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
        int deltaX = Math.abs(targetX - currentX);
        int deltaY = Math.abs(targetY - currentY);
        return (deltaX <= 1 && deltaY <= 1 && (deltaX + deltaY) == 1); // 1 case dans n'importe quelle direction
    }

    @Override
    public JSONObject handleAction(String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState) {
        JSONObject response = new JSONObject();
        if (!action.equals("shield")) {
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
        int distance = Math.abs(pieceX - targetX) + Math.abs(pieceY - targetY);
        if (distance != 1) {
            response.put("success", false);
            response.put("error", "Cible doit être adjacente");
            return response;
        }
        JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
        if (targetPiece == null || targetPiece.getString("type").equals("enemy")) {
            response.put("success", false);
            response.put("error", "Cible doit être un allié adjacent");
            return response;
        }
        // Conférer 1 bouclier à l'allié
        targetPiece.put("shield", targetPiece.optInt("shield", 0) + 1);
        System.out.println("Bouclier conféré à " + targetPiece.getString("name") + " à (" + (targetX + 1) + "," + (targetY + 1) + ")");
        piece.put("hasUsedAction", true);
        response.put("success", true);
        return response;
    }
}