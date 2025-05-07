import java.net.*;
import java.io.*;
import org.json.*;

public class GameServer {
    // Représentation du plateau (8x8)
    private static String[][] board = new String[8][8];

    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(50000);
            System.out.println("Serveur démarré sur le port 50000");

            // Initialiser le plateau avec les pions
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
                        String action = jsonRequest.getString("action");

                        if (action.equals("move")) {
                            // Traiter une requête de déplacement
                            JSONObject piece = jsonRequest.getJSONObject("piece");
                            JSONObject target = jsonRequest.getJSONObject("target");
                            String pieceName = piece.getString("name");
                            int currentX = piece.getInt("x") - 1; // Convertir en indice 0-based
                            int currentY = piece.getInt("y") - 1;
                            int targetX = target.getInt("x") - 1;
                            int targetY = target.getInt("y") - 1;

                            JSONObject response = new JSONObject();
                            if (isValidMove(currentX, currentY, targetX, targetY)) {
                                // Mettre à jour le plateau
                                board[targetX][targetY] = board[currentX][currentY];
                                board[currentX][currentY] = null;
                                response.put("success", true);
                                response.put("piece", new JSONObject()
                                    .put("name", pieceName)
                                    .put("x", targetX + 1) // Convertir en indice 1-based
                                    .put("y", targetY + 1));
                            } else {
                                response.put("success", false);
                                response.put("error", "Déplacement invalide : case cible non vide ou hors limites");
                            }
                            out.println(response.toString());
                            out.flush();
                            System.out.println("Réponse envoyée : " + response.toString());
                        } else {
                            // Réponse initiale (liste des pions)
                            String pions = "[{\"name\":\"Tourelle\",\"type\":\"simple\",\"x\":1,\"y\":1,\"hp\":3,\"maxHP\":3,\"range\":2,\"damage\":1}," +
                                          "{\"name\":\"Soldat\",\"type\":\"simple\",\"x\":7,\"y\":7,\"hp\":3,\"maxHP\":3}]";
                            out.println(pions);
                            out.flush();
                            System.out.println("Réponse envoyée : " + pions);
                        }
                    } catch (JSONException e) {
                        out.println("{\"success\":false,\"error\":\"Requête JSON invalide\"}");
                        out.flush();
                        System.out.println("Erreur JSON : " + e.getMessage());
                    }
                } else {
                    // Réponse initiale si aucune requête ou requête vide
                    String pions = "[{\"name\":\"Tourelle\",\"type\":\"simple\",\"x\":1,\"y\":1,\"hp\":3,\"maxHP\":3,\"range\":2,\"damage\":1}," +
                                  "{\"name\":\"Soldat\",\"type\":\"simple\",\"x\":7,\"y\":7,\"hp\":3,\"maxHP\":3}]";
                    out.println(pions);
                    out.flush();
                    System.out.println("Réponse envoyée (requête vide/null) : " + pions);
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
        // Placer les pions initiaux
        board[0][0] = "Tourelle"; // (1,1)
        board[6][6] = "Soldat";   // (7,7)
    }

    private static boolean isValidMove(int currentX, int currentY, int targetX, int targetY) {
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
        // Pour l'instant, tout déplacement vers une case vide est valide
        return true;
    }
}