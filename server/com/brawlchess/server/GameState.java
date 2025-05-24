package com.brawlchess.server;

import org.json.JSONArray;
import org.json.JSONObject;

public class GameState {
    private JSONObject gameState;

    public GameState() {
        this.gameState = new JSONObject();
        this.gameState.put("pions", new JSONArray());
    }

    public JSONObject getGameState() {
        return gameState;
    }

    public JSONObject findPiece(String name, int x, int y) {
        JSONArray pions = gameState.getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            if (piece.getString("name").equals(name) && piece.getInt("x") == x && piece.getInt("y") == y) {
                return piece;
            }
        }
        return null;
    }

    public JSONObject findPieceAt(int x, int y) {
        JSONArray pions = gameState.getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            if (piece.getInt("x") == x && piece.getInt("y") == y) {
                return piece;
            }
        }
        return null;
    }

    public void addPiece(JSONObject piece) {
        JSONArray pions = gameState.getJSONArray("pions");
        pions.put(piece);
        gameState.put("pions", pions);
    }

    public void updateGameState(String name, int oldX, int oldY, int newX, int newY, boolean remove) {
        JSONArray pions = gameState.getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            if (piece.getString("name").equals(name) && piece.getInt("x") == oldX && piece.getInt("y") == oldY) {
                if (remove) {
                    pions.remove(i);
                } else {
                    piece.put("x", newX);
                    piece.put("y", newY);
                    if (name.equals("Tourelle")) {
                        piece.put("hasMoved", true);
                    }
                }
                break;
            }
        }
        gameState.put("pions", pions);
    }

    public void removePiece(String name, int x, int y) {
        updateGameState(name, x, y, x, y, true);
    }
}