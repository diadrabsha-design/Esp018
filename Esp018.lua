-- ESP No-GUI | Backend Only | By AI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP_ENABLED = false
local espObjects = {}
local updaterConn = nil

-- إعدادات الألوان
local ENEMY_COLOR = Color3.fromRGB(255, 60, 60) -- أحمر للأعداء
local ALLY_COLOR  = Color3.fromRGB(60, 170, 255) -- أزرق للفريق

local function getColor(plr)
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return ALLY_COLOR
    end
    return ENEMY_COLOR
end

local function removeESP(plr)
    local objs = espObjects[plr]
    if objs then
        for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        espObjects[plr] = nil
    end
end

local function applyESP(plr, char)
    if not char or plr == LocalPlayer then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end

    removeESP(plr)
    local objs = {}
    local col = getColor(plr)

    -- تلوين اللاعب (Highlight)
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = col
        hl.FillTransparency = 0.6
        hl.OutlineColor = col
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char
        table.insert(objs, hl)
    end)

    -- اسم اللاعب فوق رأسه (BillboardGui)
    pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 200, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2.6, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = root
        bb.Parent = root
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.fromScale(1,1)
        lbl.BackgroundTransparency = 1
        lbl.Text = plr.Name
        lbl.TextColor3 = col
        lbl.TextStrokeTransparency = 0
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.Parent = bb
        table.insert(objs, bb)
    end)

    espObjects[plr] = objs
end

local function refreshAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            applyESP(plr, plr.Character)
        end
    end
end

local function startUpdater()
    if updaterConn then return end
    updaterConn = RunService.Heartbeat:Connect(function()
        for plr, objs in pairs(espObjects) do
            local char = plr.Character
            if not char or not char:FindFirstChildOfClass("Humanoid") then
                removeESP(plr)
            else
                local col = getColor(plr)
                for _, o in ipairs(objs) do
                    if o:IsA("Highlight") then
                        o.FillColor = col; o.OutlineColor = col
                    elseif o:IsA("BillboardGui") then
                        local lbl = o:FindFirstChildOfClass("TextLabel")
                        if lbl then lbl.TextColor3 = col end
                    end
                end
            end
        end
    end)
end

local function stopUpdater()
    if updaterConn then updaterConn:Disconnect(); updaterConn = nil end
end

-- دوال التشغيل والإطفاء
function _G.EnableESP()
    if ESP_ENABLED then return end
    ESP_ENABLED = true
    refreshAll()
    startUpdater()
    print("[ESP] ✅ ON")
end

function _G.DisableESP()
    ESP_ENABLED = false
    for plr in pairs(espObjects) do removeESP(plr) end
    stopUpdater()
    print("[ESP] ❌ OFF")
end

function _G.ToggleESP()
    if ESP_ENABLED then _G.DisableESP() else _G.EnableESP() end
end

-- مراقبة اللاعبين الجدد
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            if ESP_ENABLED then task.wait(0.6); applyESP(plr, char) end
        end)
    end
end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if ESP_ENABLED then task.wait(0.6); applyESP(plr, char) end
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

print("[ESP] Loaded successfully. Waiting for commands...")
