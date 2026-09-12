local FPS = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local state = {
    espEnabled = false,
    aimbotEnabled = false,
    silentAimEnabled = false,
    triggerbotEnabled = false,
    teamCheck = false,
    wallCheck = true,
    wallbangEnabled = false,
    noclipEnabled = false,
    invincibleEnabled = false,
    fovCircle = nil,
    fovRadius = 150,
    aimSmoothness = 0.15,
    triggerDelay = 0.1,
    lastTrigger = 0,
    espCache = {},
    silentAimConn = nil,
    aimbotConn = nil,
    triggerbotConn = nil,
    fovConn = nil,
    noclipConn = nil,
    invincibleConn = nil,
}

local function getLocalPlayer()
    return LocalPlayer
end

local function isTeammate(plr)
    if not state.teamCheck then return false end
    local localPlr = getLocalPlayer()
    if not localPlr or not plr then return false end
    if plr.Team and localPlr.Team then
        return plr.Team == localPlr.Team
    end
    return false
end

local function isVisible(targetPart)
    if state.wallbangEnabled then return true end
    if not state.wallCheck then return true end
    if not targetPart then return false end
    local camera = Workspace.CurrentCamera
    if not camera then return false end
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local char = LocalPlayer.Character
    params.FilterDescendantsInstances = char and {char} or {}
    local result = Workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function getTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = state.fovRadius

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not isTeammate(plr) then
            local char = plr.Character
            if char and char.Parent then
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if hum and hum.Health > 0 and root and head then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screen2D = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (screen2D - center).Magnitude
                        if dist < bestDist then
                            if isVisible(head) then
                                bestDist = dist
                                best = { player = plr, character = char, humanoid = hum, root = root, head = head }
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function getAimPosition(target)
    if not target or not target.head then return nil end
    return target.head.Position
end

function FPS.espEnable()
    if state.espEnabled then return end
    state.espEnabled = true
    for _, plr in pairs(Players:GetPlayers()) do
        FPS.espUpdate(plr)
    end
end

function FPS.espDisable()
    state.espEnabled = false
    for plr, highlight in pairs(state.espCache) do
        if highlight then highlight:Destroy() end
    end
    state.espCache = {}
end

function FPS.espUpdate(plr)
    if not state.espEnabled then return end
    if plr == LocalPlayer then return end
    if isTeammate(plr) then
        if state.espCache[plr] then
            state.espCache[plr]:Destroy()
            state.espCache[plr] = nil
        end
        return
    end
    local char = plr.Character
    if not char or not char.Parent then
        if state.espCache[plr] then
            state.espCache[plr]:Destroy()
            state.espCache[plr] = nil
        end
        return
    end
    if state.espCache[plr] and state.espCache[plr].Parent then
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "FpsHubESP"
    highlight.FillColor = Color3.fromRGB(255, 80, 80)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = game:GetService("CoreGui")
    state.espCache[plr] = highlight
end

function FPS.aimbotEnable()
    if state.aimbotEnabled then return end
    state.aimbotEnabled = true
    state.aimbotConn = RunService.RenderStepped:Connect(function()
        if not state.aimbotEnabled then return end
        local target = getTarget()
        if not target then return end
        local aimPos = getAimPosition(target)
        if not aimPos then return end
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local current = camera.CFrame
        local desired = CFrame.lookAt(current.Position, aimPos)
        camera.CFrame = current:Lerp(desired, state.aimSmoothness)
    end)
end

function FPS.aimbotDisable()
    state.aimbotEnabled = false
    if state.aimbotConn then
        state.aimbotConn:Disconnect()
        state.aimbotConn = nil
    end
end

function FPS.silentAimEnable()
    if state.silentAimEnabled then return end
    state.silentAimEnabled = true
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if state.silentAimEnabled and self == LocalPlayer:GetMouse() and (key == "Hit" or key == "Target") then
            local target = getTarget()
            if target then
                local aimPos = getAimPosition(target)
                if aimPos then
                    if key == "Hit" then
                        return aimPos
                    else
                        return target.head
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
    state.silentAimConn = oldIndex
end

function FPS.silentAimDisable()
    state.silentAimEnabled = false
end

function FPS.triggerbotEnable()
    if state.triggerbotEnabled then return end
    state.triggerbotEnabled = true
    state.triggerbotConn = RunService.RenderStepped:Connect(function()
        if not state.triggerbotEnabled then return end
        local now = tick()
        if now - state.lastTrigger < state.triggerDelay then return end
        local target = getTarget()
        if not target then return end
        local aimPos = getAimPosition(target)
        if not aimPos then return end
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
        if onScreen then
            local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < 5 then
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton1(Vector2.new(screenPos.X, screenPos.Y))
                state.lastTrigger = now
            end
        end
    end)
end

function FPS.triggerbotDisable()
    state.triggerbotEnabled = false
    if state.triggerbotConn then
        state.triggerbotConn:Disconnect()
        state.triggerbotConn = nil
    end
end

function FPS.fovEnable(radius)
    FPS.fovDisable()
    state.fovRadius = radius or 150
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local drawing = Drawing.new("Circle")
    drawing.Visible = true
    drawing.Thickness = 1
    drawing.NumSides = 64
    drawing.Radius = state.fovRadius
    drawing.Color = Color3.fromRGB(255, 255, 255)
    drawing.Transparency = 0.7
    drawing.Filled = false
    drawing.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    state.fovCircle = drawing
    state.fovConn = RunService.RenderStepped:Connect(function()
        if state.fovCircle and camera then
            state.fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            state.fovCircle.Radius = state.fovRadius
        end
    end)
end

function FPS.fovDisable()
    if state.fovCircle then
        state.fovCircle:Remove()
        state.fovCircle = nil
    end
    if state.fovConn then
        state.fovConn:Disconnect()
        state.fovConn = nil
    end
end

function FPS.noclipEnable()
    if state.noclipEnabled then return end
    state.noclipEnabled = true
    state.noclipConn = RunService.Stepped:Connect(function()
        if not state.noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

function FPS.noclipDisable()
    state.noclipEnabled = false
    if state.noclipConn then
        state.noclipConn:Disconnect()
        state.noclipConn = nil
    end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part.CanCollide then
            pcall(function() part.CanCollide = true end)
        end
    end
end

function FPS.invincibleEnable()
    if state.invincibleEnabled then return end
    state.invincibleEnabled = true
    state.invincibleConn = RunService.Heartbeat:Connect(function()
        if not state.invincibleEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
            hum.BreakJointsOnDeath = false
        end
        if not char:FindFirstChild("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Parent = char
            task.delay(0.1, function()
                if ff and ff.Parent then ff:Destroy() end
            end)
        end
    end)
end

function FPS.invincibleDisable()
    state.invincibleEnabled = false
    if state.invincibleConn then
        state.invincibleConn:Disconnect()
        state.invincibleConn = nil
    end
end

function FPS.setFovRadius(radius) state.fovRadius = radius end
function FPS.setAimSmoothness(value) state.aimSmoothness = value end
function FPS.setTriggerDelay(value) state.triggerDelay = value end
function FPS.setTeamCheck(value) state.teamCheck = value end
function FPS.setWallCheck(value) state.wallCheck = value end

function FPS.setWallbang(value)
    state.wallbangEnabled = value
    if value then
        state.wallCheck = false
    end
end

function FPS.getState() return state end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        FPS.espUpdate(plr)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if state.espCache[plr] then
        state.espCache[plr]:Destroy()
        state.espCache[plr] = nil
    end
end)

return FPS
