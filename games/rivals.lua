local UI = _G.FpsHubUI
local Utils = _G.FpsHubUtils
local FPS = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/hitboyxx23-dev/fps-hub@main/lib/fps.lua?v=" .. tick()))()

if not UI or not Utils or not FPS then
    warn("[FPS Hub] Libraries not available")
    return
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local window = UI.createWindow({
    title = "RIVALS MENU",
    subtitle = "rivals",
    width = 500,
    height = 420,
})

local left = window.createPanel("left")
local right = window.createPanel("right")

local state = {
    fly = Utils.createFly({ speed = 100 }),
    walkSpeed = 16,
    clickTP = false,
}

UI.createSectionLabel(right, "AIMBOT", 0)

local aimbotBtn, aimbotStroke = UI.createButton(right, "AIMBOT: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 16))
aimbotBtn.MouseButton1Click:Connect(function()
    if FPS.getState().aimbotEnabled then
        FPS.aimbotDisable()
        aimbotBtn.Text = "AIMBOT: OFF"
        UI.setButtonState(aimbotBtn, aimbotStroke, false)
    else
        FPS.aimbotEnable()
        aimbotBtn.Text = "AIMBOT: ON"
        UI.setButtonState(aimbotBtn, aimbotStroke, true)
    end
end)

local smoothLabel = Instance.new("TextLabel")
smoothLabel.Size = UDim2.new(1, 0, 0, 12)
smoothLabel.Position = UDim2.new(0, 0, 0, 46)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Text = "AIM SMOOTHNESS"
smoothLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothLabel.TextTransparency = 0.55
smoothLabel.TextScaled = true
smoothLabel.Font = Enum.Font.Gotham
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothLabel.Parent = right

local smoothFrame = Instance.new("Frame")
smoothFrame.Size = UDim2.new(1, 0, 0, 26)
smoothFrame.Position = UDim2.new(0, 0, 0, 60)
smoothFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
smoothFrame.BorderSizePixel = 0
smoothFrame.Parent = right

local sfc = Instance.new("UICorner")
sfc.CornerRadius = UDim.new(0, 8)
sfc.Parent = smoothFrame

local sfs = Instance.new("UIStroke")
sfs.Color = Color3.fromRGB(255, 255, 255)
sfs.Transparency = 0.7
sfs.Thickness = 1
sfs.Parent = smoothFrame

local smoothDown = Instance.new("TextButton")
smoothDown.Size = UDim2.new(0, 28, 1, 0)
smoothDown.Position = UDim2.new(0, 0, 0, 0)
smoothDown.BackgroundTransparency = 1
smoothDown.Text = "-"
smoothDown.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothDown.TextScaled = true
smoothDown.Font = Enum.Font.GothamBold
smoothDown.AutoButtonColor = false
smoothDown.Parent = smoothFrame

local smoothUp = Instance.new("TextButton")
smoothUp.Size = UDim2.new(0, 28, 1, 0)
smoothUp.Position = UDim2.new(1, -28, 0, 0)
smoothUp.BackgroundTransparency = 1
smoothUp.Text = "+"
smoothUp.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothUp.TextScaled = true
smoothUp.Font = Enum.Font.GothamBold
smoothUp.AutoButtonColor = false
smoothUp.Parent = smoothFrame

local smoothValue = Instance.new("TextLabel")
smoothValue.Size = UDim2.new(1, -56, 1, 0)
smoothValue.Position = UDim2.new(0, 28, 0, 0)
smoothValue.BackgroundTransparency = 1
smoothValue.Text = "15"
smoothValue.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothValue.TextScaled = true
smoothValue.Font = Enum.Font.GothamBold
smoothValue.Parent = smoothFrame

smoothUp.MouseButton1Click:Connect(function()
    local s = FPS.getState().aimSmoothness + 0.05
    if s > 1 then s = 1 end
    FPS.setAimSmoothness(s)
    smoothValue.Text = tostring(math.floor(s * 100))
end)

smoothDown.MouseButton1Click:Connect(function()
    local s = FPS.getState().aimSmoothness - 0.05
    if s < 0.05 then s = 0.05 end
    FPS.setAimSmoothness(s)
    smoothValue.Text = tostring(math.floor(s * 100))
end)

UI.createSectionLabel(right, "VISUALS", 96)

local espBtn, espStroke = UI.createButton(right, "ESP: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 112))
espBtn.MouseButton1Click:Connect(function()
    if FPS.getState().espEnabled then
        FPS.espDisable()
        espBtn.Text = "ESP: OFF"
        UI.setButtonState(espBtn, espStroke, false)
    else
        FPS.espEnable()
        espBtn.Text = "ESP: ON"
        UI.setButtonState(espBtn, espStroke, true)
    end
end)

UI.createSectionLabel(right, "ASSIST", 146)

local triggerBtn, triggerStroke = UI.createButton(right, "TRIGGERBOT: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 162))
triggerBtn.MouseButton1Click:Connect(function()
    if FPS.getState().triggerbotEnabled then
        FPS.triggerbotDisable()
        triggerBtn.Text = "TRIGGERBOT: OFF"
        UI.setButtonState(triggerBtn, triggerStroke, false)
    else
        FPS.triggerbotEnable()
        triggerBtn.Text = "TRIGGERBOT: ON"
        UI.setButtonState(triggerBtn, triggerStroke, true)
    end
end)

local teamBtn, teamStroke = UI.createButton(right, "TEAM CHECK: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 192))
teamBtn.MouseButton1Click:Connect(function()
    local new = not FPS.getState().teamCheck
    FPS.setTeamCheck(new)
    teamBtn.Text = new and "TEAM CHECK: ON" or "TEAM CHECK: OFF"
    UI.setButtonState(teamBtn, teamStroke, new)
end)

local wallBtn, wallStroke = UI.createButton(right, "WALL CHECK: ON", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 222))
UI.setButtonState(wallBtn, wallStroke, true)
wallBtn.MouseButton1Click:Connect(function()
    local new = not FPS.getState().wallCheck
    FPS.setWallCheck(new)
    wallBtn.Text = new and "WALL CHECK: ON" or "WALL CHECK: OFF"
    UI.setButtonState(wallBtn, wallStroke, new)
end)

UI.createSectionLabel(right, "MOVEMENT", 258)

local flyBtn, flyStroke = UI.createButton(right, "FLY: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 274))
flyBtn.MouseButton1Click:Connect(function()
    local on = state.fly:toggle()
    flyBtn.Text = on and "FLY: ON" or "FLY: OFF"
    UI.setButtonState(flyBtn, flyStroke, on)
end)

local walkLabel = Instance.new("TextLabel")
walkLabel.Size = UDim2.new(1, 0, 0, 12)
walkLabel.Position = UDim2.new(0, 0, 0, 304)
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "WALK SPEED"
walkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
walkLabel.TextTransparency = 0.55
walkLabel.TextScaled = true
walkLabel.Font = Enum.Font.Gotham
walkLabel.TextXAlignment = Enum.TextXAlignment.Left
walkLabel.Parent = right

local walkFrame = Instance.new("Frame")
walkFrame.Size = UDim2.new(1, 0, 0, 26)
walkFrame.Position = UDim2.new(0, 0, 0, 318)
walkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
walkFrame.BorderSizePixel = 0
walkFrame.Parent = right

local wfc = Instance.new("UICorner")
wfc.CornerRadius = UDim.new(0, 8)
wfc.Parent = walkFrame

local wfs = Instance.new("UIStroke")
wfs.Color = Color3.fromRGB(255, 255, 255)
wfs.Transparency = 0.7
wfs.Thickness = 1
wfs.Parent = walkFrame

local walkDown = Instance.new("TextButton")
walkDown.Size = UDim2.new(0, 28, 1, 0)
walkDown.Position = UDim2.new(0, 0, 0, 0)
walkDown.BackgroundTransparency = 1
walkDown.Text = "-"
walkDown.TextColor3 = Color3.fromRGB(255, 255, 255)
walkDown.TextScaled = true
walkDown.Font = Enum.Font.GothamBold
walkDown.AutoButtonColor = false
walkDown.Parent = walkFrame

local walkUp = Instance.new("TextButton")
walkUp.Size = UDim2.new(0, 28, 1, 0)
walkUp.Position = UDim2.new(1, -28, 0, 0)
walkUp.BackgroundTransparency = 1
walkUp.Text = "+"
walkUp.TextColor3 = Color3.fromRGB(255, 255, 255)
walkUp.TextScaled = true
walkUp.Font = Enum.Font.GothamBold
walkUp.AutoButtonColor = false
walkUp.Parent = walkFrame

local walkValue = Instance.new("TextLabel")
walkValue.Size = UDim2.new(1, -56, 1, 0)
walkValue.Position = UDim2.new(0, 28, 0, 0)
walkValue.BackgroundTransparency = 1
walkValue.Text = "16"
walkValue.TextColor3 = Color3.fromRGB(255, 255, 255)
walkValue.TextScaled = true
walkValue.Font = Enum.Font.GothamBold
walkValue.Parent = walkFrame

walkUp.MouseButton1Click:Connect(function()
    state.walkSpeed = math.clamp(state.walkSpeed + 5, 16, 200)
    walkValue.Text = tostring(state.walkSpeed)
    local hum = Utils.getHum()
    if hum then hum.WalkSpeed = state.walkSpeed end
end)

walkDown.MouseButton1Click:Connect(function()
    state.walkSpeed = math.clamp(state.walkSpeed - 5, 16, 200)
    walkValue.Text = tostring(state.walkSpeed)
    local hum = Utils.getHum()
    if hum then hum.WalkSpeed = state.walkSpeed end
end)

local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(1, 0, 0, 20)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "PLAYERS  0"
playersLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playersLabel.TextTransparency = 0.3
playersLabel.TextScaled = true
playersLabel.Font = Enum.Font.GothamBold
playersLabel.TextXAlignment = Enum.TextXAlignment.Left
playersLabel.Parent = left

local playerList = UI.createScrollList(left, UDim2.new(1, 0, 1, -28), UDim2.new(0, 0, 0, 28))

local function updatePlayerList()
    for _, c in pairs(playerList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local count = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character            if char and char.Parent then
                count = count + 1
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -8, 0, 28)
                row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                row.BorderSizePixel = 0
                row.LayoutOrder = count
                row.Parent = playerList

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = Color3.fromRGB(255, 255, 255)
                rs.Transparency = 0.6
                rs.Thickness = 1
                rs.Parent = row

                local nameBtn = Instance.new("TextButton")
                nameBtn.Size = UDim2.new(1, -8, 1, 0)
                nameBtn.BackgroundTransparency = 1
                nameBtn.Text = "  " .. plr.Name
                nameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameBtn.TextScaled = true
                nameBtn.Font = Enum.Font.Gotham
                nameBtn.TextXAlignment = Enum.TextXAlignment.Left
                nameBtn.AutoButtonColor = false
                nameBtn.Parent = row

                nameBtn.MouseButton1Click:Connect(function()
                    local root = Utils.getRoot()
                    local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        root.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 2)
                        window.notify("Teleported to " .. plr.Name)
                    end
                end)
            end
        end
    end
    playersLabel.Text = "PLAYERS  " .. tostring(count)
end

local playerRefreshConn = RunService.Heartbeat:Connect(function()
    updatePlayerList()
end)

local function isOverGui(mouseX, mouseY)
    local frame = window.frame
    if not frame or not frame.Visible then return false end
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return mouseX >= pos.X and mouseX <= pos.X + size.X and mouseY >= pos.Y and mouseY <= pos.Y + size.Y
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not state.clickTP then return end
    local mouseLoc = UserInputService:GetMouseLocation()
    if isOverGui(mouseLoc.X, mouseLoc.Y) then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local unitRay = camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local char = Utils.getChar()
    params.FilterDescendantsInstances = char and {char} or {}
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    if result then
        Utils.trueTeleport(CFrame.new(result.Position + Vector3.new(0, 3, 0)))
        window.notify("Teleported")
    end
end)

local function setupDeathProtection()
    local char = Utils.getChar()
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.Died:Connect(function()
        if state.fly:isFlying() then
            state.fly:stop()
            flyBtn.Text = "FLY: OFF"
            UI.setButtonState(flyBtn, flyStroke, false)
        end
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupDeathProtection()
end)

RunService.Heartbeat:Connect(function()
    if state.walkSpeed ~= 16 then
        local hum = Utils.getHum()
        if hum and hum.WalkSpeed ~= state.walkSpeed then
            hum.WalkSpeed = state.walkSpeed
        end
    end
end)

updatePlayerList()
setupDeathProtection()
