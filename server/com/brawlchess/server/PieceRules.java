package com.brawlchess.server;

import org.json.JSONObject;

public interface PieceRules {
    boolean isValidMove(JSONObject piece, int currentX, int currentY, int targetX, int targetY, String[][] board);
    JSONObject handleAction(String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState);
}