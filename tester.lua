-- Nebula UI Library V2.1 - Complete Edition
-- Modern UI with all features working

local NebulaUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Color Palette
local Colors = {
    Primary = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(75, 0, 130),
    Accent = Color3.fromRGB(147, 51, 234),
    Background = Color3.fromRGB(13, 13, 20),
    Surface = Color3.fromRGB(20, 20, 30),
    SurfaceLight = Color3.fromRGB(28, 28, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 146, 60),
    Error = Color3.fromRGB(239, 68, 68)
}

-- Config Management
local ConfigManager = {
    Folder = "NebulaConfigs",
    AutoLoadEnabled = false,
    CurrentConfig = {}
}

function ConfigManager:SaveConfig(configName)
    local success = pcall(function()
        local configData = HttpService:JSONEncode(self.CurrentConfig)
        writefile(self.Folder .. "/" .. configName .. ".json", configData)
    end)
    return success
end

function ConfigManager:LoadConfig(configName)
    local success, data = pcall(function()
        return readfile(self.Folder .. "/" .. configName .. ".json")
    end)
    if success then
        return HttpService:JSONDecode(data)
    end
    return nil
end

function ConfigManager:GetConfigs()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    local configs = {}
    local success = pcall(function()
        for _, file in pairs(listfiles(self.Folder)) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end)
    return configs
end

function ConfigManager:DeleteConfig(configName)
    pcall(function()
        delfile(self.Folder .. "/" .. configName .. ".json")
    end)
end

function ConfigManager:Initialize()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
end

ConfigManager:Initialize()

-- Utility Functions
local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateGradient(parent, rotation, colors)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 0
    if colors then
        local colorSequence = {}
        for i, color in ipairs(colors) do
            table.insert(colorSequence, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color))
        end
        gradient.Color = ColorSequence.new(colorSequence)
    end
    gradient.Parent = parent
    return gradient
end

local function CreateGlow(parent, size, color, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size = UDim2.new(1, size or 20, 1, size or 20)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Image = "rbxassetid://4996891970"
    glow.ImageColor3 = color or Colors.Primary
    glow.ImageTransparency = transparency or 0.5
    glow.ZIndex = 0
    glow.Parent = parent
    return glow
end

local function CreateStroke(parent, thickness, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Colors.Primary
    stroke.Transparency = transparency or 0.5
    stroke.Parent = parent
    return stroke
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

-- Main Library
function NebulaUI:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Nebula UI"
    local autoLoad = config.AutoLoad or false
    local toggleKey = config.ToggleKey or Enum.KeyCode.LeftControl
    
    ConfigManager.AutoLoadEnabled = autoLoad
    
    -- Screen GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NebulaUI_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game.CoreGui
    else
        ScreenGui.Parent = game.CoreGui
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local BackgroundGradient = CreateGradient(MainFrame, 45, {
        Colors.Background,
        Color3.fromRGB(20, 10, 35),
        Colors.Background
    })
    
    CreateGlow(MainFrame, 60, Colors.Primary, 0.7)
    
    local MainStroke = CreateStroke(MainFrame, 1.5, Colors.Primary, 0.3)
    CreateGradient(MainStroke, 90, {Colors.Primary, Colors.Accent, Colors.Secondary})
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -25, 0, -25)
    Shadow.Size = UDim2.new(1, 50, 1, 50)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Colors.Primary
    Shadow.ImageTransparency = 0.3
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = Colors.SurfaceLight
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar
    
    CreateGradient(TitleBar, 90, {Color3.fromRGB(30, 20, 45), Color3.fromRGB(20, 15, 35)})
    
    local TitleBarBottom = Instance.new("Frame")
    TitleBarBottom.BackgroundColor3 = Colors.SurfaceLight
    TitleBarBottom.BackgroundTransparency = 0.3
    TitleBarBottom.BorderSizePixel = 0
    TitleBarBottom.Position = UDim2.new(0, 0, 0.6, 0)
    TitleBarBottom.Size = UDim2.new(1, 0, 0.4, 0)
    TitleBarBottom.Parent = TitleBar
    
    local AccentLine = Instance.new("Frame")
    AccentLine.BackgroundColor3 = Colors.Primary
    AccentLine.BorderSizePixel = 0
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Parent = TitleBar
    
    local LineGradient = CreateGradient(AccentLine, 90, {Colors.Secondary, Colors.Primary, Colors.Accent, Colors.Primary, Colors.Secondary})
    
    spawn(function()
        while wait(0.05) do
            if LineGradient and LineGradient.Parent then
                LineGradient.Rotation = (LineGradient.Rotation + 2) % 360
            end
        end
    end)
    
    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.5, -25, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = windowTitle
    Title.TextColor3 = Colors.Text
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    CreateStroke(Title, 1, Colors.Primary, 0.7)
    
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.BackgroundColor3 = Colors.Success
    StatusIndicator.BorderSizePixel = 0
    StatusIndicator.Position = UDim2.new(1, -80, 0.5, -4)
    StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
    StatusIndicator.Parent = TitleBar
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator
    
    CreateGlow(StatusIndicator, 15, Colors.Success, 0.4)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(1, 5, 0, -8)
    StatusLabel.Size = UDim2.new(0, 60, 0, 24)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Active"
    StatusLabel.TextColor3 = Colors.Success
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = StatusIndicator
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.BackgroundColor3 = Colors.Surface
    TabContainer.BackgroundTransparency = 0.4
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(0, 180, 1, -50)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Colors.Primary
    TabContainer.Parent = MainFrame
    
    CreateGradient(TabContainer, 180, {Color3.fromRGB(18, 18, 28), Color3.fromRGB(15, 15, 25)})
    CreateStroke(TabContainer, 1, Colors.Primary, 0.7)
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingBottom = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    TabPadding.Parent = TabContainer
    
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 180, 0, 50)
    ContentContainer.Size = UDim2.new(1, -180, 1, -50)
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    -- Window Object
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ConfigManager = ConfigManager,
        ToggleKey = toggleKey,
        MainFrame = MainFrame
    }
    
    -- Toggle UI Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    function Window:SetToggleKey(keyCode)
        self.ToggleKey = keyCode
    end
    
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Sections = {},
            Elements = {}
        }
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.BackgroundColor3 = Colors.SurfaceLight
        TabButton.BackgroundTransparency = 0.6
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 42)
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 10)
        TabCorner.Parent = TabButton
        
        local TabStroke = CreateStroke(TabButton, 1, Colors.Primary, 0.8)
        
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0, 12, 0.5, -10)
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Image = "rbxassetid://7734053426"
        TabIcon.ImageColor3 = Colors.TextSecondary
        TabIcon.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 40, 0, 0)
        TabLabel.Size = UDim2.new(1, -45, 1, 0)
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Colors.TextSecondary
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.BackgroundColor3 = Colors.Primary
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 0.5, -12)
        Indicator.Size = UDim2.new(0, 0, 0, 24)
        Indicator.Visible = false
        Indicator.Parent = TabButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 4)
        IndicatorCorner.Parent = Indicator
        
        CreateGlow(Indicator, 20, Colors.Primary, 0.5)
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Colors.Primary
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 15)
        ContentPadding.PaddingRight = UDim.new(0, 15)
        ContentPadding.PaddingTop = UDim.new(0, 15)
        ContentPadding.PaddingBottom = UDim.new(0, 15)
        ContentPadding.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Hover Effects
        TabButton.MouseEnter:Connect(function()
            if not TabContent.Visible then
                Tween(TabButton, {BackgroundTransparency = 0.3}, 0.2)
                Tween(TabIcon, {ImageColor3 = Colors.Primary}, 0.2)
                Tween(TabLabel, {TextColor3 = Colors.Text}, 0.2)
                Tween(TabStroke, {Transparency = 0.4}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not TabContent.Visible then
                Tween(TabButton, {BackgroundTransparency = 0.6}, 0.2)
                Tween(TabIcon, {ImageColor3 = Colors.TextSecondary}, 0.2)
                Tween(TabLabel, {TextColor3 = Colors.TextSecondary}, 0.2)
                Tween(TabStroke, {Transparency = 0.8}, 0.2)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                Tween(tab.Button, {BackgroundTransparency = 0.6}, 0.3)
                Tween(tab.Button:FindFirstChild("Icon"), {ImageColor3 = Colors.TextSecondary}, 0.3)
                local label = tab.Button:FindFirstChild("TextLabel")
                if label then
                    Tween(label, {TextColor3 = Colors.TextSecondary}, 0.3)
                end
                local stroke = tab.Button:FindFirstChild("UIStroke")
                if stroke then
                    Tween(stroke, {Transparency = 0.8}, 0.3)
                end
                local indicator = tab.Button:FindFirstChild("Indicator")
                if indicator then
                    Tween(indicator, {Size = UDim2.new(0, 0, 0, 24)}, 0.2)
                    indicator.Visible = false
                end
                tab.Content.Visible = false
            end
            
            Tween(TabButton, {BackgroundTransparency = 0.2}, 0.3)
            Tween(TabIcon, {ImageColor3 = Colors.Primary}, 0.3)
            Tween(TabLabel, {TextColor3 = Colors.Text}, 0.3)
            Tween(TabStroke, {Transparency = 0.2}, 0.3)
            
            Indicator.Visible = true
            Tween(Indicator, {Size = UDim2.new(0, 4, 0, 24)}, 0.3, Enum.EasingStyle.Back)
            
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        function Tab:CreateSection(sectionName)
            local Section = {
                Name = sectionName,
                Elements = {}
            }
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = sectionName
            SectionFrame.BackgroundColor3 = Colors.SurfaceLight
            SectionFrame.BackgroundTransparency = 0.3
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 12)
            SectionCorner.Parent = SectionFrame
            
            CreateStroke(SectionFrame, 1, Colors.Primary, 0.7)
            CreateGradient(SectionFrame, 135, {Color3.fromRGB(25, 25, 38), Color3.fromRGB(20, 20, 32)})
            
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "Header"
            SectionHeader.BackgroundColor3 = Colors.Primary
            SectionHeader.BackgroundTransparency = 0.9
            SectionHeader.BorderSizePixel = 0
            SectionHeader.Size = UDim2.new(1, 0, 0, 45)
            SectionHeader.Parent = SectionFrame
            
            local HeaderCorner = Instance.new("UICorner")
            HeaderCorner.CornerRadius = UDim.new(0, 12)
            HeaderCorner.Parent = SectionHeader
            
            CreateGradient(SectionHeader, 90, {Color3.fromRGB(40, 30, 60), Color3.fromRGB(30, 25, 50)})
            
            local HeaderBottom = Instance.new("Frame")
            HeaderBottom.BackgroundColor3 = Colors.Primary
            HeaderBottom.BackgroundTransparency = 0.9
            HeaderBottom.BorderSizePixel = 0
            HeaderBottom.Position = UDim2.new(0, 0, 0.5, 0)
            HeaderBottom.Size = UDim2.new(1, 0, 0.5, 0)
            HeaderBottom.Parent = SectionHeader
            
            local AccentBar = Instance.new("Frame")
            AccentBar.BackgroundColor3 = Colors.Primary
            AccentBar.BorderSizePixel = 0
            AccentBar.Position = UDim2.new(0, 0, 1, -2)
            AccentBar.Size = UDim2.new(1, 0, 0, 2)
            AccentBar.Parent = SectionHeader
            
            CreateGradient(AccentBar, 0, {Colors.Primary, Colors.Accent})
            
            local SectionIcon = Instance.new("ImageLabel")
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Position = UDim2.new(0, 15, 0.5, -10)
            SectionIcon.Size = UDim2.new(0, 20, 0, 20)
            SectionIcon.Image = "rbxassetid://7733964370"
            SectionIcon.ImageColor3 = Colors.Primary
            SectionIcon.Parent = SectionHeader
            
            CreateGlow(SectionIcon, 15, Colors.Primary, 0.6)
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 45, 0, 0)
            SectionTitle.Size = UDim2.new(1, -50, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Colors.Text
            SectionTitle.TextSize = 15
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionHeader
            
            CreateStroke(SectionTitle, 1, Colors.Primary, 0.8)
            
            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.Position = UDim2.new(0, 0, 0, 45)
            ElementsContainer.Size = UDim2.new(1, 0, 0, 0)
            ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            ElementsContainer.Parent = SectionFrame
            
            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 8)
            ElementsLayout.Parent = ElementsContainer
            
            local ElementsPadding = Instance.new("UIPadding")
            ElementsPadding.PaddingLeft = UDim.new(0, 15)
            ElementsPadding.PaddingRight = UDim.new(0, 15)
            ElementsPadding.PaddingTop = UDim.new(0, 12)
            ElementsPadding.PaddingBottom = UDim.new(0, 12)
            ElementsPadding.Parent = ElementsContainer
            
            Section.Frame = SectionFrame
            Section.Container = ElementsContainer
            
            -- Toggle
            function Section:AddToggle(options)
                options = options or {}
                local name = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local configKey = tabName .. "_" .. sectionName .. "_" .. name
                local toggleState = default
                
                ConfigManager.CurrentConfig[configKey] = toggleState
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = name
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
                ToggleFrame.Parent = ElementsContainer
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Font = Enum.Font.GothamMedium
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Colors.Text
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.BackgroundColor3 = toggleState and Colors.Primary or Colors.SurfaceLight
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Position = UDim2.new(1, -40, 0.5, -12)
                ToggleButton.Size = UDim2.new(0, 40, 0, 24)
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleButton
                
                local ToggleStroke = CreateStroke(ToggleButton, 1.5, toggleState and Colors.Primary or Color3.fromRGB(60, 60, 70), toggleState and 0.3 or 0.6)
                local ToggleGradient = CreateGradient(ToggleButton, 45, toggleState and {Colors.Primary, Colors.Accent} or {Colors.SurfaceLight, Colors.Surface})
                
                if toggleState then
                    CreateGlow(ToggleButton, 20, Colors.Primary, 0.5)
                end
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Position = toggleState and UDim2.new(0, 18, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
                ToggleIndicator.Parent = ToggleButton
                
                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(1, 0)
                IndicatorCorner.Parent = ToggleIndicator
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggleState = not toggleState
                    ConfigManager.CurrentConfig[configKey] = toggleState
                    
                    Tween(ToggleButton, {BackgroundColor3 = toggleState and Colors.Primary or Colors.SurfaceLight}, 0.3)
                    Tween(ToggleStroke, {
                        Color = toggleState and Colors.Primary or Color3.fromRGB(60, 60, 70),
                        Transparency = toggleState and 0.3 or 0.6
                    }, 0.3)
                    
                    ToggleGradient.Color = ColorSequence.new(toggleState and {
                        ColorSequenceKeypoint.new(0, Colors.Primary),
                        ColorSequenceKeypoint.new(1, Colors.Accent)
                    } or {
                        ColorSequenceKeypoint.new(0, Colors.SurfaceLight),
                        ColorSequenceKeypoint.new(1, Colors.Surface)
                    })
                    
                    Tween(ToggleIndicator, {
                        Position = toggleState and UDim2.new(0, 18, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                        Size = UDim2.new(0, 20, 0, 20)
                    }, 0.2, Enum.EasingStyle.Back)
                    
                    wait(0.1)
                    Tween(ToggleIndicator, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
                    
                    local existingGlow = ToggleButton:FindFirstChild("Glow")
                    if toggleState and not existingGlow then
                        CreateGlow(ToggleButton, 20, Colors.Primary, 0.5)
                    elseif not toggleState and existingGlow then
                        existingGlow:Destroy()
                    end
                    
                    callback(toggleState)
                end)
                
                return {
                    Set = function(value)
                        toggleState = value
                        ConfigManager.CurrentConfig[configKey] = toggleState
                        ToggleButton.BackgroundColor3 = toggleState and Colors.Primary or Colors.SurfaceLight
                        ToggleIndicator.Position = toggleState and UDim2.new(0, 18, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                        callback(toggleState)
                    end
                }
            end
            
            -- Slider
            function Section:AddSlider(options)
                options = options or {}
                local name = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local callback = options.Callback or function() end
                
                local configKey = tabName .. "_" .. sectionName .. "_" .. name
                local sliderValue = default
                
                ConfigManager.CurrentConfig[configKey] = sliderValue
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 52)
                SliderFrame.Parent = ElementsContainer
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(1, -60, 0, 24)
                SliderLabel.Font = Enum.Font.GothamMedium
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Colors.Text
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.BackgroundColor3 = Colors.Primary
                SliderValue.BackgroundTransparency = 0.8
                SliderValue.BorderSizePixel = 0
                SliderValue.Position = UDim2.new(1, -55, 0, 0)
                SliderValue.Size = UDim2.new(0, 55, 0, 24)
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.Text = tostring(sliderValue)
                SliderValue.TextColor3 = Colors.Primary
                SliderValue.TextSize = 13
                SliderValue.Parent = SliderFrame
                
                local ValueCorner = Instance.new("UICorner")
                ValueCorner.CornerRadius = UDim.new(0, 6)
                ValueCorner.Parent = SliderValue
                
                CreateStroke(SliderValue, 1, Colors.Primary, 0.5)
                
                local SliderBack = Instance.new("Frame")
                SliderBack.BackgroundColor3 = Colors.Surface
                SliderBack.BorderSizePixel = 0
                SliderBack.Position = UDim2.new(0, 0, 0, 32)
                SliderBack.Size = UDim2.new(1, 0, 0, 8)
                SliderBack.Parent = SliderFrame
                
                local SliderBackCorner = Instance.new("UICorner")
                SliderBackCorner.CornerRadius = UDim.new(1, 0)
                SliderBackCorner.Parent = SliderBack
                
                CreateStroke(SliderBack, 1, Color3.fromRGB(50, 50, 65), 0.5)
                
                local SliderFill = Instance.new("Frame")
                SliderFill.BackgroundColor3 = Colors.Primary
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
                SliderFill.Parent = SliderBack
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                CreateGradient(SliderFill, 0, {Colors.Primary, Colors.Accent})
                CreateGlow(SliderFill, 15, Colors.Primary, 0.6)
                
                local SliderThumb = Instance.new("Frame")
                SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderThumb.BorderSizePixel = 0
                SliderThumb.Position = UDim2.new((sliderValue - min) / (max - min), -8, 0.5, -8)
                SliderThumb.Size = UDim2.new(0, 16, 0, 16)
                SliderThumb.ZIndex = 2
                SliderThumb.Parent = SliderBack
                
                local ThumbCorner = Instance.new("UICorner")
                ThumbCorner.CornerRadius = UDim.new(1, 0)
                ThumbCorner.Parent = SliderThumb
                
                CreateStroke(SliderThumb, 2, Colors.Primary, 0.3)
                CreateGlow(SliderThumb, 12, Colors.Primary, 0.5)
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 0, 24)
                SliderButton.Position = UDim2.new(0, 0, 0, 28)
                SliderButton.Text = ""
                SliderButton.Parent = SliderFrame
                
                local dragging = false
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Tween(SliderThumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
                        
                        spawn(function()
                            while dragging do
                                local mousePos = UserInputService:GetMouseLocation().X
                                local sliderPos = SliderBack.AbsolutePosition.X
                                local sliderSize = SliderBack.AbsoluteSize.X
                                local relativePos = math.clamp(mousePos - sliderPos, 0, sliderSize)
                                local percentage = relativePos / sliderSize
                                
                                sliderValue = math.floor((min + (max - min) * percentage) / increment + 0.5) * increment
                                sliderValue = math.clamp(sliderValue, min, max)
                                
                                ConfigManager.CurrentConfig[configKey] = sliderValue
                                SliderValue.Text = tostring(sliderValue)
                                SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
                                SliderThumb.Position = UDim2.new((sliderValue - min) / (max - min), -10, 0.5, -10)
                                
                                callback(sliderValue)
                                RunService.RenderStepped:Wait()
                            end
                        end)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        Tween(SliderThumb, {
                            Size = UDim2.new(0, 16, 0, 16),
                            Position = UDim2.new((sliderValue - min) / (max - min), -8, 0.5, -8)
                        }, 0.1)
                    end
                end)
                
                return {
                    Set = function(value)
                        sliderValue = math.clamp(value, min, max)
                        ConfigManager.CurrentConfig[configKey] = sliderValue
                        SliderValue.Text = tostring(sliderValue)
                        SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
                        SliderThumb.Position = UDim2.new((sliderValue - min) / (max - min), -8, 0.5, -8)
                        callback(sliderValue)
                    end
                }
            end
            
            -- Button
            function Section:AddButton(options)
                options = options or {}
                local name = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
                ButtonFrame.Parent = ElementsContainer
                
                local Button = Instance.new("TextButton")
                Button.BackgroundColor3 = Colors.Primary
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Font = Enum.Font.GothamBold
                Button.Text = name
                Button.TextColor3 = Colors.Text
                Button.TextSize = 13
                Button.Parent = ButtonFrame
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 8)
                ButtonCorner.Parent = Button
                
                CreateGradient(Button, 45, {Colors.Primary, Colors.Accent})
                local ButtonStroke = CreateStroke(Button, 1, Colors.Accent, 0.5)
                CreateGlow(Button, 20, Colors.Primary, 0.6)
                
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {Size = UDim2.new(1, -4, 1, -4)}, 0.1)
                    wait(0.1)
                    Tween(Button, {Size = UDim2.new(1, 0, 1, 0)}, 0.1)
                    callback()
                end)
                
                Button.MouseEnter:Connect(function()
                    Tween(ButtonStroke, {Transparency = 0.2}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(ButtonStroke, {Transparency = 0.5}, 0.2)
                end)
            end
            
            -- Dropdown
            function Section:AddDropdown(options)
                options = options or {}
                local name = options.Name or "Dropdown"
                local items = options.Items or {}
                local default = options.Default or (items[1] or "None")
                local callback = options.Callback or function() end
                
                local configKey = tabName .. "_" .. sectionName .. "_" .. name
                local selected = default
                
                ConfigManager.CurrentConfig[configKey] = selected
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
                DropdownFrame.Parent = ElementsContainer
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Size = UDim2.new(1, -130, 1, 0)
                DropdownLabel.Font = Enum.Font.GothamMedium
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Colors.Text
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.BackgroundColor3 = Colors.Surface
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Position = UDim2.new(1, -120, 0.5, -14)
                DropdownButton.Size = UDim2.new(0, 120, 0, 28)
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = "  " .. selected
                DropdownButton.TextColor3 = Colors.Text
                DropdownButton.TextSize = 12
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.Parent = DropdownFrame
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = DropdownButton
                
                CreateStroke(DropdownButton, 1, Colors.Primary, 0.6)
                
                local DropdownIcon = Instance.new("ImageLabel")
                DropdownIcon.BackgroundTransparency = 1
                DropdownIcon.Position = UDim2.new(1, -20, 0.5, -5)
                DropdownIcon.Size = UDim2.new(0, 10, 0, 10)
                DropdownIcon.Image = "rbxassetid://7733911828"
                DropdownIcon.ImageColor3 = Colors.TextSecondary
                DropdownIcon.Parent = DropdownButton
                
                local DropdownList = Instance.new("ScrollingFrame")
                DropdownList.BackgroundColor3 = Colors.Surface
                DropdownList.BorderSizePixel = 0
                DropdownList.Position = UDim2.new(1, -120, 1, 4)
                DropdownList.Size = UDim2.new(0, 120, 0, 0)
                DropdownList.Visible = false
                DropdownList.ZIndex = 10
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
                DropdownList.ScrollBarThickness = 4
                DropdownList.ScrollBarImageColor3 = Colors.Primary
                DropdownList.Parent = DropdownButton
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 6)
                ListCorner.Parent = DropdownList
                
                CreateStroke(DropdownList, 1, Colors.Primary, 0.5)
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropdownList
                
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end)
                
                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownList.Visible = not DropdownList.Visible
                    if DropdownList.Visible then
                        Tween(DropdownIcon, {Rotation = 180}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(0, 120, 0, math.min(#items * 28, 140))}, 0.2)
                    else
                        Tween(DropdownIcon, {Rotation = 0}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
                    end
                end)
                
                for _, item in ipairs(items) do
                    local ItemButton = Instance.new("TextButton")
                    ItemButton.BackgroundColor3 = Colors.SurfaceLight
                    ItemButton.BorderSizePixel = 0
                    ItemButton.Size = UDim2.new(1, 0, 0, 28)
                    ItemButton.Font = Enum.Font.Gotham
                    ItemButton.Text = "  " .. item
                    ItemButton.TextColor3 = Colors.Text
                    ItemButton.TextSize = 12
                    ItemButton.TextXAlignment = Enum.TextXAlignment.Left
                    ItemButton.Parent = DropdownList
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        selected = item
                        ConfigManager.CurrentConfig[configKey] = selected
                        DropdownButton.Text = "  " .. item
                        DropdownList.Visible = false
                        Tween(DropdownIcon, {Rotation = 0}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
                        callback(item)
                    end)
                    
                    ItemButton.MouseEnter:Connect(function()
                        Tween(ItemButton, {BackgroundColor3 = Colors.Primary}, 0.1)
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        Tween(ItemButton, {BackgroundColor3 = Colors.SurfaceLight}, 0.1)
                    end)
                end
                
                return {
                    Set = function(value)
                        if table.find(items, value) then
                            selected = value
                            ConfigManager.CurrentConfig[configKey] = selected
                            DropdownButton.Text = "  " .. value
                            callback(value)
                        end
                    end,
                    Refresh = function(newItems)
                        items = newItems
                        for _, child in ipairs(DropdownList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        for _, item in ipairs(items) do
                            local ItemButton = Instance.new("TextButton")
                            ItemButton.BackgroundColor3 = Colors.SurfaceLight
                            ItemButton.BorderSizePixel = 0
                            ItemButton.Size = UDim2.new(1, 0, 0, 28)
                            ItemButton.Font = Enum.Font.Gotham
                            ItemButton.Text = "  " .. item
                            ItemButton.TextColor3 = Colors.Text
                            ItemButton.TextSize = 12
                            ItemButton.TextXAlignment = Enum.TextXAlignment.Left
                            ItemButton.Parent = DropdownList
                            
                            ItemButton.MouseButton1Click:Connect(function()
                                selected = item
                                ConfigManager.CurrentConfig[configKey] = selected
                                DropdownButton.Text = "  " .. item
                                DropdownList.Visible = false
                                callback(item)
                            end)
                        end
                    end
                }
            end
            
            -- Keybind
            function Section:AddKeybind(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.F
                local callback = options.Callback or function() end
                
                local configKey = tabName .. "_" .. sectionName .. "_" .. name
                local currentKey = default
                
                ConfigManager.CurrentConfig[configKey] = currentKey.Name
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Size = UDim2.new(1, 0, 0, 36)
                KeybindFrame.Parent = ElementsContainer
                
                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Size = UDim2.new(1, -90, 1, 0)
                KeybindLabel.Font = Enum.Font.GothamMedium
                KeybindLabel.Text = name
                KeybindLabel.TextColor3 = Colors.Text
                KeybindLabel.TextSize = 13
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.Parent = KeybindFrame
                
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.BackgroundColor3 = Colors.Surface
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Position = UDim2.new(1, -80, 0.5, -14)
                KeybindButton.Size = UDim2.new(0, 80, 0, 28)
                KeybindButton.Font = Enum.Font.Gotham
                KeybindButton.Text = currentKey.Name
                KeybindButton.TextColor3 = Colors.Text
                KeybindButton.TextSize = 12
                KeybindButton.Parent = KeybindFrame
                
                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 6)
                KeybindCorner.Parent = KeybindButton
                
                CreateStroke(KeybindButton, 1, Colors.Primary, 0.6)
                
                local SettingsIcon = Instance.new("ImageLabel")
                SettingsIcon.BackgroundTransparency = 1
                SettingsIcon.Position = UDim2.new(0, 5, 0.5, -6)
                SettingsIcon.Size = UDim2.new(0, 12, 0, 12)
                SettingsIcon.Image = "rbxassetid://7734053426"
                SettingsIcon.ImageColor3 = Colors.Primary
                SettingsIcon.Parent = KeybindButton
                
                local binding = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    KeybindButton.Text = "..."
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            ConfigManager.CurrentConfig[configKey] = currentKey.Name
                            KeybindButton.Text = currentKey.Name
                            binding = false
                            connection:Disconnect()
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode == currentKey and not binding then
                        callback()
                    end
                end)
                
                return {
                    Set = function(keycode)
                        currentKey = keycode
                        ConfigManager.CurrentConfig[configKey] = currentKey.Name
                        KeybindButton.Text = currentKey.Name
                    end
                }
            end
            
            -- Color Picker
            function Section:AddColorPicker(options)
                options = options or {}
                local name = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(138, 43, 226)
                local callback = options.Callback or function() end
                
                local configKey = tabName .. "_" .. sectionName .. "_" .. name
                local selectedColor = default
                
                ConfigManager.CurrentConfig[configKey] = {selectedColor.R, selectedColor.G, selectedColor.B}
                
                local ColorFrame = Instance.new("Frame")
                ColorFrame.BackgroundTransparency = 1
                ColorFrame.Size = UDim2.new(1, 0, 0, 36)
                ColorFrame.Parent = ElementsContainer
                
                local ColorLabel = Instance.new("TextLabel")
                ColorLabel.BackgroundTransparency = 1
                ColorLabel.Size = UDim2.new(1, -50, 1, 0)
                ColorLabel.Font = Enum.Font.GothamMedium
                ColorLabel.Text = name
                ColorLabel.TextColor3 = Colors.Text
                ColorLabel.TextSize = 13
                ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColorLabel.Parent = ColorFrame
                
                local ColorButton = Instance.new("TextButton")
                ColorButton.BackgroundColor3 = selectedColor
                ColorButton.BorderSizePixel = 0
                ColorButton.Position = UDim2.new(1, -36, 0.5, -12)
                ColorButton.Size = UDim2.new(0, 36, 0, 24)
                ColorButton.Text = ""
                ColorButton.Parent = ColorFrame
                
                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(0, 6)
                ColorCorner.Parent = ColorButton
                
                CreateStroke(ColorButton, 1.5, Colors.Text, 0.5)
                
                local ColorPicker = Instance.new("Frame")
                ColorPicker.BackgroundColor3 = Colors.Surface
                ColorPicker.BorderSizePixel = 0
                ColorPicker.Position = UDim2.new(1, 10, 0, 0)
                ColorPicker.Size = UDim2.new(0, 200, 0, 150)
                ColorPicker.Visible = false
                ColorPicker.ZIndex = 100
                ColorPicker.Parent = ColorButton
                
                local PickerCorner = Instance.new("UICorner")
                PickerCorner.CornerRadius = UDim.new(0, 8)
                PickerCorner.Parent = ColorPicker
                
                CreateStroke(ColorPicker, 1.5, Colors.Primary, 0.5)
                CreateGlow(ColorPicker, 30, Colors.Primary, 0.6)
                
                ColorButton.MouseButton1Click:Connect(function()
                    ColorPicker.Visible = not ColorPicker.Visible
                end)
                
                -- RGB Sliders
                local function createColorSlider(yPos, colorName, defaultVal)
                    local sliderFrame = Instance.new("Frame")
                    sliderFrame.BackgroundTransparency = 1
                    sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
                    sliderFrame.Size = UDim2.new(1, -20, 0, 35)
                    sliderFrame.Parent = ColorPicker
                    
                    local label = Instance.new("TextLabel")
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(0, 20, 0, 20)
                    label.Font = Enum.Font.GothamBold
                    label.Text = colorName
                    label.TextColor3 = Colors.Text
                    label.TextSize = 12
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Parent = sliderFrame
                    
                    local sliderBack = Instance.new("Frame")
                    sliderBack.BackgroundColor3 = Colors.SurfaceLight
                    sliderBack.BorderSizePixel = 0
                    sliderBack.Position = UDim2.new(0, 25, 0, 18)
                    sliderBack.Size = UDim2.new(1, -55, 0, 6)
                    sliderBack.Parent = sliderFrame
                    
                    local sliderCorner = Instance.new("UICorner")
                    sliderCorner.CornerRadius = UDim.new(1, 0)
                    sliderCorner.Parent = sliderBack
                    
                    local sliderFill = Instance.new("Frame")
                    sliderFill.BackgroundColor3 = colorName == "R" and Color3.fromRGB(255, 0, 0) or 
                                                   colorName == "G" and Color3.fromRGB(0, 255, 0) or 
                                                   Color3.fromRGB(0, 0, 255)
                    sliderFill.BorderSizePixel = 0
                    sliderFill.Size = UDim2.new(defaultVal / 255, 0, 1, 0)
                    sliderFill.Parent = sliderBack
                    
                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(1, 0)
                    fillCorner.Parent = sliderFill
                    
                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.Position = UDim2.new(1, -25, 0, 0)
                    valueLabel.Size = UDim2.new(0, 25, 0, 20)
                    valueLabel.Font = Enum.Font.Gotham
                    valueLabel.Text = tostring(math.floor(defaultVal))
                    valueLabel.TextColor3 = Colors.Text
                    valueLabel.TextSize = 11
                    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    valueLabel.Parent = sliderFrame
                    
                    local sliderButton = Instance.new("TextButton")
                    sliderButton.BackgroundTransparency = 1
                    sliderButton.Position = UDim2.new(0, 25, 0, 0)
                    sliderButton.Size = UDim2.new(1, -55, 1, 0)
                    sliderButton.Text = ""
                    sliderButton.Parent = sliderFrame
                    
                    local dragging = false
                    local value = defaultVal
                    
                    sliderButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            spawn(function()
                                while dragging do
                                    local mousePos = UserInputService:GetMouseLocation().X
                                    local sliderPos = sliderBack.AbsolutePosition.X
                                    local sliderSize = sliderBack.AbsoluteSize.X
                                    local relativePos = math.clamp(mousePos - sliderPos, 0, sliderSize)
                                    value = math.floor((relativePos / sliderSize) * 255)
                                    
                                    valueLabel.Text = tostring(value)
                                    sliderFill.Size = UDim2.new(value / 255, 0, 1, 0)
                                    
                                    if colorName == "R" then
                                        selectedColor = Color3.fromRGB(value, selectedColor.G * 255, selectedColor.B * 255)
                                    elseif colorName == "G" then
                                        selectedColor = Color3.fromRGB(selectedColor.R * 255, value, selectedColor.B * 255)
                                    else
                                        selectedColor = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, value)
                                    end
                                    
                                    ColorButton.BackgroundColor3 = selectedColor
                                    ConfigManager.CurrentConfig[configKey] = {selectedColor.R, selectedColor.G, selectedColor.B}
                                    callback(selectedColor)
                                    
                                    RunService.RenderStepped:Wait()
                                end
                            end)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    return {
                        Set = function(val)
                            value = math.clamp(val, 0, 255)
                            valueLabel.Text = tostring(value)
                            sliderFill.Size = UDim2.new(value / 255, 0, 1, 0)
                        end
                    }
                end
                
                local rSlider = createColorSlider(10, "R", selectedColor.R * 255)
                local gSlider = createColorSlider(50, "G", selectedColor.G * 255)
                local bSlider = createColorSlider(90, "B", selectedColor.B * 255)
                
                return {
                    Set = function(color)
                        selectedColor = color
                        ColorButton.BackgroundColor3 = color
                        ConfigManager.CurrentConfig[configKey] = {color.R, color.G, color.B}
                        rSlider.Set(color.R * 255)
                        gSlider.Set(color.G * 255)
                        bSlider.Set(color.B * 255)
                        callback(color)
                    end
                }
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            TabButton.BackgroundTransparency = 0.2
            TabIcon.ImageColor3 = Colors.Primary
            TabLabel.TextColor3 = Colors.Text
            TabStroke.Transparency = 0.2
            Indicator.Visible = true
            Indicator.Size = UDim2.new(0, 4, 0, 24)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    -- Auto-load config if enabled
    if ConfigManager.AutoLoadEnabled then
        local configs = ConfigManager:GetConfigs()
        if #configs > 0 then
            local lastConfig = configs[#configs]
            local config = ConfigManager:LoadConfig(lastConfig)
            if config then
                for key, value in pairs(config) do
                    ConfigManager.CurrentConfig[key] = value
                end
            end
        end
    end
    
    return Window
end

return NebulaUI
