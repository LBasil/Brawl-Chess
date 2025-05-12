local screens = {}

local views = {
    combat = require("src.views.combatMenu.combatMenu"),
    boutique = require("src.views.boutique.boutique"),
    collection = require("src.views.collection.collection"),
    social = require("src.views.social.social"),
    leaderboard = require("src.views.leaderboard.leaderboard")
}

function screens.load()
    for _, view in pairs(views) do
        view.load()
    end
end

function screens.update(dt, currentScreen)
    if views[currentScreen] then
        views[currentScreen].update(dt)
    end
end

function screens.draw(currentScreen)
    if views[currentScreen] then
        views[currentScreen].draw()
    end
end

function screens.mousepressed(x, y, button, currentScreen)
    if views[currentScreen] then
        views[currentScreen].mousepressed(x, y, button)
    end
end

return screens