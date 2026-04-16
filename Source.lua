getgenv().SecureMode = true

--// SECTION: Core Services & Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

--// SECTION: Logic State Variables
local espFolder = Instance.new("Folder")
espFolder.Name = "YartHub_ESP"
espFolder.Parent = (gethui and gethui()) or CoreGui

local Target = nil
local Aimbotting = nil

local Aimbot = {
    Enabled = false,
    Smoothness = 0.5,
    Prediction = false,
    BulletVelocity = 1000,
    BulletDrop = 0,
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
    Skeletons = false,
    Names = false
}

local Movement = {
    WSEnabled = false,
    WSValue = 16,
    JPEnabled = false,
    JPValue = 50,
    TPWalk = false,
    TPSpeed = 50
}

local ESPDrawings = {}

--// SECTION: Utility & Math Functions
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

--// SECTION: ESP Logic Engine
local function clearESP()
    for _, drawing in pairs(ESPDrawings) do
        if drawing then drawing:Remove() end
    end
    table.clear(ESPDrawings)
    espFolder:ClearAllChildren()
end

local function drawText(text, pos, color)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Position = pos
    txt.Color = color
    txt.Size = 16
    txt.Center = true
    txt.Outline = true
    txt.Visible = true
    table.insert(ESPDrawings, txt)
    return txt
end

RunService.RenderStepped:Connect(function()
    clearESP()
    if not Visuals.Enabled then return end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            
            -- Chams Logic
            if Visuals.Chams then
                local highlight = espFolder:FindFirstChild(v.Name .. "_cham")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = v.Name .. "_cham"
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = espFolder
                end
                highlight.Adornee = v.Character
            end

            -- Names Logic
            if Visuals.Names then
                local head = v.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
                    if onScreen then
                        drawText(v.Name, Vector2.new(pos.X, pos.Y), Color3.new(1, 1, 1))
                    end
                end
            end

            -- Skeleton Logic Placeholder (Expanded per your R6/R15 tables if needed)
            if Visuals.Skeletons then
                -- Add skeleton drawing math here based on R6/R15 arrays
            end
        end
    end
end)

--// SECTION: Aimbot & Triggerbot Hooks
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

            -- Advanced Prediction Math
            if Aimbot.Prediction then
                local dist = (Camera.CFrame.Position - position).Magnitude
                local timeToHit = dist / Aimbot.BulletVelocity
                
                -- Target Velocity compensation
                local targetVel = Target.Character.HumanoidRootPart.Velocity
                position = position + (targetVel * timeToHit)
                
                -- Bullet Drop compensation
                local drop = 0.5 * Aimbot.BulletDrop * (timeToHit ^ 2)
                position = position + Vector3.new(0, drop, 0)
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

--// SECTION: Movement Hooks
RunService.Heartbeat:Connect(function(dt)
    local char = Player.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hum = char.Humanoid
    local hrp = char.HumanoidRootPart

    if Movement.WSEnabled then hum.WalkSpeed = Movement.WSValue end
    if Movement.JPEnabled then 
        hum.UseJumpPower = true 
        hum.JumpPower = Movement.JPValue 
    end

    if Movement.TPWalk and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * Movement.TPSpeed * dt)
    end
end)


--// SECTION: Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739,
    LoadingEnabled = true,
    LoadingSettings = { Title = "Yart Hub", Subtitle = "Detecting game..." },
    FileSettings = { RootFolder = "YartHub", ConfigFolder = "configs" }
})

win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"},
    Changelog = {{ Title = "Release", Date = "Current", Description = "Universal & TSB Modules Active." }}
})

--// SECTION: UNIVERSAL TABS (Always Active)
local universalSection = win:CreateTabSection("UNIVERSAL")

-- 1. COMBAT
local combatTab = universalSection:CreateTab({Name = "Combat", Columns = 2, Icon = NebulaIcons:GetIcon("crosshair", "Lucide")}, "uni_combat")

local aimGroup = combatTab:CreateGroupbox({Name = "Aimbot Settings", Column = 1}, "aim_gb")
aimGroup:CreateToggle({Name = "Enable Aimbot", Callback = function(v) Aimbot.Enabled = v if not v then aimbotKeyUp() end end}, "aim_enable")
aimGroup:CreateSlider({Name = "Smoothness", Range = {0.1, 1}, Increment = 0.05, CurrentValue = 0.5, Callback = function(v) Aimbot.Smoothness = v end}, "aim_smooth")
aimGroup:CreateSlider({Name = "FOV Radius", Range = {10, 800}, CurrentValue = 100, Callback = function(v) Aimbot.FOV = v end}, "aim_fov")
aimGroup:CreateLabel({Name = "Aimbot Keybind"}, "aim_key_lbl"):AddBind({CurrentValue = "MouseButton2", OnChangedCallback = function(key) Aimbot.Keybind = key end}, "aim_key")

local predGroup = combatTab:CreateGroupbox({Name = "Prediction Settings", Column = 1}, "pred_gb")
predGroup:CreateToggle({Name = "Enable Prediction", Callback = function(v) Aimbot.Prediction = v end}, "aim_pred_tgl")
predGroup:CreateSlider({Name = "Bullet Velocity", Range = {100, 3000}, CurrentValue = 1000, Increment = 50, Callback = function(v) Aimbot.BulletVelocity = v end}, "aim_vel")
predGroup:CreateSlider({Name = "Bullet Drop", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) Aimbot.BulletDrop = v end}, "aim_drop")

local trigGroup = combatTab:CreateGroupbox({Name = "Triggerbot", Column = 2}, "trig_gb")
trigGroup:CreateToggle({Name = "Enable Triggerbot", Callback = function(v) Triggerbot.Enabled = v end}, "trig_enable")
trigGroup:CreateSlider({Name = "Click Delay", Range = {0, 0.5}, Increment = 0.01, CurrentValue = 0.05, Callback = function(v) Triggerbot.Delay = v end}, "trig_delay")

-- 2. VISUALS
local visualTab = universalSection:CreateTab({Name = "Visuals", Columns = 2, Icon = NebulaIcons:GetIcon("eye", "Lucide")}, "uni_vis")

local espGroup = visualTab:CreateGroupbox({Name = "ESP Settings", Column = 1}, "esp_gb")
espGroup:CreateToggle({Name = "Master ESP Switch", Callback = function(v) Visuals.Enabled = v if not v then clearESP() end end}, "esp_master")
espGroup:CreateToggle({Name = "Show Names", Callback = function(v) Visuals.Names = v end}, "esp_names")
espGroup:CreateToggle({Name = "Show Skeletons", Callback = function(v) Visuals.Skeletons = v end}, "esp_skel")

local chamGroup = visualTab:CreateGroupbox({Name = "Chams", Column = 2}, "cham_gb")
chamGroup:CreateToggle({Name = "Enable Chams", Callback = function(v) Visuals.Chams = v end}, "esp_chams")

-- 3. MOVEMENT
local moveTab = universalSection:CreateTab({Name = "Movement", Columns = 2, Icon = NebulaIcons:GetIcon("move", "Lucide")}, "uni_move")

local physGroup = moveTab:CreateGroupbox({Name = "Player Physics", Column = 1}, "phys_gb")
physGroup:CreateToggle({Name = "Enable WalkSpeed", Callback = function(v) Movement.WSEnabled = v end}, "ws_enable")
physGroup:CreateSlider({Name = "WalkSpeed Value", Range = {16, 250}, CurrentValue = 16, Callback = function(v) Movement.WSValue = v end}, "ws_val")

physGroup:CreateToggle({Name = "Enable JumpPower", Callback = function(v) Movement.JPEnabled = v end}, "jp_enable")
physGroup:CreateSlider({Name = "JumpPower Value", Range = {50, 300}, CurrentValue = 50, Callback = function(v) Movement.JPValue = v end}, "jp_val")

local tpGroup = moveTab:CreateGroupbox({Name = "TP Walk", Column = 2}, "tp_gb")
tpGroup:CreateToggle({Name = "Enable TP Walk", Callback = function(v) Movement.TPWalk = v end}, "tp_enable")
tpGroup:CreateSlider({Name = "TP Walk Speed", Range = {10, 200}, CurrentValue = 50, Callback = function(v) Movement.TPSpeed = v end}, "tp_val")


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
