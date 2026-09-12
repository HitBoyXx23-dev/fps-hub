local UI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local DARK = Color3.fromRGB(15, 15, 15)

local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

local function stroke(inst, t, th)
    local s = Instance.new("UIStroke")
    s.Color = WHITE
    s.Transparency = t or 0.7
    s.Thickness = th or 1
    s.Parent = inst
    return s
end

function UI.createWindow(config)
    config = config or {}
    local title = config.title or "OBBY MENU"
    local subtitle = config.subtitle or ""
    local width = config.width or 560
    local height = config.height or 440
    local toggleKey = config.toggleKey or Enum.KeyCode.E
    local toggleKeyLabel = config.toggleKeyLabel or "[E]"

    local player = game.Players.LocalPlayer
    local pg = player:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("ObbyHub")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ObbyHub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = pg

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, width, 0, height)
    frame.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    frame.BackgroundColor3 = BLACK
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.ClipsDescendants = true
    frame.Parent = gui
    corner(frame, 14)
    stroke(frame, 0.45, 1)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = BLACK
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = frame
    corner(header, 14)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -30, 0, 1)
    divider.Position = UDim2.new(0, 15, 1, -1)
    divider.BackgroundColor3 = WHITE
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -220, subtitle ~= "" and 0.6 or 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, subtitle ~= "" and 4 or 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = WHITE
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    if subtitle ~= "" then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -220, 0, 14)
        sub.Position = UDim2.new(0, 22, 1, -20)
        sub.BackgroundTransparency = 1
        sub.Text = subtitle
        sub.TextColor3 = WHITE
        sub.TextTransparency = 0.55
        sub.TextScaled = true
        sub.Font = Enum.Font.Gotham
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent = header
    end

    local keyHint = Instance.new("TextLabel")
    keyHint.Size = UDim2.new(0, 80, 1, 0)
    keyHint.Position = UDim2.new(1, -185, 0, 0)
    keyHint.BackgroundTransparency = 1
    keyHint.Text = toggleKeyLabel
    keyHint.TextColor3 = WHITE
    keyHint.TextTransparency = 0.4
    keyHint.TextScaled = true
    keyHint.Font = Enum.Font.GothamBold
    keyHint.TextXAlignment = Enum.TextXAlignment.Center
    keyHint.Parent = header

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -100, 0, 10)
    minBtn.BackgroundColor3 = BLACK
    minBtn.BackgroundTransparency = 0.3
    minBtn.Text = "—"
    minBtn.TextColor3 = WHITE
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.Parent = header
    corner(minBtn, 8)
    stroke(minBtn, 0.5, 1)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -60, 0, 10)
    closeBtn.BackgroundColor3 = BLACK
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "X"
    closeBtn.TextColor3 = WHITE
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    corner(closeBtn, 8)
    stroke(closeBtn, 0.5, 1)

    minBtn.MouseEnter:Connect(function()
        minBtn.BackgroundColor3 = WHITE
        minBtn.TextColor3 = BLACK
    end)
    minBtn.MouseLeave:Connect(function()
        minBtn.BackgroundColor3 = BLACK
        minBtn.TextColor3 = WHITE
    end)
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = WHITE
        closeBtn.TextColor3 = BLACK
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = BLACK
        closeBtn.TextColor3 = WHITE
    end)

    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 0, 0, 0)
    miniBtn.Position = UDim2.new(0, 20, 0.5, -25)
    miniBtn.BackgroundColor3 = BLACK
    miniBtn.Text = "≡"
    miniBtn.TextColor3 = WHITE
    miniBtn.TextScaled = true
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.BorderSizePixel = 0
    miniBtn.AutoButtonColor = false
    miniBtn.Visible = false
    miniBtn.Parent = gui
    corner(miniBtn, 12)
    stroke(miniBtn, 0.4, 1)

    local closed = false
    local minimized = false
    local animating = false

    local function minimize()
        if closed or minimized or animating then return end
        animating = true
        minimized = true

        local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        TweenService:Create(frame, info, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()

        TweenService:Create(header, info, {BackgroundTransparency = 1}):Play()

        task.wait(0.2)
        frame.Visible = false
        frame.BackgroundTransparency = 0
        header.BackgroundTransparency = 0.3

        miniBtn.Size = UDim2.new(0, 0, 0, 0)
        miniBtn.Visible = true

        local showTween = TweenService:Create(miniBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 50)
        })
        showTween:Play()
        showTween.Completed:Wait()

        animating = false
    end

    local function restore()
        if closed or not minimized or animating then return end
        animating = true
        minimized = false

        local hideTween = TweenService:Create(miniBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        hideTween:Play()
        hideTween.Completed:Wait()
        miniBtn.Visible = false

        frame.Visible = true
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.BackgroundTransparency = 1
        header.BackgroundTransparency = 1

        TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, width, 0, height),
            Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
            BackgroundTransparency = 0
        }):Play()

        TweenService:Create(header, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.3
        }):Play()

        task.wait(0.35)
        animating = false
    end

    local function close()
        if closed then return end
        closed = true
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.2)
        gui:Destroy()
    end

    minBtn.MouseButton1Click:Connect(minimize)
    miniBtn.MouseButton1Click:Connect(restore)
    closeBtn.MouseButton1Click:Connect(close)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            if closed then return end
            if minimized then restore() else minimize() end
        end
    end)

    local api = {
        gui = gui,
        frame = frame,
        header = header,
        width = width,
        height = height,
        toggleKey = toggleKey,
        closed = function() return closed end,
        minimized = function() return minimized end,
        minimize = minimize,
        restore = restore,
        close = close,
    }

    function api.createPanel(side)
        local panel = Instance.new("Frame")
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel = 0
        if side == "left" then
            panel.Size = UDim2.new(0.5, -25, 1, -68)
            panel.Position = UDim2.new(0, 15, 0, 58)
        else
            panel.Size = UDim2.new(0.5, -25, 1, -68)
            panel.Position = UDim2.new(0.5, 10, 0, 58)
        end
        panel.Parent = frame
        return panel
    end

    function api.notify(text)
        if closed then return end
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 240, 0, 30)
        notif.Position = UDim2.new(0.5, -120, 0.88, 0)
        notif.BackgroundColor3 = BLACK
        notif.BackgroundTransparency = 0.15
        notif.Text = text
        notif.TextColor3 = WHITE
        notif.TextScaled = true
        notif.Font = Enum.Font.Gotham
        notif.BorderSizePixel = 0
        notif.ZIndex = 100
        notif.Parent = gui
        corner(notif, 8)
        stroke(notif, 0.7, 1)

        TweenService:Create(notif, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -120, 0.85, 0)}):Play()
        task.delay(1.5, function()
            local fade = TweenService:Create(notif, TweenInfo.new(0.25), {
                Position = UDim2.new(0.5, -120, 0.92, 0),
                BackgroundTransparency = 1,
                TextTransparency = 1
            })
            fade:Play()
            fade.Completed:Connect(function() notif:Destroy() end)
        end)
    end

    return api
end

function UI.createButton(parent, text, size, position)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = position or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = BLACK
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = WHITE
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    local s = stroke(btn, 0.7, 1)

    btn.MouseEnter:Connect(function()
        if btn.BackgroundTransparency > 0.5 then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundTransparency < 0.5 then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
        end
    end)

    return btn, s
end

function UI.setButtonState(btn, s, on)
    if on then
        btn.BackgroundColor3 = WHITE
        btn.BackgroundTransparency = 0.1
        btn.TextColor3 = BLACK
        s.Transparency = 0.3
    else
        btn.BackgroundColor3 = BLACK
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = WHITE
        s.Transparency = 0.7
    end
end

function UI.createSectionLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.Position = UDim2.new(0, 0, 0, y or 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = WHITE
    lbl.TextTransparency = 0.55
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

function UI.createScrollList(parent, size, position)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = size
    scroll.Position = position
    scroll.BackgroundColor3 = DARK
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = WHITE
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent
    corner(scroll, 10)
    stroke(scroll, 0.7, 1)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = scroll

    return scroll, layout
end

function UI.createTabs(parent)
    local state = { current = nil, panels = {}, buttons = {} }

    local bar = Instance.new("Frame")
    bar.Name = "TabBar"
    bar.Size = UDim2.new(1, 0, 0, 30)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.Parent = parent

    local barLayout = Instance.new("UIListLayout")
    barLayout.FillDirection = Enum.FillDirection.Horizontal
    barLayout.Padding = UDim.new(0, 5)
    barLayout.SortOrder = Enum.SortOrder.LayoutOrder
    barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    barLayout.Parent = bar

    local content = Instance.new("Frame")
    content.Name = "TabContent"
    content.Size = UDim2.new(1, 0, 1, -36)
    content.Position = UDim2.new(0, 0, 0, 36)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Parent = parent

    local function switchTo(name)
        for n, p in pairs(state.panels) do
            p.Visible = (n == name)
        end
        for n, b in pairs(state.buttons) do
            if n == name then
                b.BackgroundColor3 = WHITE
                b.BackgroundTransparency = 0.1
                b.TextColor3 = BLACK
                b.UIStroke.Transparency = 0.3
            else
                b.BackgroundColor3 = BLACK
                b.BackgroundTransparency = 0.2
                b.TextColor3 = WHITE
                b.UIStroke.Transparency = 0.7
            end
        end
        state.current = name
    end

    local api = {}

    function api.addTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 62, 0, 26)
        btn.BackgroundColor3 = BLACK
        btn.BackgroundTransparency = 0.2
        btn.Text = name
        btn.TextColor3 = WHITE
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = bar
        corner(btn, 6)
        local s = stroke(btn, 0.7, 1)

        btn.MouseEnter:Connect(function()
            if state.current ~= name then
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if state.current ~= name then
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
            end
        end)

        local panel = Instance.new("ScrollingFrame")
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel = 0
        panel.ScrollBarThickness = 3
        panel.ScrollBarImageColor3 = WHITE
        panel.CanvasSize = UDim2.new(0, 0, 0, 0)
        panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
        panel.Visible = false
        panel.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = panel

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        pad.Parent = panel

        state.panels[name] = panel
        state.buttons[name] = btn

        btn.MouseButton1Click:Connect(function()
            switchTo(name)
        end)

        if not state.current then
            switchTo(name)
        end

        return panel
    end

    function api.getCurrent()
        return state.current
    end

    return api
end

return UI
