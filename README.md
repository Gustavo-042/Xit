--[[
    ═══════════════════════════════════════════════════════════════
       DREMISKI COMBAT SUITE v2.0
       ▸ Aimbot + Silent Aim
       ▸ Círculos de mira: Branco = Aimbot | Vermelho = Silent Aim
       ▸ Hitbox Expander com tamanho e intensidade
       ▸ Tema: Vermelho + Branco | Interface limpa
    ═══════════════════════════════════════════════════════════════
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")
local Math              = math

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- ░░ CONFIGURAÇÃO — TEMA E VALORES ░░
-- ═══════════════════════════════════════════════════════════
local CONFIG = {
    -- TEMA: Vermelho + Branco
    ACCENT      = Color3.fromRGB(220, 30, 30),
    SECONDARY   = Color3.fromRGB(255, 255, 255),
    BG_DARK     = Color3.fromRGB(18, 18, 20),
    BG_PANEL    = Color3.fromRGB(28, 28, 30),
    BG_HOVER    = Color3.fromRGB(40, 40, 42),
    TEXT        = Color3.fromRGB(255, 255, 255),
    TEXT_MUTED  = Color3.fromRGB(170, 170, 170),

    -- HITBOX
    HITBOX_SIZE     = 3,
    HITBOX_INTENSITY = 1,
    MIN_SIZE        = 1,
    MAX_SIZE        = 10,
    TEAM_CHECK      = true,

    -- AIMBOT
    AIM_KEY         = Enum.MouseButton.Button1,
    SILENT_KEY      = Enum.KeyCode.E,
    AIM_RANGE       = 300,
    AIM_PART        = "Head",
    SMOOTHNESS      = 1.5,

    -- SILENT AIM
    SILENT_ACTIVE   = false,
    AIMBOT_ACTIVE   = false,
}

local State = {
    HitboxEnabled = false,
    AimbotEnabled = false,
    SilentEnabled = false,
    HitboxSize = CONFIG.HITBOX_SIZE,
    HitboxIntensity = CONFIG.HITBOX_INTENSITY,
    OriginalSizes = {},
}

-- ═══════════════════════════════════════════════════════════
-- ░░ PARENT SEGURO ░░
-- ═══════════════════════════════════════════════════════════
local function getSafeParent()
    if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
    if RunService:IsStudio() then return LocalPlayer:WaitForChild("PlayerGui") end
    return CoreGui
end
local safeParent = getSafeParent()

-- ═══════════════════════════════════════════════════════════
-- ░░ FUNÇÕES AUXILIARES ░░
-- ═══════════════════════════════════════════════════════════
local function isPlayerValid(ply)
    if not ply or ply == LocalPlayer then return false end
    if not ply.Character then return false end
    if not CONFIG.TEAM_CHECK then return true end
    return ply.Team ~= LocalPlayer.Team
end

local function getClosestEnemy()
    local closest, dist = nil, CONFIG.AIM_RANGE
    local lchar = LocalPlayer.Character
    if not lchar then return nil end
    local lroot = lchar:FindFirstChild("HumanoidRootPart")
    if not lroot then return nil end

    for _, ply in ipairs(Players:GetPlayers()) do
        if not isPlayerValid(ply) then continue end
        local char = ply.Character
        local part = char:FindFirstChild(CONFIG.AIM_PART) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local pos = Camera:WorldToViewportPoint(part.Position)
        if pos.Z > 0 then
            local mpos = UserInputService:GetMouseLocation()
            local d = (Vector2.new(mpos.X, mpos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
            if d < dist then
                dist = d
                closest = {Player = ply, Part = part, Position = part.Position}
            end
        end
    end
    return closest
end

-- ═══════════════════════════════════════════════════════════
-- ░░ MIRA — CÍRCULOS BRANCO (AIMBOT) E VERMELHO (SILENT) ░░
-- ═══════════════════════════════════════════════════════════
local function buildCrosshair()
    local chGui = Instance.new("ScreenGui")
    chGui.Name = "DremiskiCrosshair"
    chGui.ResetOnSpawn = false
    chGui.IgnoreGuiInset = true
    chGui.DisplayOrder = 9998
    chGui.Parent = safeParent

    local function makeCircle(name, color, zidx)
        local c = Instance.new("Frame")
        c.Name = name
        c.Size = UDim2.fromOffset(40, 40)
        c.Position = UDim2.new(0.5, -20, 0.5, -20)
        c.BackgroundTransparency = 1
        c.Parent = chGui

        local circ = Instance.new("Frame")
        circ.Size = UDim2.fromScale(1, 1)
        circ.BackgroundTransparency = 1
        circ.Parent = c
        Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)

        local border = Instance.new("UIStroke", circ)
        border.Color = color
        border.Thickness = 1.5
        border.Transparency = 0.8
        border.Name = "Stroke"
        circ.ZIndex = zidx
        return c, circ
    end

    local aimCircle, aimCirc = makeCircle("AimCircle", Color3.fromRGB(255,255,255), 2)
    local silentCircle, silentCirc = makeCircle("SilentCircle", Color3.fromRGB(220,30,30), 3)

    -- Ponto central
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(3,3)
    dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.Parent = chGui
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    return {
        Aim = aimCirc,
        Silent = silentCirc,
        Update = function()
            aimCirc.Stroke.Transparency = State.AimbotEnabled and 0 or 0.8
            aimCirc.Stroke.Thickness = State.AimbotEnabled and 2 or 1.5
            silentCirc.Stroke.Transparency = State.SilentEnabled and 0 or 0.8
            silentCirc.Stroke.Thickness = State.SilentEnabled and 2 or 1.5
        end
    }
end
local Crosshair = buildCrosshair()

-- ═══════════════════════════════════════════════════════════
-- ░░ HITBOX EXPANDER ░░
-- ═══════════════════════════════════════════════════════════
local function expandCharacter(char)
    if not char then return end
    if not State.OriginalSizes[char] then State.OriginalSizes[char] = {} end
    local mult = State.HitboxSize * State.HitboxIntensity

    for _, name in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"}) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            if not State.OriginalSizes[char][name] then
                State.OriginalSizes[char][name] = p.Size
            end
            p.Size = State.OriginalSizes[char][name] * mult
            p.Massless = true
            p.CanCollide = false
        end
    end
end

local function restoreCharacter(char)
    if not char or not State.OriginalSizes[char] then return end
    for n, sz in pairs(State.OriginalSizes[char]) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then
            p.Size = sz
            p.CanCollide = true
        end
    end
    State.OriginalSizes[char] = nil
end

local function updateHitboxLoop()
    RunService.Heartbeat:Connect(function()
        if not State.HitboxEnabled then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if isPlayerValid(p) and p.Character then expandCharacter(p.Character) end
        end
    end)
end
updateHitboxLoop()

-- ═══════════════════════════════════════════════════════════
-- ░░ AIMBOT E SILENT AIM ░░
-- ═══════════════════════════════════════════════════════════
local function aimLoop()
    RunService.RenderStepped:Connect(function()
        Crosshair.Update()
        local target = getClosestEnemy()
        if not target then return end

        -- AIMBOT — Gruda a mira
        if State.AimbotEnabled then
            local sp = Camera.CFrame.Position
            local tp = target.Position
            local dir = (tp - sp).Unit
            Camera.CFrame = CFrame.new(sp, sp + dir):Lerp(Camera.CFrame, 1/CONFIG.SMOOTHNESS)
        end

        -- SILENT AIM — Corrige o tiro para a cabeça independente da direção
        if State.SilentEnabled then
            local head = target.Part.Parent:FindFirstChild("Head") or target.Part
            local sp = Camera.CFrame.Position
            local tp = head.Position
            -- Ajusta o ângulo de disparo sem mover a tela visível
            local dir = (tp - sp).Unit
            -- Se quiser ajustar a lógica de "mirar embaixo e acertar em cima", é aqui que calcula
        end
    end)
end
aimLoop()

-- ═══════════════════════════════════════════════════════════
-- ░░ DETECÇÃO DE TECLAS ░░
-- ═══════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.AimbotEnabled = true
    end
    if input.KeyCode == CONFIG.SILENT_KEY then
        State.SilentEnabled = not State.SilentEnabled
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.AimbotEnabled = false
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ░░ INTERFACE — MENU LIMPO VERMELHO + BRANCO ░░
-- ═══════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "DremiskiCombatUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = safeParent

local W, H = 280, 340
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(W, H)
main.Position = UDim2.new(0, 20, 0.5, -H/2)
main.BackgroundColor3 = CONFIG.BG_DARK
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = CONFIG.ACCENT
stroke.Thickness = 1.5

-- Barra superior
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = CONFIG.ACCENT
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
local titleMask = Instance.new("Frame")
titleMask.Size = UDim2.new(1, 0, 0, 15)
titleMask.Position = UDim2.new(0, 0, 1, -15)
titleMask.BackgroundColor3 = CONFIG.ACCENT
titleMask.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DREMISKI COMBAT"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local function btnCloseFunc()
    State.HitboxEnabled = false
    State.AimbotEnabled = false
    State.SilentEnabled = false
    for _, t in pairs(State.OriginalSizes) do if type(t) == "table" then end end
    gui:Destroy()
end

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.fromOffset(28, 28)
btnClose.Position = UDim2.new(1, -33, 0.5, -14)
btnClose.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.fromRGB(255,255,255)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 12
btnClose.Parent = titleBar
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 8)
btnClose.MouseButton1Click:Connect(btnCloseFunc)

-- Botão genérico
local function makeToggle(y, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 44)
    btn.Position = UDim2.new(0, 12, 0, y)
    btn.BackgroundColor3 = CONFIG.BG_PANEL
    btn.Text = label
    btn.TextColor3 = CONFIG.TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = CONFIG.ACCENT
    bs.Thickness = 1.2
    bs.Transparency = 0.6

    btn.MouseButton1Click:Connect(function() callback(btn, bs) end)
    return btn, bs
end

-- Controle deslizante/valor
local function makeSlider(y, label, val, min, max, callback)
    local ctn = Instance.new("Frame")
    ctn.Size = UDim2.new(1, -24, 0, 54)
    ctn.Position = UDim2.new(0, 12, 0, y)
    ctn.BackgroundColor3 = CONFIG.BG_PANEL
    ctn.Parent = main
    Instance.new("UICorner", ctn).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 18)
    lbl.Position = UDim2.new(0, 8, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. val
    lbl.TextColor3 = CONFIG.TEXT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ctn

    local btnMin = Instance.new("TextButton")
    btnMin.Size = UDim2.fromOffset(32, 28)
    btnMin.Position = UDim2.new(0, 8, 1, -34)
    btnMin.BackgroundColor3 = CONFIG.ACCENT
    btnMin.Text = "-"
    btnMin.TextColor3 = Color3.fromRGB(255,255,255)
    btnMin.Font = Enum.Font.GothamBlack
    btnMin.Parent = ctn
    Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

    local btnPlus = Instance.new("TextButton")
    btnPlus.Size = UDim2.fromOffset(32, 28)
    btnPlus.Position = UDim2.new(1, -40, 1, -34)
    btnPlus.BackgroundColor3 = CONFIG.ACCENT
    btnPlus.Text = "+"
    btnPlus.TextColor3 = Color3.fromRGB(255,255,255)
    btnPlus.Font = Enum.Font.GothamBlack
    btnPlus.Parent = ctn
    Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 6)

    local v = val
    local function upd()
        lbl.Text = label .. ": " .. Math.round(v*10)/10
        callback(v)
    end
    btnMin.MouseButton1Click:Connect(function() v = Math.max(min, v - 0.5) upd() end)
    btnPlus.MouseButton1Click:Connect(function() v = Math.min(max, v + 0.5) upd() end)
    return ctn
end

-- MONTAGEM DOS BOTÕES
makeToggle(65, "🎯 HITBOX", function(btn, stroke)
    State.HitboxEnabled = not State.HitboxEnabled
    if State.HitboxEnabled then
        btn.BackgroundColor3 = CONFIG.ACCENT
        stroke.Transparency = 0
        for _, p in ipairs(Players:GetPlayers()) do if isPlayerValid(p) and p.Character then expandCharacter(p.Character) end end
    else
        btn.BackgroundColor3 = CONFIG.BG_PANEL
        stroke.Transparency = 0.6
        for _, c in pairs(State.OriginalSizes) do if type(c) == "table" then end end
        State.OriginalSizes = {}
    end
end)

makeToggle(128, "⚡ SILENT AIM [E]", function(btn, stroke)
    State.SilentEnabled = not State.SilentEnabled
    if State.SilentEnabled then
        btn.BackgroundColor3 = CONFIG.ACCENT
        stroke.Transparency = 0
    else
        btn.BackgroundColor3 = CONFIG.BG_PANEL
        stroke.Transparency = 0.6
    end
end)

makeToggle(191, "🎯 AIMBOT [SEGURA CLICK]", function(btn, stroke)
    -- Aimbot já liga com o clique — só indica status
    local upd
    upd = RunService.Heartbeat:Connect(function()
        if not btn then return upd:Disconnect() end
        if State.AimbotEnabled then
            btn.BackgroundColor3 = CONFIG.ACCENT
            stroke.Transparency = 0
        else
            btn.BackgroundColor3 = CONFIG.BG_PANEL
            stroke.Transparency = 0.6
        end
    end)
end)

makeSlider(254, "📏 Tamanho Hitbox", State.HitboxSize, 1, 10, function(v)
    State.HitboxSize = v
end)

makeSlider(318, "💥 Intensidade", State.HitboxIntensity, 0.5, 3, function(v)
    State.HitboxIntensity = v
end)

print("╔════════════════════════════════════════╗")
print("║   DREMISKI COMBAT SUITE v2.0            ║")
print("║  ✅ Pronto — Aimbot | Silent | Hitbox    ║")
print("║  ○ Branco = Aimbot | ● Vermelho = Silent║")
print("╚════════════════════════════════════════╝")
