# 📘 Lua Cheat Sheet

---

## 🧮 Longueur d'une table : `#table`

```lua
local buttons = { "A", "B", "X", "Y" }
print(#buttons)  -- Affiche 4
```

- `#` donne **le nombre d’éléments indexés** (commençant à 1).
- ⚠️ Ne fonctionne pas bien si les index ne sont pas continus (ex : trous dans la table).

---

## 🔁 Boucles

### ➤ `for i = 1, N do ... end` — Boucle numérique simple

```lua
for i = 1, 5 do
  print(i)
end
```

- Démarre à `1`, s’arrête à `5`, inclusivement.

### ➤ `for _, value in ipairs(table) do ... end` — Boucle sur table indexée

```lua
local fruits = { "pomme", "banane", "cerise" }

for _, fruit in ipairs(fruits) do
  print(fruit)
end
```

- `_` : On ignore l’index.
- `ipairs()` : Parcours dans l’ordre les **valeurs indexées** (1, 2, 3, ...).

### ➤ `for key, value in pairs(table) do ... end` — Boucle sur table clé/valeur

```lua
local joueur = {
  nom = "Léo",
  vie = 100,
  niveau = 5
}

for k, v in pairs(joueur) do
  print(k, v)
end
```

- Utilisé pour les **dictionnaires** (tables non indexées ou mélangées).

---

## 🔀 Conditions : `if / elseif / else / end`

```lua
local vie = 80

if vie > 90 then
  print("En pleine forme !")
elseif vie > 50 then
  print("Encore bon.")
else
  print("En danger.")
end
```

- **Pas de `()` autour des conditions.**
- **Pas de `{}` : on termine par `end`.**

---

## 🧱 Fonctions

```lua
function addition(a, b)
  return a + b
end

print(addition(2, 3))  -- 5
```

- `function nom(params) ... end`
- Peut être stockée dans une variable (comme les fonctions anonymes JS).

---

## 🧰 Table = tableau + objet

```lua
local joueur = {
  nom = "Léo",
  vie = 100
}

print(joueur.nom)      -- "Léo"
print(joueur["vie"])   -- 100
```

- Accès avec `.` ou `["key"]`.
- Peut contenir tout : fonctions, booléens, sous-tables...

---

## 🖼️ Le mot-clé `draw` (dans les jeux)

```lua
function love.draw()
  love.graphics.print("Hello World", 100, 100)
end
```

- Pas un mot réservé de Lua, mais utilisé dans les moteurs comme LÖVE2D, Solar2D...
- Appelé automatiquement par le moteur pour afficher à l’écran.

---

## 🗂️ Modules et `require`

```lua
local utils = require("mon_module")

utils.fonctionUtilitaire()
```

- `require("fichier")` charge un module `.lua`.
- Le fichier doit **retourner une table**.

---

## ✅ Boolean & Comparateurs

| Opérateur Lua | Signification JS équivalente |
|---------------|------------------------------|
| `==`          | `===`                        |
| `~=`          | `!==`                        |
| `and`         | `&&`                         |
| `or`          | `||`                         |
| `not`         | `!`                          |

```lua
if not isDead and vie > 0 then
  print("Toujours vivant")
end
```

---

## 🧠 Petit mémo VS JavaScript

| JavaScript           | Lua                   |
|----------------------|-----------------------|
| `let x = 5`          | `local x = 5`         |
| `if (x > 0) {}`      | `if x > 0 then ... end` |
| `array.length`       | `#array`              |
| `for (i = 0; ...)`   | `for i = 1, ... do`   |
| `obj.key`            | `table.key`           |
| `===` / `!==`        | `==` / `~=`           |
| `function() {}`      | `function() end`      |


