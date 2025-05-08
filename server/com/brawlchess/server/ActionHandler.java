package com.brawlchess.server;

import org.json.JSONArray;
import org.json.JSONObject;

public class ActionHandler {
    public static JSONObject handleAction(String pieceName, String action, int pieceX, int pieceY, int targetX, int targetY, Board board, GameState gameState) {
        JSONObject response = new JSONObject();
        JSONObject piece = gameState.findPiece(pieceName, pieceX + 1, pieceY + 1);
        if (piece == null) {
            response.put("success", false);
            response.put("error", "Pion non trouvé");
            return response;
        }

        if (piece.getBoolean("hasUsedAction") && (pieceName.equals("Sniper") || pieceName.equals("Kamikaze") || pieceName.equals("Mur"))) {
            response.put("success", false);
            response.put("error", "Action déjà utilisée");
            return response;
        }

        if (pieceName.equals("Sniper")) {
            if (action.equals("attack")) {
                if (targetX < 0 || targetY < 0) {
                    response.put("success", false);
                    response.put("error", "Cible invalide");
                    return response;
                }
                JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
                if (targetPiece == null || targetPiece.getString("type").equals("player")) {
                    response.put("success", false);
                    response.put("error", "Cible invalide : doit être un ennemi");
                    return response;
                }
                int hp = targetPiece.getInt("hp") - 1;
                targetPiece.put("hp", hp);
                if (hp <= 0) {
                    board.getBoard()[targetX][targetY] = null;
                    gameState.removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
                }
                piece.put("hasUsedAction", true);
                response.put("success", true);
            }
        } else if (pieceName.equals("Bouclier")) {
            if (action.equals("shield")) {
                if (targetX < 0 || targetY < 0) {
                    response.put("success", false);
                    response.put("error", "Cible invalide");
                    return response;
                }
                JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
                if (targetPiece == null || targetPiece.getString("type").equals("enemy")) {
                    response.put("success", false);
                    response.put("error", "Cible invalide : doit être un allié");
                    return response;
                }
                targetPiece.put("shield", targetPiece.optInt("shield", 0) + 1);
                response.put("success", true);
            }
        } else if (pieceName.equals("Kamikaze")) {
            if (action.equals("attack")) {
                if (targetX < 0 || targetY < 0) {
                    response.put("success", false);
                    response.put("error", "Cible invalide");
                    return response;
                }
                int distance = Math.abs(pieceX - targetX) + Math.abs(pieceY - targetY);
                if (distance != 1) {
                    response.put("success", false);
                    response.put("error", "Cible trop loin : doit être à 1 case");
                    return response;
                }
                JSONObject targetPiece = gameState.findPieceAt(targetX + 1, targetY + 1);
                if (targetPiece == null || targetPiece.getString("type").equals("player")) {
                    response.put("success", false);
                    response.put("error", "Cible invalide : doit être un ennemi");
                    return response;
                }
                int hp = targetPiece.getInt("hp") - 1;
                targetPiece.put("hp", hp);
                if (hp <= 0) {
                    board.getBoard()[targetX][targetY] = null;
                    gameState.removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
                }
                // Détruire le Kamikaze
                board.getBoard()[pieceX][pieceY] = null;
                gameState.removePiece(pieceName, pieceX + 1, pieceY + 1);
                response.put("success", true);
            }
        } else if (pieceName.equals("Mur")) {
            if (action.equals("deploy")) {
                if (targetX < 0 || targetY < 0) {
                    response.put("success", false);
                    response.put("error", "Direction invalide");
                    return response;
                }
                String direction = targetX == pieceX ? "vertical" : "horizontal";
                JSONArray wallPieces = new JSONArray();
                if (direction.equals("vertical")) {
                    int startY = Math.max(0, pieceY - 1);
                    int endY = Math.min(7, pieceY + 1);
                    for (int y = startY; y <= endY; y++) {
                        if (board.getBoard()[pieceX][y] != null && (y != pieceY || !board.getBoard()[pieceX][y].equals("Mur"))) {
                            response.put("success", false);
                            response.put("error", "Cases occupées pour le mur");
                            return response;
                        }
                    }
                    for (int y = startY; y <= endY; y++) {
                        if (y != pieceY) {
                            board.getBoard()[pieceX][y] = "Wall";
                            wallPieces.put(new JSONObject()
                                .put("name", "Wall")
                                .put("type", "player")
                                .put("x", pieceX + 1)
                                .put("y", y + 1)
                                .put("hp", 1)
                                .put("maxHP", 1));
                        }
                    }
                } else {
                    int startX = Math.max(0, pieceX - 1);
                    int endX = Math.min(7, pieceX + 1);
                    for (int x = startX; x <= endX; x++) {
                        if (board.getBoard()[x][pieceY] != null && (x != pieceX || !board.getBoard()[x][pieceY].equals("Mur"))) {
                            response.put("success", false);
                            response.put("error", "Cases occupées pour le mur");
                            return response;
                        }
                    }
                    for (int x = startX; x <= endX; x++) {
                        if (x != pieceX) {
                            board.getBoard()[x][pieceY] = "Wall";
                            wallPieces.put(new JSONObject()
                                .put("name", "Wall")
                                .put("type", "player")
                                .put("x", x + 1)
                                .put("y", pieceY + 1)
                                .put("hp", 1)
                                .put("maxHP", 1));
                        }
                    }
                }
                piece.put("hasUsedAction", true);
                response.put("success", true);
                response.put("wallPieces", wallPieces);
            }
        } else {
            response.put("success", false);
            response.put("error", "Action non reconnue");
        }
        return response;
    }
}