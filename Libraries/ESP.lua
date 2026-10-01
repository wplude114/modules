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

function ESPModule:ApplySetting(Setting,Value)
	if table.find(ESPModule.Config,Setting) and Value then
		if typeof(ESPModule.Config[Setting]) ~= typeof(Value) then return end
		ESPModule.Config[Setting] == Value
	end
end

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

    local Camera = workspace.CurrentCamera

    for item, data in pairs(ESPActive) do
        if not data.obj or not data.obj.Parent then 
            if data.box then data.box:Destroy() end
            ESPActive[item] = nil 
            continue 
        end

        local Obj = data.obj
        local Outline = data.box
        local Text = Outline:FindFirstChildOfClass("TextLabel")
        
        Outline.BorderSizePixel = Config.OutlineSize
        if Text then Text.TextSize = Config.TextSize end
        
        local IsModel = Obj:IsA("Model")
        if not IsModel and not Obj:IsA("BasePart") then continue end
        
        local CFramePos, Size
        if IsModel then
            CFramePos, Size = Obj:GetBoundingBox()
        else
            CFramePos, Size = Obj.CFrame, Obj.Size
        end

        local SX, SY, SZ = Size.X / 2, Size.Y / 2, Size.Z / 2

        local Corners = {
            CFramePos * Vector3.new(-SX,  SY, -SZ),
            CFramePos * Vector3.new( SX,  SY, -SZ),
            CFramePos * Vector3.new(-SX, -SY, -SZ),
            CFramePos * Vector3.new( SX, -SY, -SZ),
            CFramePos * Vector3.new(-SX,  SY,  SZ),
            CFramePos * Vector3.new( SX,  SY,  SZ),
            CFramePos * Vector3.new(-SX, -SY,  SZ),
            CFramePos * Vector3.new( SX, -SY,  SZ),
        }

        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local AnyOnScreen = false

        for i = 1, 8 do
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Corners[i])
            if ScreenPos.Z > 0 then
                if OnScreen then AnyOnScreen = true end
                minX = math.min(minX, ScreenPos.X)
                minY = math.min(minY, ScreenPos.Y)
                maxX = math.max(maxX, ScreenPos.X)
                maxY = math.max(maxY, ScreenPos.Y)
            end
        end

        if AnyOnScreen and minX < maxX and minY < maxY then
            local width = (maxX - minX)/1.33
            local height = (maxY - minY)/1.33

            local centerX = minX + (width / 2)
            local centerY = minY + (height / 2)

            Outline.Position = UDim2.fromOffset(centerX, centerY)
            Outline.Size = UDim2.fromOffset(width, height)
			Outline.UIStroke.Thickness = Config.OutlineSize
            Outline.Visible = true
        else
            Outline.Visible = false
        end
    end
end

return ESPModule
