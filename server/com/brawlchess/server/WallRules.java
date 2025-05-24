package com.brawlchess.server;

import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;

public class WallRules implements PieceRules {
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
        if (piece.optBoolean("hasUsedWallInGame", false)) {
            return false; // Le Mur est figé après avoir utilisé son action
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
        if (!action.equals("deployWall")) {
            response.put("success", false);
            response.put("error", "Action non reconnue");
            return response;
        }
        if (piece.optBoolean("hasUsedWallInGame", false)) {
            response.put("success", false);
            response.put("error", "Le Mur a déjà déployé un mur dans cette partie");
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

        // Positions pour une ligne horizontale : centre (cible), gauche, droite
        List<int[]> wallPositions = new ArrayList<>();

        // 1. Centre (position cible elle-même, considérée comme "devant")
        if (targetX >= 0 && targetX < 8 && targetY >= 0 && targetY < 8 && board[targetX][targetY] == null) {
            wallPositions.add(new int[]{targetX, targetY});
        } else {
            response.put("success", false);
            response.put("error", "Position cible occupée ou invalide");
            return response;
        }

        // 2. Gauche (X-1 par rapport à la position cible)
        int leftX = targetX - 1;
        int leftY = targetY;
        if (leftX >= 0 && leftX < 8 && leftY >= 0 && leftY < 8 && board[leftX][leftY] == null) {
            wallPositions.add(new int[]{leftX, leftY});
        } else {
            response.put("success", false);
            response.put("error", "Position gauche occupée ou invalide");
            return response;
        }

        // 3. Droite (X+1 par rapport à la position cible)
        int rightX = targetX + 1;
        int rightY = targetY;
        if (rightX >= 0 && rightX < 8 && rightY >= 0 && rightY < 8 && board[rightX][rightY] == null) {
            wallPositions.add(new int[]{rightX, rightY});
        } else {
            response.put("success", false);
            response.put("error", "Position droite occupée ou invalide");
            return response;
        }

        // Ajouter les murs au plateau
        for (int[] pos : wallPositions) {
            int wallX = pos[0];
            int wallY = pos[1];
            board[wallX][wallY] = "WallPiece";
            JSONObject wallPiece = new JSONObject();
            wallPiece.put("name", "WallPiece_" + wallX + "_" + wallY);
            wallPiece.put("type", "wall");
            wallPiece.put("x", wallX + 1);
            wallPiece.put("y", wallY + 1);
            wallPiece.put("hp", 1);
            gameState.addPiece(wallPiece);
            System.out.println("Mur déployé à (" + (wallX + 1) + "," + (wallY + 1) + ")");
        }

        piece.put("hasUsedWallInGame", true);
        piece.put("hasUsedAction", true);
        response.put("success", true);
        return response;
    }
}