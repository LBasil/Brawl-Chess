package com.brawlchess.server;

import org.json.JSONObject;

public class ActionHandler {
    public static JSONObject handleAction(String pieceName, String action, int pieceX, int pieceY, int targetX, int targetY, Board board, GameState gameState) {
        JSONObject piece = gameState.findPiece(pieceName, pieceX + 1, pieceY + 1);
        if (piece == null) {
            JSONObject response = new JSONObject();
            response.put("success", false);
            response.put("error", "Pion non trouvé");
            return response;
        }
        return PieceRules.handleAction(pieceName, action, pieceX, pieceY, targetX, targetY, piece, board.getBoard(), gameState);
    }
}