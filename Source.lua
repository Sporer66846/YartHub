--// SECTION : Booting Libraries
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

--// SECTION : Window Initialization
-- The CreateWindow method sets up the main interface and loading screen.
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739, -- Verified working Asset ID
    
    LoadingEnabled = true,
    LoadingSettings = {
        Title = "Yart Hub",
        Subtitle = "Preparing Finished Assets...",
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
-- The Home Tab displays the executor compatibility and the latest changelog entry.
win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    IconStyle = 1,
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"}, 
    Changelog = {
        {
            Title = "Release", 
            Date = "Pending",
            Description = "The script is currently in development. All features will be finalized upon official release."
        }
    }
})

--// SECTION : Game Identification
local Games = {
    TSB = 10449761463
}

--// SECTION : The Strongest Battlegrounds Features
if game.PlaceId == Games.TSB then
    -- CreateTabSection organizes the navigation sidebar.
    local tsbSection = win:CreateTabSection("TSB FEATURES")
    
    -- CreateTab defines the individual page structure.
    local combatTab = tsbSection:CreateTab({
        Name = "Combat",
        Columns = 2,
        Icon = NebulaIcons:GetIcon("swords", "Lucide")
    }, "tsb_combat")

    -- Groupboxes hold individual elements like toggles and sliders.
    local mainGroup = combatTab:CreateGroupbox({
        Name = "Automation",
        Column = 1,
        Icon = NebulaIcons:GetIcon("zap", "Lucide")
    }, "tsb_auto")

    mainGroup:CreateToggle({
        Name = "Auto Skills",
        CurrentValue = false,
        Callback = function(state)
            print("Auto Skills active:", state)
        end
    }, "auto_skills")

--// SECTION : Universal Features (Fallback)
else
    local uniSection = win:CreateTabSection("UNIVERSAL")
    local uniTab = uniSection:CreateTab({
        Name = "General", 
        Icon = NebulaIcons:GetIcon("globe", "Lucide")
    })
    
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

--// SECTION : Settings and Customization
-- Starlight includes prebuilt methods for managing themes and configurations.
local settingsSection = win:CreateTabSection("INTERFACE")
local settingsTab = settingsSection:CreateTab({
    Name = "Settings", 
    Icon = NebulaIcons:GetIcon("settings", "Lucide")
}, "ui_settings")

settingsTab:BuildThemeGroupbox(1)
settingsTab:BuildConfigGroupbox(2)

-- Finalize by loading any saved user preferences.
Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
