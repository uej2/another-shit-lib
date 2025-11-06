--[[
	NeonUI - Complete Roblox UI Library
	Modern dark-themed UI library with neon purple accents
	Usage: local Library = loadstring(game:HttpGetAsync("RAW_GITHUB_URL"))()
]]

local NeonUI = {}
NeonUI.__index = NeonUI

-- Color Scheme
local COLORS = {
	Primary = Color3.fromRGB(88, 0, 255),      -- Neon Purple
	Secondary = Color3.fromRGB(50, 50, 50),   -- Dark Gray
	Tertiary = Color3.fromRGB(25, 25, 25),    -- Almost Black
	Background = Color3.fromRGB(15, 15, 15),  -- Very Dark
	Text = Color3.fromRGB(240, 240, 240),     -- Light Gray
	TextSecondary = Color3.fromRGB(150, 150, 150), -- Medium Gray
	Accent = Color3.fromRGB(0, 255, 200),     -- Cyan
	Red = Color3.fromRGB(255, 85, 85),
	Green = Color3.fromRGB(85, 255, 85),
}

-- Utility Functions
local function CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		instance[prop] = value
	end
	return instance
end

local function MakeDraggable(frame)
	local dragging = false
	local dragStart = nil
	local frameStart = nil

	frame.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			frameStart = frame.Position
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function AnimatePropertyChange(instance, property, targetValue, duration)
	local startValue = instance[property]
	local startTime = tick()
	
	if typeof(targetValue) == "Color3" then
		local startColor = startValue
		while tick() - startTime < duration do
			local progress = math.min((tick() - startTime) / duration, 1)
			instance[property] = startColor:Lerp(targetValue, progress)
			task.wait(0.016)
		end
		instance[property] = targetValue
	elseif typeof(targetValue) == "number" then
		local startNum = startValue
		while tick() - startTime < duration do
			local progress = math.min((tick() - startTime) / duration, 1)
			instance[property] = startNum + (targetValue - startNum) * progress
			task.wait(0.016)
		end
		instance[property] = targetValue
	end
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
	
	-- Main Frame
	self.Frame = CreateInstance("Frame", {
		Name = "NeonUIWindow",
		Size = self.Size,
		Position = self.Position,
		BackgroundColor3 = COLORS.Tertiary,
		BorderSizePixel = 0,
		Parent = game:GetService("CoreGui"),
	})
	
	-- Add corner radius
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
	
	closeBtn.MouseButton1Click:Connect(function()
		self.Frame:Destroy()
	end)
	
	-- Make draggable
	MakeDraggable(self.Header)
	
	-- Content Area with TabBar
	self.TabBar = CreateInstance("Frame", {
		Name = "TabBar",
		Size = UDim2.new(0, 150, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	
	-- Content Container
	self.ContentArea = CreateInstance("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -150, 1, -40),
		Position = UDim2.new(0, 150, 0, 40),
		BackgroundColor3 = COLORS.Tertiary,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})
	
	-- Scrolling frame for content
	self.ContentScroll = CreateInstance("ScrollingFrame", {
		Name = "ContentScroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 8,
		ScrollBarImageColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Parent = self.ContentArea,
	})
	
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = self.ContentScroll,
	})
	
	self.ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	
	return self
end

function Window:AddTab(name)
	local tab = {
		Name = name,
		Elements = {},
		Frame = nil,
	}
	
	-- Tab button on sidebar
	local tabBtn = CreateInstance("TextButton", {
		Name = name .. "Tab",
		Size = UDim2.new(1, -10, 0, 35),
		Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 40)),
		BackgroundColor3 = self.CurrentTab == tab and COLORS.Primary or COLORS.Secondary,
		TextColor3 = COLORS.Text,
		Text = name,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		BorderSizePixel = 0,
		Parent = self.TabBar,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = tabBtn,
	})
	
	-- Content frame for this tab
	tab.Frame = CreateInstance("Frame", {
		Name = name .. "Content",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = #self.Tabs == 0,
		Parent = self.ContentScroll,
	})
	
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = tab.Frame,
	})
	
	tabBtn.MouseButton1Click:Connect(function()
		if self.CurrentTab then
			self.CurrentTab.Frame.Visible = false
		end
		self.CurrentTab = tab
		tab.Frame.Visible = true
		
		-- Update button color
		for _, btn in pairs(self.TabBar:GetChildren()) do
			if btn:IsA("TextButton") then
				AnimatePropertyChange(btn, "BackgroundColor3", btn == tabBtn and COLORS.Primary or COLORS.Secondary, 0.2)
			end
		end
	end)
	
	if #self.Tabs == 0 then
		self.CurrentTab = tab
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
		AnimatePropertyChange(button, "BackgroundColor3", COLORS.Primary:Lerp(Color3.new(1,1,1), 0.2), 0.1)
	end)
	
	button.MouseLeave:Connect(function()
		AnimatePropertyChange(button, "BackgroundColor3", COLORS.Primary, 0.1)
	end)
	
	button.MouseButton1Click:Connect(callback or function() end)
	
	return button
end

function Window:AddToggle(text, default, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
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
	
	local toggle = {
		Value = default or false,
		Enabled = true,
	}
	
	-- Toggle Switch
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
	
	local switchButton = CreateInstance("TextButton", {
		Name = "SwitchButton",
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(0, toggle.Value and 24 or 2, 0.5, -11),
		BackgroundColor3 = COLORS.Text,
		BorderSizePixel = 0,
		Text = "",
		Parent = switchContainer,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = switchButton,
	})
	
	function toggle:Set(value)
		self.Value = value
		AnimatePropertyChange(switchContainer, "BackgroundColor3", value and COLORS.Primary or COLORS.Secondary, 0.15)
		AnimatePropertyChange(switchButton, "Position", UDim2.new(0, value and 24 or 2, 0.5, -11), 0.15)
		callback(value)
	end
	
	switchContainer.MouseButton1Click:Connect(function()
		toggle:Set(not toggle.Value)
	end)
	
	return toggle
end

function Window:AddSlider(text, min, max, default, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
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
	
	local slider = {
		Value = default or min,
		Min = min,
		Max = max,
	}
	
	-- Slider background
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
	
	-- Slider fill
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
	
	-- Slider knob
	local knob = CreateInstance("Frame", {
		Name = "Knob",
		Size = UDim2.new(0, 14, 0, 20),
		Position = UDim2.new((default - min) / (max - min), -7, 0, -7),
		BackgroundColor3 = COLORS.Primary,
		BorderSizePixel = 0,
		Parent = sliderBg,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = knob,
	})
	
	local dragging = false
	knob.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	
	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		
		local mousePos = input.Position.X
		local sliderPos = sliderBg.AbsolutePosition.X
		local sliderSize = sliderBg.AbsoluteSize.X
		local relativePos = math.max(0, math.min(mousePos - sliderPos, sliderSize))
		local percentage = relativePos / sliderSize
		
		local newValue = math.floor(min + (max - min) * percentage)
		slider.Value = newValue
		
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		knob.Position = UDim2.new(percentage, -7, 0, -7)
		label.Text = text .. ": " .. newValue
		
		callback(newValue)
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
		Parent = tab.Frame,
		ClearTextOnFocus = false,
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
	
	textbox.FocusLost:Connect(function()
		if callback then
			callback(textbox.Text)
		end
	end)
	
	return textbox
end

function Window:AddDropdown(text, options, default, callback, tab)
	tab = tab or self.CurrentTab
	if not tab then return end
	
	local container = CreateInstance("Frame", {
		Name = "DropdownContainer",
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundTransparency = 1,
		Parent = tab.Frame,
	})
	
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = container,
	})
	
	local label = CreateInstance("TextLabel", {
		Name = "Label",
		Size = UDim2.new(0, 80, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})
	
	local dropdown = {
		Value = default or options[1],
		Open = false,
	}
	
	local dropdownBtn = CreateInstance("TextButton", {
		Name = "DropdownButton",
		Size = UDim2.new(1, -90, 1, 0),
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
		Size = UDim2.new(1, -90, 0, 0),
		Position = UDim2.new(0, 80, 1, 0),
		BackgroundColor3 = COLORS.Secondary,
		BorderSizePixel = 0,
		Visible = false,
		Parent = container,
		ClipsDescendants = true,
		ZIndex = 2,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = dropdownList,
	})
	
	CreateInstance("UIListLayout", {
		Parent = dropdownList,
	})
	
	local function ShowDropdown()
		dropdown.Open = true
		dropdownList.Visible = true
		AnimatePropertyChange(dropdownList, "Size", UDim2.new(1, -90, 0, #options * 32), 0.15)
	end
	
	local function HideDropdown()
		dropdown.Open = false
		AnimatePropertyChange(dropdownList, "Size", UDim2.new(1, -90, 0, 0), 0.15)
		task.wait(0.15)
		dropdownList.Visible = false
	end
	
	for _, option in pairs(options) do
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
		
		optionBtn.MouseButton1Click:Connect(function()
			dropdown.Value = option
			dropdownBtn.Text = option
			HideDropdown()
			callback(option)
		end)
	end
	
	dropdownBtn.MouseButton1Click:Connect(function()
		if dropdown.Open then
			HideDropdown()
		else
			ShowDropdown()
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

-- Library export
local Library = {
	Window = Window,
	Colors = COLORS,
	CreateInstance = CreateInstance,
}

-- Add direct component creation functions that work on the last created window
function Library.Button(text, callback, tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddButton(text, callback, tab)
end

function Library.Toggle(text, default, callback, tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddToggle(text, default, callback, tab)
end

function Library.Slider(text, min, max, default, callback, tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddSlider(text, min, max, default, callback, tab)
end

function Library.TextBox(placeholder, callback, tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddTextBox(placeholder, callback, tab)
end

function Library.Dropdown(text, options, default, callback, tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddDropdown(text, options, default, callback, tab)
end

function Library.Label(text, tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddLabel(text, tab)
end

function Library.Divider(tab, window)
	local targetWindow = window or Library._currentWindow
	if not targetWindow then error("No window created! Create a window first with Library.Window.new()") end
	return targetWindow:AddDivider(tab)
end

-- Wrap the Window.new to track the current window
local OriginalWindowNew = Window.new
function Window.new(title, size, position)
	local window = OriginalWindowNew(title, size, position)
	Library._currentWindow = window
	return window
end

return Library
