package com.brawlchess.server;

import org.json.JSONObject;

public class PieceRules {
    public static boolean isValidMove(String pieceName, JSONObject piece, int currentX, int currentY, int targetX, int targetY, String[][] board) {
        // Vérifier les limites du plateau
        if (targetX < 0 || targetX >= 8 || targetY < 0 || targetY >= 8) {
            return false;
        }
        // Vérifier si la case cible est vide
        if (board[targetX][targetY] != null) {
            return false;
        }
        // Vérifier si la case actuelle contient un pion
        if (board[currentX][currentY] == null) {
            return false;
        }

        // Calculer la distance de déplacement
        int dx = Math.abs(targetX - currentX);
        int dy = Math.abs(targetY - currentY);

        // Règles spécifiques selon le type de pion
        if (pieceName.equals("Tourelle")) {
            if (piece.getBoolean("hasMoved")) {
                return false;
            }
            return true; // Tourelle peut se déplacer n'importe où une fois
        } else if (pieceName.equals("Sniper") || pieceName.equals("Bouclier") || pieceName.equals("Kamikaze")) {
            if (piece.getBoolean("hasUsedAction")) {
                return false;
            }
            // Déplacement d'une case horizontalement ou verticalement
            return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
        } else if (pieceName.equals("Mur")) {
            if (piece.getBoolean("hasUsedAction")) {
                return false;
            }
            // Déplacement d'une case horizontalement ou verticalement
            return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
        } else if (pieceName.equals("Soldat")) {
            // Déplacement d'une case vers l'avant (y+1 pour l'ennemi)
            return targetX == currentX && targetY == currentY + 1;
        }
        return false;
    }

    public static JSONObject handleAction(String pieceName, String action, int pieceX, int pieceY, int targetX, int targetY, JSONObject piece, String[][] board, GameState gameState) {
        JSONObject response = new JSONObject();
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
                    board[targetX][targetY] = null;
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
                    board[targetX][targetY] = null;
                    gameState.removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
                }
                // Détruire le Kamikaze
                board[pieceX][pieceY] = null;
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
                if (direction.equals("vertical")) {
                    int startY = Math.max(0, pieceY - 1);
                    int endY = Math.min(7, pieceY + 1);
                    for (int y = startY; y <= endY; y++) {
                        if (board[pieceX][y] != null && (y != pieceY || !board[pieceX][y].equals("Mur"))) {
                            response.put("success", false);
                            response.put("error", "Cases occupées pour le mur");
                            return response;
                        }
                    }
                } else {
                    int startX = Math.max(0, pieceX - 1);
                    int endX = Math.min(7, pieceX + 1);
                    for (int x = startX; x <= endX; x++) {
                        if (board[x][pieceY] != null && (x != pieceX || !board[x][pieceY].equals("Mur"))) {
                            response.put("success", false);
                            response.put("error", "Cases occupées pour le mur");
                            return response;
                        }
                    }
                }
                piece.put("hasUsedAction", true);
                response.put("success", true);
            }
        } else {
            response.put("success", false);
            response.put("error", "Action non reconnue");
        }
        return response;
    }
}