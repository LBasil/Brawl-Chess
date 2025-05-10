package com.brawlchess.server;

import org.json.JSONArray;
import org.json.JSONObject;

public class LeaderboardManager {
    // Données simulées du classement (à remplacer par une base de données)
    private static final JSONArray leaderboardData = new JSONArray();

    // Initialisation statique des données simulées
    static {
        leaderboardData.put(new JSONObject()
            .put("rank", 1)
            .put("name", "GrokMaster")
            .put("score", 1500));
        leaderboardData.put(new JSONObject()
            .put("rank", 2)
            .put("name", "ChessWizard")
            .put("score", 1200));
        leaderboardData.put(new JSONObject()
            .put("rank", 3)
            .put("name", "PawnSlayer")
            .put("score", 900));
        leaderboardData.put(new JSONObject()
            .put("rank", 4)
            .put("name", "Knightmare")
            .put("score", 750));
        leaderboardData.put(new JSONObject()
            .put("rank", 5)
            .put("name", "RookRuler")
            .put("score", 600));
    }

    public JSONArray getLeaderboard() {
        return leaderboardData;
    }

    // Méthode pour ajouter un joueur au classement (à utiliser plus tard avec une base de données)
    public void addPlayer(String name, int score) {
        JSONObject newEntry = new JSONObject()
            .put("name", name)
            .put("score", score);

        // Ajouter et trier (simulé ici)
        leaderboardData.put(newEntry);
        // Simuler un tri par score décroissant
        JSONArray sortedData = new JSONArray();
        // Convertir en liste temporaire pour trier
        java.util.List<JSONObject> list = new java.util.ArrayList<>();
        for (int i = 0; i < leaderboardData.length(); i++) {
            list.add(leaderboardData.getJSONObject(i));
        }
        list.sort((a, b) -> Integer.compare(b.getInt("score"), a.getInt("score")));
        for (int i = 0; i < list.size(); i++) {
            JSONObject entry = list.get(i);
            entry.put("rank", i + 1);
            sortedData.put(entry);
        }
        // Mettre à jour les données
        while (leaderboardData.length() > 0) {
            leaderboardData.remove(0);
        }
        for (int i = 0; i < sortedData.length(); i++) {
            leaderboardData.put(sortedData.getJSONObject(i));
        }
    }

    // Méthode pour mettre à jour le score d’un joueur
    public void updateScore(String name, int newScore) {
        for (int i = 0; i < leaderboardData.length(); i++) {
            JSONObject entry = leaderboardData.getJSONObject(i);
            if (entry.getString("name").equals(name)) {
                entry.put("score", newScore);
                break;
            }
        }
        // Retrier après mise à jour
        addPlayer("", 0); // Utiliser addPlayer pour retrier (astuce)
    }
}