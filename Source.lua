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

--// SECTION : Internal Script Logic (Aimbot & Visuals)
local espFolder = Instance.new("Folder")
espFolder.Name = "YartHub_ESP"
espFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Target = nil
local Aimbotting = nil

-- State Management
local Aimbot = {
    Enabled = false,
    Smoothness = 0.5,
    BulletDropAmount = 0,
    FOV = 100,
    Keybind = "MouseButton2"
}

local Visuals = {
    Enabled = false,
    Chams = false,
    Skeletons = false
}

-- Target Selection Logic
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

-- Aimbot Execution
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

            -- Bullet Drop Math Integration
            if Aimbot.BulletDropAmount > 0 then
                local dist = (Camera.CFrame.Position - position).Magnitude
                local bulletTravelTime = dist / 1000 
                local drop = 0.5 * Aimbot.BulletDropAmount * bulletTravelTime * bulletTravelTime
                position = Vector3.new(position.X, position.Y + drop, position.Z)
            end

            -- CFrame Lerping Logic
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

-- Input Listeners
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if key == Aimbot.Keybind then aimbotKeyDown() end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if key == Aimbot.Keybind then aimbotKeyUp() end
end)

--// SECTION : Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739,
    
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Detecting game...", -- Per your request
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
            Description = "Official release of Yart Hub. Universal and Game-Specific modules active."
        }
    }
})

--// SECTION : UNIVERSAL TABS (Always Visible)
local universalSection = win:CreateTabSection("UNIVERSAL")

-- 1. AIMBOT
local aimTab = universalSection:CreateTab({
    Name = "Aimbot", Columns = 2, Icon = NebulaIcons:GetIcon("target", "Lucide")
}, "uni_aim")

local aimGroup = aimTab:CreateGroupbox({Name = "Main Settings", Column = 1})
aimGroup:CreateToggle({
    Name = "Enable Aimbot", 
    CurrentValue = false,
    Callback = function(v) Aimbot.Enabled = v if not v then aimbotKeyUp() end end
}, "aim_toggle")

aimGroup:CreateSlider({
    Name = "Smoothness", Range = {0.1, 1}, Increment = 0.05, CurrentValue = 0.5,
    Callback = function(v) Aimbot.Smoothness = v end
}, "aim_smooth")

local aimTargeting = aimTab:CreateGroupbox({Name = "Targeting", Column = 2})
aimTargeting:CreateSlider({
    Name = "FOV Radius", Range = {10, 800}, CurrentValue = 100,
    Callback = function(v) Aimbot.FOV = v end
}, "aim_fov")

aimTargeting:CreateLabel({Name = "Aimbot Keybind"}):AddBind({
    CurrentValue = "MouseButton2",
    OnChangedCallback = function(key) Aimbot.Keybind = key end
}, "aim_bind")

-- 2. VISUALS
local visualTab = universalSection:CreateTab({
    Name = "Visuals", Columns = 2, Icon = NebulaIcons:GetIcon("eye", "Lucide")
}, "uni_vis")

local espGroup = visualTab:CreateGroupbox({Name = "ESP", Column = 1})
espGroup:CreateToggle({
    Name = "Master Switch", 
    Callback = function(v) Visuals.Enabled = v if not v then espFolder:ClearAllChildren() end end
}, "esp_master")

espGroup:CreateToggle({Name = "Show Skeletons", Callback = function(v) Visuals.Skeletons = v end}, "esp_skel")

local chamGroup = visualTab:CreateGroupbox({Name = "Chams", Column = 2})
chamGroup:CreateToggle({Name = "Enable Chams", Callback = function(v) Visuals.Chams = v end}, "chams_on")

-- 3. MOVEMENT
local moveTab = universalSection:CreateTab({
    Name = "Movement", Columns = 2, Icon = NebulaIcons:GetIcon("move", "Lucide")
}, "uni_move")

local physGroup = moveTab:CreateGroupbox({Name = "Modifiers", Column = 1})
physGroup:CreateSlider({
    Name = "WalkSpeed", Range = {16, 250}, CurrentValue = 16,
    Callback = function(v) Player.Character.Humanoid.WalkSpeed = v end
}, "ws_val")

physGroup:CreateSlider({
    Name = "JumpPower", Range = {50, 300}, CurrentValue = 50,
    Callback = function(v) 
        Player.Character.Humanoid.UseJumpPower = true
        Player.Character.Humanoid.JumpPower = v 
    end
}, "jp_val")

local exploitGroup = moveTab:CreateGroupbox({Name = "Utility", Column = 2})
exploitGroup:CreateToggle({Name = "TP Walk", Callback = function(v) end}, "tpwalk")
exploitGroup:CreateButton({Name = "Click TP", Callback = function() end}, "clicktp")

--// SECTION : GAME SPECIFIC (TSB)
if game.PlaceId == 10449761463 then
    local tsbSection = win:CreateTabSection("GAME SPECIFIC")
    local tsbTab = tsbSection:CreateTab({
        Name = "Battlegrounds", Columns = 2, Icon = NebulaIcons:GetIcon("swords", "Lucide")
    }, "tsb_tab")

    local tsbAuto = tsbTab:CreateGroupbox({Name = "Automation", Column = 1})
    tsbAuto:CreateToggle({Name = "Auto Skill Cycle", Callback = function(v) end}, "tsb_auto_skill")
end

--// SECTION : Interface Settings
local configSection = win:CreateTabSection("INTERFACE")
local configTab = configSection:CreateTab({
    Name = "Settings", Columns = 2, Icon = NebulaIcons:GetIcon("settings", "Lucide")
}, "settings")

configTab:BuildThemeGroupbox(1)
configTab:BuildConfigGroupbox(2)

--// Finalize
Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
