--// SECTION : Booting Libraries
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

--// SECTION : Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Suite",
    Icon = 101065953742739, -- Your working asset ID
    
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Finalizing Interface...",
    },
    
    FileSettings = {
        RootFolder = "YartHub",
        ConfigFolder = "configs"
    }
})

--// SECTION : Home Tab
win:CreateHomeTab({
    DiscordInvite = "euUwQzXNmC", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"},
    Changelog = {
        {
            Title = "Release", 
            Date = "Current",
            Description = "Initial development release."
        }
    }
})

--// SECTION : Game Detection Logic
local Games = { TSB = 10449761463 }

if game.PlaceId == Games.TSB then
    local tsbSection = win:CreateTabSection("TSB FEATURES")
    
    -- Ensuring TabIndex ("combat") and Columns (2) are provided to fix console errors
    local combatTab = tsbSection:CreateTab({
        Name = "Combat",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("swords", "Lucide")
    }, "combat") -- Fixed: TabIndex provided here

    local mainGroup = combatTab:CreateGroupbox({
        Name = "TSB Automation",
        Column = 1
    }, "tsb_main")

    mainGroup:CreateToggle({
        Name = "Auto Skills",
        CurrentValue = false,
        Callback = function(v) print("TSB Auto Skills:", v) end
    }, "auto_skills")

--// SECTION : UNIVERSAL MODULES
else
    local universalSection = win:CreateTabSection("UNIVERSAL")

    -- 1. VISUALS TAB
    local visualsTab = universalSection:CreateTab({
        Name = "Visuals",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("eye", "Lucide")
    }, "universal_visuals")

    local espGroup = visualsTab:CreateGroupbox({Name = "ESP", Column = 1}, "esp_group")
    espGroup:CreateToggle({Name = "Enable ESP", Callback = function(v) end}, "esp_toggle")
    
    local chamGroup = visualsTab:CreateGroupbox({Name = "Chams", Column = 2}, "cham_group")
    chamGroup:CreateToggle({Name = "Enable Chams", Callback = function(v) end}, "cham_toggle")

    -- 2. MOVEMENT TAB
    local moveTab = universalSection:CreateTab({
        Name = "Movement",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("move", "Lucide")
    }, "universal_movement")

    local physGroup = moveTab:CreateGroupbox({Name = "Physics", Column = 1}, "phys_group")
    physGroup:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 250},
        CurrentValue = 16,
        Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
    }, "ws_slider")
    
    physGroup:CreateSlider({
        Name = "JumpPower",
        Range = {50, 300},
        CurrentValue = 50,
        Callback = function(v) 
            game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
        end
    }, "jp_slider")

    local exploitGroup = moveTab:CreateGroupbox({Name = "Exploits", Column = 2}, "exploit_group")
    exploitGroup:CreateToggle({Name = "TP Walk", Callback = function(v) end}, "tpwalk")
    exploitGroup:CreateButton({Name = "Click TP", Callback = function() end}, "clicktp")

    -- 3. AIMBOT TAB
    local aimTab = universalSection:CreateTab({
        Name = "Aimbot",
        Columns = 1,
        Icon = NebulaIcons:GetIcon("target", "Lucide")
    }, "universal_aim")

    local aimGroup = aimTab:CreateGroupbox({Name = "Settings", Column = 1}, "aim_group")
    aimGroup:CreateToggle({Name = "Enable Aimbot", Callback = function(v) end}, "aim_enabled")
    aimGroup:CreateSlider({Name = "FOV Radius", Range = {10, 600}, CurrentValue = 100, Callback = function(v) end}, "aim_fov")
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
