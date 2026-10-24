-- ESP No-GUI | Delta Mobile Ready | Toggle via _G or Key
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local ESP_ENABLED = false
local espObjects = {} -- [Player] = {Highlight}
local updaterConn = nil

-- إعدادات اللون (تقدر تغيرها)
local TEAM_COLOR = true
local DEFAULT_COLOR = Color3.fromRGB(0, 255, 0) -- أخضر
local ENEMY_COLOR = Color3.fromRGB(255, 0, 0) -- أحمر

local function getColor(plr)
    if not TEAM_COLOR then return DEFAULT_COLOR end
    if plr.Team == LocalPlayer.Team then
        return Color3.fromRGB(0, 170, 255) -- أزرق للفريق
    else
        return ENEMY_COLOR
    end
end

local function applyESP(plr, char)
    if not char or plr == LocalPlayer then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if espObjects[plr] then espObjects[plr]:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "Delta_ESP_HL"
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = getColor(plr)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char
    espObjects[plr] = hl
end

local function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
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
        for plr, hl in pairs(espObjects) do
            local char = plr.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                hl.OutlineColor = getColor(plr)
            else
                removeESP(plr)
            end
        end
    end)
end

local function stopUpdater()
    if updaterConn then
        updaterConn:Disconnect()
        updaterConn = nil
    end
end

-- الدوال اللي تقدر تستدعيها من سكربتك الأساسي
function EnableESP()
    if ESP_ENABLED then return end
    ESP_ENABLED = true
    refreshAll()
    startUpdater()
    print("[ESP] ✅ ON")
end

function DisableESP()
    ESP_ENABLED = false
    for plr, _ in pairs(espObjects) do
        removeESP(plr)
    end
    stopUpdater()
    print("[ESP] ❌ OFF")
end

function ToggleESP()
    if ESP_ENABLED then
        DisableESP()
    else
        EnableESP()
    end
end

-- مراقبة اللاعبين الجدد
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if ESP_ENABLED then
            task.wait(0.5)
            applyESP(plr, char)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

-- مفتاح التبديل الافتراضي (RightControl) — تقدر تغيره أو تشيله
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ToggleESP()
    end
end)

-- تصدير الدوال عالميًا عشان سكربتك الأساسي يقدر يتحكم فيها
_G.EnableESP = EnableESP
_G.DisableESP = DisableESP
_G.ToggleESP = ToggleESP
_G.ESP_ENABLED = false

print("[ESP] تم التحميل. استخدم _G.ToggleESP() أو RightControl")
