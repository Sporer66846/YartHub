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
local ESP_Cache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Color = Color3.new(1, 1, 1)

local Aimbot = {
    Enabled = false,
    ShowFOV = false,
    Smoothness = 0.5,
    Prediction = false,
    BulletVelocity = 1000,
    BulletDrop = 0,
    FOV = 100,
    Keybind = "E" -- Safe default keyboard key to prevent Starlight parsing crashes
}

local Triggerbot = { Enabled = false, Delay = 0.05 }

local Visuals = {
    Enabled = false, -- Box ESP is the default and only mode when true
    Names = false,
    Distance = false,
    HealthBar = false,
    TeamColor = false,
    Rainbow = false
}

local Movement = {
    WSEnabled = false, WSValue = 16,
    JPEnabled = false, JPValue = 50,
    TPWalk = false, TPSpeed = 50,
    ClickTP = false
}

--// SECTION: Utility Functions
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

local function HideCache(cache)
    cache.Box.Visible = false
    cache.HealthBarBg.Visible = false
    cache.HealthBar.Visible = false
    cache.Text.Visible = false
end

--// SECTION: ESP & FOV Engine
RunService.RenderStepped:Connect(function()
    -- FOV Circle Logic
    if Aimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Color = Visuals.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)
    else
        FOVCircle.Visible = false
    end

    local rainbowColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    -- ESP Logic
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player then
            if not ESP_Cache[v] then
                ESP_Cache[v] = {
                    Box = Drawing.new("Square"),
                    HealthBarBg = Drawing.new("Line"),
                    HealthBar = Drawing.new("Line"),
                    Text = Drawing.new("Text")
                }
                ESP_Cache[v].Box.Thickness = 1
                ESP_Cache[v].Box.Filled = false
                ESP_Cache[v].HealthBarBg.Thickness = 3
                ESP_Cache[v].HealthBarBg.Color = Color3.new(0,0,0)
                ESP_Cache[v].HealthBar.Thickness = 1
                ESP_Cache[v].Text.Size = 16
                ESP_Cache[v].Text.Center = true
                ESP_Cache[v].Text.Outline = true
            end

            local cache = ESP_Cache[v]
            
            if not Visuals.Enabled then
                HideCache(cache)
                continue
            end

            local char = v.Character
            local isAlive = char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char:FindFirstChild("Head") and char.Humanoid.Health > 0

            if isAlive then
                local hrp = char.HumanoidRootPart
                local head = char.Head
                local hum = char.Humanoid
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                local useColor = Color3.new(1, 1, 1)
                if Visuals.Rainbow then useColor = rainbowColor
                elseif Visuals.TeamColor and v.Team then useColor = v.TeamColor.Color end

                if onScreen then
                    -- Math bypassed for executor compatibility
                    local hOffset = Vector3.new(head.Position.X, head.Position.Y + 0.5, head.Position.Z)
                    local lOffset = Vector3.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
                    
                    local headPos = Camera:WorldToViewportPoint(hOffset)
                    local legPos = Camera:WorldToViewportPoint(lOffset)
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2

                    -- Box ESP (Default)
                    cache.Box.Visible = true
                    cache.Box.Size = Vector2.new(width, height)
                    cache.Box.Position = Vector2.new(hrpPos.X - width / 2, headPos.Y)
                    cache.Box.Color = useColor

                    -- Health Bar
                    if Visuals.HealthBar then
                        cache.HealthBarBg.Visible = true
                        cache.HealthBarBg.From = Vector2.new(cache.Box.Position.X - 5, cache.Box.Position.Y + height)
                        cache.HealthBarBg.To = Vector2.new(cache.Box.Position.X - 5, cache.Box.Position.Y)

                        cache.HealthBar.Visible = true
                        cache.HealthBar.From = Vector2.new(cache.Box.Position.X - 5, cache.Box.Position.Y + height)
                        local healthPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        cache.HealthBar.To = Vector2.new(cache.Box.Position.X - 5, cache.Box.Position.Y + height - (height * healthPerc))
                        cache.HealthBar.Color = Color3.new(1 - healthPerc, healthPerc, 0)
                    else
                        cache.HealthBarBg.Visible = false
                        cache.HealthBar.Visible = false
                    end

                    -- Text Info
                    if Visuals.Names or Visuals.Distance then
                        local textStr = ""
                        if Visuals.Names then textStr = textStr .. v.Name end
                        if Visuals.Distance then 
                            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                            textStr = textStr .. (Visuals.Names and " [" or "[") .. dist .. "m]" 
                        end

                        cache.Text.Visible = true
                        cache.Text.Text = textStr
                        cache.Text.Position = Vector2.new(hrpPos.X, hrpPos.Y - 40)
                        cache.Text.Color = useColor
                    else
                        cache.Text.Visible = false
                    end
                else
                    HideCache(cache)
                end
            else
                HideCache(cache)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Cache[plr] then
        if ESP_Cache[plr].Box then ESP_Cache[plr].Box:Remove() end
        if ESP_Cache[plr].HealthBarBg then ESP_Cache[plr].HealthBarBg:Remove() end
        if ESP_Cache[plr].HealthBar then ESP_Cache[plr].HealthBar:Remove() end
        if ESP_Cache[plr].Text then ESP_Cache[plr].Text:Remove() end
        ESP_Cache[plr] = nil
    end
end)

--// SECTION: Aimbot Hook
local function aimbotKeyDown()
    if not Aimbot.Enabled then return end
    Target = GetClosestPlayer()
    
    if Target and Target.Character and Target.Character:FindFirstChild("Head") and Target.Character:FindFirstChild("HumanoidRootPart") then
        Aimbotting = RunService.RenderStepped:Connect(function(dt)
            if not Target or not Target.Character or not Target.Character:FindFirstChild("Head") or not Target.Character:FindFirstChild("HumanoidRootPart") or Target.Character.Humanoid.Health <= 0 then
                if Aimbotting then Aimbotting:Disconnect() Aimbotting = nil end
                return
            end

            local position = Target.Character.Head.Position

            if Aimbot.Prediction then
                local dist = (Camera.CFrame.Position - position).Magnitude
                local timeToHit = dist / Aimbot.BulletVelocity
                local targetVel = Target.Character.HumanoidRootPart.AssemblyLinearVelocity
                local drop = 0.5 * Aimbot.BulletDrop * (timeToHit ^ 2)
                
                position = Vector3.new(
                    position.X + (targetVel.X * timeToHit),
                    position.Y + (targetVel.Y * timeToHit) + drop,
                    position.Z + (targetVel.Z * timeToHit)
                )
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

--// SECTION: Input Hooks (Aimbot & Click TP)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Click TP Logic (Ctrl + Left Click)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Movement.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            if Mouse.Hit then
                local char = Player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end

    -- Aimbot Key Check
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

--// SECTION: Movement Hook
RunService.Heartbeat:Connect(function(dt)
    local char = Player.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hum = char.Humanoid
    local hrp = char.HumanoidRootPart

    if Movement.WSEnabled then hum.WalkSpeed = Movement.WSValue end
    if Movement.JPEnabled then hum.UseJumpPower = true hum.JumpPower = Movement.JPValue end

    if Movement.TPWalk and hum.MoveDirection.Magnitude > 0 then
        local offset = hum.MoveDirection * Movement.TPSpeed * dt
        local newPos = Vector3.new(hrp.Position.X + offset.X, hrp.Position.Y + offset.Y, hrp.Position.Z + offset.Z)
        hrp.CFrame = CFrame.new(newPos) * hrp.CFrame.Rotation
    end
end)


--// SECTION: Window Initialization
local win = Starlight:CreateWindow({
    Name = "Yart Hub",
    Subtitle = "Premium Script Hub",
    Icon = 101065953742739,
    LoadingEnabled = true,
    LoadingSettings = { Title = "Yart Hub", Subtitle = "Detecting game..." },
    -- Changed Folder to bypass corrupted keybind saves!
    FileSettings = { RootFolder = "YartHub", ConfigFolder = "YartConfigs" } 
})

win:CreateHomeTab({
    DiscordInvite = "yarthub", 
    SupportedExecutors = {"Volt", "Potassium", "Wave", "Seliware"},
    Changelog = {{ Title = "Release", Date = "Current", Description = "Universal & TSB Modules Active." }}
})

--// SECTION: UNIVERSAL TABS
local universalSection = win:CreateTabSection("UNIVERSAL")

-- 1. COMBAT
local combatTab = universalSection:CreateTab({Name = "Combat", Columns = 2, Icon = NebulaIcons:GetIcon("crosshair", "Lucide")}, "uni_combat")

local aimGroup = combatTab:CreateGroupbox({Name = "Aimbot Settings", Column = 1}, "aim_gb")
aimGroup:CreateToggle({Name = "Enable Aimbot", Callback = function(v) Aimbot.Enabled = v if not v then aimbotKeyUp() end end}, "aim_enable")
aimGroup:CreateToggle({Name = "Show FOV Circle", Callback = function(v) Aimbot.ShowFOV = v end}, "aim_fov_tgl")
aimGroup:CreateSlider({Name = "Smoothness", Range = {0.1, 1}, Increment = 0.05, CurrentValue = 0.5, Callback = function(v) Aimbot.Smoothness = v end}, "aim_smooth")
aimGroup:CreateSlider({Name = "FOV Radius", Range = {10, 800}, CurrentValue = 100, Callback = function(v) Aimbot.FOV = v end}, "aim_fov")
aimGroup:CreateLabel({Name = "Aimbot Keybind"}, "aim_key_lbl"):AddBind({CurrentValue = "E", OnChangedCallback = function(key) Aimbot.Keybind = key end}, "aim_key")

local predGroup = combatTab:CreateGroupbox({Name = "Prediction Settings", Column = 1}, "pred_gb")
predGroup:CreateToggle({Name = "Enable Prediction", Callback = function(v) Aimbot.Prediction = v end}, "aim_pred_tgl")
predGroup:CreateSlider({Name = "Bullet Velocity", Range = {100, 3000}, CurrentValue = 1000, Increment = 50, Callback = function(v) Aimbot.BulletVelocity = v end}, "aim_vel")
predGroup:CreateSlider({Name = "Bullet Drop", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) Aimbot.BulletDrop = v end}, "aim_drop")

local trigGroup = combatTab:CreateGroupbox({Name = "Triggerbot", Column = 2}, "trig_gb")
trigGroup:CreateToggle({Name = "Enable Triggerbot", Callback = function(v) Triggerbot.Enabled = v end}, "trig_enable")
trigGroup:CreateSlider({Name = "Click Delay", Range = {0, 0.5}, Increment = 0.01, CurrentValue = 0.05, Callback = function(v) Triggerbot.Delay = v end}, "trig_delay")

-- 2. VISUALS
local visualTab = universalSection:CreateTab({Name = "Visuals", Columns = 2, Icon = NebulaIcons:GetIcon("eye", "Lucide")}, "uni_vis")

local espGroup = visualTab:CreateGroupbox({Name = "ESP Features", Column = 1}, "esp_gb")
espGroup:CreateToggle({Name = "Enable Box ESP", Callback = function(v) Visuals.Enabled = v end}, "esp_master")
espGroup:CreateToggle({Name = "Show Names", Callback = function(v) Visuals.Names = v end}, "esp_names")
espGroup:CreateToggle({Name = "Show Distance", Callback = function(v) Visuals.Distance = v end}, "esp_dist")
espGroup:CreateToggle({Name = "Show Health Bar", Callback = function(v) Visuals.HealthBar = v end}, "esp_hp")

local espColorGroup = visualTab:CreateGroupbox({Name = "Colors", Column = 2}, "esp_colors")
espColorGroup:CreateToggle({Name = "Team Color", Callback = function(v) Visuals.TeamColor = v end}, "esp_team")
espColorGroup:CreateToggle({Name = "Rainbow Mode", Callback = function(v) Visuals.Rainbow = v end}, "esp_rainbow")

-- 3. MOVEMENT
local moveTab = universalSection:CreateTab({Name = "Movement", Columns = 2, Icon = NebulaIcons:GetIcon("move", "Lucide")}, "uni_move")

local physGroup = moveTab:CreateGroupbox({Name = "Player Physics", Column = 1}, "phys_gb")
physGroup:CreateToggle({Name = "Enable WalkSpeed", Callback = function(v) 
    Movement.WSEnabled = v 
    if not v and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16 
    end
end}, "ws_enable")
physGroup:CreateSlider({Name = "WalkSpeed Value", Range = {16, 250}, CurrentValue = 16, Callback = function(v) Movement.WSValue = v end}, "ws_val")

physGroup:CreateToggle({Name = "Enable JumpPower", Callback = function(v) 
    Movement.JPEnabled = v 
    if not v and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.UseJumpPower = true
        Player.Character.Humanoid.JumpPower = 50
    end
end}, "jp_enable")
physGroup:CreateSlider({Name = "JumpPower Value", Range = {50, 300}, CurrentValue = 50, Callback = function(v) Movement.JPValue = v end}, "jp_val")

local tpGroup = moveTab:CreateGroupbox({Name = "Utility", Column = 2}, "tp_gb")
tpGroup:CreateToggle({Name = "Enable TP Walk", Callback = function(v) Movement.TPWalk = v end}, "tp_enable")
tpGroup:CreateSlider({Name = "TP Walk Speed", Range = {10, 200}, CurrentValue = 50, Callback = function(v) Movement.TPSpeed = v end}, "tp_val")
tpGroup:CreateToggle({Name = "Click TP (Ctrl + Click)", Callback = function(v) Movement.ClickTP = v end}, "clicktp_enable")


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
