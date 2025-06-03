-- Kali Hub UI Library
-- Advanced Roblox GUI Library with modern design

local KaliHub = {}
KaliHub.__index = KaliHub

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration
local Config = {
    -- Colors
    Primary = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(75, 0, 130),
    Background = Color3.fromRGB(30, 30, 35),
    Surface = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(186, 85, 211),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(76, 175, 80),
    Error = Color3.fromRGB(244, 67, 54),
    
    -- Animation
    AnimationSpeed = 0.3,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out,
    
    -- Sizes
    WindowSize = UDim2.new(0, 450, 0, 600),
    HeaderHeight = 50,
    TabHeight = 35,
    ElementHeight = 30,
    Padding = 12,
    CornerRadius = 8
}

-- Utility Functions
local function CreateTween(object, properties, duration)
    duration = duration or Config.AnimationSpeed
    local tweenInfo = TweenInfo.new(
        duration,
        Config.EasingStyle,
        Config.EasingDirection,
        0,
        false,
        0
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Config.CornerRadius)
    corner.Parent = parent
    return corner
end

local function CreateGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function CreateStroke(parent, thickness, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Config.Primary
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

-- Main Library Constructor
function KaliHub.new(title)
    local self = setmetatable({}, KaliHub)
    
    self.Title = title or "Kali Hub"
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsVisible = true
    self.IsDragging = false
    
    self:CreateMainGui()
    self:SetupDragging()
    
    return self
end

function KaliHub:CreateMainGui()
    -- Destroy existing GUI if it exists
    local existingGui = PlayerGui:FindFirstChild("KaliHubGui")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Main ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "KaliHubGui"
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.Parent = PlayerGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = Config.WindowSize
    self.MainFrame.Position = UDim2.new(0.5, -Config.WindowSize.X.Offset/2, 0.5, -Config.WindowSize.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = Config.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.Gui
    
    CreateCorner(self.MainFrame, Config.CornerRadius)
    CreateStroke(self.MainFrame, 2, Config.Primary, 0.3)
    
    -- Add shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = self.MainFrame
    
    -- Header Frame
    self.HeaderFrame = Instance.new("Frame")
    self.HeaderFrame.Name = "Header"
    self.HeaderFrame.Size = UDim2.new(1, 0, 0, Config.HeaderHeight)
    self.HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    self.HeaderFrame.BackgroundColor3 = Config.Surface
    self.HeaderFrame.BorderSizePixel = 0
    self.HeaderFrame.Parent = self.MainFrame
    
    CreateCorner(self.HeaderFrame, Config.CornerRadius)
    CreateGradient(self.HeaderFrame, {Config.Primary, Config.Secondary}, 45)
    
    -- Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, Config.Padding, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Config.Text
    self.TitleLabel.TextSize = 18
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.HeaderFrame
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
    self.CloseButton.BackgroundColor3 = Config.Error
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Config.Text
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.HeaderFrame
    
    CreateCorner(self.CloseButton, 15)
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, Config.TabHeight)
    self.TabContainer.Position = UDim2.new(0, 0, 0, Config.HeaderHeight)
    self.TabContainer.BackgroundColor3 = Config.Surface
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = self.TabContainer
    
    -- Content Frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "Content"
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -(Config.HeaderHeight + Config.TabHeight))
    self.ContentFrame.Position = UDim2.new(0, 0, 0, Config.HeaderHeight + Config.TabHeight)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = 4
    self.ContentFrame.ScrollBarImageColor3 = Config.Primary
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentFrame.Parent = self.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = self.ContentFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, Config.Padding)
    contentPadding.PaddingBottom = UDim.new(0, Config.Padding)
    contentPadding.PaddingLeft = UDim.new(0, Config.Padding)
    contentPadding.PaddingRight = UDim.new(0, Config.Padding)
    contentPadding.Parent = self.ContentFrame
    
    -- Auto-resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + Config.Padding * 2)
    end)
    
    -- Close button functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    -- Hover effects for close button
    self.CloseButton.MouseEnter:Connect(function()
        CreateTween(self.CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        CreateTween(self.CloseButton, {BackgroundColor3 = Config.Error}):Play()
    end)
end

function KaliHub:SetupDragging()
    local dragStart = nil
    local startPos = nil
    
    self.HeaderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end)
end

-- Tab Management
function KaliHub:CreateTab(name)
    local tab = {
        Name = name,
        Button = nil,
        Content = nil,
        Elements = {},
        IsActive = false
    }
    
    -- Tab Button
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name .. "Tab"
    tab.Button.Size = UDim2.new(0, 100, 1, 0)
    tab.Button.BackgroundColor3 = Config.Surface
    tab.Button.BorderSizePixel = 0
    tab.Button.Text = name
    tab.Button.TextColor3 = Config.TextSecondary
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.Gotham
    tab.Button.Parent = self.TabContainer
    
    CreateCorner(tab.Button, 4)
    
    -- Tab Content
    tab.Content = Instance.new("Frame")
    tab.Content.Name = name .. "Content"
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Visible = false
    tab.Content.Parent = self.ContentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tab.Content
    
    -- Tab button click
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    -- Hover effects
    tab.Button.MouseEnter:Connect(function()
        if not tab.IsActive then
            CreateTween(tab.Button, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if not tab.IsActive then
            CreateTween(tab.Button, {BackgroundColor3 = Config.Surface}):Play()
        end
    end)
    
    self.Tabs[name] = tab
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SwitchTab(name)
    end
    
    return self:CreateTabInterface(tab)
end

function KaliHub:CreateTabInterface(tab)
    local interface = {}
    
    function interface:AddToggle(text, default, callback)
        local toggle = Instance.new("Frame")
        toggle.Name = text .. "Toggle"
        toggle.Size = UDim2.new(1, 0, 0, Config.ElementHeight)
        toggle.BackgroundColor3 = Config.Surface
        toggle.BorderSizePixel = 0
        toggle.Parent = tab.Content
        
        CreateCorner(toggle, 6)
        CreateStroke(toggle, 1, Config.Primary, 0.7)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, Config.Padding, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggle
        
        local switchFrame = Instance.new("Frame")
        switchFrame.Size = UDim2.new(0, 40, 0, 20)
        switchFrame.Position = UDim2.new(1, -50, 0.5, -10)
        switchFrame.BackgroundColor3 = default and Config.Success or Config.TextSecondary
        switchFrame.BorderSizePixel = 0
        switchFrame.Parent = toggle
        
        CreateCorner(switchFrame, 10)
        
        local switchButton = Instance.new("Frame")
        switchButton.Size = UDim2.new(0, 16, 0, 16)
        switchButton.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        switchButton.BackgroundColor3 = Config.Text
        switchButton.BorderSizePixel = 0
        switchButton.Parent = switchFrame
        
        CreateCorner(switchButton, 8)
        
        local isEnabled = default or false
        
        local function updateToggle()
            local newColor = isEnabled and Config.Success or Config.TextSecondary
            local newPos = isEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            
            CreateTween(switchFrame, {BackgroundColor3 = newColor}):Play()
            CreateTween(switchButton, {Position = newPos}):Play()
            
            if callback then
                callback(isEnabled)
            end
        end
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = toggle
        
        button.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            updateToggle()
        end)
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            CreateTween(toggle, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            CreateTween(toggle, {BackgroundColor3 = Config.Surface}):Play()
        end)
        
        return {
            SetValue = function(value)
                isEnabled = value
                updateToggle()
            end,
            GetValue = function()
                return isEnabled
            end
        }
    end
    
    function interface:AddButton(text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(1, 0, 0, Config.ElementHeight)
        button.BackgroundColor3 = Config.Primary
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Config.Text
        button.TextSize = 14
        button.Font = Enum.Font.GothamMedium
        button.Parent = tab.Content
        
        CreateCorner(button, 6)
        CreateGradient(button, {Config.Primary, Config.Secondary}, 45)
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        -- Hover and click effects
        button.MouseEnter:Connect(function()
            CreateTween(button, {Size = UDim2.new(1, 0, 0, Config.ElementHeight + 2)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            CreateTween(button, {Size = UDim2.new(1, 0, 0, Config.ElementHeight)}):Play()
        end)
        
        button.MouseButton1Down:Connect(function()
            CreateTween(button, {Size = UDim2.new(1, 0, 0, Config.ElementHeight - 2)}):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            CreateTween(button, {Size = UDim2.new(1, 0, 0, Config.ElementHeight)}):Play()
        end)
        
        return button
    end
    
    function interface:AddDropdown(text, options, default, callback)
        local dropdown = Instance.new("Frame")
        dropdown.Name = text .. "Dropdown"
        dropdown.Size = UDim2.new(1, 0, 0, Config.ElementHeight)
        dropdown.BackgroundColor3 = Config.Surface
        dropdown.BorderSizePixel = 0
        dropdown.Parent = tab.Content
        
        CreateCorner(dropdown, 6)
        CreateStroke(dropdown, 1, Config.Primary, 0.7)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Position = UDim2.new(0, Config.Padding, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = dropdown
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0.6, -Config.Padding, 0.8, 0)
        dropdownButton.Position = UDim2.new(0.4, 0, 0.1, 0)
        dropdownButton.BackgroundColor3 = Config.Background
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Text = default or (options[1] or "Select...")
        dropdownButton.TextColor3 = Config.Text
        dropdownButton.TextSize = 12
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.Parent = dropdown
        
        CreateCorner(dropdownButton, 4)
        
        local isOpen = false
        local selectedValue = default or options[1]
        
        local dropdownList = Instance.new("Frame")
        dropdownList.Name = "DropdownList"
        dropdownList.Size = UDim2.new(0.6, -Config.Padding, 0, 0)
        dropdownList.Position = UDim2.new(0.4, 0, 1, 2)
        dropdownList.BackgroundColor3 = Config.Background
        dropdownList.BorderSizePixel = 0
        dropdownList.Visible = false
        dropdownList.ZIndex = 10
        dropdownList.Parent = dropdown
        
        CreateCorner(dropdownList, 4)
        CreateStroke(dropdownList, 1, Config.Primary, 0.5)
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = dropdownList
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            optionButton.BackgroundTransparency = 1
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = Config.Text
            optionButton.TextSize = 12
            optionButton.Font = Enum.Font.Gotham
            optionButton.Parent = dropdownList
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundTransparency = 0.8
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundTransparency = 1
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selectedValue = option
                dropdownButton.Text = option
                isOpen = false
                dropdownList.Visible = false
                CreateTween(dropdownList, {Size = UDim2.new(0.6, -Config.Padding, 0, 0)}):Play()
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            dropdownList.Visible = isOpen
            
            if isOpen then
                local targetHeight = #options * 25
                CreateTween(dropdownList, {Size = UDim2.new(0.6, -Config.Padding, 0, targetHeight)}):Play()
            else
                CreateTween(dropdownList, {Size = UDim2.new(0.6, -Config.Padding, 0, 0)}):Play()
                wait(Config.AnimationSpeed)
                dropdownList.Visible = false
            end
        end)
        
        return {
            SetValue = function(value)
                selectedValue = value
                dropdownButton.Text = value
                if callback then
                    callback(value)
                end
            end,
            GetValue = function()
                return selectedValue
            end
        }
    end
    
    function interface:AddSlider(text, min, max, default, callback)
        local slider = Instance.new("Frame")
        slider.Name = text .. "Slider"
        slider.Size = UDim2.new(1, 0, 0, Config.ElementHeight + 10)
        slider.BackgroundColor3 = Config.Surface
        slider.BorderSizePixel = 0
        slider.Parent = tab.Content
        
        CreateCorner(slider, 6)
        CreateStroke(slider, 1, Config.Primary, 0.7)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 0.5, 0)
        label.Position = UDim2.new(0, Config.Padding, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = slider
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.5, -Config.Padding, 0.5, 0)
        valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default or min)
        valueLabel.TextColor3 = Config.Primary
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamMedium
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = slider
        
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(1, -Config.Padding * 2, 0, 4)
        sliderTrack.Position = UDim2.new(0, Config.Padding, 0.7, -2)
        sliderTrack.BackgroundColor3 = Config.Background
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = slider
        
        CreateCorner(sliderTrack, 2)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0, 0, 1, 0)
        sliderFill.BackgroundColor3 = Config.Primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderTrack
        
        CreateCorner(sliderFill, 2)
        CreateGradient(sliderFill, {Config.Primary, Config.Secondary}, 0)
        
        local sliderButton = Instance.new("Frame")
        sliderButton.Size = UDim2.new(0, 16, 0, 16)
        sliderButton.Position = UDim2.new(0, -8, 0.5, -8)
        sliderButton.BackgroundColor3 = Config.Text
        sliderButton.BorderSizePixel = 0
        sliderButton.Parent = sliderTrack
        
        CreateCorner(sliderButton, 8)
        CreateStroke(sliderButton, 2, Config.Primary)
        
        local isDragging = false
        local currentValue = default or min
        
        local function updateSlider(value)
            currentValue = math.clamp(value, min, max)
            local percentage = (currentValue - min) / (max - min)
            
            CreateTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
            CreateTween(sliderButton, {Position = UDim2.new(percentage, -8, 0.5, -8)}):Play()
            
            valueLabel.Text = string.format("%.1f", currentValue)
            
            if callback then
                callback(currentValue)
            end
        end
        
        local dragButton = Instance.new("TextButton")
        dragButton.Size = UDim2.new(1, 0, 1, 0)
        dragButton.BackgroundTransparency = 1
        dragButton.Text = ""
        dragButton.Parent = sliderTrack
        
        dragButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percentage
                updateSlider(value)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percentage
                updateSlider(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        -- Initialize slider
        updateSlider(currentValue)
        
        return {
            SetValue = function(value)
                updateSlider(value)
            end,
            GetValue = function()
                return currentValue
            end
        }
    end
    
    function interface:AddLabel(text)
        local label = Instance.new("TextLabel")
        label.Name = text .. "Label"
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.TextSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tab.Content
        
        return label
    end
    
    function interface:AddTextBox(text, placeholder, callback)
        local textboxFrame = Instance.new("Frame")
        textboxFrame.Name = text .. "TextBox"
        textboxFrame.Size = UDim2.new(1, 0, 0, Config.ElementHeight)
        textboxFrame.BackgroundColor3 = Config.Surface
        textboxFrame.BorderSizePixel = 0
        textboxFrame.Parent = tab.Content
        
        CreateCorner(textboxFrame, 6)
        CreateStroke(textboxFrame, 1, Config.Primary, 0.7)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.3, 0, 1, 0)
        label.Position = UDim2.new(0, Config.Padding, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = textboxFrame
        
        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(0.7, -Config.Padding, 0.8, 0)
        textbox.Position = UDim2.new(0.3, 0, 0.1, 0)
        textbox.BackgroundColor3 = Config.Background
        textbox.BorderSizePixel = 0
        textbox.Text = ""
        textbox.PlaceholderText = placeholder or "Enter text..."
        textbox.TextColor3 = Config.Text
        textbox.PlaceholderColor3 = Config.TextSecondary
        textbox.TextSize = 12
        textbox.Font = Enum.Font.Gotham
        textbox.ClearTextOnFocus = false
        textbox.Parent = textboxFrame
        
        CreateCorner(textbox, 4)
        
        textbox.FocusLost:Connect(function(enterPressed)
            if callback then
                callback(textbox.Text, enterPressed)
            end
        end)
        
        -- Focus effects
        textbox.Focused:Connect(function()
            CreateTween(textboxFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
            CreateStroke(textboxFrame, 1, Config.Primary, 0.3)
        end)
        
        textbox.FocusLost:Connect(function()
            CreateTween(textboxFrame, {BackgroundColor3 = Config.Surface}):Play()
            CreateStroke(textboxFrame, 1, Config.Primary, 0.7)
        end)
        
        return {
            SetText = function(newText)
                textbox.Text = newText
            end,
            GetText = function()
                return textbox.Text
            end
        }
    end
    
    function interface:AddKeybind(text, defaultKey, callback)
        local keybind = Instance.new("Frame")
        keybind.Name = text .. "Keybind"
        keybind.Size = UDim2.new(1, 0, 0, Config.ElementHeight)
        keybind.BackgroundColor3 = Config.Surface
        keybind.BorderSizePixel = 0
        keybind.Parent = tab.Content
        
        CreateCorner(keybind, 6)
        CreateStroke(keybind, 1, Config.Primary, 0.7)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, Config.Padding, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = keybind
        
        local keybindButton = Instance.new("TextButton")
        keybindButton.Size = UDim2.new(0.4, -Config.Padding, 0.8, 0)
        keybindButton.Position = UDim2.new(0.6, 0, 0.1, 0)
        keybindButton.BackgroundColor3 = Config.Background
        keybindButton.BorderSizePixel = 0
        keybindButton.Text = defaultKey and defaultKey.Name or "None"
        keybindButton.TextColor3 = Config.Text
        keybindButton.TextSize = 12
        keybindButton.Font = Enum.Font.GothamMedium
        keybindButton.Parent = keybind
        
        CreateCorner(keybindButton, 4)
        
        local currentKey = defaultKey
        local isBinding = false
        
        local function updateKeybind(key)
            currentKey = key
            keybindButton.Text = key and key.Name or "None"
            
            if callback then
                callback(key)
            end
        end
        
        keybindButton.MouseButton1Click:Connect(function()
            if isBinding then return end
            
            isBinding = true
            keybindButton.Text = "Press a key..."
            keybindButton.TextColor3 = Config.Primary
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    updateKeybind(input.KeyCode)
                    keybindButton.TextColor3 = Config.Text
                    isBinding = false
                    connection:Disconnect()
                end
            end)
            
            -- Timeout after 5 seconds
            task.wait(5)
            if isBinding then
                keybindButton.Text = currentKey and currentKey.Name or "None"
                keybindButton.TextColor3 = Config.Text
                isBinding = false
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        -- Key detection for activation
        if defaultKey then
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or not currentKey then return end
                
                if input.KeyCode == currentKey then
                    if callback then
                        callback(currentKey, true) -- true indicates key was pressed
                    end
                end
            end)
        end
        
        return {
            SetKey = function(key)
                updateKeybind(key)
            end,
            GetKey = function()
                return currentKey
            end
        }
    end
    
    function interface:AddSeparator()
        local separator = Instance.new("Frame")
        separator.Name = "Separator"
        separator.Size = UDim2.new(1, 0, 0, 1)
        separator.BackgroundColor3 = Config.Primary
        separator.BorderSizePixel = 0
        separator.BackgroundTransparency = 0.7
        separator.Parent = tab.Content
        
        return separator
    end
    
    function interface:AddColorPicker(text, defaultColor, callback)
        local colorPicker = Instance.new("Frame")
        colorPicker.Name = text .. "ColorPicker"
        colorPicker.Size = UDim2.new(1, 0, 0, Config.ElementHeight)
        colorPicker.BackgroundColor3 = Config.Surface
        colorPicker.BorderSizePixel = 0
        colorPicker.Parent = tab.Content
        
        CreateCorner(colorPicker, 6)
        CreateStroke(colorPicker, 1, Config.Primary, 0.7)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, Config.Padding, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Config.Text
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = colorPicker
        
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(0, 50, 0.8, 0)
        colorDisplay.Position = UDim2.new(1, -60, 0.1, 0)
        colorDisplay.BackgroundColor3 = defaultColor or Config.Primary
        colorDisplay.BorderSizePixel = 0
        colorDisplay.Parent = colorPicker
        
        CreateCorner(colorDisplay, 4)
        CreateStroke(colorDisplay, 1, Config.Text, 0.3)
        
        local currentColor = defaultColor or Config.Primary
        
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(1, 0, 1, 0)
        colorButton.BackgroundTransparency = 1
        colorButton.Text = ""
        colorButton.Parent = colorDisplay
        
        colorButton.MouseButton1Click:Connect(function()
            -- Simple color cycling for demo (in real implementation, you'd want a proper color picker)
            local colors = {
                Color3.fromRGB(255, 0, 0),    -- Red
                Color3.fromRGB(0, 255, 0),    -- Green
                Color3.fromRGB(0, 0, 255),    -- Blue
                Color3.fromRGB(255, 255, 0),  -- Yellow
                Color3.fromRGB(255, 0, 255),  -- Magenta
                Color3.fromRGB(0, 255, 255),  -- Cyan
                Config.Primary
            }
            
            local currentIndex = 1
            for i, color in ipairs(colors) do
                if currentColor == color then
                    currentIndex = i
                    break
                end
            end
            
            currentIndex = currentIndex % #colors + 1
            currentColor = colors[currentIndex]
            
            CreateTween(colorDisplay, {BackgroundColor3 = currentColor}):Play()
            
            if callback then
                callback(currentColor)
            end
        end)
        
        return {
            SetColor = function(color)
                currentColor = color
                CreateTween(colorDisplay, {BackgroundColor3 = color}):Play()
                if callback then
                    callback(color)
                end
            end,
            GetColor = function()
                return currentColor
            end
        }
    end
    
    return interface
end

function KaliHub:SwitchTab(tabName)
    -- Hide all tabs
    for name, tab in pairs(self.Tabs) do
        tab.Content.Visible = false
        tab.IsActive = false
        CreateTween(tab.Button, {
            BackgroundColor3 = Config.Surface,
            TextColor3 = Config.TextSecondary
        }):Play()
    end
    
    -- Show selected tab
    if self.Tabs[tabName] then
        local tab = self.Tabs[tabName]
        tab.Content.Visible = true
        tab.IsActive = true
        self.CurrentTab = tabName
        
        CreateTween(tab.Button, {
            BackgroundColor3 = Config.Primary,
            TextColor3 = Config.Text
        }):Play()
    end
end

function KaliHub:Show()
    self.IsVisible = true
    self.Gui.Enabled = true
    
    -- Entrance animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    CreateTween(self.MainFrame, {
        Size = Config.WindowSize,
        Position = UDim2.new(0.5, -Config.WindowSize.X.Offset/2, 0.5, -Config.WindowSize.Y.Offset/2)
    }, 0.5):Play()
end

function KaliHub:Hide()
    self.IsVisible = false
    
    -- Exit animation
    local exitTween = CreateTween(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.3)
    
    exitTween:Play()
    exitTween.Completed:Connect(function()
        self.Gui.Enabled = false
    end)
end

function KaliHub:Toggle()
    if self.IsVisible then
        self:Hide()
    else
        self:Show()
    end
end

function KaliHub:Destroy()
    if self.Gui then
        self.Gui:Destroy()
    end
end

-- Usage Example
--[[
local gui = 

-- Create Main tab
local mainTab = gui:CreateTab("Main")
mainTab:AddLabel("Welcome to Kali Hub!")
mainTab:AddSeparator()

local aimbot = mainTab:AddToggle("Enable Aimbot", false, function(state)
    print("Aimbot:", state)
end)

local wallCheck = mainTab:AddToggle("Wall Check", true, function(state)
    print("Wall Check:", state)
end)

local esp = mainTab:AddToggle("Enable ESP", false, function(state)
    print("ESP:", state)
end)

mainTab:AddSeparator()

local targetPart = mainTab:AddDropdown("Aimbot Target Part", {
    "Head", "Torso", "HumanoidRootPart"
}, "Head", function(selected)
    print("Target Part:", selected)
end)

mainTab:AddButton("Unlock Mouse Cursor", function()
    print("Mouse cursor unlocked!")
end)

local proximity = mainTab:AddToggle("Instant Proximity Prompts", false, function(state)
    print("Proximity Prompts:", state)
end)

local doorHitboxes = mainTab:AddToggle("Enlarge Door Hitboxes", false, function(state)
    print("Door Hitboxes:", state)
end)

-- Create Settings tab
local settingsTab = gui:CreateTab("Settings")
settingsTab:AddLabel("Configuration Settings")
settingsTab:AddSeparator()

local fovSlider = settingsTab:AddSlider("FOV", 30, 180, 90, function(value)
    print("FOV:", value)
end)

local sensitivitySlider = settingsTab:AddSlider("Mouse Sensitivity", 0.1, 5.0, 1.0, function(value)
    print("Sensitivity:", value)
end)

settingsTab:AddSeparator()

local toggleKey = settingsTab:AddKeybind("Toggle GUI", Enum.KeyCode.Insert, function(key, pressed)
    if pressed then
        gui:Toggle()
    end
end)

local colorPicker = settingsTab:AddColorPicker("Theme Color", Config.Primary, function(color)
    print("Theme Color:", color)
end)

local configName = settingsTab:AddTextBox("Config Name", "MyConfig", function(text)
    print("Config Name:", text)
end)

settingsTab:AddButton("Save Config", function()
    print("Config saved!")
end)

settingsTab:AddButton("Load Config", function()
    print("Config loaded!")
end)

-- Show the GUI
gui:Show()

-- Toggle with Insert key
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        gui:Toggle()
    end
end)
--]]

return KaliHub
