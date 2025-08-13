local MenuMaker = {}
MenuMaker.__index = MenuMaker

local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Exponential)
local optionListerPosition = UDim2.new(0.324,0,0.149,0)
local optionListerPositionOffSight = UDim2.new(1.028,0,0.149,0)
local inputBoxPosition = UDim2.new(0.324,0,0.883,0)
local inputBoxPositionOffSight = UDim2.new(0.324, 0, 2.883, 0)
local errorSubfix = " --MenuMaker"

local menuSize = UDim2.new(0,450,0,300) --UDim2.new(0.434,0,0.563,0)
local hoverTipSize = UDim2.new(0,280,0,35)

local frameSize = UDim2.new(1,0,0,24)

--- local functions

local function err(message : string)
	warn(if message then message else "There was an error."..errorSubfix)
	return
end

local function roundify(obj : GuiObject, self)
	if self.RoundCorners then
		local corner = Instance.new("UICorner", obj)
		corner.CornerRadius = UDim.new(0, 12)
	end
	return
end

local function addPadding (obj : GuiObject, Left : number, Right : number, Top : number, Bottom : number)
	local padding = Instance.new("UIPadding", obj)
	padding.PaddingLeft = UDim.new(0, Left)
	padding.PaddingRight = UDim.new(0, Right)
	padding.PaddingTop = UDim.new(0, Top)
	padding.PaddingBottom = UDim.new(0, Bottom)
	return
end

local function tweenColor(guiObj : GuiObject, targetColor : Color3)
	TweenService:Create(guiObj, tweenInfo, {BackgroundColor3 = targetColor}):Play()
	return
end

local function hover(guiObj : GuiObject, state : boolean, self)
	if self.RoundCorners then
		if guiObj:FindFirstChildWhichIsA("UICorner") then
			TweenService:Create(guiObj.UICorner, tweenInfo, {CornerRadius = if state then UDim.new(0,9) else UDim.new(0,12)}):Play()
		end
	else
		if state then
			TweenService:Create(guiObj, tweenInfo, {Size = UDim2.new(1.05,0,0,frameSize.Y.Offset)}):Play()
		elseif not state then
			TweenService:Create(guiObj, tweenInfo, {Size = frameSize}):Play()
		end
	end
	return
end

local hoverTipConnection
local function hoverTip(state : boolean, text : string, self : {any})
	local hoverTip = self.HoverTip
	local mouse = game.Players.LocalPlayer:GetMouse()
	
	if state then
		hoverTip.Text = text
		hoverTipConnection = runService.RenderStepped:Connect(function()
			hoverTip.Position = UDim2.new(0, mouse.X, 0, mouse.Y) 
		end)
		hoverTip.Visible = true
	else
		if hoverTipConnection then hoverTipConnection:Disconnect() end
		hoverTip.Visible = false
		hoverTip.Text = ""
	end
	
end

local function createGuiInstance (Type : GuiObject, Name : string, Parent : any, Size : UDim2, Position : UDim2, AnchorPoint : Vector2, IsPrimary : number, RoundifyObj : boolean, Transparency : number, self) : GuiObject
	local obj = Instance.new(Type, Parent)
	obj.Name = Name
	obj.Size = Size
	obj.Position = Position
	obj.AnchorPoint = AnchorPoint
	obj.BackgroundTransparency = Transparency
	obj:SetAttribute("ColorGroup",  if IsPrimary == 1 then self.BackgroundColor elseif IsPrimary == 2 then self.PrimaryColor else self.SecondaryColor)
	obj.BackgroundColor3 = obj:GetAttribute("ColorGroup")
	if RoundifyObj then roundify(obj, self) end
	if obj:IsA("TextButton") or obj:IsA("TextLabel") then obj.Font = self.Font; obj.TextColor3 = self.FontColor; end
	return obj
end

local function createMainMenu (self) --If anyone is reading this... i'm terribly sorry.
	if not self then err() return end
	self.Gui = Instance.new("ScreenGui", self.Player.PlayerGui)
	self.Gui.Name = "$#"..self.Title.."#$"
	self.Gui.ResetOnSpawn = false
	
	self.Main = createGuiInstance("Frame", "Main", self.Gui, UDim2.new(1,0,1,0), UDim2.new(0.5,0,0.5,0), Vector2.new(0.5,0.5), 1, false, 1, self)
	self.Menu = createGuiInstance("Frame", "Menu", self.Main, menuSize, UDim2.new(0.5,0,0.5,0), Vector2.new(0.5,0.5), 1, true, 0, self)
	self.Categories = createGuiInstance("Frame", "Categories", self.Menu, UDim2.new(0.276,0,0.817,0), UDim2.new(0.024,0,0.149,0), Vector2.new(0,0), 2, true, 0, self)
	self.ExitButton = createGuiInstance("TextButton", "ExitButton", self.Menu, UDim2.new(0.08,0,0.114,0), UDim2.new(1,0,0,0), Vector2.new(1,0), 3, false, 1, self)
	self.TitleLabel = createGuiInstance("TextLabel", "Title", self.Menu, UDim2.new(1,0,0.114,10), UDim2.new(0.5,0,0,0), Vector2.new(0.5,0), 3, true, 0, self)
	self.HoverTip = createGuiInstance("TextLabel", "HoverTip", self.Main, hoverTipSize, UDim2.new(0,0,0,0), Vector2.new(0,1), 1, true, 0.4, self)
	self.HoverTip.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
	self.HoverTip.TextSize = 10
	self.HoverTip.Visible = false
	
	self.Menu.ClipsDescendants = true
	
	self.ExitButton.Text = "X"
	self.ExitButton.TextSize = 25
	self.ExitButton.ZIndex = 2
	self.TitleLabel.Text = self.Title
	self.TitleLabel.TextSize = 25
	
	local listLayout = Instance.new("UIListLayout", self.Categories)
	listLayout.Padding = UDim.new(0,5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	Instance.new("UIDragDetector", self.Menu)
	
	addPadding(self.Categories, 5,5,5,5)
	return
end

local function optionInitializerHelper(params, self)
	if params and params[1] == "Input" then
		if self.IsInputSeeking then
			if self.textBox.Text == "" or self.textBox.Text == nil then return false end
		else
			if params[2].Text == "" then return false end
		end
	end
	return true
end

local function optionInitializer (self, guiObj, keyBind, hoverTipText, toggleButton, funcOn, funcOff, params : {any})
	local key = if keyBind then keyBind else guiObj
	self.Parent.Functions[key] = function() -- sets the function with the keybind as key
		if self.PlayerIsDead then print("plr is dead.") return end
		
		
		if funcOff == nil then -- Non-toggle option, because no "funcOff" given
			if optionInitializerHelper(params, self) == false then return end
			funcOn(if params and params[1] == "Input" then if self.IsInputSeeking then self.textBox.Text else params[2].Text else params)
			tweenColor(guiObj, self.Parent.SelectedColor)
			task.delay(tweenInfo.Time / 5, function()
				tweenColor(guiObj, self.Parent.SecondaryColor)
			end)
		end
		
		if funcOff ~= nil then -- Toggle option, because "funcOff" is given
			local toggled = toggleButton:GetAttribute("Active")
			toggleButton:SetAttribute("Active", not toggled)

			if not toggled then
				if optionInitializerHelper(params, self) == false then return end
				funcOn(if params and params[1] == "Input" then if self.IsInputSeeking then self.textBox.Text else params[2].Text else params)
				tweenColor(guiObj, self.Parent.SelectedColor)
			elseif toggled then
				funcOff(if params and params[1] == "Input" then if self.IsInputSeeking then self.textBox.Text else params[2].Text else params)
				tweenColor(guiObj, self.Parent.SecondaryColor)
			end
		end
	end

	toggleButton.MouseButton1Click:Connect(function()
		self.Parent.Functions[key]()
	end)
	
	local hovering = false
	toggleButton.MouseEnter:Connect(function()
		hovering = true
		hover(guiObj, true, self)
		
		task.delay(0.6, function()
			if hovering then
				if hoverTipText ~= "" then hoverTip(true, hoverTipText, self) end
			end
		end)

	end)
	
	toggleButton.MouseLeave:Connect(function()
		hovering = false
		hover(guiObj, false, self)
		hoverTip(false, "", self)
	end)
	return
end

--- Global functions

function MenuMaker.newMenu(MenuData : {Title : string, BackgroundColor : Color3, PrimaryColor : Color3, SecondaryColor : Color3, SelectedColor : Color3, TextColor : Color3, Font : Enum.Font, RoundCorners : boolean }) : ScreenGui
	if not MenuData then err("MenuData must be provided.") return end
	local self = setmetatable({}, MenuMaker)
	self.Player = game.Players.LocalPlayer
	self.Character = self.Player.Character

	self.Title = MenuData["Title"]
	self.BackgroundColor = MenuData["BackgroundColor"]
	self.PrimaryColor = MenuData["PrimaryColor"]
	self.SecondaryColor = MenuData["SecondaryColor"]
	self.SelectedColor = MenuData["SelectedColor"]
	self.HoverColor = MenuData["HoverColor"]
	self.FontColor = MenuData["FontColor"]
	self.Font = MenuData["Font"]
	self.RoundCorners = MenuData["RoundCorners"]
	
	self.ActiveOptions = nil
	self.Functions = {}
	self.PlayerIsDead = false
	
	createMainMenu(self)
	self.ExitButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	uis.InputBegan:Connect(function(input, gp) -- Connection for options that have keys bound to them
		if gp then return end
		if self.Functions[input.KeyCode] then
			self.Functions[input.KeyCode]() -- Fires the function with the keybind as key if it exists
		end
	end)
	
	local con
	local function setupPlayerDeathConnection() -- To make sure nothing glitches out when the player dies
		con = self.Character.Humanoid.Died:Connect(function()
			con:Disconnect()
			self.PlayerIsDead = true
			self.Gui.Enabled = false

			self.Character = self.Player.CharacterAdded:Wait()
			self.PlayerIsDead = false
			self.Gui.Enabled = true
			setupPlayerDeathConnection()  -- Set the connection up again, because it's a new character
		end)
	end
	
	setupPlayerDeathConnection()
	return self
end

function MenuMaker:CreateCategory(name : string, layoutOrder : number) : {any}
	if not name then err("No name given.") return end
	local category = setmetatable({}, { __index = self})
	category.Parent = self
	category.Name = name
	category.IsInputSeeking = false
	
	category.GuiObject = createGuiInstance("Frame", name, self.Categories, frameSize, UDim2.new(0,0,0,0), Vector2.new(0,0), 3, true, 0, self)
	category.GuiObject.LayoutOrder = layoutOrder
	
	category.OpenButton = createGuiInstance("TextButton", "OpenButton", category.GuiObject, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Vector2.new(0,0), 2, false, 1, self)
	category.OpenButton.Text = name
	category.OpenButton.TextSize = 18
	
	category.OptionLister = createGuiInstance("ScrollingFrame", "OptionLister", self.Menu, UDim2.new(0.652,0,0.817,0), optionListerPositionOffSight, Vector2.new(0,0), 2, true, 0, self)
	category.OptionLister.ScrollBarThickness = 8
	category.OptionLister.AutomaticCanvasSize = Enum.AutomaticSize.Y
	addPadding(category.OptionLister, 8,16,8,8)
	
	local listLayout = Instance.new("UIListLayout", category.OptionLister)
	listLayout.Padding = UDim.new(0,5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	category.OptionLister.Visible = true
	category.OptionLister:SetAttribute("Active", false)
	
	category.OpenButton.MouseButton1Click:Connect(function()
		self:ToggleOptionLister(category.OptionLister, category)
	end)
	category.OpenButton.MouseEnter:Connect(function()
		hover(category.GuiObject, true, self)
	end)
	category.OpenButton.MouseLeave:Connect(function()
		hover(category.GuiObject, false, self)
	end)
	
	local function updateCanvas()
		category.OptionLister.CanvasSize = UDim2.new(
			0, 0,
			0, listLayout.AbsoluteContentSize.Y + frameSize.Y.Offset
		)
	end

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	updateCanvas()

	return category
end

-- "Inherits" from the basic category, but adds an input box and some custom properties
function MenuMaker:CreateInputCategory(name : string, layoutOrder : number, inputTitle : string, placeholderText : string) : {any}
	local category = self:CreateCategory(name, layoutOrder) -- "Inheritance"
	category.OptionLister.Size = UDim2.new(0.652,0,0.711,0) -- Shrinks the frame to make room for an input box
	category.IsInputSeeking = true -- Sets a custom property so the function "optionInitializer" knows that it needs to ignore an option's own inputBox
	
	category.inputBox = createGuiInstance("Frame", name.."InputBox", self.Menu, UDim2.new(0.652,0,0.083,0), UDim2.new(0.324,0,0.883,0), Vector2.new(0,0), 3, true, 0, self)
	category.inputBox.Position = inputBoxPositionOffSight
	
	category.title = createGuiInstance("TextLabel", "Title", category.inputBox, UDim2.new(0.35,0,1,0), UDim2.new(0,0,0,0), Vector2.new(0,0), 2, false, 1, self)
	category.title.TextSize = 18
	category.title.Text = inputTitle
	category.title.TextXAlignment = Enum.TextXAlignment.Left
	
	category.textBox = createGuiInstance("TextBox", "TextBox", category.inputBox, UDim2.new(0.35,0,1,0), UDim2.new(0.809,0,0,0), Vector2.new(0.5,0), 2, false, 1, self)
	category.textBox.Text = ""
	category.textBox.PlaceholderText = placeholderText
	category.textBox.TextSize = 10
	
	addPadding(category.inputBox, 10,10,0,0)
	return category
end

function MenuMaker:CreateDivider(name : string, layoutOrder : number) : Frame
	local guiObj = createGuiInstance("Frame", name, self.OptionLister, frameSize, UDim2.new(0.5,0,0.5,0), Vector2.new(0.5,0.5), 2, false, 1, self.Parent)
	guiObj.LayoutOrder = layoutOrder
	addPadding(guiObj, 0,10,0,0)
	
	local Title = createGuiInstance("TextLabel", "Title", guiObj, UDim2.new(0.35,0,1,0), UDim2.new(0,0,0,0), Vector2.new(0,0), 2, false, 1, self.Parent)
	Title.TextSize = 18
	Title.Text = name
	Title.TextXAlignment = Enum.TextXAlignment.Left
	self.Parent[name.."Divider"] = guiObj
	
	return guiObj
end

function MenuMaker:CreateOptionFrame (name : string, keyBind : Enum.KeyCode, layoutOrder : number) : (Frame, TextButton)
	local guiObj = createGuiInstance("Frame", name, self.OptionLister, frameSize, UDim2.new(0.5,0,0.5,0), Vector2.new(0.5,0.5), 3, true, 0, self.Parent)
	guiObj.LayoutOrder = layoutOrder
	addPadding(guiObj, 10,10,0,0)
	
	local toggleButton = createGuiInstance("TextButton", "ToggleButton", guiObj, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Vector2.new(0,0), 2, false, 1, self.Parent)
	toggleButton.Text = ""
	toggleButton:SetAttribute("Active", false)
	
	local Title = createGuiInstance("TextLabel", "Title", guiObj, UDim2.new(0.35,0,1,0), UDim2.new(0,0,0,0), Vector2.new(0,0), 2, false, 1, self.Parent)
	Title.TextSize = 18
	Title.Text = name
	Title.TextXAlignment = Enum.TextXAlignment.Left
	self.Parent[name.."Option"] = guiObj
	
	if keyBind ~= nil then
		local keyBindDisplayer = createGuiInstance("TextLabel", "KeyBind", guiObj, UDim2.new(0.1,0,1,0), UDim2.new(1,0,0,0), Vector2.new(1,0), 2, false, 1, self.Parent)
		keyBindDisplayer.TextSize = 12
		keyBindDisplayer.Text = keyBind.Name
	end
	
	return guiObj, toggleButton
end

function MenuMaker:CreateToggleOption(name : string, keyBind : Enum.KeyCode, hoverTip : string, layoutOrder : number, funcOn : () -> any, funcOff : () -> any)
	if hoverTip == nil then hoverTip = "" end
	local guiObj, toggleButton = self:CreateOptionFrame(name, keyBind, layoutOrder)
	
	optionInitializer(self, guiObj, keyBind, hoverTip, toggleButton, funcOn, funcOff)
	return
end

function MenuMaker:CreateInputOption (name : string, keyBind : Enum.KeyCode, hoverTip : string, placeholderText : string, layoutOrder : number,  funcOn : () -> any, funcOff : () -> any)
	if hoverTip == nil then hoverTip = "" end
	local guiObj, toggleButton = self:CreateOptionFrame(name, keyBind, layoutOrder)
	
	local inputButton
	if not self.IsInputSeeking then
		inputButton = createGuiInstance("TextBox", "InputBox", guiObj, UDim2.new(0.25,0,1,0), UDim2.new(0.75,0,0,0), Vector2.new(0.5,0), 2, false, 1, self.Parent)
		inputButton.PlaceholderText = placeholderText
		inputButton.Text = ""
	end
	
	optionInitializer(self, guiObj, keyBind, hoverTip, toggleButton, funcOn, funcOff, {"Input", inputButton})
	return
end

function MenuMaker:Toggle() -- Main Menu
	local visible = self.Menu.Visible
	
	if visible then
		TweenService:Create(self.Menu, tweenInfo, {Position = UDim2.new(0.5,0,1.5,0)}):Play() -- Tweens the menu
		TweenService:Create(self.Menu, tweenInfo, {Size = UDim2.new(0,0,0,0)}):Play() -----------^  
		
		------------------------------------------
		self.Menu.Visible = not visible
		self.OpenButton = createGuiInstance("TextButton", "OpenButton", self.Main, UDim2.new(0.045,0,0.077,0), UDim2.new(-1,0,0.463,0), Vector2.new(0,0), 3, true, 0, self)
		self.OpenButton.Text = "Open"
		TweenService:Create(self.OpenButton, tweenInfo, {Position = UDim2.new(0,0,0.463,0)}):Play()
		-- This section creates a button to open the menu again, and tweens it on screen
		
		task.delay(tweenInfo.Time, function() -- Sets up the button after the tween is completed to prevent bugs (lazy approach)
			local con
			con = self.OpenButton.MouseButton1Click:Connect(function()
				self:Toggle()
				con:Disconnect()
				con = nil
				TweenService:Create(self.OpenButton, tweenInfo, {Position = UDim2.new(-1,0,0.463,0)}):Play() -- Tweens the button away
				task.delay(tweenInfo.Time, function() self.OpenButton:Destroy(); end) -- Destroys the button after it finished tweening
			end)
		end)
	elseif not visible then
		self.Menu.Visible = not visible
		TweenService:Create(self.Menu, tweenInfo, {Position = UDim2.new(0.5,0,0.5,0)}):Play()
		TweenService:Create(self.Menu, tweenInfo, {Size = menuSize}):Play()
	end
	return
end


function MenuMaker:ToggleOptionLister (GuiObj : GuiObject, category : {any}) -- Toggles option listers
	local acitve = GuiObj:GetAttribute("Active")
	local newState = not acitve
	
	if newState then		
		
		if self.ActiveOptionLister and self.ActiveOptionLister ~= GuiObj then
			TweenService:Create(self.ActiveOptionLister.OptionLister, tweenInfo, {Position = optionListerPositionOffSight}):Play()
			if self.ActiveOptionLister.IsInputSeeking then
				TweenService:Create(self.ActiveOptionLister.inputBox, tweenInfo, {Position = inputBoxPositionOffSight}):Play()
			end
			
			for _, v in self.Categories:GetChildren() do
				if v:IsA("Frame") then tweenColor(v, self.SecondaryColor) end
				self.ActiveOptionLister.OptionLister:SetAttribute("Active", false)
			end
		end
		
		self.ActiveOptionLister = category
		tweenColor(category.GuiObject, self.SelectedColor)
		TweenService:Create(GuiObj, tweenInfo, {Position = optionListerPosition}):Play()
		if category.IsInputSeeking then
			TweenService:Create(self.ActiveOptionLister.inputBox, tweenInfo, {Position = inputBoxPosition}):Play()
		end

		
	elseif not newState then
		tweenColor(category.GuiObject, self.SecondaryColor)
		TweenService:Create(GuiObj, tweenInfo, {Position = 	optionListerPositionOffSight}):Play()
		if category.IsInputSeeking then
			TweenService:Create(self.ActiveOptionLister.inputBox, tweenInfo, {Position = inputBoxPositionOffSight}):Play()
		end
	end

	GuiObj:SetAttribute("Active", not acitve)
	return
end

function MenuMaker:Destroy()
	self.Gui:Destroy()
	self = nil
end

function MenuMaker:Notify(NotificationData : {Title : string, Description : string, Duration : number?})
	game.StarterGui:SetCore("SendNotification", {
		Title = NotificationData["Title"],
		Text = NotificationData["Description"],
		Duration = if NotificationData["Duration"] then NotificationData["Duration"] else 2
	})
end

---

return MenuMaker
