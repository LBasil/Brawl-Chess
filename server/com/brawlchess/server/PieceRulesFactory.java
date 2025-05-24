package com.brawlchess.server;

import java.util.HashMap;
import java.util.Map;
import org.json.*;

public class PieceRulesFactory {
    private static final Map<String, PieceRules> rulesMap = new HashMap<>();

    static {
        rulesMap.put("Tourelle", new TowerRules());
        rulesMap.put("Sniper", new SniperRules());
        rulesMap.put("Kamikaze", new KamikazeRules());
        rulesMap.put("Bouclier", new ShieldRules());
        // Ajouter d'autres types de pions ici à l'avenir, par exemple :
        // rulesMap.put("Mur", new WallRules());
    }

    public static PieceRules getRules(String pieceName) {
        return rulesMap.getOrDefault(pieceName, new DefaultRules());
    }
}

class DefaultRules implements PieceRules {
    @Override
    public boolean isValidMove(JSONObject piece, int currentX, int currentY, int targetX, int targetY, String[][] board) {
        return false;
    }

    @Override
    public JSONObject handleAction(String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState) {
        JSONObject response = new JSONObject();
        response.put("success", false);
        response.put("error", "Règles non définies pour ce type de pion");
        return response;
    }
}