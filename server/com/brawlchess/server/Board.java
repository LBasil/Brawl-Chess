package com.brawlchess.server;

import org.json.JSONObject;

public class Board {
    private String[][] board;
    private static final int BOARD_SIZE = 8;
    private GameState gameState;

    public Board(GameState gameState) {
        this.board = new String[BOARD_SIZE][BOARD_SIZE];
        this.gameState = gameState;
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
        JSONObject piece = gameState.findPiece(pieceName, currentX + 1, currentY + 1);
        if (piece == null) {
            return false;
        }
        PieceRules rules = PieceRulesFactory.getRules(pieceName);
        return rules.isValidMove(piece, currentX, currentY, targetX, targetY, board);
    }
}