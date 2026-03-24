-- [[ 🛡️ KERIMTTL DYNAMIC BYPASS ENGINE ]] --
pcall(function()
    local RawMT = getrawmetatable(game)
    local OldIndex = RawMT.__index
    setreadonly(RawMT, false)

    RawMT.__index = newcclosure(function(self, Key)
        if not checkcaller() and self:IsA("Humanoid") then
            if Key == "WalkSpeed" then return 16 end
            if Key == "JumpPower" then return 50 end
        end
        return OldIndex(self, Key)
    end)
    setreadonly(RawMT, true)
end)

-- [[ BY KERIMTTL PREMIUM HUB - LEGACY + VISIBLE ESP + MEVLANA ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

if CoreGui:FindFirstChild("KerimTTL_Hub") then CoreGui.KerimTTL_Hub:Destroy() end

local Settings = {
    WalkSpeed = 16, JumpPower = 50, FlySpeed = 100,
    FlyEnabled = false, NoClip = false, GodMode = false,
    CharFOV = 70, ESP_Enabled = false,
    AimEnabled = false, AimFOV_Enabled = false, AimFOV_Radius = 150, AimSmoothness = 0.2,
    Hitbox_Enabled = false, Hitbox_Size = 2, Hitbox_Transparency = 0.7,
    SavedPositions = {}, 
    SpinEnabled = false, SpinSpeed = 100
}

-- --- 🌪️ MEVLANA (SPINBOT) ENGINE ---
local function UpdateSpin()
    local Root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if Settings.SpinEnabled and Root then
        local Spin = Root:FindFirstChild("TTL_Spinbot") or Instance.new("BodyAngularVelocity", Root)
        Spin.Name = "TTL_Spinbot"
        Spin.MaxTorque = Vector3.new(0, math.huge, 0)
        Spin.AngularVelocity = Vector3.new(0, Settings.SpinSpeed, 0)
    else
        if Root and Root:FindFirstChild("TTL_Spinbot") then
            Root.TTL_Spinbot:Destroy()
        end
    end
end

-- --- 🔍 GÖRÜNÜRLÜK KONTROLÜ ---
local function IsVisible(part)
    if not part then return false end
    local _, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end 
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LP.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, rayParams)
    return not result or (result.Instance and result.Instance:IsDescendantOf(part.Parent))
end

-- --- 🎯 DRAWING (FOV) ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(0, 255, 150); FOVCircle.Visible = false

-- --- 🚀 PHYSICS ENGINE ---
local BVel, BGyro
local function UpdateFly()
    local Root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if Settings.FlyEnabled and Root then
        if not BVel then BVel = Instance.new("BodyVelocity", Root); BVel.MaxForce = Vector3.new(9e9, 9e9, 9e9) end
        if not BGyro then BGyro = Instance.new("BodyGyro", Root); BGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BGyro.D = 100; BGyro.P = 10000 end
        BGyro.CFrame = Camera.CFrame
        local Dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then Dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then Dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then Dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then Dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then Dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then Dir -= Vector3.new(0,1,0) end
        BVel.Velocity = Dir * Settings.FlySpeed
    else
        if BVel then BVel:Destroy(); BVel = nil end
        if BGyro then BGyro:Destroy(); BGyro = nil end
    end
end

-- --- 🎯 AIMBOT ENGINE ---
local LockedTarget = nil
local function GetClosestToMouse()
    if LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild("Head") and LockedTarget.Character.Humanoid.Health > 0 then
        local Pos, OnScreen = Camera:WorldToViewportPoint(LockedTarget.Character.Head.Position)
        if OnScreen then
            local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if Distance <= Settings.AimFOV_Radius then return LockedTarget end
        end
    end
    local Target = nil; local MaxDist = Settings.AimFOV_Radius
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if OnScreen then
                local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if Distance < MaxDist then MaxDist = Distance; Target = v end
            end
        end
    end
    return Target
end

-- --- 🔄 ANA DÖNGÜ ---
RunService.RenderStepped:Connect(function()
    local Char = LP.Character
    if Char and Char:FindFirstChildOfClass("Humanoid") then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        UpdateFly()
        UpdateSpin()
        Hum.WalkSpeed = Settings.WalkSpeed
        Hum.JumpPower = Settings.JumpPower
        if Settings.GodMode then Hum.Health = 100 end
        if Settings.NoClip then for _, p in pairs(Char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end
    FOVCircle.Visible = Settings.AimFOV_Enabled
    FOVCircle.Radius = Settings.AimFOV_Radius
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    Camera.FieldOfView = Settings.CharFOV
    if Settings.AimEnabled then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            LockedTarget = GetClosestToMouse()
            if LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild("Head") then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, LockedTarget.Character.Head.Position), Settings.AimSmoothness)
            end
        else
            LockedTarget = nil
        end
    end
end)

-- --- 🐢 OPTİMİZE DÖNGÜ ---
task.spawn(function()
    while task.wait(0.1) do 
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
                local Head = v.Character.Head
                if Settings.Hitbox_Enabled then
                    Head.Size = Vector3.new(Settings.Hitbox_Size, Settings.Hitbox_Size, Settings.Hitbox_Size)
                    Head.Transparency = Settings.Hitbox_Transparency
                    Head.CanCollide = false; Head.Massless = true
                else
                    if Head.Size ~= Vector3.new(1.2, 1.2, 1.2) then
                        Head.Size = Vector3.new(1.2, 1.2, 1.2); Head.Transparency = 0
                    end
                end
                
                local HL = v.Character:FindFirstChild("KerimESP")
                if Settings.ESP_Enabled then
                    if not HL then HL = Instance.new("Highlight", v.Character); HL.Name = "KerimESP" end
                    if IsVisible(v.Character.Head) then 
                        HL.FillColor = Color3.fromRGB(0, 255, 0) 
                        HL.OutlineColor = Color3.fromRGB(255, 255, 255) 
                    else 
                        HL.FillColor = Color3.fromRGB(255, 0, 0) 
                        HL.OutlineColor = Color3.fromRGB(100, 0, 0) 
                    end
                    HL.FillTransparency = 0.5
                elseif HL then 
                    HL:Destroy() 
                end
            end
        end
    end
end)

-- --- 🖥️ UI SYSTEM ---
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "KerimTTL_Hub"; ScreenGui.ResetOnSpawn = false
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 500, 0, 420); Main.Position = UDim2.new(0.5, -250, 0.5, -210); Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15); Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

-- --- 🔘 GÜNCELLENMİŞ IMAGE ID'Lİ BUTON ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 65, 0, 65); OpenBtn.Position = UDim2.new(0, 20, 0.5, -30); OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18); OpenBtn.Text = ""; OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 255, 150)

local OpenBtnImage = Instance.new("ImageLabel", OpenBtn)
OpenBtnImage.Size = UDim2.new(1, 0, 1, 0)
OpenBtnImage.Position = UDim2.new(0, 0, 0, 0)
OpenBtnImage.BackgroundTransparency = 1
OpenBtnImage.Image = "rbxassetid://94939164422994" -- Senin en son verdiğin Image ID
Instance.new("UICorner", OpenBtnImage).CornerRadius = UDim.new(1, 0)

-- --- UI DEVAMI ---
local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 45); Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
local Title = Instance.new("TextLabel", Header); Title.Size = UDim2.new(1, -20, 0.6, 0); Title.Position = UDim2.new(0, 15, 0, 4); Title.Text = "By KerimTTL • PREMIUM HUB"; Title.TextColor3 = Color3.fromRGB(0, 255, 150); Title.Font = Enum.Font.GothamBold; Title.TextSize = 15; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1

local InstaLabel = Instance.new("TextLabel", Header)
InstaLabel.Size = UDim2.new(0, 250, 0, 20)
InstaLabel.Position = UDim2.new(0, 15, 0, 24)
InstaLabel.BackgroundTransparency = 1
InstaLabel.Text = "📸 @therealkerim_13" 
InstaLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InstaLabel.Font = Enum.Font.GothamMedium
InstaLabel.TextSize = 12
InstaLabel.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 130, 1, -60); Sidebar.Position = UDim2.new(0, 10, 0, 50); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 6)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -160, 1, -65); Container.Position = UDim2.new(0, 150, 0, 55); Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local P = Instance.new("ScrollingFrame", Container); P.Size = UDim2.new(1, 0, 1, 0); P.BackgroundTransparency = 1; P.Visible = false; P.ScrollBarThickness = 0; Instance.new("UIListLayout", P).Padding = UDim.new(0, 8)
    local B = Instance.new("TextButton", Sidebar); B.Size = UDim2.new(1, 0, 0, 38); B.Text = "  "..name; B.BackgroundColor3 = Color3.fromRGB(20, 20, 25); B.TextColor3 = Color3.fromRGB(200, 200, 200); B.Font = Enum.Font.GothamBold; B.TextSize = 12; B.TextXAlignment = "Left"; Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
    B.MouseButton1Click:Connect(function() for _, v in pairs(Pages) do v[1].Visible = false; v[2].BackgroundColor3 = Color3.fromRGB(20, 20, 25); v[2].TextColor3 = Color3.fromRGB(200, 200, 200) end P.Visible = true; B.BackgroundColor3 = Color3.fromRGB(0, 255, 150); B.TextColor3 = Color3.fromRGB(10, 10, 12) end)
    Pages[name] = {P, B}; return P
end

local SSliders = {}
local function AddToggle(name, key, parent)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -10, 0, 40); F.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    local L = Instance.new("TextLabel", F); L.Size = UDim2.new(1, -50, 1, 0); L.Position = UDim2.new(0, 12, 0, 0); L.Text = name; L.TextColor3 = Color3.new(1,1,1); L.Font = Enum.Font.Gotham; L.TextSize = 12; L.BackgroundTransparency = 1; L.TextXAlignment = "Left"
    local T = Instance.new("TextButton", F); T.Size = UDim2.new(0, 34, 0, 20); T.Position = UDim2.new(1, -44, 0.5, -10); T.Text = ""; T.BackgroundColor3 = Color3.fromRGB(45, 45, 50); Instance.new("UICorner", T).CornerRadius = UDim.new(1, 0)
    T.MouseButton1Click:Connect(function() Settings[key] = not Settings[key]; T.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(45, 45, 50) end)
end

local function AddSlider(name, min, max, def, key, parent, isDec)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, -10, 0, 55); F.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    local L = Instance.new("TextLabel", F); L.Size = UDim2.new(1, -20, 0, 28); L.Position = UDim2.new(0, 12, 0, 2); L.Text = name .. " : " .. def; L.TextColor3 = Color3.new(1,1,1); L.Font = Enum.Font.Gotham; L.TextSize = 11; L.BackgroundTransparency = 1; L.TextXAlignment = "Left"
    local B = Instance.new("Frame", F); B.Size = UDim2.new(1, -24, 0, 4); B.Position = UDim2.new(0, 12, 0, 40); B.BackgroundColor3 = Color3.fromRGB(50, 50, 55); Instance.new("UICorner", B)
    local Fill = Instance.new("Frame", B); Fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Instance.new("UICorner", Fill)
    local D = Instance.new("TextButton", B); D.Size = UDim2.new(0, 12, 0, 12); D.Position = UDim2.new((def-min)/(max-min), -6, 0.5, -6); D.Text = ""; Instance.new("UICorner", D)
    local function Update(v) v = math.clamp(v, min, max); Settings[key] = v; L.Text = name .. " : " .. (isDec and string.format("%.2f", v) or math.floor(v)); Fill.Size = UDim2.new((v-min)/(max-min), 0, 1, 0); D.Position = UDim2.new((v-min)/(max-min), -6, 0.5, -6) end
    SSliders[key] = Update; local drag = false; D.MouseButton1Down:Connect(function() drag = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then Update(min + (max-min) * math.clamp((i.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)) end end)
end

-- --- 📂 PAGES ---
local G = NewPage("GENERAL"); local A = NewPage("AIMBOT"); local H = NewPage("HITBOX"); local V = NewPage("VISUALS"); local T = NewPage("TELEPORT"); local T2 = NewPage("TELEPORT V2")

AddToggle("MEVLANA (SPIN)", "SpinEnabled", G)
AddSlider("SPIN SPEED", 10, 1000, 100, "SpinSpeed", G, false)

local IY = Instance.new("TextButton", G); IY.Size = UDim2.new(1, -10, 0, 35); IY.Text = "RUN INFINITE YIELD"; IY.BackgroundColor3 = Color3.fromRGB(35, 35, 45); IY.TextColor3 = Color3.new(1,1,1); IY.Font = Enum.Font.GothamBold; Instance.new("UICorner", IY)
IY.MouseButton1Click:Connect(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)

AddToggle("GOD MODE", "GodMode", G); AddToggle("FLY MODE", "FlyEnabled", G); AddToggle("NOCLIP", "NoClip", G)
AddSlider("WALKSPEED", 16, 500, 16, "WalkSpeed", G, false); AddSlider("JUMP POWER", 50, 500, 50, "JumpPower", G, false); AddSlider("FLY SPEED", 10, 500, 100, "FlySpeed", G, false)

local Res = Instance.new("TextButton", G); Res.Size = UDim2.new(1, -10, 0, 35); Res.Text = "RESET STATS (WS/JP)"; Res.BackgroundColor3 = Color3.fromRGB(150, 0, 0); Res.TextColor3 = Color3.new(1,1,1); Res.Font = Enum.Font.GothamBold; Instance.new("UICorner", Res)
Res.MouseButton1Click:Connect(function() SSliders["WalkSpeed"](16); SSliders["JumpPower"](50); Settings.FlyEnabled = false end)

AddToggle("ENABLE AIMBOT", "AimEnabled", A); AddToggle("SHOW FOV", "AimFOV_Enabled", A); AddSlider("SMOOTHNESS", 0.01, 1, 0.2, "AimSmoothness", A, true); AddSlider("FOV RADIUS", 10, 800, 150, "AimFOV_Radius", A, false)
AddToggle("ENABLE HITBOX", "Hitbox_Enabled", H); AddSlider("HEAD SIZE", 1, 35, 2, "Hitbox_Size", H, false); AddSlider("TRANSPARENCY", 0, 1, 0.7, "Hitbox_Transparency", H, true)
AddToggle("VISIBLE ESP", "ESP_Enabled", V); AddSlider("CAMERA FOV", 70, 150, 70, "CharFOV", V, false)

local function UpdateTPList()
    for _, x in pairs(T:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LP then
        local b = Instance.new("TextButton", T); b.Size = UDim2.new(1, -10, 0, 30); b.Text = "  " .. p.DisplayName; b.BackgroundColor3 = Color3.fromRGB(25, 25, 30); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 11; b.TextXAlignment = "Left"; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() if p.Character then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end)
    end end
end
spawn(function() while task.wait(5) do UpdateTPList() end end); UpdateTPList()

-- --- 🚀 TELEPORT V2 (10'LU SİSTEM) ---
local T2_List = Instance.new("Frame", T2); T2_List.Size = UDim2.new(1, -10, 0, 300); T2_List.Position = UDim2.new(0, 0, 0, 55); T2_List.BackgroundTransparency = 1
local T2_Layout = Instance.new("UIListLayout", T2_List); T2_Layout.Padding = UDim.new(0, 5)

local function UpdateSavedPositions()
    for _, child in pairs(T2_List:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for i, data in pairs(Settings.SavedPositions) do
        local Item = Instance.new("Frame", T2_List); Item.Size = UDim2.new(1, 0, 0, 35); Item.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", Item)
        local Label = Instance.new("TextLabel", Item); Label.Size = UDim2.new(0.6, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.Text = "Pos #"..i; Label.TextColor3 = Color3.new(1,1,1); Label.Font = Enum.Font.Gotham; Label.TextSize = 11; Label.TextXAlignment = "Left"
        
        local TPBtn = Instance.new("TextButton", Item); TPBtn.Size = UDim2.new(0.2, -5, 0.8, 0); TPBtn.Position = UDim2.new(0.6, 0, 0.1, 0); TPBtn.Text = "TP"; TPBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100); TPBtn.TextColor3 = Color3.new(1,1,1); TPBtn.Font = Enum.Font.GothamBold; TPBtn.TextSize = 10; Instance.new("UICorner", TPBtn)
        local DelBtn = Instance.new("TextButton", Item); DelBtn.Size = UDim2.new(0.2, -5, 0.8, 0); DelBtn.Position = UDim2.new(0.8, 5, 0.1, 0); DelBtn.Text = "X"; DelBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); DelBtn.TextColor3 = Color3.new(1,1,1); DelBtn.Font = Enum.Font.GothamBold; DelBtn.TextSize = 10; Instance.new("UICorner", DelBtn)
        
        TPBtn.MouseButton1Click:Connect(function() if LP.Character then LP.Character.HumanoidRootPart.CFrame = data end end)
        DelBtn.MouseButton1Click:Connect(function() table.remove(Settings.SavedPositions, i); UpdateSavedPositions() end)
    end
end

local SaveCurrentBtn = Instance.new("TextButton", T2); SaveCurrentBtn.Size = UDim2.new(1, -10, 0, 45); SaveCurrentBtn.Text = "SAVE CURRENT POSITION (MAX 10)"; SaveCurrentBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); SaveCurrentBtn.TextColor3 = Color3.fromRGB(0, 255, 150); SaveCurrentBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SaveCurrentBtn)
SaveCurrentBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        if #Settings.SavedPositions < 10 then
            table.insert(Settings.SavedPositions, LP.Character.HumanoidRootPart.CFrame)
            UpdateSavedPositions()
        else
            SaveCurrentBtn.Text = "LIST FULL!"; task.wait(1); SaveCurrentBtn.Text = "SAVE CURRENT POSITION (MAX 10)"
        end
    end
end)

Pages["GENERAL"][1].Visible = true; Pages["GENERAL"][2].BackgroundColor3 = Color3.fromRGB(0, 255, 150); Pages["GENERAL"][2].TextColor3 = Color3.fromRGB(10, 10, 12)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
Main.Draggable = true; Main.Active = true
