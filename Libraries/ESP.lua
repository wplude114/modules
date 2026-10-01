local ESPModule = {}
local ESPActive = {}
local GUI = Instance.new("GuiMain",game:GetService("CoreGui"))
GUI.Name = "ESPMain"

ESPModule.Colors = {
    
}
ESPModule.Config = {
    ESPEnabled = true,
    
    TextSize = 18,
    OutlineSize = 5,
    
    
    IsScaled = true,
    IsRainbow = false
}

function ESPModule:AddESP(obj:Object|Model,col:Color3)
    local CanAdd = true
    for i,v in ESPActive do
        if v.obj == obj then
           CanAdd = false
        end
    end
    if not CanAdd then return end
	--if obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") then obj = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") end
    local ESPBox = Instance.new("Frame",GUI)
    ESPBox.BackgroundTransparency = 1
    ESPBox.Size = UDim2.new(0, 0, 0, 0)
	ESPBox.AnchorPoint = Vector2.new(0.5,0.5)
	local Outline = Instance.new("UIStroke", ESPBox)
	Outline.Color = col
	Outline.BorderStrokePosition = Enum.BorderStrokePosition.Inner

    local ESPText = Instance.new("TextLabel",ESPBox)
    ESPText.Name = "ESPText"
    ESPText.Text = obj.Name
    ESPText.TextColor3 = col
    ESPText.BackgroundTransparency = 1
    ESPText.Font = Enum.Font.RobotoCondensed
	ESPText.Position = UDim2.fromScale(0.5,0.5)
	ESPText.AnchorPoint = Vector2.new(0.5,0.5)
	ESPText.TextStrokeTransparency = 0
	
    
    local uuid = game.HttpService:GenerateGUID(false)
    ESPActive[uuid] = {obj = obj, Color = col, box = ESPBox}
end

function ESPModule.Update(DeltaTime)
    local Config = ESPModule.Config
    if not Config.ESPEnabled then return end

    for item,data in ESPActive do
        if not data.obj or not data.obj.Parent then data.box.Visible = false ESPActive[item] = nil continue end
		local Camera = workspace.CurrentCamera
        local Obj = data.obj
        local Outline = data.box
		local RealOutline = Outline.UIStroke
        local Text = Outline:FindFirstChildOfClass("TextLabel")
        Text.TextSize = Config.TextSize
        
        local IsModel = Obj:IsA("Model")
		
        local Position, Size
		if IsModel then
			Position, Size = Obj:GetBoundingBox()
		else
    		Position, Size = Obj.CFrame, Obj.Size
		end
        
        Position = Position.Position
        local TopPos = Position + Vector3.new(0, Size.Y/2, 0)
        local BottomPos = Position - Vector3.new(0, Size.Y/2, 0)
        
        local TopScreen, TopVisible = Camera:WorldToViewportPoint(TopPos)
        local BottomScreen, BottomVisible = Camera:WorldToViewportPoint(BottomPos)
        
        if TopVisible or BottomVisible then
            local height = math.abs(BottomScreen.Y - TopScreen.Y)
		    local width = height * 0.75
			
			local centerY = (TopScreen.Y + BottomScreen.Y) / 2
			local posX = (TopScreen.X + BottomScreen.X) / 2

            Outline.Position = UDim2.fromOffset(posX, centerY)
		    Outline.Size = UDim2.fromOffset(width,height)
		    Outline.Visible = true
			RealOutline.Thickness = Config.OutlineSize
        else
            Outline.Visible = false
        end
    end
end

return ESPModule
