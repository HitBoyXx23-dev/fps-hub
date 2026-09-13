local REPO_OWNER = "hitboyxx23-dev"
local REPO_NAME = "fps-hub"
local BRANCH = "main"
local CACHE_BUST = "?v=" .. tostring(os.time())
local BASE_URL = "https://cdn.jsdelivr.net/gh/" .. REPO_OWNER .. "/" .. REPO_NAME .. "@" .. BRANCH .. "/"
local SELF_URL = "https://cdn.jsdelivr.net/gh/" .. REPO_OWNER .. "/" .. REPO_NAME .. "@" .. BRANCH .. "/main.lua"
local PURGE_URL = "https://purge.jsdelivr.net/gh/" .. REPO_OWNER .. "/" .. REPO_NAME .. "@" .. BRANCH .. "/main.lua"

pcall(function()
    game:HttpGet(PURGE_URL, true)
end)

local function queueOnTeleport()
    local code = 'loadstring(game:HttpGet("' .. SELF_URL .. '?v=" .. tick()))()'
    pcall(function()
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(code)
        elseif queue_on_teleport then
            queue_on_teleport(code)
        elseif fluxus and fluxus.queue_on_teleport then
            fluxus.queue_on_teleport(code)
        elseif krnl and krnl.queue_on_teleport then
            krnl.queue_on_teleport(code)
        end
    end)
end

queueOnTeleport()

local GAME_IDS = {
    [17625359962] = "rivals",
}

local GAME_NAMES = {
    [17625359962] = "rivals",
}

local FALLBACK = "generic"

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

local gameId = game.PlaceId
local gameFile = GAME_IDS[gameId] or FALLBACK
local displayName = GAME_NAMES[gameId] or "generic mode"

local function fetch(path)
    local url = BASE_URL .. path .. CACHE_BUST
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not result then
        warn("[FPS Hub] HTTP failed for " .. path .. ": " .. tostring(result))
        return nil
    end
    if result:lower():find("404: not found") or result:lower():find("couldn't find") then
        warn("[FPS Hub] 404 for " .. path)
        return nil
    end
    return result
end

local function run(path)
    local source = fetch(path)
    if not source then return nil end
    local fn, compileErr = loadstring(source)
    if not fn then
        warn("[FPS Hub] Compile error in " .. path .. ": " .. tostring(compileErr))
        return nil
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("[FPS Hub] Runtime error in " .. path .. ": " .. tostring(result))
        return nil
    end
    return result
end

local uiModule = run("lib/ui.lua")
local utilsModule = run("lib/utils.lua")
local fpsModule = run("lib/fps.lua")

if not uiModule then
    notify("FPS Hub", "Failed to load UI library")
    return
end

if not utilsModule then
    notify("FPS Hub", "Failed to load utils library")
    return
end

if not fpsModule then
    notify("FPS Hub", "Failed to load FPS library")
    return
end

_G.FpsHubUI = uiModule
_G.FpsHubUtils = utilsModule
_G.FpsHubFPS = fpsModule
_G.FpsHubLoaded = true
_G.FpsHubGameId = gameId
_G.FpsHubGameFile = gameFile
_G.FpsHubDisplayName = displayName

local loaded = run("games/" .. gameFile .. ".lua")

if not loaded then
    notify("FPS Hub", "Failed to load " .. gameFile)
    return
end

if gameFile == FALLBACK then
    notify("FPS Hub", "Generic menu loaded")
else
    notify("FPS Hub", "Loaded: " .. displayName)
end

print("[FPS Hub] Loaded " .. gameFile .. " (" .. tostring(gameId) .. ")")
