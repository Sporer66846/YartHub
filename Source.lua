-- Boot Libraries
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- Create the Main Window
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 102791866964190, -- Your specific asset ID
    
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Welcome to the Future of Scripting",
    },
    
    BuildWarnings = false,
    NotifyOnCallbackError = true,
    
    FileSettings = {
        RootFolder = "YartHub",
        ConfigFolder = "configs",
        ThemesInRoot = false
    }
})

-- Build the Home Tab
win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    IconStyle = 1,
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"}, -- Updated executors
    Changelog = {
        {
            Title = "v1.1.0 Update",
            Date = "April 2026",
            Description = "Updated icon assets and executor compatibility list."
        }
    }
})

-- Create a Main Features Section
local mainSection = win:CreateTabSection("HUB FEATURES")

-- Example Feature Tab
local mainTab = mainSection:CreateTab({
    Name = "Main",
    Columns = 2,
    Icon = NebulaIcons:GetIcon("zap", "Lucide")
}, "main_tab")

-- Feature Groupbox
local featureGroup = mainTab:CreateGroupbox({
    Name = "Combat Mods",
    Column = 1,
    Icon = NebulaIcons:GetIcon("crosshair", "Lucide")
}, "combat_group")

featureGroup:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(state)
        print("Kill Aura Status:", state)
    end
}, "kill_aura")

-- Settings Section
local configSection = win:CreateTabSection("SETTINGS")
local configTab = configSection:CreateTab({
    Name = "Configuration",
    Columns = 2,
    Icon = NebulaIcons:GetIcon("settings", "Lucide")
}, "config_tab")

-- Built-in Starlight Modules
configTab:BuildThemeGroupbox(1)
configTab:BuildConfigGroupbox(2)

-- Initialization
Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
