--[[
	NeonUI - Complete Roblox UI Library (FIXED)
	Modern dark-themed UI library with neon purple accents
	Compatible with all executors
]]

local NeonUI = {}
NeonUI.__index = NeonUI

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Color Scheme
local COLORS = {
	Primary = Color3.fromRGB(88, 0, 255),
	Secondary = Color3.fromRGB(50, 50, 50),
	Tertiary = Color3.fromRGB(25, 25, 25),
	Background = Color3.fromRGB(15, 15, 15),
	Text = Color3.fromRGB(240, 240, 240),
	TextSecondary = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(0, 255, 200),
	Red = Color3.fromRGB(255, 85, 85),
	Green = Color3.fromRGB(85, 255, 85),
}

-- Utility Functions
local function CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		if prop ~= "Parent" then
			instance[prop] = value
		end
	end
	if properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

local function MakeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart = nil
	local frameStart = nil

	dragHandle = dragHandle or frame

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			frameStart = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				frameStart.X.Scale,
				frameStart.X.Offset + delta.X,
				frameStart.Y.Scale,
				frameStart.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function Tween(instance, property, targetValue, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, {[property] = targetValue})
	tween:Play()
	return tween
end

-- Window Component
local Window = {}
Window.__index = Window

function Window.new(title, size, position)
	local self = setmetatable({}, Window)
	
	self.Title = title
	self.Size = size or UDim2.new(0, 600, 0, 500)
	self.Position = position or UDim2.new(0.5, -300, 0.5, -250)
	self.Visible = true
	self.Elements = {}
	self.Tabs = {}
	self.CurrentTab = nil
	
	-- Create ScreenGui
	self.ScreenGui = CreateInstance("ScreenGui", {
		Name = "NeonUI_" .. tick(),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	
	-- Try to parent to CoreGui, fallback to PlayerGui
	local success = pcall(function()
		self.ScreenGui.Parent = game:GetService("CoreGui")
	end)
	
	if not success then
		self.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end
	
	-- Main Frame
	self.Frame = CreateInstance("Frame", {
		Name = "NeonUIWindow",
		Size = self.Size,
		Position = self.Position,
		BackgroundColor3 = COLORS.Tertiary,
		BorderSizePixel = 0,
		Parent = self.ScreenGui,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.Frame,
	})
	
	-- Header
	self.Header = CreateInstance("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = COLORS.Secondary,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.Header,
	})
	
	-- Title Text
	CreateInstance("TextLabel", {
		Name = "TitleText",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = COLORS.Primary,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Header,
	})
	
	-- Close Button
	local closeBtn = CreateInstance("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = COLORS.Red,
		TextColor3 = COLORS.Text,
		Text = "×",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		Parent = self.Header,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = closeBtn,
	})
	
	closeBtn.MouseButton1:Connect(function()
		self.ScreenGui:Destroy()
	end)
	
	-- Make draggable
	MakeDraggable(self.Frame, self.Header)
	
	-- TabBar
	self.TabBar = CreateInstance("Frame", {
		Name = "TabBar",
		Size = UDim2.new(0, 150, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	
	-- TabBar ScrollFrame
	self.TabScroll = CreateInstance("ScrollingFrame", {
		Name = "TabScroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Parent = self.TabBar,
	})
	
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 5),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = self.TabScroll,
	})
	
	CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 5),
		Parent = self.TabScroll,
	})
	
	-- Content Area
	self.ContentArea = CreateInstance("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -150, 1, -40),
		Position = UDim2.new(0, 150, 0, 40),
		BackgroundColor3 = COLORS.Tertiary,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	
	return self
end

function Window:AddTab(name)
	local tab = {
		Name = name,
		Elements = {},
		Button = nil,
		Frame = nil,
	}
	
	-- Tab button
	tab.Button = CreateInstance("TextButton", {
		Name = name .. "Tab",
		Size = UDim2.new(1, -10, 0, 35),
		BackgroundColor3 = COLORS.Secondary,
		TextColor3 = COLORS.Text,
		Text = name,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		BorderSizePixel = 0,
		Parent = self.TabScroll,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = tab.Button,
	})
	
	-- Content frame
	tab.Frame = CreateInstance("ScrollingFrame", {
		Name = name .. "Content",
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Visible = false,
		Parent = self.ContentArea,
	})
	
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Parent = tab.Frame,
	})
	
	CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 5),
		Parent = tab.Frame,
	})
	
	-- Auto-resize canvas
	tab.Frame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		tab.Frame.CanvasSize = UDim2.new(0, 0, 0, tab.Frame.UIListLayout.AbsoluteContentSize.Y + 10)
	end)
	
	self.TabScroll.CanvasSize = UDim2.new(0, 0, 0, self.TabScroll.UIListLayout.AbsoluteContentSize.Y + 10)
	
	-- Tab switching
	tab.Button.MouseButton1:Connect(function()
		if self.CurrentTab then
			self.CurrentTab.Frame.Visible = false
			Tween(self.CurrentTab.Button, "BackgroundColor3", COLORS.Secondary, 0.2)
		end
		self.CurrentTab = tab
		tab.Frame.Visible = true
		Tween(tab.Button, "BackgroundColor3", COLORS.Primary, 0.2)
	end)
	
	-- Select first tab by default
	if #self.Tabs == 0 then
		self.CurrentTab = tab
		tab.Frame.Visible = true
		tab.Button.BackgroundColor3 = COLORS.Primary
	end
	
	table.insert(self.Tabs, tab)
	return tab
end

function Window:AddLabel(text, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local label = CreateInstance("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -20, 0, 25),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = tab.Frame,
	})
	
	return label
end

function Window:AddButton(text, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local button = CreateInstance("TextButton", {
		Name = "Button",
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundColor3 = COLORS.Primary,
		TextColor3 = COLORS.Text,
		Text = text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		Parent = tab.Frame,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = button,
	})
	
	button.MouseEnter:Connect(function()
		Tween(button, "BackgroundColor3", Color3.fromRGB(120, 30, 255), 0.1)
	end)
	
	button.MouseLeave:Connect(function()
		Tween(button, "BackgroundColor3", COLORS.Primary, 0.1)
	end)
	
	button.MouseButton1:Connect(function()
		if callback then
			callback()
		end
	end)
	
	return button
end

function Window:AddToggle(text, default, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local toggle = {
		Value = default or false,
	}
	
	local container = CreateInstance("Frame", {
		Name = "ToggleContainer",
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundTransparency = 1,
		Parent = tab.Frame,
	})
	
	local label = CreateInstance("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})
	
	local switchContainer = CreateInstance("Frame", {
		Name = "Switch",
		Size = UDim2.new(0, 50, 0, 26),
		Position = UDim2.new(1, -50, 0.5, -13),
		BackgroundColor3 = toggle.Value and COLORS.Primary or COLORS.Secondary,
		BorderSizePixel = 0,
		Parent = container,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 13),
		Parent = switchContainer,
	})
	
	local switchButton = CreateInstance("Frame", {
		Name = "SwitchButton",
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(0, toggle.Value and 24 or 2, 0.5, -11),
		BackgroundColor3 = COLORS.Text,
		BorderSizePixel = 0,
		Parent = switchContainer,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = switchButton,
	})
	
	local clickDetector = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		Parent = switchContainer,
	})
	
	function toggle:Set(value)
		self.Value = value
		Tween(switchContainer, "BackgroundColor3", value and COLORS.Primary or COLORS.Secondary, 0.15)
		Tween(switchButton, "Position", UDim2.new(0, value and 24 or 2, 0.5, -11), 0.15)
		if callback then
			callback(value)
		end
	end
	
	clickDetector.MouseButton1:Connect(function()
		toggle:Set(not toggle.Value)
	end)
	
	return toggle
end

function Window:AddSlider(text, min, max, default, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local slider = {
		Value = default or min,
		Min = min,
		Max = max,
	}
	
	local container = CreateInstance("Frame", {
		Name = "SliderContainer",
		Size = UDim2.new(1, -20, 0, 50),
		BackgroundTransparency = 1,
		Parent = tab.Frame,
	})
	
	local label = CreateInstance("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = text .. ": " .. (default or min),
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})
	
	local sliderBg = CreateInstance("Frame", {
		Name = "SliderBG",
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = COLORS.Secondary,
		BorderSizePixel = 0,
		Parent = container,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = sliderBg,
	})
	
	local sliderFill = CreateInstance("Frame", {
		Name = "SliderFill",
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Parent = sliderBg,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = sliderFill,
	})
	
	local knob = CreateInstance("Frame", {
		Name = "Knob",
		Size = UDim2.new(0, 14, 0, 20),
		Position = UDim2.new((default - min) / (max - min), -7, 0.5, -10),
		BackgroundColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Parent = sliderBg,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = knob,
	})
	
	local clickDetector = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 20),
		Position = UDim2.new(0, 0, 0, -10),
		BackgroundTransparency = 1,
		Text = "",
		Parent = sliderBg,
	})
	
	local dragging = false
	
	clickDetector.MouseButton1Down:Connect(function()
		dragging = true
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	local function UpdateSlider(input)
		local mousePos = input.Position.X
		local sliderPos = sliderBg.AbsolutePosition.X
		local sliderSize = sliderBg.AbsoluteSize.X
		local relativePos = math.clamp(mousePos - sliderPos, 0, sliderSize)
		local percentage = relativePos / sliderSize
		
		local newValue = math.floor(min + (max - min) * percentage)
		slider.Value = newValue
		
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		knob.Position = UDim2.new(percentage, -7, 0.5, -10)
		label.Text = text .. ": " .. newValue
		
		if callback then
			callback(newValue)
		end
	end
	
	clickDetector.MouseButton1:Connect(UpdateSlider)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateSlider(input)
		end
	end)
	
	return slider
end

function Window:AddTextBox(placeholder, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local textbox = CreateInstance("TextBox", {
		Name = "TextBox",
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundColor3 = COLORS.Secondary,
		TextColor3 = COLORS.Text,
		PlaceholderColor3 = COLORS.TextSecondary,
		PlaceholderText = placeholder,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		Text = "",
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Parent = tab.Frame,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = textbox,
	})
	
	CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = textbox,
	})
	
	textbox.FocusLost:Connect(function(enterPressed)
		if callback then
			callback(textbox.Text)
		end
	end)
	
	return textbox
end

function Window:AddDropdown(text, options, default, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local dropdown = {
		Value = default or options[1],
		Open = false,
		Options = options,
	}
	
	local container = CreateInstance("Frame", {
		Name = "DropdownContainer",
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = tab.Frame,
	})
	
	local label = CreateInstance("TextLabel", {
		Name = "Label",
		Size = UDim2.new(0, 100, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})
	
	local dropdownBtn = CreateInstance("TextButton", {
		Name = "DropdownButton",
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 110, 0, 0),
		BackgroundColor3 = COLORS.Secondary,
		TextColor3 = COLORS.Text,
		Text = dropdown.Value,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		BorderSizePixel = 0,
		Parent = container,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = dropdownBtn,
	})
	
	local dropdownList = CreateInstance("Frame", {
		Name = "DropdownList",
		Size = UDim2.new(1, -110, 0, 0),
		Position = UDim2.new(0, 110, 1, 5),
		BackgroundColor3 = COLORS.Secondary,
		BorderSizePixel = 0,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 10,
		Parent = container,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = dropdownList,
	})
	
	CreateInstance("UIListLayout", {
		Parent = dropdownList,
	})
	
	local function CloseDropdown()
		dropdown.Open = false
		Tween(dropdownList, "Size", UDim2.new(1, -110, 0, 0), 0.15)
		task.wait(0.15)
		dropdownList.Visible = false
	end
	
	local function OpenDropdown()
		dropdown.Open = true
		dropdownList.Visible = true
		Tween(dropdownList, "Size", UDim2.new(1, -110, 0, #options * 32), 0.15)
	end
	
	for _, option in ipairs(options) do
		local optionBtn = CreateInstance("TextButton", {
			Name = "Option",
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = COLORS.Secondary,
			TextColor3 = COLORS.Text,
			Text = option,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			BorderSizePixel = 0,
			Parent = dropdownList,
		})
		
		optionBtn.MouseEnter:Connect(function()
			Tween(optionBtn, "BackgroundColor3", COLORS.Tertiary, 0.1)
		end)
		
		optionBtn.MouseLeave:Connect(function()
			Tween(optionBtn, "BackgroundColor3", COLORS.Secondary, 0.1)
		end)
		
		optionBtn.MouseButton1:Connect(function()
			dropdown.Value = option
			dropdownBtn.Text = option
			CloseDropdown()
			if callback then
				callback(option)
			end
		end)
	end
	
	dropdownBtn.MouseButton1:Connect(function()
		if dropdown.Open then
			CloseDropdown()
		else
			OpenDropdown()
		end
	end)
	
	return dropdown
end

function Window:AddDivider(tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local divider = CreateInstance("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, -20, 0, 2),
		BackgroundColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Parent = tab.Frame,
	})
	
	return divider
end

function Window:Toggle()
	self.Visible = not self.Visible
	self.Frame.Visible = self.Visible
end

function Window:Destroy()
	self.ScreenGui:Destroy()
end

-- Library export
return {
	Window = Window,
	Colors = COLORS,
	CreateInstance = CreateInstance,
}
