import java.net.*;
import java.io.*;

public class GameServer {
    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(50000);
            System.out.println("Serveur démarré sur le port 50000");

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("Client connecté");

                PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
                String pions = "[{\"name\":\"Tourelle\",\"type\":\"simple\",\"x\":1,\"y\":1,\"hp\":3,\"maxHP\":3,\"range\":2,\"damage\":1}," +
                              "{\"name\":\"Soldat\",\"type\":\"simple\",\"x\":7,\"y\":7,\"hp\":3,\"maxHP\":3}]";
                out.println(pions);

                clientSocket.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}