local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wplude114/modules/refs/heads/main/Libraries/Interface.lua"))()
local ESPlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wplude114/modules/refs/heads/main/Libraries/ESP.lua"))()

local sgui = Instance.new("ScreenGui",game:GetService("CoreGui"))
sgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local Panel = lib.Menu:CreatePanel("sigmintonium",sgui)
Instance.new("UIDragDetector",Panel).BoundingUI = sgui
local CurrentMenu
local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
task.wait()

CurrentMenu = lib.Menu.AddMenu(Panel:WaitForChild("MainFrame").Open,"Player","Left")
lib.Button.AddValue(CurrentMenu,"Speed","WalkSpeed",Character.Humanoid)
lib.Button.AddButton(CurrentMenu,"Double Speed", function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed *= 2 end)
lib.Button.AddButton(CurrentMenu,"Double Jump Height", function() game.Players.LocalPlayer.Character.Humanoid.JumpHeight *= 2 end)
lib.Button.AddToggle(CurrentMenu,"Emote", false)

CurrentMenu = lib.Menu.AddMenu(Panel:WaitForChild("MainFrame").Open,"Visual","Left")
local EnabledESP = {Plr = false, Egg = false, Entity = false, Item = false}
lib.Button.AddToggle(CurrentMenu,"Player ESP", false, function(Toggle)
	EnabledESP.Plr = Toggle
	if Toggle then
		for i,v in game.Players:GetPlayers() do
			if v.Character then
				ESPlib:AddESP(v.Character, Color3.new(1,1,1))
			end
		end
	end
end)
lib.Button.AddToggle(CurrentMenu,"Egg ESP", false)
lib.Button.AddToggle(CurrentMenu,"Entity ESP", false)
lib.Button.AddToggle(CurrentMenu,"Item ESP", false)
lib.Button.AddToggle(CurrentMenu,"ESP Enabled", true, function(Toggle) ESPlib:ApplySetting("ESPEnabled", Toggle) end)

CurrentMenu = lib.Menu.AddMenu(Panel:WaitForChild("MainFrame").Open,"Player","Right")
lib.Button.AddButton(CurrentMenu, "Respawn", function() Character.Humanoid.Health = 0 end)
lib.Button.AddToggle(CurrentMenu,"Fly", false)
local Gravity = workspace.Gravity
lib.Button.AddToggle(CurrentMenu,"Gravity Enabled", true, function(Toggle) workspace.Gravity = Toggle and Gravity or 0 end)
lib.Button.AddToggle(CurrentMenu,"Parts Gravity Ring", false)
lib.Button.AddButton(CurrentMenu, "Iconoconatatonic Button")

CurrentMenu = lib.Menu.AddMenu(Panel:WaitForChild("MainFrame").Open,"Exploits","Right")
lib.Button.AddToggle(CurrentMenu,"Fling", false)
lib.Button.AddToggle(CurrentMenu,"Anti Fling", true)
lib.Button.AddToggle(CurrentMenu,"Aimbot", false)
lib.Button.AddToggle(CurrentMenu,"Auto Egg Steal", false)
lib.Button.AddButton(CurrentMenu, "Kill All", function() for i,v in game.Players:GetPlayers() do v.Character.Humanoid.Health = 0 end end)
lib.Button.AddButton(CurrentMenu, "Rock-ify All", function() for i,v in game.Players:GetPlayers() do v.Character.Humanoid:Destroy() end end)

game["Run Service"].RenderStepped:Connect(function(dt) lib:Update(dt) end)
game["Run Service"].Heartbeat:Connect(function(dt) ESPlib.Update(dt) end)

game.Players.PlayerAdded:Connect(function(v)
	v.CharacterAdded:Connect(function()
		if not EnabledESP.Plr then return end
		ESPlib:AddESP(v.Character, Color3.new(1,1,1))
	end)
end)

game.UserInputService.InputEnded:Connect(function(i,gpe)
	if i.KeyCode ~= Enum.KeyCode.LeftControl or gpe then return end
	Panel.Visible = not Panel.Visible
end)
