package com.brawlchess.server;

import org.json.JSONObject;

/**
 * Tests des règles de déplacement, sans framework : le programme s'arrête avec un code
 * d'erreur si une vérification échoue. Lancé par la CI (voir le README).
 */
public class RulesTest {
    private static int failures = 0;
    private static int checks = 0;

    private static void check(String name, boolean condition) {
        checks++;
        if (!condition) {
            failures++;
            System.err.println("ECHEC : " + name);
        }
    }

    private static JSONObject piece(boolean hasMoved) {
        return new JSONObject().put("hasMoved", hasMoved);
    }

    /** Plateau 8x8 avec une pièce posée en (x, y). */
    private static String[][] boardWith(int x, int y) {
        String[][] board = new String[8][8];
        board[x][y] = "piece";
        return board;
    }

    private static boolean move(String name, boolean hasMoved, int x, int y, int tx, int ty, String[][] board) {
        return PieceRulesFactory.getRules(name).isValidMove(piece(hasMoved), x, y, tx, ty, board);
    }

    public static void main(String[] args) {
        // Sniper et Kamikaze : une case vers l'avant, une seule fois.
        for (String name : new String[] {"Sniper", "Kamikaze"}) {
            check(name + " avance d'une case", move(name, false, 3, 3, 3, 4, boardWith(3, 3)));
            check(name + " ne recule pas", !move(name, false, 3, 3, 3, 2, boardWith(3, 3)));
            check(name + " ne se déplace pas en diagonale", !move(name, false, 3, 3, 4, 4, boardWith(3, 3)));
            check(name + " ne saute pas deux cases", !move(name, false, 3, 3, 3, 5, boardWith(3, 3)));
            check(name + " ne joue qu'un déplacement", !move(name, true, 3, 3, 3, 4, boardWith(3, 3)));
        }

        // Bouclier et Mur : une case dans les quatre directions, pas en diagonale.
        for (String name : new String[] {"Bouclier", "Mur"}) {
            check(name + " va à droite", move(name, false, 3, 3, 4, 3, boardWith(3, 3)));
            check(name + " va en arrière", move(name, false, 3, 3, 3, 2, boardWith(3, 3)));
            check(name + " pas en diagonale", !move(name, false, 3, 3, 4, 4, boardWith(3, 3)));
            check(name + " pas sur place", !move(name, false, 3, 3, 3, 3, boardWith(3, 3)));
        }

        // La Tourelle ne bouge qu'une fois, partout où c'est libre.
        check("Tourelle : première case libre", move("Tourelle", false, 0, 0, 5, 5, boardWith(0, 0)));
        check("Tourelle : déjà déplacée", !move("Tourelle", true, 0, 0, 5, 5, boardWith(0, 0)));

        // Règles communes : hors du plateau, case occupée, case de départ vide.
        check("hors plateau (x)", !move("Bouclier", false, 7, 3, 8, 3, boardWith(7, 3)));
        check("hors plateau (y)", !move("Bouclier", false, 3, 0, 3, -1, boardWith(3, 0)));
        String[][] occupied = boardWith(3, 3);
        occupied[4][3] = "autre";
        check("case d'arrivée occupée", !move("Bouclier", false, 3, 3, 4, 3, occupied));
        check("case de départ vide", !move("Bouclier", false, 3, 3, 4, 3, new String[8][8]));

        // Le Mur est figé après avoir utilisé son action.
        JSONObject wall = piece(false).put("hasUsedWallInGame", true);
        check("Mur figé après son action",
            !PieceRulesFactory.getRules("Mur").isValidMove(wall, 3, 3, 4, 3, boardWith(3, 3)));

        // Type inconnu : aucune règle, donc aucun déplacement.
        check("pion inconnu refusé", !move("Inconnu", false, 3, 3, 3, 4, boardWith(3, 3)));

        // Action inconnue refusée proprement, sans exception.
        JSONObject response = PieceRulesFactory.getRules("Sniper")
            .handleAction("danser", 3, 3, 3, 4, piece(false), boardWith(3, 3), null);
        check("action inconnue : success=false", !response.getBoolean("success"));

        System.out.println(checks + " vérifications, " + failures + " échec(s)");
        if (failures > 0) System.exit(1);
    }
}
