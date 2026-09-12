local Utils = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

function Utils.getLocalPlayer()
    return LocalPlayer
end

function Utils.getChar()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

function Utils.getRoot()
    local char = Utils.getChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function Utils.getHum()
    local char = Utils.getChar()
    if char then
        return char:FindFirstChild("Humanoid")
    end
    return nil
end

function Utils.getMouse()
    return LocalPlayer:GetMouse()
end

function Utils.getCamera()
    return Workspace.CurrentCamera
end

function Utils.getAlivePlayers()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char.Parent then
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(list, {
                        player = plr,
                        character = char,
                        humanoid = hum,
                        root = root,
                    })
                end
            end
        end
    end
    return list
end

function Utils.isVisible(targetPart)
    if not targetPart then return false end
    local camera = Workspace.CurrentCamera
    if not camera then return false end
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local char = Utils.getChar()
    params.FilterDescendantsInstances = char and {char} or {}
    local result = Workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

function Utils.worldToScreen(position)
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    local screenPoint, onScreen = camera:WorldToViewportPoint(position)
    if onScreen then
        return Vector2.new(screenPoint.X, screenPoint.Y)
    end
    return nil
end

function Utils.getNearestPlayer(maxDistance)
    maxDistance = maxDistance or math.huge
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = maxDistance
    for _, entry in pairs(Utils.getAlivePlayers()) do
        local screenPos = Utils.worldToScreen(entry.root.Position)
        if screenPos then
            local dist = (screenPos - mousePos).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = entry
            end
        end
    end
    return best, bestDist
end

function Utils.trueTeleport(cframe)
    local root = Utils.getRoot()
    if not root then return false end
    for _, v in pairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") or v:IsA("BodyForce") then
            v:Destroy()
        end
    end
    root.Velocity = Vector3.new(0, 0, 0)
    root.RotVelocity = Vector3.new(0, 0, 0)
    if root.AssemblyLinearVelocity then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    task.wait(0.05)
    root.CFrame = cframe
    root.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.05)
    return true
end

function Utils.createFly(config)
    config = config or {}
    local state = {
        flying = false,
        speed = config.speed or 100,
        acceleration = config.acceleration or 0.2,
        bodyVel = nil,
        bodyGyro = nil,
        conn = nil,
        velocity = Vector3.new(0, 0, 0),
        onChange = config.onChange or function() end,
    }

    local function start()
        if state.flying then return end
        local root = Utils.getRoot()
        local hum = Utils.getHum()
        if not root or not hum then return end
        state.flying = true
        hum.PlatformStand = true
        state.bodyVel = Instance.new("BodyVelocity")
        state.bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        state.bodyVel.Velocity = Vector3.new(0, 0, 0)
        state.bodyVel.P = 1250
        state.bodyVel.Parent = root
        state.bodyGyro = Instance.new("BodyGyro")
        state.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        state.bodyGyro.P = 1250
        state.bodyGyro.CFrame = root.CFrame
        state.bodyGyro.Parent = root
        state.conn = RunService.Heartbeat:Connect(function()
            if not state.flying then return end
            local r = Utils.getRoot()
            if not r or not state.bodyVel or not state.bodyGyro then return end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local move = Vector3.new(0, 0, 0)
            local fwd = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local UIS = game:GetService("UserInputService")
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - right end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + right end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * state.speed
            end
            state.velocity = state.velocity:Lerp(move, state.acceleration)
            state.bodyVel.Velocity = state.velocity
            state.bodyGyro.CFrame = CFrame.new(r.Position, r.Position + cam.CFrame.LookVector)
        end)
        state.onChange(true)
    end

    local function stop()
        if not state.flying then return end
        state.flying = false
        state.velocity = Vector3.new(0, 0, 0)
        if state.conn then state.conn:Disconnect() state.conn = nil end
        if state.bodyVel then state.bodyVel:Destroy() state.bodyVel = nil end
        if state.bodyGyro then state.bodyGyro:Destroy() state.bodyGyro = nil end
        local hum = Utils.getHum()
        if hum then hum.PlatformStand = false end
        state.onChange(false)
    end

    function state:start() start() end
    function state:stop() stop() end
    function state:toggle()
        if self.flying then stop() else start() end
        return self.flying
    end
    function state:setSpeed(v) self.speed = v end
    function state:isFlying() return self.flying end

    return state
end

return Utils
