-- Nebula UI Library
-- Clean, modern UI with config system

local NebulaUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Config Management
local ConfigManager = {
    Folder = "NebulaConfigs",
    AutoLoadEnabled = false,
    CurrentConfig = {}
}

function ConfigManager:SaveConfig(configName)
    local success, err = pcall(function()
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
        local decoded = HttpService:JSONDecode(data)
        return decoded
    end
    return nil
end

function ConfigManager:GetConfigs()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    local configs = {}
    for _, file in pairs(listfiles(self.Folder)) do
        local name = file:match("([^/]+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
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
    
    ConfigManager.AutoLoadEnabled = autoLoad
    
    -- Screen GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NebulaUI"
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
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    MainFrame.Size = UDim2.new(0, 600, 0, 450)
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleBarBottom = Instance.new("Frame")
    TitleBarBottom.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleBarBottom.BorderSizePixel = 0
    TitleBarBottom.Position = UDim2.new(0, 0, 0.5, 0)
    TitleBarBottom.Size = UDim2.new(1, 0, 0.5, 0)
    TitleBarBottom.Parent = TitleBar
    
    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = windowTitle
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 150, 1, -40)
    TabContainer.Parent = MainFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 150, 0, 40)
    ContentContainer.Size = UDim2.new(1, -150, 1, -40)
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    -- Window Object
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ConfigManager = ConfigManager
    }
    
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Sections = {},
            Elements = {}
        }
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 12)
        ContentPadding.PaddingRight = UDim.new(0, 12)
        ContentPadding.PaddingTop = UDim.new(0, 12)
        ContentPadding.PaddingBottom = UDim.new(0, 12)
        ContentPadding.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 24)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
                tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
                tab.Content.Visible = false
            end
            
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            SectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame
            
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "Header"
            SectionHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            SectionHeader.BorderSizePixel = 0
            SectionHeader.Size = UDim2.new(1, 0, 0, 35)
            SectionHeader.Parent = SectionFrame
            
            local HeaderCorner = Instance.new("UICorner")
            HeaderCorner.CornerRadius = UDim.new(0, 6)
            HeaderCorner.Parent = SectionHeader
            
            local HeaderBottom = Instance.new("Frame")
            HeaderBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            HeaderBottom.BorderSizePixel = 0
            HeaderBottom.Position = UDim2.new(0, 0, 0.5, 0)
            HeaderBottom.Size = UDim2.new(1, 0, 0.5, 0)
            HeaderBottom.Parent = SectionHeader
            
            local SectionIcon = Instance.new("ImageLabel")
            SectionIcon.Name = "Icon"
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Position = UDim2.new(0, 10, 0.5, -8)
            SectionIcon.Size = UDim2.new(0, 16, 0, 16)
            SectionIcon.Image = "rbxassetid://7733964370"
            SectionIcon.ImageColor3 = Color3.fromRGB(100, 100, 255)
            SectionIcon.Parent = SectionHeader
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 35, 0, 0)
            SectionTitle.Size = UDim2.new(1, -35, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionHeader
            
            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.Position = UDim2.new(0, 0, 0, 35)
            ElementsContainer.Size = UDim2.new(1, 0, 0, 0)
            ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            ElementsContainer.Parent = SectionFrame
            
            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 6)
            ElementsLayout.Parent = ElementsContainer
            
            local ElementsPadding = Instance.new("UIPadding")
            ElementsPadding.PaddingLeft = UDim.new(0, 10)
            ElementsPadding.PaddingRight = UDim.new(0, 10)
            ElementsPadding.PaddingTop = UDim.new(0, 8)
            ElementsPadding.PaddingBottom = UDim.new(0, 8)
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
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.Parent = ElementsContainer
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "Button"
                ToggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(40, 40, 45)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Position = UDim2.new(1, -30, 0.5, -10)
                ToggleButton.Size = UDim2.new(0, 30, 0, 20)
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleButton
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "Indicator"
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Position = toggleState and UDim2.new(0, 14, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                ToggleIndicator.Size = UDim2.new(0, 14, 0, 14)
                ToggleIndicator.Parent = ToggleButton
                
                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(1, 0)
                IndicatorCorner.Parent = ToggleIndicator
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggleState = not toggleState
                    ConfigManager.CurrentConfig[configKey] = toggleState
                    
                    Tween(ToggleButton, {
                        BackgroundColor3 = toggleState and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(40, 40, 45)
                    })
                    
                    Tween(ToggleIndicator, {
                        Position = toggleState and UDim2.new(0, 14, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    })
                    
                    callback(toggleState)
                end)
                
                return {
                    Set = function(value)
                        toggleState = value
                        ConfigManager.CurrentConfig[configKey] = toggleState
                        ToggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(40, 40, 45)
                        ToggleIndicator.Position = toggleState and UDim2.new(0, 14, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
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
                SliderFrame.Name = name
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 45)
                SliderFrame.Parent = ElementsContainer
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0, 0, 0, 0)
                SliderLabel.Size = UDim2.new(1, -50, 0, 20)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(1, -50, 0, 0)
                SliderValue.Size = UDim2.new(0, 50, 0, 20)
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.Text = tostring(sliderValue)
                SliderValue.TextColor3 = Color3.fromRGB(100, 100, 255)
                SliderValue.TextSize = 13
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                local SliderBack = Instance.new("Frame")
                SliderBack.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                SliderBack.BorderSizePixel = 0
                SliderBack.Position = UDim2.new(0, 0, 0, 25)
                SliderBack.Size = UDim2.new(1, 0, 0, 6)
                SliderBack.Parent = SliderFrame
                
                local SliderBackCorner = Instance.new("UICorner")
                SliderBackCorner.CornerRadius = UDim.new(1, 0)
                SliderBackCorner.Parent = SliderBack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
                SliderFill.Parent = SliderBack
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 0, 20)
                SliderButton.Position = UDim2.new(0, 0, 0, 20)
                SliderButton.Text = ""
                SliderButton.Parent = SliderFrame
                
                local dragging = false
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local function update()
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
                                
                                callback(sliderValue)
                                RunService.RenderStepped:Wait()
                            end
                        end
                        update()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                return {
                    Set = function(value)
                        sliderValue = math.clamp(value, min, max)
                        ConfigManager.CurrentConfig[configKey] = sliderValue
                        SliderValue.Text = tostring(sliderValue)
                        SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
                        callback(sliderValue)
                    end
                }
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
                DropdownFrame.Name = name
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                DropdownFrame.Parent = ElementsContainer
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                DropdownLabel.Size = UDim2.new(1, -120, 1, 0)
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Position = UDim2.new(1, -110, 0.5, -12)
                DropdownButton.Size = UDim2.new(0, 110, 0, 24)
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = selected
                DropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownButton.TextSize = 12
                DropdownButton.Parent = DropdownFrame
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 4)
                DropdownCorner.Parent = DropdownButton
                
                local DropdownIcon = Instance.new("ImageLabel")
                DropdownIcon.BackgroundTransparency = 1
                DropdownIcon.Position = UDim2.new(1, -18, 0.5, -5)
                DropdownIcon.Size = UDim2.new(0, 10, 0, 10)
                DropdownIcon.Image = "rbxassetid://7733911828"
                DropdownIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                DropdownIcon.Parent = DropdownButton
                
                local DropdownList = Instance.new("Frame")
                DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                DropdownList.BorderSizePixel = 0
                DropdownList.Position = UDim2.new(1, -110, 1, 4)
                DropdownList.Size = UDim2.new(0, 110, 0, 0)
                DropdownList.Visible = false
                DropdownList.ZIndex = 10
                DropdownList.Parent = DropdownButton
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 4)
                ListCorner.Parent = DropdownList
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropdownList
                
                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownList.Visible = not DropdownList.Visible
                    if DropdownList.Visible then
                        Tween(DropdownIcon, {Rotation = 180}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(0, 110, 0, #items * 26)}, 0.2)
                    else
                        Tween(DropdownIcon, {Rotation = 0}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(0, 110, 0, 0)}, 0.2)
                    end
                end)
                
                for _, item in ipairs(items) do
                    local ItemButton = Instance.new("TextButton")
                    ItemButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    ItemButton.BorderSizePixel = 0
                    ItemButton.Size = UDim2.new(1, 0, 0, 26)
                    ItemButton.Font = Enum.Font.Gotham
                    ItemButton.Text = item
                    ItemButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    ItemButton.TextSize = 12
                    ItemButton.Parent = DropdownList
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        selected = item
                        ConfigManager.CurrentConfig[configKey] = selected
                        DropdownButton.Text = item
                        DropdownList.Visible = false
                        Tween(DropdownIcon, {Rotation = 0}, 0.2)
                        Tween(DropdownList, {Size = UDim2.new(0, 110, 0, 0)}, 0.2)
                        callback(item)
                    end)
                    
                    ItemButton.MouseEnter:Connect(function()
                        Tween(ItemButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 255)}, 0.1)
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        Tween(ItemButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.1)
                    end)
                end
                
                return {
                    Set = function(value)
                        if table.find(items, value) then
                            selected = value
                            ConfigManager.CurrentConfig[configKey] = selected
                            DropdownButton.Text = value
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
                            ItemButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                            ItemButton.BorderSizePixel = 0
                            ItemButton.Size = UDim2.new(1, 0, 0, 26)
                            ItemButton.Font = Enum.Font.Gotham
                            ItemButton.Text = item
                            ItemButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                            ItemButton.TextSize = 12
                            ItemButton.Parent = DropdownList
                            
                            ItemButton.MouseButton1Click:Connect(function()
                                selected = item
                                ConfigManager.CurrentConfig[configKey] = selected
                                DropdownButton.Text = item
                                DropdownList.Visible = false
                                Tween(DropdownIcon, {Rotation = 0}, 0.2)
                                callback(item)
                            end)
                        end
                    end
                }
            end
            
            -- Color Picker
            function Section:AddColorPicker(options)
                options = options or {}
                local name = options.Name or "Color"
                local default = options.Default or Color3.fromRGB(100, 100, 255)
                local callback = options.Callback or function() end
                
                local configKey = tabName .. "_" .. sectionName .. "_" .. name
                local selectedColor = default
                
                ConfigManager.CurrentConfig[configKey] = {selectedColor.R, selectedColor.G, selectedColor.B}
                
                local ColorFrame = Instance.new("Frame")
                ColorFrame.Name = name
                ColorFrame.BackgroundTransparency = 1
                ColorFrame.Size = UDim2.new(1, 0, 0, 30)
                ColorFrame.Parent = ElementsContainer
                
                local ColorLabel = Instance.new("TextLabel")
                ColorLabel.BackgroundTransparency = 1
                ColorLabel.Position = UDim2.new(0, 0, 0, 0)
                ColorLabel.Size = UDim2.new(1, -40, 1, 0)
                ColorLabel.Font = Enum.Font.Gotham
                ColorLabel.Text = name
                ColorLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                ColorLabel.TextSize = 13
                ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColorLabel.Parent = ColorFrame
                
                local ColorButton = Instance.new("TextButton")
                ColorButton.BackgroundColor3 = selectedColor
                ColorButton.BorderSizePixel = 0
                ColorButton.Position = UDim2.new(1, -30, 0.5, -10)
                ColorButton.Size = UDim2.new(0, 30, 0, 20)
                ColorButton.Text = ""
                ColorButton.Parent = ColorFrame
                
                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(0, 4)
                ColorCorner.Parent = ColorButton
                
                local ColorPicker = Instance.new("Frame")
                ColorPicker.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                ColorPicker.BorderSizePixel = 0
                ColorPicker.Position = UDim2.new(1, 10, 0, 0)
                ColorPicker.Size = UDim2.new(0, 200, 0, 150)
                ColorPicker.Visible = false
                ColorPicker.ZIndex = 100
                ColorPicker.Parent = ColorButton
                
                local PickerCorner = Instance.new("UICorner")
                PickerCorner.CornerRadius = UDim.new(0, 6)
                PickerCorner.Parent = ColorPicker
                
                ColorButton.MouseButton1Click:Connect(function()
                    ColorPicker.Visible = not ColorPicker.Visible
                end)
                
                -- Simple RGB sliders for color picker
                local function createColorSlider(yPos, colorName, defaultVal)
                    local sliderFrame = Instance.new("Frame")
                    sliderFrame.BackgroundTransparency = 1
                    sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
                    sliderFrame.Size = UDim2.new(1, -20, 0, 30)
                    sliderFrame.Parent = ColorPicker
                    
                    local label = Instance.new("TextLabel")
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(0, 20, 1, 0)
                    label.Font = Enum.Font.Gotham
                    label.Text = colorName
                    label.TextColor3 = Color3.fromRGB(200, 200, 200)
                    label.TextSize = 12
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Parent = sliderFrame
                    
                    local sliderBack = Instance.new("Frame")
                    sliderBack.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    sliderBack.BorderSizePixel = 0
                    sliderBack.Position = UDim2.new(0, 25, 0.5, -3)
                    sliderBack.Size = UDim2.new(1, -55, 0, 6)
                    sliderBack.Parent = sliderFrame
                    
                    local sliderCorner = Instance.new("UICorner")
                    sliderCorner.CornerRadius = UDim.new(1, 0)
                    sliderCorner.Parent = sliderBack
                    
                    local sliderFill = Instance.new("Frame")
                    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                    sliderFill.BorderSizePixel = 0
                    sliderFill.Size = UDim2.new(defaultVal / 255, 0, 1, 0)
                    sliderFill.Parent = sliderBack
                    
                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(1, 0)
                    fillCorner.Parent = sliderFill
                    
                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.Position = UDim2.new(1, -25, 0, 0)
                    valueLabel.Size = UDim2.new(0, 25, 1, 0)
                    valueLabel.Font = Enum.Font.Gotham
                    valueLabel.Text = tostring(math.floor(defaultVal))
                    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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
                            local function update()
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
                            end
                            update()
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
                local gSlider = createColorSlider(45, "G", selectedColor.G * 255)
                local bSlider = createColorSlider(80, "B", selectedColor.B * 255)
                
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
                KeybindFrame.Name = name
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Size = UDim2.new(1, 0, 0, 30)
                KeybindFrame.Parent = ElementsContainer
                
                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Position = UDim2.new(0, 0, 0, 0)
                KeybindLabel.Size = UDim2.new(1, -80, 1, 0)
                KeybindLabel.Font = Enum.Font.Gotham
                KeybindLabel.Text = name
                KeybindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                KeybindLabel.TextSize = 13
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.Parent = KeybindFrame
                
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Position = UDim2.new(1, -70, 0.5, -12)
                KeybindButton.Size = UDim2.new(0, 70, 0, 24)
                KeybindButton.Font = Enum.Font.Gotham
                KeybindButton.Text = currentKey.Name
                KeybindButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                KeybindButton.TextSize = 12
                KeybindButton.Parent = KeybindFrame
                
                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 4)
                KeybindCorner.Parent = KeybindButton
                
                local SettingsIcon = Instance.new("ImageLabel")
                SettingsIcon.BackgroundTransparency = 1
                SettingsIcon.Position = UDim2.new(0, 5, 0.5, -6)
                SettingsIcon.Size = UDim2.new(0, 12, 0, 12)
                SettingsIcon.Image = "rbxassetid://7734053426"
                SettingsIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                SettingsIcon.Parent = KeybindButton
                
                local binding = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    KeybindButton.Text = "..."
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            ConfigManager.CurrentConfig[configKey] = currentKey.Name
                            KeybindButton.Text = currentKey.Name
                            binding = false
                            connection:Disconnect()
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if input.KeyCode == currentKey and not binding then
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
            
            -- Button
            function Section:AddButton(options)
                options = options or {}
                local name = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = name
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size = UDim2.new(1, 0, 0, 32)
                ButtonFrame.Parent = ElementsContainer
                
                local Button = Instance.new("TextButton")
                Button.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Font = Enum.Font.GothamBold
                Button.Text = name
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.TextSize = 13
                Button.Parent = ButtonFrame
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(120, 120, 255)}, 0.1)
                    wait(0.1)
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(100, 100, 255)}, 0.1)
                    callback()
                end)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(110, 110, 255)}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(100, 100, 255)}, 0.2)
                end)
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    -- Config Manager UI
    function Window:AddConfigSection()
        local ConfigTab = Window:CreateTab("Configs")
        local ConfigSection = ConfigTab:CreateSection("Config Manager")
        
        local configInput = ""
        local selectedConfig = ""
        
        -- Config name input (using button to simulate input)
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = "ConfigInput"
        InputFrame.BackgroundTransparency = 1
        InputFrame.Size = UDim2.new(1, 0, 0, 30)
        InputFrame.Parent = ConfigSection.Container
        
        local InputLabel = Instance.new("TextLabel")
        InputLabel.BackgroundTransparency = 1
        InputLabel.Size = UDim2.new(0, 80, 1, 0)
        InputLabel.Font = Enum.Font.Gotham
        InputLabel.Text = "Config Name"
        InputLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        InputLabel.TextSize = 13
        InputLabel.TextXAlignment = Enum.TextXAlignment.Left
        InputLabel.Parent = InputFrame
        
        local InputBox = Instance.new("TextBox")
        InputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        InputBox.BorderSizePixel = 0
        InputBox.Position = UDim2.new(0, 85, 0.5, -12)
        InputBox.Size = UDim2.new(1, -90, 0, 24)
        InputBox.Font = Enum.Font.Gotham
        InputBox.PlaceholderText = "Enter config name..."
        InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputBox.Text = ""
        InputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
        InputBox.TextSize = 12
        InputBox.Parent = InputFrame
        
        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = InputBox
        
        InputBox:GetPropertyChangedSignal("Text"):Connect(function()
            configInput = InputBox.Text
        end)
        
        -- Save button
        ConfigSection:AddButton({
            Name = "Save Config",
            Callback = function()
                if configInput ~= "" then
                    if ConfigManager:SaveConfig(configInput) then
                        print("Config saved:", configInput)
                    end
                end
            end
        })
        
        -- Load config dropdown
        local configDropdown = ConfigSection:AddDropdown({
            Name = "Load Config",
            Items = ConfigManager:GetConfigs(),
            Callback = function(selected)
                local config = ConfigManager:LoadConfig(selected)
                if config then
                    for key, value in pairs(config) do
                        ConfigManager.CurrentConfig[key] = value
                    end
                    -- Apply loaded config to all elements
                    print("Config loaded:", selected)
                end
            end
        })
        
        -- Delete button
        ConfigSection:AddButton({
            Name = "Delete Config",
            Callback = function()
                if configInput ~= "" then
                    ConfigManager:DeleteConfig(configInput)
                    configDropdown:Refresh(ConfigManager:GetConfigs())
                    print("Config deleted:", configInput)
                end
            end
        })
        
        -- Auto-load toggle
        ConfigSection:AddToggle({
            Name = "Auto Load Last Config",
            Default = ConfigManager.AutoLoadEnabled,
            Callback = function(state)
                ConfigManager.AutoLoadEnabled = state
            end
        })
        
        -- Refresh configs button
        ConfigSection:AddButton({
            Name = "Refresh Configs",
            Callback = function()
                configDropdown:Refresh(ConfigManager:GetConfigs())
            end
        })
    end
    
    -- Auto-load last config if enabled
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
