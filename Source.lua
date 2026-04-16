getgenv().SecureMode = true

--// SECTION : Services & Core Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

--// SECTION : Aimbot & Visuals Logic
local espFolder = Instance.new("Folder")
espFolder.Name = "YartHub_ESP"
espFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local ESPDrawings = {}
local Target = nil
local Aimbotting = nil

-- Global settings synced with the Yart Hub UI
local Aimbot = {
    Enabled = false,
    Smoothness = 0.5,
    BulletDropAmount = 0,
    FOV = 100,
    Keybind = "MouseButton2"
}

local ESPSettings = {
    Enabled = false,
    ChamsEnabled = false,
    ShowSkeletons = false
}

local R6_Connections = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local R15_Connections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

-- Utility Functions
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

-- Aimbot Core Connections
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

            -- Bullet Drop Math
            if Aimbot.BulletDropAmount > 0 then
                local dist = (Camera.CFrame.Position - position).Magnitude
                local bulletTravelTime = dist / 1000 
                local drop = 0.5 * Aimbot.BulletDropAmount * bulletTravelTime * bulletTravelTime
                position = Vector3.new(position.X, position.Y + drop, position.Z)
            end

            -- Lerping Math
            local newCFrame = CFrame.lookAt(Camera.CFrame.Position, position)
            local alpha = 1 - math.pow(1 - Aimbot.Smoothness, dt * 60)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, math.clamp(alpha, 0, 1))
        end)
    end
end

local function aimbotKeyUp()
    if Aimbotting then
        Aimbotting:Disconnect()
        Aimbotting = nil
    end
    Target = nil
end

UserInputService.InputBegan:Connect(function(input, gameprocessed)
    if gameprocessed then return end
    local keyName = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if keyName == Aimbot.Keybind then aimbotKeyDown() end
end)

UserInputService.InputEnded:Connect(function(input, gameprocessed)
    local keyName = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if keyName == Aimbot.Keybind then aimbotKeyUp() end
end)


--// SECTION : Yart Hub Window Initialization
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

--// SECTION : Home Tab
win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"},
    Changelog = {
        {
            Title = "Release", 
            Date = "Current",
            Description = "Aimbot and Visual Logic Successfully Integrated."
        }
    }
})

--// SECTION : Game Routing Logic
local Games = { TSB = 10449761463 }

if game.PlaceId == Games.TSB then
    local tsbSection = win:CreateTabSection("TSB FEATURES")
    local combatTab = tsbSection:CreateTab({
        Name = "Combat",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("swords", "Lucide")
    }, "tsb_combat")

    local mainGroup = combatTab:CreateGroupbox({Name = "TSB Automation", Column = 1}, "tsb_main")
    mainGroup:CreateToggle({Name = "Auto Skills", Callback = function(v) end}, "tsb_skills")

--// SECTION : UNIVERSAL MODULES
else
    local universalSection = win:CreateTabSection("UNIVERSAL")

    -- 1. VISUALS TAB
    local visualsTab = universalSection:CreateTab({
        Name = "Visuals",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("eye", "Lucide")
    }, "universal_visuals")

    local espGroup = visualsTab:CreateGroupbox({Name = "ESP Settings", Column = 1}, "esp_group")
    
    espGroup:CreateToggle({
        Name = "Enable Master ESP",
        CurrentValue = false,
        Callback = function(state) 
            ESPSettings.Enabled = state
            if not state then
                espFolder:ClearAllChildren()
            end
        end
    }, "esp_master")

    espGroup:CreateToggle({
        Name = "Draw Skeletons",
        CurrentValue = false,
        Callback = function(state) ESPSettings.ShowSkeletons = state end
    }, "esp_skel")
    
    local chamGroup = visualsTab:CreateGroupbox({Name = "Chams", Column = 2}, "cham_group")
    chamGroup:CreateToggle({
        Name = "Enable Chams",
        CurrentValue = false,
        Callback = function(state) ESPSettings.ChamsEnabled = state end
    }, "cham_toggle")

    -- 2. MOVEMENT TAB
    local moveTab = universalSection:CreateTab({
        Name = "Movement",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("move", "Lucide")
    }, "universal_movement")

    local physGroup = moveTab:CreateGroupbox({Name = "Physics", Column = 1}, "phys_group")
    physGroup:CreateSlider({
        Name = "WalkSpeed", Range = {16, 250}, CurrentValue = 16,
        Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
    }, "ws_slider")
    
    physGroup:CreateSlider({
        Name = "JumpPower", Range = {50, 300}, CurrentValue = 50,
        Callback = function(v) 
            game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    }, "jp_slider")

    -- 3. AIMBOT TAB
    local aimTab = universalSection:CreateTab({
        Name = "Aimbot",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("target", "Lucide")
    }, "universal_aim")

    local aimGroup = aimTab:CreateGroupbox({Name = "Aimbot Controls", Column = 1}, "aim_group")
    
    aimGroup:CreateToggle({
        Name = "Enable Aimbot", 
        CurrentValue = false,
        Callback = function(state) 
            Aimbot.Enabled = state 
            if not state then aimbotKeyUp() end
        end
    }, "aim_enabled")
    
    aimGroup:CreateSlider({
        Name = "FOV Radius", 
        Range = {10, 800}, 
        CurrentValue = 100, 
        Callback = function(v) Aimbot.FOV = v end
    }, "aim_fov")

    aimGroup:CreateSlider({
        Name = "Smoothness", 
        Range = {0.1, 1}, 
        Increment = 0.05,
        CurrentValue = 0.5, 
        Callback = function(v) Aimbot.Smoothness = v end
    }, "aim_smooth")

    aimGroup:CreateSlider({
        Name = "Bullet Drop Prediction", 
        Range = {0, 5}, 
        Increment = 0.1,
        CurrentValue = 0, 
        Callback = function(v) Aimbot.BulletDropAmount = v end
    }, "aim_drop")

    local aimMisc = aimTab:CreateGroupbox({Name = "Keybinds", Column = 2}, "aim_misc")
    
    aimMisc:CreateLabel({Name = "Aimbot Keybind"}, "aim_key_lbl"):AddBind({
        CurrentValue = "MouseButton2",
        Callback = function() end,
        OnChangedCallback = function(key) 
            Aimbot.Keybind = key 
        end
    }, "aim_keybind")
end

--// SECTION : Interface Settings
local settingsSection = win:CreateTabSection("INTERFACE")
local settingsTab = settingsSection:CreateTab({
    Name = "Settings", 
    Columns = 2,
    Icon = NebulaIcons:GetIcon("settings", "Lucide")
}, "settings")

settingsTab:BuildThemeGroupbox(1)
settingsTab:BuildConfigGroupbox(2)

--// SECTION : Finalize
Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
