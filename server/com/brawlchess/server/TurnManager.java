package com.brawlchess.server;

public class TurnManager {
    private String currentTurn;

    public TurnManager() {
        this.currentTurn = "player"; // Le joueur commence
    }

    public String getCurrentTurn() {
        return currentTurn;
    }

    public void switchTurn() {
        currentTurn = currentTurn.equals("player") ? "enemy" : "player";
    }

    public boolean isPlayerTurn() {
        return currentTurn.equals("player");
    }
}