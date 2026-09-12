local UI = _G.FpsHubUI
local Utils = _G.FpsHubUtils
local FPS = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/hitboyxx23-dev/fps-hub@main/lib/fps.lua?v=" .. tick()))()

if not UI or not Utils or not FPS then
    warn("[FPS Hub] Libraries not available")
    return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local window = UI.createWindow({
    title = "FPS MENU",
    subtitle = "generic mode",
    width = 500,
    height = 380,
})

local right = window.createPanel("right")
local left = window.createPanel("left")

UI.createSectionLabel(right, "AIMBOT", 0)

local aimbotBtn, aimbotStroke = UI.createButton(right, "AIMBOT: OFF", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 16))
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

local wallbangBtn, wallbangStroke = UI.createButton(right, "WALLBANG: OFF", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 48))
wallbangBtn.MouseButton1Click:Connect(function()
    local new = not FPS.getState().wallbangEnabled
    FPS.setWallbang(new)
    wallbangBtn.Text = new and "WALLBANG: ON" or "WALLBANG: OFF"
    UI.setButtonState(wallbangBtn, wallbangStroke, new)
end)

UI.createSectionLabel(right, "VISUALS", 88)

local espBtn, espStroke = UI.createButton(right, "ESP: OFF", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 104))
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

UI.createSectionLabel(right, "SURVIVAL", 144)

local noclipBtn, noclipStroke = UI.createButton(right, "NOCLIP: OFF", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 160))
noclipBtn.MouseButton1Click:Connect(function()
    if FPS.getState().noclipEnabled then
        FPS.noclipDisable()
        noclipBtn.Text = "NOCLIP: OFF"
        UI.setButtonState(noclipBtn, noclipStroke, false)
    else
        FPS.noclipEnable()
        noclipBtn.Text = "NOCLIP: ON"
        UI.setButtonState(noclipBtn, noclipStroke, true)
    end
end)

local invBtn, invStroke = UI.createButton(right, "INVINCIBLE: OFF", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 192))
invBtn.MouseButton1Click:Connect(function()
    if FPS.getState().invincibleEnabled then
        FPS.invincibleDisable()
        invBtn.Text = "INVINCIBLE: OFF"
        UI.setButtonState(invBtn, invStroke, false)
    else
        FPS.invincibleEnable()
        invBtn.Text = "INVINCIBLE: ON"
        UI.setButtonState(invBtn, invStroke, true)
    end
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
        if plr ~= Players.LocalPlayer and plr.Character and plr.Character.Parent then
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
    playersLabel.Text = "PLAYERS  " .. tostring(count)
end

RunService.Heartbeat:Connect(updatePlayerList)

updatePlayerList()
