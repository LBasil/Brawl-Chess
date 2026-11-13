# Brawl Chess

Prototype d'un jeu mobile d'échecs en 1 contre 1 où les pièces se battent. Le client est en Lua avec [LÖVE](https://love2d.org/), le serveur en Java.

Les règles des pièces (tour, mur, bouclier, sniper, kamikaze) sont dans `server/com/brawlchess/server/`. La version JavaScript est dans [BrawlChessJs](https://github.com/LBasil/BrawlChessJs).

## Lancer le serveur

Il faut le JDK et la bibliothèque `lib/json-20230227.jar`. Le serveur écoute sur le port 50000.

```bash
javac -cp lib/json-20230227.jar -d bin server/com/brawlchess/server/*.java
java -cp "lib/json-20230227.jar;bin" com.brawlchess.server.GameServer
```

Sous Linux et macOS, remplacer `;` par `:` dans le classpath.

## Lancer le client

```bash
love .
```

## Structure

- `main.lua`, `conf.lua` : point d'entrée LÖVE
- `src/components/` : plateau, avatar, combat, navigation, réseau, entrées
- `server/` : serveur de jeu et règles des pièces
- `config/pions.txt` : caractéristiques des pièces
- `cheatSheet.md` : mes notes sur Lua
