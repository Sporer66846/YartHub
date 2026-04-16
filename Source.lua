--// SECTION : Booting Libraries
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

--// SECTION : Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739, -- Verified working Asset ID
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Finalizing Universal Modules...",
    },
    FileSettings = {
        RootFolder = "YartHub",
        ConfigFolder = "configs"
    }
})

--// SECTION : Home Tab Setup
win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"}, --
    Changelog = {
        {
            Title = "Release", 
            Date = "Pending",
            Description = "Initial development release with full Universal support."
        }
    }
})

--// SECTION : Game Routing Logic
local Games = { TSB = 10449761463 }

if game.PlaceId == Games.TSB then
    -- [Specific TSB Code would go here]
    local tsbSection = win:CreateTabSection("TSB FEATURES")
    local tsbTab = tsbSection:CreateTab({Name = "Combat", Icon = NebulaIcons:GetIcon("zap", "Lucide")})
    local tsbGroup = tsbTab:CreateGroupbox({Name = "The Strongest Battlegrounds"})
    tsbGroup:CreateLabel({Name = "TSB Logic Loaded"})

--// SECTION : UNIVERSAL TABS (Visuals, Movement, Aimbot)
else
    local uniSection = win:CreateTabSection("UNIVERSAL")

    -- 1. Visuals Tab
    local visualsTab = uniSection:CreateTab({
        Name = "Visuals", 
        Icon = NebulaIcons:GetIcon("eye", "Lucide")
    }, "uni_visuals_tab")

    local espGroup = visualsTab:CreateGroupbox({Name = "ESP & Chams", Column = 1})
    espGroup:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Callback = function(v) print("ESP:", v) end
    }, "uni_esp")

    espGroup:CreateToggle({
        Name = "Enable Chams",
        CurrentValue = false,
        Callback = function(v) print("Chams:", v) end
    }, "uni_chams")

    -- 2. Movement Tab
    local movementTab = uniSection:CreateTab({
        Name = "Movement", 
        Icon = NebulaIcons:GetIcon("move", "Lucide")
    }, "uni_movement_tab")

    local moveGroup = movementTab:CreateGroupbox({Name = "Player Physics", Column = 1})
    moveGroup:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 250},
        CurrentValue = 16,
        Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
    }, "uni_ws")

    moveGroup:CreateSlider({
        Name = "JumpPower",
        Range = {50, 300},
        CurrentValue = 50,
        Callback = function(v) 
            local hum = game.Players.LocalPlayer.Character.Humanoid
            hum.UseJumpPower = true
            hum.JumpPower = v 
        end
    }, "uni_jp")

    local extraMove = movementTab:CreateGroupbox({Name = "Exploits", Column = 2})
    extraMove:CreateToggle({
        Name = "TP Walk",
        CurrentValue = false,
        Callback = function(v) print("TP Walk:", v) end
    }, "uni_tpwalk")

    extraMove:CreateButton({
        Name = "Click TP (Ctrl + Click)",
        Callback = function() print("Click TP Enabled (Tool/Logic Required)") end
    }, "uni_clicktp")

    -- 3. Aimbot Tab
    local aimbotTab = uniSection:CreateTab({
        Name = "Aimbot", 
        Icon = NebulaIcons:GetIcon("target", "Lucide")
    }, "uni_aimbot_tab")

    local aimGroup = aimbotTab:CreateGroupbox({Name = "Main Aimbot", Column = 1})
    aimGroup:CreateToggle({
        Name = "Enabled",
        CurrentValue = false,
        Callback = function(v) print("Aimbot Status:", v) end
    }, "uni_aim_toggle")
    
    aimGroup:CreateSlider({
        Name = "FOV Radius",
        Range = {10, 800},
        CurrentValue = 100,
        Callback = function(v) print("Aimbot FOV:", v) end
    }, "uni_aim_fov")
end

--// SECTION : Core Settings
local configSection = win:CreateTabSection("INTERFACE")
local configTab = configSection:CreateTab({Name = "Settings", Icon = NebulaIcons:GetIcon("settings", "Lucide")})
configTab:BuildThemeGroupbox(1)
configTab:BuildConfigGroupbox(2)

--// SECTION : Finalize
Starlight:LoadAutoloadConfig() --
Starlight:LoadAutoloadTheme() --
