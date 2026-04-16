--// SECTION : Booting Libraries & Core Variables
getgenv().SecureMode = true
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

--// SECTION : DynamicAim Variables (From your source)
local espFolder = Instance.new("Folder")
espFolder.Name = "DynamicAim_ESP"
espFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local ESPDrawings = {}
local Target = nil
local Aimbotting = nil

-- Create a global config table for your aimbot to easily sync with the UI
local AimbotSettings = {
    Enabled = false,
    Smoothness = 0.5,
    BulletDropAmount = 0,
    FOV = 100,
    Keybind = "MouseButton2" -- Default to Right Click
}

local ESPSettings = {
    Enabled = false,
    ChamsEnabled = false
}

-- [!] PASTE THE REST OF YOUR DYNAMICAIM FUNCTIONS HERE (e.g., GetHumanoid, ESP render loops, target selection logic) --
local function aimbotKeyDown()
    if not AimbotSettings.Enabled then return end
    -- Paste your target locking logic here
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
    if keyName == AimbotSettings.Keybind then aimbotKeyDown() end
end)

UserInputService.InputEnded:Connect(function(input, gameprocessed)
    local keyName = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or input.UserInputType.Name
    if keyName == AimbotSettings.Keybind then aimbotKeyUp() end
end)
-- [!] -------------------------------------------------------------------------------------------------------------- --

--// SECTION : Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739,
    LoadingEnabled = true,
    FileSettings = { RootFolder = "YartHub", ConfigFolder = "configs" }
})

win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"},
    Changelog = {{ Title = "Release", Date = "Pending", Description = "DynamicAim Integration Applied." }}
})

local Games = { TSB = 10449761463 }

if game.PlaceId == Games.TSB then
    -- TSB SPECIFIC CODE HERE
    local tsbSection = win:CreateTabSection("TSB FEATURES")
    local combatTab = tsbSection:CreateTab({ Name = "Combat", Columns = 1, Icon = NebulaIcons:GetIcon("swords", "Lucide") }, "tsb_combat")
    local mainGroup = combatTab:CreateGroupbox({ Name = "TSB Automation", Column = 1 }, "tsb_main")
    mainGroup:CreateToggle({ Name = "Auto Skills", Callback = function(v) end }, "tsb_skills")

--// SECTION : UNIVERSAL TABS
else
    local uniSection = win:CreateTabSection("UNIVERSAL")

    --// 1. VISUALS TAB
    local visualsTab = uniSection:CreateTab({
        Name = "Visuals", 
        Columns = 2,
        Icon = NebulaIcons:GetIcon("eye", "Lucide")
    }, "uni_visuals")

    local espGroup = visualsTab:CreateGroupbox({Name = "DynamicAim ESP", Column = 1}, "esp_group")
    
    espGroup:CreateToggle({
        Name = "Enable Master ESP",
        CurrentValue = false,
        Callback = function(state) 
            ESPSettings.Enabled = state
            if not state then
                -- Clear your ESP drawings when toggled off
                espFolder:ClearAllChildren()
                for _, drawing in pairs(ESPDrawings) do
                    drawing:Remove()
                end
            end
        end
    }, "esp_master")

    local chamGroup = visualsTab:CreateGroupbox({Name = "Chams", Column = 2}, "cham_group")
    chamGroup:CreateToggle({
        Name = "Enable Chams",
        CurrentValue = false,
        Callback = function(state) 
            ESPSettings.ChamsEnabled = state 
            -- Trigger your chams refresh logic here
        end
    }, "cham_toggle")

    --// 2. MOVEMENT TAB
    local movementTab = uniSection:CreateTab({
        Name = "Movement", 
        Columns = 2,
        Icon = NebulaIcons:GetIcon("move", "Lucide")
    }, "uni_move")

    local moveGroup = movementTab:CreateGroupbox({Name = "Physics", Column = 1}, "phys_group")
    moveGroup:CreateSlider({
        Name = "WalkSpeed", Range = {16, 250}, CurrentValue = 16,
        Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
    }, "ws_slider")

    moveGroup:CreateSlider({
        Name = "JumpPower", Range = {50, 300}, CurrentValue = 50,
        Callback = function(v) 
            game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    }, "jp_slider")

    --// 3. AIMBOT TAB
    local aimbotTab = uniSection:CreateTab({
        Name = "Aimbot", 
        Columns = 2,
        Icon = NebulaIcons:GetIcon("target", "Lucide")
    }, "uni_aim")

    local aimGroup = aimbotTab:CreateGroupbox({Name = "DynamicAim Controls", Column = 1}, "aim_controls")
    
    aimGroup:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = false,
        Callback = function(state) 
            AimbotSettings.Enabled = state 
            if not state then aimbotKeyUp() end -- Force stop if disabled while holding
        end
    }, "aim_toggle")

    aimGroup:CreateSlider({
        Name = "Smoothness",
        Range = {0.1, 1},
        Increment = 0.1,
        CurrentValue = 0.5,
        Callback = function(v) AimbotSettings.Smoothness = v end
    }, "aim_smooth")

    aimGroup:CreateSlider({
        Name = "Bullet Drop Prediction",
        Range = {0, 2},
        Increment = 0.1,
        CurrentValue = 0,
        Callback = function(v) AimbotSettings.BulletDropAmount = v end
    }, "aim_drop")

    local aimMisc = aimbotTab:CreateGroupbox({Name = "Targeting", Column = 2}, "aim_misc")
    
    aimMisc:CreateSlider({
        Name = "FOV Radius",
        Range = {10, 800},
        CurrentValue = 100,
        Callback = function(v) AimbotSettings.FOV = v end
    }, "aim_fov")

    aimMisc:CreateLabel({Name = "Aimbot Keybind"}, "aim_key_lbl"):AddBind({
        CurrentValue = "MouseButton2",
        Callback = function() end,
        OnChangedCallback = function(key) 
            AimbotSettings.Keybind = key 
        end
    }, "aim_keybind")
end

--// SECTION : Settings
local configSection = win:CreateTabSection("INTERFACE")
local configTab = configSection:CreateTab({Name = "Settings", Columns = 2, Icon = NebulaIcons:GetIcon("settings", "Lucide")}, "config")
configTab:BuildThemeGroupbox(1)
configTab:BuildConfigGroupbox(2)

Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
