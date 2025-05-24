package com.brawlchess.server;

import org.json.JSONObject;

public class SniperRules implements PieceRules {
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
        return (deltaX == 0 && deltaY == 1);
    }

    @Override
    public JSONObject handleAction(String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState) {
        JSONObject response = new JSONObject();
        if (!action.equals("attack")) {
            response.put("success", false);
            response.put("error", "Action non reconnue");
            return response;
        }
        if (piece.optBoolean("hasUsedAttackInGame", false)) {
            response.put("success", false);
            response.put("error", "Le Sniper a déjà utilisé son attaque dans cette partie");
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
        JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
        if (targetPiece == null) {
            response.put("success", false);
            response.put("error", "Aucune cible à cette position");
            return response;
        }
        int damage = 1; // Dégât de base du Sniper
        GameServer.applyDamage(targetPiece, damage);
        int targetHp = targetPiece.getInt("hp");
        System.out.println("HP de la cible après attaque du Sniper : " + targetHp);
        if (targetHp <= 0) {
            board[targetX][targetY] = null;
            gameState.removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
            System.out.println("Cible retirée à (" + (targetX + 1) + "," + (targetY + 1) + ")");
        }
        piece.put("hasUsedAttackInGame", true);
        piece.put("hasUsedAction", true);
        response.put("success", true);
        return response;
    }
}