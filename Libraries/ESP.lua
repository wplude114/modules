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
            -- CRITICAL FIX: Only consider points in front of camera (Z > 0)
            if ScreenPos.Z > 0 then
                if OnScreen then AnyOnScreen = true end
                minX = math.min(minX, ScreenPos.X)
                minY = math.min(minY, ScreenPos.Y)
                maxX = math.max(maxX, ScreenPos.X)
                maxY = math.max(maxY, ScreenPos.Y)
            end
        end

        if AnyOnScreen and minX < maxX and minY < maxY then
            local width = maxX - minX
            local height = maxY - minY

            local centerX = minX + (width / 2)
            local centerY = minY + (height / 2)

            Outline.Position = UDim2.fromOffset(centerX, centerY)
            Outline.Size = UDim2.fromOffset(width, height)
            Outline.Visible = true
        else
            Outline.Visible = false
        end
    end
end

return ESPModule
