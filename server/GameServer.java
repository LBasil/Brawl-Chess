import java.net.*;
import java.io.*;
import org.json.*;

public class GameServer {
    // Représentation du plateau (8x8)
    private static String[][] board = new String[8][8];
    private static JSONObject gameState = new JSONObject();

    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(50000);
            System.out.println("Serveur démarré sur le port 50000");

            // Initialiser le plateau avec les pions depuis le fichier
            initializeBoard();

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
                            if (isValidMove(pieceName, currentX, currentY, targetX, targetY)) {
                                // Mettre à jour le plateau
                                board[targetX][targetY] = board[currentX][currentY];
                                board[currentX][currentY] = null;
                                // Mettre à jour le gameState
                                updateGameState(pieceName, currentX + 1, currentY + 1, targetX + 1, targetY + 1, false);
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

                            JSONObject response = handleAction(pieceName, action, pieceX, pieceY, targetX, targetY);
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
                    out.println(gameState.getJSONArray("pions").toString());
                    out.flush();
                    System.out.println("Réponse envoyée (requête vide/null) : " + gameState.getJSONArray("pions").toString());
                }

                clientSocket.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void initializeBoard() {
        // Réinitialiser le plateau
        for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 8; j++) {
                board[i][j] = null;
            }
        }

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
                    board[x][y] = name;

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
            gameState.put("pions", pions);
        } catch (IOException e) {
            System.err.println("Erreur lors de la lecture de pions.txt : " + e.getMessage());
            System.exit(1); // Arrêter le programme si le fichier ne peut pas être lu
        } catch (NumberFormatException e) {
            System.err.println("Erreur de format dans pions.txt : " + e.getMessage());
            System.exit(1); // Arrêter si les données sont mal formatées
        }
    }

    private static boolean isValidMove(String pieceName, int currentX, int currentY, int targetX, int targetY) {
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

        // Trouver le pion dans gameState
        JSONObject piece = findPiece(pieceName, currentX + 1, currentY + 1);
        if (piece == null) {
            return false;
        }

        // Vérifier si le pion peut encore se déplacer
        if (pieceName.equals("Tourelle") && piece.getBoolean("hasMoved")) {
            return false;
        }
        if ((pieceName.equals("Sniper") || pieceName.equals("Mur")) && piece.getBoolean("hasUsedAction")) {
            return false;
        }

        // Règles de déplacement selon le type de pion
        if (pieceName.equals("Tourelle")) {
            // Tourelle : peut se déplacer sur n'importe quelle case vide (une fois)
            return true;
        } else if (pieceName.equals("Sniper") || pieceName.equals("Bouclier") || pieceName.equals("Kamikaze")) {
            // Sniper, Bouclier, Kamikaze : 1 case vers l'avant (y-1 pour joueur, y+1 pour ennemi)
            String pieceType = piece.getString("type");
            if (pieceType.equals("player")) {
                return targetX == currentX && targetY == currentY - 1;
            } else {
                return targetX == currentX && targetY == currentY + 1;
            }
        } else if (pieceName.equals("Mur")) {
            // Mur : 1 case dans toutes les directions
            int dx = Math.abs(targetX - currentX);
            int dy = Math.abs(targetY - currentY);
            return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
        } else {
            // Soldat (ennemi) : 1 case vers l'avant (y+1)
            return targetX == currentX && targetY == currentY + 1;
        }
    }

    private static JSONObject handleAction(String pieceName, String action, int pieceX, int pieceY, int targetX, int targetY) {
        JSONObject response = new JSONObject();
        JSONObject piece = findPiece(pieceName, pieceX + 1, pieceY + 1);
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
                JSONObject targetPiece = findPieceAt(targetX + 1, targetY + 1);
                if (targetPiece == null || targetPiece.getString("type").equals("player")) {
                    response.put("success", false);
                    response.put("error", "Cible invalide : doit être un ennemi");
                    return response;
                }
                int hp = targetPiece.getInt("hp") - 1;
                targetPiece.put("hp", hp);
                if (hp <= 0) {
                    board[targetX][targetY] = null;
                    removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
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
                JSONObject targetPiece = findPieceAt(targetX + 1, targetY + 1);
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
                JSONObject targetPiece = findPieceAt(targetX + 1, targetY + 1);
                if (targetPiece == null || targetPiece.getString("type").equals("player")) {
                    response.put("success", false);
                    response.put("error", "Cible invalide : doit être un ennemi");
                    return response;
                }
                int hp = targetPiece.getInt("hp") - 1;
                targetPiece.put("hp", hp);
                if (hp <= 0) {
                    board[targetX][targetY] = null;
                    removePiece(targetPiece.getString("name"), targetX + 1, targetY + 1);
                }
                // Détruire le Kamikaze
                board[pieceX][pieceY] = null;
                removePiece(pieceName, pieceX + 1, pieceY + 1);
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
                        if (board[pieceX][y] != null && (y != pieceY || !board[pieceX][y].equals("Mur"))) {
                            response.put("success", false);
                            response.put("error", "Cases occupées pour le mur");
                            return response;
                        }
                    }
                    for (int y = startY; y <= endY; y++) {
                        if (y != pieceY) {
                            board[pieceX][y] = "Wall";
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
                        if (board[x][pieceY] != null && (x != pieceX || !board[x][pieceY].equals("Mur"))) {
                            response.put("success", false);
                            response.put("error", "Cases occupées pour le mur");
                            return response;
                        }
                    }
                    for (int x = startX; x <= endX; x++) {
                        if (x != pieceX) {
                            board[x][pieceY] = "Wall";
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

    private static JSONObject findPiece(String name, int x, int y) {
        JSONArray pions = gameState.getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            if (piece.getString("name").equals(name) && piece.getInt("x") == x && piece.getInt("y") == y) {
                return piece;
            }
        }
        return null;
    }

    private static JSONObject findPieceAt(int x, int y) {
        JSONArray pions = gameState.getJSONArray("pions");
        for (int i = 0; i < pions.length(); i++) {
            JSONObject piece = pions.getJSONObject(i);
            if (piece.getInt("x") == x && piece.getInt("y") == y) {
                return piece;
            }
        }
        return null;
    }

    private static void updateGameState(String name, int oldX, int oldY, int newX, int newY, boolean remove) {
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

    private static void removePiece(String name, int x, int y) {
        updateGameState(name, x, y, x, y, true);
    }
}