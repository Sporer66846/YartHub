--[[ 
    Yart Hub - Multi-Game Template
    Powered by Starlight Interface Suite 
--]]

--// SECTION : Booting Libraries
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

--// SECTION : Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739, -- Your working Asset ID
    
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Detecting Game Environment...",
    },
    
    BuildWarnings = false,
    NotifyOnCallbackError = true,
    
    FileSettings = {
        RootFolder = "YartHub",
        ConfigFolder = "configs",
        ThemesInRoot = false
    }
})

--// SECTION : Home Tab Setup
win:CreateHomeTab({
    DiscordInvite = "euUwQzXNmC", 
    IconStyle = 1,
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"}, -- Your requested list
    Changelog = {
        {
            Title = "v1.2.0 - TSB Support",
            Date = "April 2026",
            Description = "Added full support for The Strongest Battlegrounds."
        }
    }
})

--// SECTION : Multi-Game Router
-- Place your PlaceIds here for easy management
local Games = {
    TSB = 10449761463
}

-- Current Place Detection
local currentPlaceId = game.PlaceId

--// SUBSECTION : The Strongest Battlegrounds Logic
if currentPlaceId == Games.TSB then
    local tsbSection = win:CreateTabSection("TSB FEATURES")
    
    local combatTab = tsbSection:CreateTab({
        Name = "Combat",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("swords", "Lucide")
    }, "tsb_combat")

    local mainGroup = combatTab:CreateGroupbox({
        Name = "Automation",
        Column = 1,
        Icon = NebulaIcons:GetIcon("zap", "Lucide")
    }, "tsb_auto")

    mainGroup:CreateToggle({
        Name = "Auto Skills",
        CurrentValue = false,
        Tooltip = "Automatically uses skills when they are off cooldown.",
        Callback = function(state)
            -- Your TSB Skill Logic here
            print("Auto Skills:", state)
        end
    }, "auto_skills")

    local miscGroup = combatTab:CreateGroupbox({
        Name = "Movement",
        Column = 2
    }, "tsb_move")

    miscGroup:CreateSlider({
        Name = "Infinite Dash Distance",
        Range = {1, 50},
        CurrentValue = 25,
        Increment = 1,
        Callback = function(val)
            -- Your TSB Dash Logic here
            print("Dash Distance:", val)
        end
    }, "dash_slider")

--// SUBSECTION : Future Games (Placeholder)
-- elseif currentPlaceId == 123456789 then
--    -- Setup for the next game goes here

--// SUBSECTION : Universal (Fallback for unsupported games)
else
    local uniSection = win:CreateTabSection("UNIVERSAL")
    local uniTab = uniSection:CreateTab({Name = "General", Icon = NebulaIcons:GetIcon("globe", "Lucide")})
    local uniGroup = uniTab:CreateGroupbox({Name = "Movement"})
    
    uniGroup:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 150},
        CurrentValue = 16,
        Callback = function(v)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    }, "uni_ws")
end

--// SECTION : Core Settings (Always Visible)
local settingsSection = win:CreateTabSection("INTERFACE")
local settingsTab = settingsSection:CreateTab({
    Name = "Settings", 
    Icon = NebulaIcons:GetIcon("settings", "Lucide")
}, "ui_settings")

settingsTab:BuildThemeGroupbox(1)
settingsTab:BuildConfigGroupbox(2)

--// SECTION : Finalize
Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
