package com.brawlchess.server;

import java.net.*;
import java.io.*;
import org.json.*;

public class GameServer {
    public static void main(String[] args) {
        GameState gameState = new GameState();
        Board board = new Board(gameState);

        try {
            ServerSocket serverSocket = new ServerSocket(50000);
            System.out.println("Serveur démarré sur le port 50000");

            // Initialiser le plateau avec les pions depuis le fichier
            BoardInitializer.initializeBoard(board, gameState);

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("Client connecté");

                // Lire la requête du client
                BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);

                String request = in.readLine();
                System.out.println("Requête reçue : '" + (request != null ? request : "null") + "'");
                if (request != null && !request.trim().isEmpty()) {
                    try {
                        JSONObject jsonRequest = new JSONObject(request);
                        String type = jsonRequest.getString("type");

                        if (type.equals("move")) {
                            // Traiter une requête de déplacement
                            JSONObject piece = jsonRequest.getJSONObject("piece");
                            JSONObject target = jsonRequest.getJSONObject("target");
                            String pieceName = piece.getString("name");
                            int currentX = piece.getInt("x") - 1; // Convertir en indice 0-based
                            int currentY = piece.getInt("y") - 1;
                            int targetX = target.getInt("x") - 1;
                            int targetY = target.getInt("y") - 1;

                            JSONObject response = new JSONObject();
                            if (board.isValidMove(pieceName, currentX, currentY, targetX, targetY)) {
                                // Mettre à jour le plateau
                                board.getBoard()[targetX][targetY] = board.getBoard()[currentX][currentY];
                                board.getBoard()[currentX][currentY] = null;
                                // Mettre à jour le gameState
                                gameState.updateGameState(pieceName, currentX + 1, currentY + 1, targetX + 1, targetY + 1, false);
                                response.put("success", true);
                                response.put("piece", new JSONObject()
                                    .put("name", pieceName)
                                    .put("x", targetX + 1) // Convertir en indice 1-based
                                    .put("y", targetY + 1));
                            } else {
                                response.put("success", false);
                                response.put("error", "Déplacement invalide");
                            }
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        } else if (type.equals("action")) {
                            // Traiter une action
                            JSONObject piece = jsonRequest.getJSONObject("piece");
                            JSONObject target = jsonRequest.optJSONObject("target");
                            String pieceName = piece.getString("name");
                            String action = jsonRequest.getString("action");
                            int pieceX = piece.getInt("x") - 1;
                            int pieceY = piece.getInt("y") - 1;
                            int targetX = target != null ? target.getInt("x") - 1 : -1;
                            int targetY = target != null ? target.getInt("y") - 1 : -1;

                            JSONObject response = ActionHandler.handleAction(pieceName, action, pieceX, pieceY, targetX, targetY, board, gameState);
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        }
                    } catch (JSONException e) {
                        out.println("{\"success\":false,\"error\":\"Requête JSON invalide\"}");
                        out.flush();
                        System.out.println("Erreur JSON : " + e.getMessage());
                    }
                } else {
                    // Réponse initiale si aucune requête ou requête vide
                    out.println(gameState.getGameState().getJSONArray("pions").toString());
                    out.flush();
                    System.out.println("Réponse envoyée (requête vide/null) : " + gameState.getGameState().getJSONArray("pions").toString());
                }

                clientSocket.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}