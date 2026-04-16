getgenv().SecureMode = true

--// SECTION: Core Services & Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

--// SECTION: Logic State Variables
local espFolder = Instance.new("Folder")
espFolder.Name = "YartHub_ESP"
espFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Target = nil
local Aimbotting = nil

local Aimbot = {
    Enabled = false,
    Smoothness = 0.5,
    Prediction = 0,
    FOV = 100,
    Keybind = "MouseButton2"
}

local Triggerbot = {
    Enabled = false,
    Delay = 0.05
}

local Visuals = {
    Enabled = false,
    Chams = false,
    Skeletons = false
}

--// SECTION: Aimbot & Triggerbot Logic
local function GetClosestPlayer()
    local closestDist = Aimbot.FOV
    local closestTarget = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < closestDist then
                    closestTarget = v
                    closestDist = dist
                end
            end
        end
    end
    return closestTarget
end

-- Aimbot Hook
local function aimbotKeyDown()
    if not Aimbot.Enabled then return end
    Target = GetClosestPlayer()
    
    if Target and Target.Character and Target.Character:FindFirstChild("Head") then
        Aimbotting = RunService.RenderStepped:Connect(function(dt)
            if not Target or not Target.Character or not Target.Character:FindFirstChild("Head") or Target.Character.Humanoid.Health <= 0 then
                if Aimbotting then Aimbotting:Disconnect() Aimbotting = nil end
                return
            end

            local position = Target.Character.Head.Position

            if Aimbot.Prediction > 0 then
                local dist = (Camera.CFrame.Position - position).Magnitude
                local bulletTravelTime = dist / 1000 
                local drop = 0.5 * Aimbot.Prediction * bulletTravelTime * bulletTravelTime
                position = Vector3.new(position.X, position.Y + drop, position.Z)
            end

            local newCFrame = CFrame.lookAt(Camera.CFrame.Position, position)
            local alpha = 1 - math.pow(1 - Aimbot.Smoothness, dt * 60)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, math.clamp(alpha, 0, 1))
        end)
    end
end

local function aimbotKeyUp()
    if Aimbotting then Aimbotting:Disconnect() Aimbotting = nil end
    Target = nil
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if key == Aimbot.Keybind then aimbotKeyDown() end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if key == Aimbot.Keybind then aimbotKeyUp() end
end)

-- Triggerbot Hook
RunService.RenderStepped:Connect(function()
    if Triggerbot.Enabled and Mouse.Target then
        local targetChar = Mouse.Target:FindFirstAncestorOfClass("Model")
        if targetChar and targetChar:FindFirstChild("Humanoid") then
            local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
            if targetPlayer and targetPlayer ~= Player and targetChar.Humanoid.Health > 0 then
                if mouse1click then mouse1click() end
                task.wait(Triggerbot.Delay)
            end
        end
    end
end)


--// SECTION: Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739,
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Detecting game...",
    },
    FileSettings = {
        RootFolder = "YartHub",
        ConfigFolder = "configs"
    }
})

win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"},
    Changelog = {{ Title = "Release", Date = "Current", Description = "Universal & TSB Modules Active." }}
})

--// SECTION: UNIVERSAL TABS (Always Active)
local universalSection = win:CreateTabSection("UNIVERSAL")

-- 1. COMBAT
local combatTab = universalSection:CreateTab({
    Name = "Combat", Columns = 2, Icon = NebulaIcons:GetIcon("crosshair", "Lucide")
}, "uni_combat")

local aimGroup = combatTab:CreateGroupbox({Name = "Aimbot Settings", Column = 1}, "aim_gb")
aimGroup:CreateToggle({Name = "Enable Aimbot", Callback = function(v) Aimbot.Enabled = v if not v then aimbotKeyUp() end end}, "aim_enable")
aimGroup:CreateSlider({Name = "Smoothness", Range = {0.1, 1}, Increment = 0.05, CurrentValue = 0.5, Callback = function(v) Aimbot.Smoothness = v end}, "aim_smooth")
aimGroup:CreateSlider({Name = "FOV Radius", Range = {10, 800}, CurrentValue = 100, Callback = function(v) Aimbot.FOV = v end}, "aim_fov")
aimGroup:CreateSlider({Name = "Prediction / Drop", Range = {0, 5}, Increment = 0.1, CurrentValue = 0, Callback = function(v) Aimbot.Prediction = v end}, "aim_pred")
aimGroup:CreateLabel({Name = "Aimbot Keybind"}, "aim_key_lbl"):AddBind({CurrentValue = "MouseButton2", OnChangedCallback = function(key) Aimbot.Keybind = key end}, "aim_key")

local trigGroup = combatTab:CreateGroupbox({Name = "Triggerbot", Column = 2}, "trig_gb")
trigGroup:CreateToggle({Name = "Enable Triggerbot", Callback = function(v) Triggerbot.Enabled = v end}, "trig_enable")
trigGroup:CreateSlider({Name = "Click Delay", Range = {0, 0.5}, Increment = 0.01, CurrentValue = 0.05, Callback = function(v) Triggerbot.Delay = v end}, "trig_delay")

-- 2. VISUALS
local visualTab = universalSection:CreateTab({
    Name = "Visuals", Columns = 2, Icon = NebulaIcons:GetIcon("eye", "Lucide")
}, "uni_vis")

local espGroup = visualTab:CreateGroupbox({Name = "ESP Features", Column = 1}, "esp_gb")
espGroup:CreateToggle({Name = "Master ESP Switch", Callback = function(v) Visuals.Enabled = v if not v then espFolder:ClearAllChildren() end end}, "esp_master")
espGroup:CreateToggle({Name = "Show Skeletons", Callback = function(v) Visuals.Skeletons = v end}, "esp_skel")

local chamGroup = visualTab:CreateGroupbox({Name = "Chams", Column = 2}, "cham_gb")
chamGroup:CreateToggle({Name = "Enable Chams", Callback = function(v) Visuals.Chams = v end}, "esp_chams")

-- 3. MOVEMENT
local moveTab = universalSection:CreateTab({
    Name = "Movement", Columns = 2, Icon = NebulaIcons:GetIcon("move", "Lucide")
}, "uni_move")

local physGroup = moveTab:CreateGroupbox({Name = "Physics", Column = 1}, "phys_gb")
physGroup:CreateSlider({Name = "WalkSpeed", Range = {16, 250}, CurrentValue = 16, Callback = function(v) Player.Character.Humanoid.WalkSpeed = v end}, "move_ws")
physGroup:CreateSlider({Name = "JumpPower", Range = {50, 300}, CurrentValue = 50, Callback = function(v) Player.Character.Humanoid.UseJumpPower = true Player.Character.Humanoid.JumpPower = v end}, "move_jp")

local utilGroup = moveTab:CreateGroupbox({Name = "Utility", Column = 2}, "util_gb")
utilGroup:CreateToggle({Name = "TP Walk", Callback = function(v) end}, "move_tpwalk")


--// SECTION: THE STRONGEST BATTLEGROUNDS
if game.PlaceId == 10449761463 then
    local tsbSection = win:CreateTabSection("THE STRONGEST BATTLEGROUNDS")
    
    local techsTab = tsbSection:CreateTab({Name = "Techs", Columns = 1, Icon = NebulaIcons:GetIcon("zap", "Lucide")}, "tsb_techs")
    techsTab:CreateGroupbox({Name = "Future Tech Features", Column = 1}, "tsb_techs_gb")
    
    local aimlockTab = tsbSection:CreateTab({Name = "Aimlock", Columns = 1, Icon = NebulaIcons:GetIcon("target", "Lucide")}, "tsb_aimlock")
    aimlockTab:CreateGroupbox({Name = "Future Aimlock Features", Column = 1}, "tsb_aim_gb")
    
    local autoblockTab = tsbSection:CreateTab({Name = "AutoBlock", Columns = 1, Icon = NebulaIcons:GetIcon("shield", "Lucide")}, "tsb_autoblock")
    autoblockTab:CreateGroupbox({Name = "Future AutoBlock Features", Column = 1}, "tsb_block_gb")
end


--// SECTION: Settings
local configSection = win:CreateTabSection("INTERFACE")
local configTab = configSection:CreateTab({Name = "Settings", Columns = 2, Icon = NebulaIcons:GetIcon("settings", "Lucide")}, "ui_settings")
configTab:BuildThemeGroupbox(1)
configTab:BuildConfigGroupbox(2)

Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
