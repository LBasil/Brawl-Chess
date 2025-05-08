package com.brawlchess.server;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import org.json.JSONArray;
import org.json.JSONObject;

public class BoardInitializer {
    public static void initializeBoard(Board board, GameState gameState) {
        // Charger les pions depuis pions.txt
        try (BufferedReader reader = new BufferedReader(new FileReader("pions.txt"))) {
            String line;
            JSONArray pions = new JSONArray();
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 5) { // Minimum : name,type,x,y,hp
                    String name = parts[0].trim();
                    String type = parts[1].trim();
                    int x = Integer.parseInt(parts[2].trim()) - 1; // Convertir en indice 0-based
                    int y = Integer.parseInt(parts[3].trim()) - 1;
                    int hp = Integer.parseInt(parts[4].trim());
                    int maxHP = parts.length > 5 && !parts[5].trim().isEmpty() ? Integer.parseInt(parts[5].trim()) : hp;
                    int range = parts.length > 6 && !parts[6].trim().isEmpty() ? Integer.parseInt(parts[6].trim()) : 0;
                    int damage = parts.length > 7 && !parts[7].trim().isEmpty() ? Integer.parseInt(parts[7].trim()) : 0;
                    boolean hasMoved = parts.length > 8 && !parts[8].trim().isEmpty() ? Integer.parseInt(parts[8].trim()) == 1 : false;
                    boolean hasUsedAction = parts.length > 9 && !parts[9].trim().isEmpty() ? Integer.parseInt(parts[9].trim()) == 1 : false;
                    int shield = parts.length > 10 && !parts[10].trim().isEmpty() ? Integer.parseInt(parts[10].trim()) : 0;

                    // Placer le pion sur le plateau
                    board.getBoard()[x][y] = name;

                    // Ajouter au gameState
                    JSONObject piece = new JSONObject();
                    piece.put("name", name);
                    piece.put("type", type);
                    piece.put("x", x + 1); // Convertir en indice 1-based
                    piece.put("y", y + 1);
                    piece.put("hp", hp);
                    piece.put("maxHP", maxHP);
                    if (range > 0) piece.put("range", range);
                    if (damage > 0) piece.put("damage", damage);
                    piece.put("hasMoved", hasMoved);
                    piece.put("hasUsedAction", hasUsedAction);
                    if (shield > 0) piece.put("shield", shield);
                    pions.put(piece);
                }
            }
            gameState.getGameState().put("pions", pions);
        } catch (IOException e) {
            System.err.println("Erreur lors de la lecture de pions.txt : " + e.getMessage());
            System.exit(1);
        } catch (NumberFormatException e) {
            System.err.println("Erreur de format dans pions.txt : " + e.getMessage());
            System.exit(1);
        }
    }
}