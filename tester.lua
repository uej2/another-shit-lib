-- Axiom UI Library
-- Modern, sleek UI library for Roblox

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- Utility Functions
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props):Play()
end

-- Main Library Functions
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Axiom"
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AxiomUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 20)
    HeaderCover.Position = UDim2.new(0, 0, 1, -20)
    HeaderCover.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = windowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Header
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 4)
    CloseBtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Search Bar
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(1, -20, 0, 30)
    SearchFrame.Position = UDim2.new(0, 10, 0, 50)
    SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SearchFrame.BorderSizePixel = 0
    SearchFrame.Parent = MainFrame
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchFrame
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -35, 1, 0)
    SearchBox.Position = UDim2.new(0, 30, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    SearchBox.TextSize = 14
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Parent = SearchFrame
    
    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size = UDim2.new(0, 20, 1, 0)
    SearchIcon.Position = UDim2.new(0, 8, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextSize = 14
    SearchIcon.Parent = SearchFrame
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -90)
    TabContainer.Position = UDim2.new(0, 10, 0, 90)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -180, 1, -100)
    ContentContainer.Position = UDim2.new(0, 170, 0, 90)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentContainer
    
    MakeDraggable(MainFrame, Header)
    
    local Window = {
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        Tabs = {},
        SearchBox = SearchBox
    }
    
    return setmetatable(Window, Library)
end

function Library:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabButton.Text = ""
    TabButton.BorderSizePixel = 0
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Size = UDim2.new(1, -15, 1, 0)
    TabLabel.Position = UDim2.new(0, 10, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = name
    TabLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabLabel.TextSize = 14
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.Font = Enum.Font.Gotham
    TabLabel.Parent = TabButton
    
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Name = "Indicator"
    TabIndicator.Size = UDim2.new(0, 3, 0, 0)
    TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
    TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
    TabIndicator.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Parent = TabButton
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = TabIndicator
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, -10, 1, -10)
    TabContent.Position = UDim2.new(0, 5, 0, 5)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = TabContent
    
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button:FindFirstChild("Indicator").Size = UDim2.new(0, 3, 0, 0)
            tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            tab.Button.TextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            tab.Content.Visible = false
        end
        
        Tween(TabIndicator, {Size = UDim2.new(0, 3, 0, 20)})
        Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)})
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabContent.Visible = true
    end)
    
    local Tab = {
        Button = TabButton,
        Content = TabContent,
        Elements = {}
    }
    
    table.insert(self.Tabs, Tab)
    
    if #self.Tabs == 1 then
        TabButton.MouseButton1Click:Fire()
    end
    
    return Tab
end

function Library:CreateSection(tab, name)
    local Section = Instance.new("Frame")
    Section.Name = name
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.BorderSizePixel = 0
    Section.Parent = tab.Content
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = name
    SectionLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    SectionLabel.TextSize = 16
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Parent = Section
    
    return Section
end

function Library:CreateToggle(tab, name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = tab.Content
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    ToggleButton.Text = ""
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    ToggleBtnCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    local toggled = default or false
    
    local function UpdateToggle()
        if toggled then
            Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(138, 43, 226)})
            Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)})
        else
            Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)})
            Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)})
        end
        if callback then
            callback(toggled)
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        UpdateToggle()
    end)
    
    UpdateToggle()
    
    return {
        Set = function(value)
            toggled = value
            UpdateToggle()
        end
    }
end

function Library:CreateSlider(tab, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = tab.Content
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -60, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Parent = SliderFrame
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Size = UDim2.new(0, 50, 0, 20)
    SliderValue.Position = UDim2.new(1, -55, 0, 5)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(default or min)
    SliderValue.TextColor3 = Color3.fromRGB(138, 43, 226)
    SliderValue.TextSize = 14
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 1, -15)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(1, 0)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    local value = default or min
    local dragging = false
    
    local function UpdateSlider(input)
        local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * sizeX)
        SliderValue.Text = tostring(value)
        SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
        if callback then
            callback(value)
        end
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UpdateSlider({Position = Vector2.new(SliderBar.AbsolutePosition.X + (SliderBar.AbsoluteSize.X * ((value - min) / (max - min))), 0)})
    
    return {
        Set = function(val)
            value = math.clamp(val, min, max)
            local sizeX = (value - min) / (max - min)
            SliderValue.Text = tostring(value)
            SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
            if callback then
                callback(value)
            end
        end
    }
end

function Library:CreateButton(tab, name, callback)
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Name = name
    ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    ButtonFrame.Text = ""
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.AutoButtonColor = false
    ButtonFrame.Parent = tab.Content
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ButtonFrame
    
    local ButtonLabel = Instance.new("TextLabel")
    ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
    ButtonLabel.BackgroundTransparency = 1
    ButtonLabel.Text = name
    ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonLabel.TextSize = 14
    ButtonLabel.Font = Enum.Font.GothamBold
    ButtonLabel.Parent = ButtonFrame
    
    ButtonFrame.MouseEnter:Connect(function()
        Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(158, 63, 246)})
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(138, 43, 226)})
    end)
    
    ButtonFrame.MouseButton1Click:Connect(function()
        Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(118, 23, 206)})
        wait(0.1)
        Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(138, 43, 226)})
        if callback then
            callback()
        end
    end)
end

function Library:CreateDropdown(tab, name, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = name
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = tab.Content
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 35)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = ""
    DropdownButton.Parent = DropdownFrame
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(1, -60, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = name
    DropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropdownLabel.TextSize = 14
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.Parent = DropdownButton
    
    local DropdownValue = Instance.new("TextLabel")
    DropdownValue.Size = UDim2.new(0, 100, 1, 0)
    DropdownValue.Position = UDim2.new(1, -110, 0, 0)
    DropdownValue.BackgroundTransparency = 1
    DropdownValue.Text = default or options[1] or "None"
    DropdownValue.TextColor3 = Color3.fromRGB(138, 43, 226)
    DropdownValue.TextSize = 13
    DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
    DropdownValue.Font = Enum.Font.Gotham
    DropdownValue.Parent = DropdownButton
    
    local DropdownArrow = Instance.new("TextLabel")
    DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
    DropdownArrow.Position = UDim2.new(1, -25, 0, 0)
    DropdownArrow.BackgroundTransparency = 1
    DropdownArrow.Text = "▼"
    DropdownArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    DropdownArrow.TextSize = 10
    DropdownArrow.Font = Enum.Font.Gotham
    DropdownArrow.Parent = DropdownButton
    
    local OptionContainer = Instance.new("Frame")
    OptionContainer.Size = UDim2.new(1, 0, 0, 0)
    OptionContainer.Position = UDim2.new(0, 0, 0, 35)
    OptionContainer.BackgroundTransparency = 1
    OptionContainer.Parent = DropdownFrame
    
    local OptionList = Instance.new("UIListLayout")
    OptionList.SortOrder = Enum.SortOrder.LayoutOrder
    OptionList.Padding = UDim.new(0, 2)
    OptionList.Parent = OptionContainer
    
    local expanded = false
    local selectedValue = default or options[1]
    
    for _, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        OptionButton.TextSize = 13
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.BorderSizePixel = 0
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionContainer
        
        OptionButton.MouseEnter:Connect(function()
            Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)})
        end)
        
        OptionButton.MouseLeave:Connect(function()
            Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            selectedValue = option
            DropdownValue.Text = option
            expanded = false
            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)})
            Tween(DropdownArrow, {Rotation = 0})
            if callback then
                callback(option)
            end
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            local contentHeight = #options * 32
            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35 + contentHeight)})
            Tween(DropdownArrow, {Rotation = 180})
        else
            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)})
            Tween(DropdownArrow, {Rotation = 0})
        end
    end)
    
    return {
        Set = function(value)
            selectedValue = value
            DropdownValue.Text = value
            if callback then
                callback(value)
            end
        end
    }
end

function Library:CreateInput(tab, name, placeholder, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = name
    InputFrame.Size = UDim2.new(1, 0, 0, 35)
    InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = tab.Content
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputFrame
    
    local InputLabel = Instance.new("TextLabel")
    InputLabel.Size = UDim2.new(0, 100, 1, 0)
    InputLabel.Position = UDim2.new(0, 10, 0, 0)
    InputLabel.BackgroundTransparency = 1
    InputLabel.Text = name
    InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InputLabel.TextSize = 14
    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
    InputLabel.Font = Enum.Font.Gotham
    InputLabel.Parent = InputFrame
    
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -120, 0, 25)
    InputBox.Position = UDim2.new(0, 110, 0, 5)
    InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    InputBox.Text = ""
    InputBox.PlaceholderText = placeholder or ""
    InputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    InputBox.TextSize = 13
    InputBox.Font = Enum.Font.Gotham
    InputBox.BorderSizePixel = 0
    InputBox.Parent = InputFrame
    
    local InputBoxCorner = Instance.new("UICorner")
    InputBoxCorner.CornerRadius = UDim.new(0, 4)
    InputBoxCorner.Parent = InputBox
    
    InputBox.FocusLost:Connect(function(enter)
        if enter and callback then
            callback(InputBox.Text)
        end
    end)
    
    return {
        Set = function(text)
            InputBox.Text = text
        end
    }
end

function Library:CreateLabel(tab, text)
    local LabelFrame = Instance.new("Frame")
    LabelFrame.Size = UDim2.new(1, 0, 0, 25)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.Parent = tab.Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.Font = Enum.Font.Gotham
    Label.Parent = LabelFrame
    
    return {
        Set = function(newText)
            Label.Text = newText
        end
    }
end

return Library
