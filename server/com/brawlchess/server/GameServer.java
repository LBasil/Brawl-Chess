package com.brawlchess.server;

import java.net.*;
import java.io.*;
import org.json.*;

public class GameServer {
    public static void main(String[] args) {
        GameState gameState = new GameState();
        Board board = new Board(gameState);
        TurnManager turnManager = new TurnManager();
        LeaderboardManager leaderboardManager = new LeaderboardManager();

        try {
            ServerSocket serverSocket = new ServerSocket(50000);
            System.out.println("Serveur démarré sur le port 50000");

            BoardInitializer.initializeBoard(board, gameState);

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("Client connecté");

                BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);

                String request = in.readLine();
                System.out.println("Requête reçue : '" + (request != null ? request : "null") + "'");
                if (request != null && !request.trim().isEmpty()) {
                    try {
                        JSONObject jsonRequest = new JSONObject(request);
                        String type = jsonRequest.getString("type");

                        if (type.equals("move")) {
                            JSONObject piece = jsonRequest.getJSONObject("piece");
                            JSONObject target = jsonRequest.getJSONObject("target");
                            String pieceName = piece.getString("name");
                            int currentX = piece.getInt("x") - 1;
                            int currentY = piece.getInt("y") - 1;
                            int targetX = target.getInt("x") - 1;
                            int targetY = target.getInt("y") - 1;

                            JSONObject response = new JSONObject();
                            if (!turnManager.isPlayerTurn()) {
                                response.put("success", false);
                                response.put("error", "Ce n'est pas votre tour");
                            } else {
                                if (board.isValidMove(pieceName, currentX, currentY, targetX, targetY)) {
                                    JSONObject existingPiece = gameState.findPiece(pieceName, currentX + 1, currentY + 1);
                                    int currentHp = existingPiece.getInt("hp");
                                    board.getBoard()[targetX][targetY] = board.getBoard()[currentX][currentY];
                                    board.getBoard()[currentX][currentY] = null;
                                    gameState.updateGameState(pieceName, currentX + 1, currentY + 1, targetX + 1, targetY + 1, false);
                                    JSONObject movedPiece = gameState.findPiece(pieceName, targetX + 1, targetY + 1);
                                    movedPiece.put("hp", currentHp);
                                    response.put("success", true);
                                    response.put("piece", new JSONObject()
                                        .put("name", pieceName)
                                        .put("x", targetX + 1)
                                        .put("y", targetY + 1)
                                        .put("hp", currentHp));
                                    turnManager.switchTurn();
                                    resetPieceFlags(gameState);
                                    if (turnManager.isPlayerTurn()) {
                                        handleTowerAutomaticAction(gameState, board);
                                    }
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                    response.put("pions", gameState.getGameState().getJSONArray("pions"));
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
                                    turnManager.switchTurn();
                                    resetPieceFlags(gameState);
                                    if (turnManager.isPlayerTurn()) {
                                        handleTowerAutomaticAction(gameState, board);
                                    }
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                    response.put("pions", gameState.getGameState().getJSONArray("pions"));
                                } else {
                                    response.put("currentTurn", turnManager.getCurrentTurn());
                                }
                            }
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        } else if (type.equals("endEnemyTurn")) {
                            JSONObject response = new JSONObject();
                            if (turnManager.getCurrentTurn().equals("enemy")) {
                                turnManager.switchTurn();
                                resetPieceFlags(gameState);
                                handleTowerAutomaticAction(gameState, board);
                                response.put("success", true);
                            } else {
                                response.put("success", false);
                                response.put("error", "Ce n'est pas le tour de l'ennemi");
                            }
                            response.put("currentTurn", turnManager.getCurrentTurn());
                            response.put("pions", gameState.getGameState().getJSONArray("pions"));
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        } else if (type.equals("leaderboard")) {
                            JSONObject response = new JSONObject();
                            response.put("scores", leaderboardManager.getLeaderboard());
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée (leaderboard) : " + response.toString());
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
                    JSONObject response = new JSONObject();
                    response.put("pions", gameState.getGameState().getJSONArray("pions"));
                    response.put("currentTurn", turnManager.getCurrentTurn());
                    handleTowerAutomaticAction(gameState, board);
                    response.put("pions", gameState.getGameState().getJSONArray("pions"));
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

    private static void resetPieceFlags(GameState gameState) {
        JSONArray pions = gameState.getGameState().getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            piece.put("hasMoved", false);
            piece.put("hasUsedAction", false);
        }
    }

    private static void handleTowerAutomaticAction(GameState gameState, Board board) {
        JSONArray pions = gameState.getGameState().getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            String pieceName = piece.getString("name");
            if (pieceName.equals("Tourelle") && piece.getString("type").equals("player") && piece.getInt("hp") > 0 && !piece.getBoolean("hasUsedAction")) {
                int pieceX = piece.getInt("x") - 1;
                int pieceY = piece.getInt("y") - 1;
                System.out.println("Vérification Tourelle à (" + (pieceX + 1) + "," + (pieceY + 1) + ") avec HP: " + piece.getInt("hp"));
                int[][] directions = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}};
                for (int[] dir : directions) {
                    int targetX = pieceX + dir[0];
                    int targetY = pieceY + dir[1];
                    if (targetX >= 0 && targetX < 8 && targetY >= 0 && targetY < 8) {
                        JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
                        if (targetPiece != null && targetPiece.getString("type").equals("enemy") && targetPiece.getInt("hp") > 0) {
                            System.out.println("Tourelle trouve un ennemi à (" + (targetX + 1) + "," + (targetY + 1) + ")");
                            PieceRules rules = PieceRulesFactory.getRules(pieceName);
                            JSONObject response = rules.handleAction("attack", pieceX, pieceY, targetX, targetY, piece, board.getBoard(), gameState);
                            if (response.getBoolean("success")) {
                                System.out.println("Tourelle attaque automatiquement un ennemi à (" + (targetX + 1) + "," + (targetY + 1) + ")");
                            } else {
                                System.out.println("Échec de l'attaque automatique : " + response.optString("error", "raison inconnue"));
                            }
                            return;
                        }
                    }
                }
                System.out.println("Aucun ennemi trouvé à 1 case de la Tourelle.");
            }
        }
    }
}