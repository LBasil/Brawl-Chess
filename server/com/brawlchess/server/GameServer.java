package com.brawlchess.server;

import java.net.*;
import java.io.*;
import org.json.*;

public class GameServer {
    public static void main(String[] args) {
        GameState gameState = new GameState();
        Board board = new Board(gameState);
        TurnManager turnManager = new TurnManager();

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
                            if (!turnManager.isPlayerTurn()) {
                                response.put("success", false);
                                response.put("error", "Ce n'est pas votre tour");
                            } else {
                                if (board.isValidMove(pieceName, currentX, currentY, targetX, targetY)) {
                                    // Mettre à jour le plateau
                                    board.getBoard()[targetX][targetY] = board.getBoard()[currentX][currentY];
                                    board.getBoard()[currentX][currentY] = null;
                                    // Mettre à jour le gameState
                                    gameState.updateGameState(pieceName, currentX + 1, currentY + 1, targetX + 1, targetY + 1, false);
                                    response.put("success", true);
                                    response.put("piece", new JSONObject()
                                        .put("name", pieceName)
                                        .put("x", targetX + 1)
                                        .put("y", targetY + 1));
                                    // Passer au tour suivant
                                    turnManager.switchTurn();
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                } else {
                                    response.put("success", false);
                                    response.put("error", "Déplacement invalide");
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                }
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

                            JSONObject response = new JSONObject();
                            if (!turnManager.isPlayerTurn()) {
                                response.put("success", false);
                                response.put("error", "Ce n'est pas votre tour");
                            } else {
                                response = ActionHandler.handleAction(pieceName, action, pieceX, pieceY, targetX, targetY, board, gameState);
                                if (response.getBoolean("success")) {
                                    // Passer au tour suivant
                                    turnManager.switchTurn();
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                } else {
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                }
                            }
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        } else if (type.equals("endEnemyTurn")) {
                            // L'ennemi passe son tour
                            JSONObject response = new JSONObject();
                            if (turnManager.getCurrentTurn().equals("enemy")) {
                                turnManager.switchTurn();
                                response.put("success", true);
                            } else {
                                response.put("success", false);
                                response.put("error", "Ce n'est pas le tour de l'ennemi");
                            }
                            response.put("currentTurn", turnManager.getCurrentTurn());
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        }
                    } catch (JSONException e) {
                        JSONObject response = new JSONObject();
                        response.put("success", false);
                        response.put("error", "Requête JSON invalide");
                        response.put("currentTurn", turnManager.getCurrentTurn());
                        out.println(response.toString());
                        out.flush();
                        System.out.println("Erreur JSON : " + e.getMessage());
                    }
                } else {
                    // Réponse initiale si aucune requête ou requête vide
                    JSONObject response = new JSONObject();
                    response.put("pions", gameState.getGameState().getJSONArray("pions"));
                    response.put("currentTurn", turnManager.getCurrentTurn());
                    out.println(response.toString());
                    out.flush();
                    System.out.println("Réponse envoyée (requête vide/null) : " + response.toString());
                }

                clientSocket.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}