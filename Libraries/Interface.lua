local GuiModule = {}
local Items = {
	Buttons = {},
	Toggles = {},
}

local function AddPadding(Object:Object,Padding)
	if typeof(Padding) == "UDim" then Padding = {Padding,Padding,Padding,Padding} end
	local ObjectPadding = Instance.new("UIPadding",Object)
	ObjectPadding.PaddingLeft = Padding.Left or Padding[1] or UDim.new()
	ObjectPadding.PaddingRight = Padding.Right or Padding[2] or UDim.new()
	ObjectPadding.PaddingTop = Padding.Top or Padding[3] or UDim.new()
	ObjectPadding.PaddingBottom = Padding.Bottom or Padding[4] or UDim.new()
	return ObjectPadding
end

local function CreateFrame()
	local Frame = Instance.new("Frame")
	local Components = {
		Stroke = Instance.new("UIStroke",Frame),
		Corner = Instance.new("UICorner",Frame),
	}
	Components.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Components.Stroke.Color = Color3.fromRGB(100, 100, 100)

	Components.Corner.CornerRadius = UDim.new(0,10)
	Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
	return Frame,Components
end
local function CreateButton()
	local Button = Instance.new("ImageButton")
	local Components = {
		Stroke = Instance.new("UIStroke",Button),
		Corner = Instance.new("UICorner",Button),
	}
	Components.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Components.Stroke.Color = Color3.fromRGB(100, 100, 100)
	Components.Corner.CornerRadius = UDim.new(0,2)
	
	Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Button.AutoButtonColor = false
	Button.Image = ""
	
	
	return Button,Components
end

GuiModule.Menu = {}
GuiModule.Menu.PositionOptions = {
	"Left",
	"Right",
}
function GuiModule.Menu.AddMenu(Location:Object,Name:string,Position:string)
	if not table.find(GuiModule.Menu.PositionOptions,Position) then return end
	if Position then
		if Position == "Left" then
			Location = Location:FindFirstChild("Left")
		elseif Position == "Right" then
			Location = Location:FindFirstChild("Right")
		end
	end
	local Main,MainComponents = CreateFrame()
	Main.Parent = Location
	Main.Name = Name or "UnnamedMenu"
	Main.Size = UDim2.new(1,0,0,20)
	Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
	Main.ClipsDescendants = true
	MainComponents.Corner.CornerRadius = UDim.new(0,5)
	Instance.new("UIListLayout",Main).SortOrder = Enum.SortOrder.LayoutOrder
	Main:AddTag("Menu")
	
	local TopBar,TopBarComponents = CreateFrame()
	TopBar.Parent = Main
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1,0,0,20)
	TopBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
	TopBar.LayoutOrder = -100
	TopBar.ZIndex = 2
	TopBarComponents.Corner:Destroy()
	
	local CloseButton = Instance.new("TextButton",TopBar)
	CloseButton.Name = "Collapse"
	CloseButton.Size = UDim2.new(0,20,0,20)
	CloseButton.Position = UDim2.fromScale(1,1)
	CloseButton.AnchorPoint = Vector2.new(1,1)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "▲"
	CloseButton.TextSize = 10
	CloseButton.Font = Enum.Font.RobotoMono
	CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
	CloseButton.ZIndex = 2
	local Toggled = true
	local LastSize = Main.Size
	CloseButton.Activated:Connect(function()
		LastSize = Main.Size.Y.Offset > LastSize.Y.Offset and Main.Size or LastSize
		Toggled = not Toggled
		CloseButton.Rotation = Toggled and 0 or 180
		Main:TweenSize(Toggled and LastSize or UDim2.new(1,0,0,20),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.333,true)
	end)
	
	local Title = Instance.new("TextLabel")
	Title.Parent = TopBar
	Title.Size = UDim2.new(0.8,0,0.8,0)
	Title.Position = UDim2.new(0,0,0.5,0)
	Title.AnchorPoint = Vector2.new(0,0.5)
	Title.Name = "Title"
	Title.Text = Name or "Menu"
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.RobotoCondensed
	Title.TextColor3 = Color3.fromRGB(255,255,255)
	Title.TextSize = 14
	Title.RichText = true
	AddPadding(Title,{Left=UDim.new(0.025,0)})
	
	return Main
end

GuiModule.Button = {}
function GuiModule.Button.AddButton(Location:Object,Name:string, Callback:() -> ())
	if not Location:HasTag("Menu") then return end
	Location.Size = Location.Size + UDim2.new(0,0,0,30)
	
	local Button = Instance.new("Frame")
	Button.Parent = Location
	Button.BorderSizePixel = 0
	Button.Name = Name or "UnnamedButton"
	Button.Size = UDim2.new(1,0,0,30)
	Button.BackgroundTransparency = 1
	AddPadding(Button,UDim.new(0,5))
	
	
	local RealButton, ButtonComponents = CreateButton()
	RealButton.Parent = Button
	RealButton.Name = "Button"
	RealButton.Size = UDim2.new(1,0,1,0)
	
	local ButtonText = Instance.new("TextLabel")
	ButtonText.Parent = RealButton
	ButtonText.Name = "ButtonText"
	ButtonText.Size = UDim2.new(1,0,1,0)
	ButtonText.Text = Name or "Menu"
	ButtonText.BackgroundTransparency = 1
	ButtonText.Font = Enum.Font.RobotoCondensed
	ButtonText.TextColor3 = Color3.fromRGB(255,255,255)
	ButtonText.TextSize = 14
	ButtonText.RichText = true
	local uuid = game.HttpService:GenerateGUID(false)
	Items.Buttons[uuid] = {item = Button, hover = false}
	local Table = Items.Buttons[uuid]
	RealButton.MouseEnter:Connect(function()
		Table.hover = true
		RealButton.MouseLeave:Wait()
		Table.hover = false
	end)
	RealButton.Activated:Connect(Callback)
	return Button
end

function GuiModule.Button.AddToggle(Location:Object,Name:string,Value:boolean, Callback:(Toggled) -> (Toggled))
	if not Location:HasTag("Menu") then return end
	Location.Size = Location.Size + UDim2.new(0,0,0,30)
	
	local Toggle = Instance.new("Frame")
	Toggle.Parent = Location
	Toggle.BorderSizePixel = 0
	Toggle.Name = Name or "UnnamedToggle"
	Toggle.Size = UDim2.new(1,0,0,30)
	Toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
	AddPadding(Toggle,UDim.new(0,5))
	
	local RealToggle, ToggleComponents = CreateButton()
	RealToggle.Position = UDim2.new(0.95,0,0.5,0)
	RealToggle.AnchorPoint = Vector2.new(1,0.5)
	RealToggle.Parent = Toggle
	RealToggle.Name = "ToggleButton"
	RealToggle.BackgroundColor3 = Color3.fromRGB(15,15,15)
	RealToggle.Size = UDim2.fromScale(0.8,0.8)
	Instance.new("UIAspectRatioConstraint",RealToggle).AspectRatio = 2
	RealToggle.ZIndex = 2
	ToggleComponents.Corner.CornerRadius = UDim.new(1,0)
	
	local Indicator, ToggleIndicatorComponents = CreateFrame()
	Indicator.Parent = RealToggle
	Indicator.Name = "Indicator"
	Indicator.Size = UDim2.fromScale(0.8,0.8)
	Indicator.AnchorPoint = Vector2.new(0.5,0.5)
	Indicator.Position = UDim2.fromScale(Value and 0.75 or 0.25,0.5)
	Indicator.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Indicator.BackgroundTransparency = 0
	Instance.new("UIAspectRatioConstraint",Indicator).AspectRatio = 1
	ToggleIndicatorComponents.Stroke:Destroy()
	ToggleIndicatorComponents.Corner.CornerRadius = UDim.new(1,0)
	
	local Title = Instance.new("TextLabel")
	Title.Parent = Toggle

	Title.Size = UDim2.new(0.8,0,0.8,0)
	Title.Position = UDim2.new(0,0,0.5,0)
	Title.AnchorPoint = Vector2.new(0,0.5)

	Title.Name = "Title"
	Title.Text = Name or "Toggle"
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.RobotoCondensed
	Title.TextColor3 = Color3.fromRGB(255,255,255)
	Title.TextSize = 16
	Title.RichText = true
	AddPadding(Title,{Left=UDim.new(0.025,0)})
	local uuid = game.HttpService:GenerateGUID(false)
	Items.Toggles[uuid] = {item = Toggle, hover = false, toggled = Value}
	local Table = Items.Toggles[uuid]
	Toggle.MouseEnter:Connect(function()
		Table.hover = true
		Toggle.MouseLeave:Wait()
		Table.hover = false
	end)
	RealToggle.Activated:Connect(function()
		Table.toggled = not Table.toggled
	end)
	return Toggle
end

local colors = {
	button = Color3.fromRGB(25,25,25),
	buttonhover = Color3.fromRGB(40,40,40),
	optionhover = Color3.fromRGB(30,30,30),
	bg = Color3.fromRGB(20,20,20),
}
local function lerpPos(obj:Object,trg:UDim2|Vector3|Vector2,spd:number,dt:number)
	obj.Position = obj.Position:Lerp(trg, math.clamp(spd*dt,0,1))
end
local function lerpCol(obj:Object,trg:Color3,spd:number,dt:number)
	obj.BackgroundColor3 = obj.BackgroundColor3:Lerp(trg, math.clamp(spd*dt,0,1))
end
function GuiModule:Update(deltaTime)
	for i,v in Items.Buttons do
		lerpCol(v.item.Button,v.hover and colors.buttonhover or colors.button,20,deltaTime)
	end
	for i,v in Items.Toggles do
		lerpCol(v.item,v.hover and colors.optionhover or colors.bg,20,deltaTime)
		lerpPos(v.item.ToggleButton.Indicator,v.toggled and UDim2.fromScale(0.75,0.5) or UDim2.fromScale(0.25,0.5),33.3,deltaTime)
	end
end


function GuiModule.Menu:CreatePanel(PanelName:string,Parent:ScreenGui|CoreGui)
	local Panel = CreateFrame()
	Panel.ClipsDescendants = true
	Panel.Name = "Panel"
	Panel.Parent = Parent
	Panel.Size = UDim2.fromScale(0.6,0.6)
	Panel.Position = UDim2.fromScale(0.5,0.5)
	Panel.AnchorPoint = Vector2.new(0.5,0.5)
	Instance.new("UIAspectRatioConstraint",Panel).AspectRatio = 1.333
	Instance.new("UIShadow",Panel).BlurRadius = UDim.new(0,30)

	local TopBar,TopBarComponents = CreateFrame()
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.fromScale(1,0.1)
	TopBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
	TopBar.Parent = Panel
	TopBarComponents.Corner.BottomLeftRadius = UDim.new()
	TopBarComponents.Corner.BottomRightRadius = UDim.new()

	local Name = Instance.new("TextLabel")
	Name.Name = "Name"
	Name.Parent = TopBar
	Name.Text = PanelName or "[Name]"
	Name.Size = UDim2.fromScale(0.8,0.7)
	Name.Position = UDim2.fromScale(0,0.5)
	Name.AnchorPoint = Vector2.new(0,0.5)
	Name.BackgroundTransparency = 1
	Name.TextXAlignment = Enum.TextXAlignment.Left
	Name.Font = Enum.Font.RobotoCondensed
	Name.TextColor3 = Color3.fromRGB(255,255,255)
	Name.RichText = true
	Name.TextScaled = true
	AddPadding(Name, {UDim.new(0.025,0)})
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Parent = Panel
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.fromScale(1,0.9)
	MainFrame.Position = UDim2.fromScale(1,1)
	MainFrame.AnchorPoint = Vector2.new(1,1)
	MainFrame.BackgroundTransparency = 1
	
	local Current = Instance.new("Frame")
	Current.Parent = MainFrame
	Current.Name = "Open"
	Current.Size = UDim2.fromScale(0.75,1)
	Current.Position = UDim2.fromScale(1,1)
	Current.AnchorPoint = Vector2.new(1,1)
	Current.BackgroundTransparency = 1
	Current.ClipsDescendants = true
	
	local CurrentLeft = Instance.new("ScrollingFrame")
	AddPadding(CurrentLeft,UDim.new(0,10))
	CurrentLeft.ScrollingDirection = Enum.ScrollingDirection.Y
	CurrentLeft.CanvasSize = UDim2.fromScale(0,0)
	CurrentLeft.ScrollBarThickness = 0
	CurrentLeft.AutomaticCanvasSize = Enum.AutomaticSize.Y
	
	CurrentLeft.Parent = Current
	CurrentLeft.Name = "Left"
	CurrentLeft.Size = UDim2.new(0.5,-5,1,0)
	CurrentLeft.Position = UDim2.fromScale(0,0)
	CurrentLeft.BackgroundTransparency = 1
	local CurrentLeftList = Instance.new("UIListLayout")
	CurrentLeftList.Parent = CurrentLeft
	CurrentLeftList.Padding = UDim.new(0,10)
	CurrentLeftList.FillDirection = Enum.FillDirection.Vertical
	
	local CurrentRight = Instance.new("ScrollingFrame")
	AddPadding(CurrentRight,UDim.new(0,10))
	CurrentRight.ScrollingDirection = Enum.ScrollingDirection.Y
	CurrentRight.CanvasSize = UDim2.fromScale(0,0)
	CurrentRight.ScrollBarThickness = 0
	CurrentRight.AutomaticCanvasSize = Enum.AutomaticSize.Y
	
	CurrentRight.Parent = Current
	CurrentRight.Name = "Right"
	CurrentRight.Size = UDim2.new(0.5,-5,1,0)
	CurrentRight.AnchorPoint = Vector2.new(1,1)
	CurrentRight.Position = UDim2.fromScale(1,1)
	CurrentRight.BackgroundTransparency = 1
	local CurrentRightList = Instance.new("UIListLayout")
	CurrentRightList.Parent = CurrentRight
	CurrentRightList.Padding = UDim.new(0,10)
	CurrentRightList.FillDirection = Enum.FillDirection.Vertical
	
	local Tabs, TabComponents = CreateFrame()
	Tabs.Name = "Tabs"
	Tabs.Parent = MainFrame
	Tabs.Size = UDim2.fromScale(0.25,1)
	Tabs.BackgroundColor3 = Color3.fromRGB(20,20,20)
	TabComponents.Corner:Destroy()
	
	return Panel
end

return GuiModule
