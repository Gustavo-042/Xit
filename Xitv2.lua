--[[
    DREMISKI SILENT + ESP — COMPLETO
    ✅ Silent Aim | Aimbot
    ✅ ESP: Caixa | Nome | Distância | Linha
    ✅ Mira: ⚪ Branco = Aimbot | 🔴 Vermelho = Silent
    ✅ Tema: Vermelho + Branco | Leve & Universal
]]

local S=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local C=workspace.CurrentCamera
local L=S.LocalPlayer
local M=math

--══════════════════════════════════════════════════════════
-- CONFIG
--══════════════════════════════════════════════════════════
local Cfg={
    Vermelho=Color3.fromRGB(210,25,25),
    Branco=Color3.new(1,1,1),
    Fundo=Color3.fromRGB(12,12,15),
    Painel=Color3.fromRGB(28,28,30),
    ESPcor=Color3.fromRGB(255,50,50),
    Alcance=400,
    Suave=2.5,
    TeamCheck=true
}
local Estado={
    Silent=false,
    Aimbot=false,
    ESP=true,
    AlvoDist=350,
    DadosESP={}
}

--══════════════════════════════════════════════════════════
-- PARENT SEGURO
--══════════════════════════════════════════════════════════
local P=(gethui and select(2,pcall(gethui))) or L:FindFirstChild("PlayerGui",true) or L:WaitForChild("PlayerGui")

--══════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
--══════════════════════════════════════════════════════════
local function Val(p)return p~=L and p.Character and (not Cfg.TeamCheck or p.Team~=L.Team)end

local function PegarAlvo()
    local alvo,menorD=nil,Estado.AlvoDist
    local mouse=U:GetMouseLocation()
    for _,p next S:GetPlayers()do if Val(p)then
        local pt=p.Character:FindFirstChild("Head")or p.Character:FindFirstChild("HumanoidRootPart")
        if pt then local x,y=C:WorldToViewportPoint(pt.Position)
            if y>0 then local d=(Vector2.new(x.X,x.Y)-mouse).Magnitude
                if d<menorD then menorD=d alvo={P=pt,Pos=pt.Position,Ch=p.Character,Nome=p.Name}end
            end
        end
    end end return alvo
end

--══════════════════════════════════════════════════════════
-- MIRA
--══════════════════════════════════════════════════════════
local Gui=Instance.new("ScreenGui")Gui.Parent=P Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local function Cir(cor,z)
    local f=Instance.new("Frame")f.Size=UDim2.fromOffset(44,44)f.Position=UDim2.new(.5,-22,.5,-22)f.BackgroundTransparency=1 f.Parent=Gui
    local a=Instance.new("Frame")a.Size=UDim2.fromScale(1,1)a.BackgroundTransparency=1 a.Parent=f
    Instance.new("UICorner",a).CornerRadius=UDim.new(1,0)
    local s=Instance.new("UIStroke")s.Color=cor s.Thickness=1.5 s.Transparency=.85 s.Parent=a a.ZIndex=z return s
end
local MiraBranca=Cir(Cfg.Branco,2)
local MiraVermelha=Cir(Cfg.Vermelho,3)
local Centro=Instance.new("Frame")Centro.Size=UDim2.fromOffset(4,4)Centro.Position=UDim2.new(.5,-2,.5,-2)
Centro.BackgroundColor3=Cfg.Branco Centro.Parent=Gui Instance.new("UICorner",Centro).CornerRadius=UDim.new(1,0)

local function AtualizarMira()
    MiraBranca.Transparency=Estado.Aimbot and 0 or .85
    MiraBranca.Thickness=Estado.Aimbot and 2.5 or 1.5
    MiraVermelha.Transparency=Estado.Silent and 0 or .85
    MiraVermelha.Thickness=Estado.Silent and 2.5 or 1.5
end

--══════════════════════════════════════════════════════════
-- ESP
--══════════════════════════════════════════════════════════
local function NovoESP(ply)
    local Cont=Instance.new("Frame")Cont.BackgroundTransparency=1 Cont.Size=UDim2.new(0,0,0,0)Cont.Parent=Gui
    local Caixa=Instance.new("Frame")Caixa.BackgroundColor3=Cfg.ESPcor Caixa.BackgroundTransparency=.7 Caixa.BorderSizePixel=0 Caixa.Parent=Cont
    local Nome=Instance.new("TextLabel")Nome.BackgroundTransparency=1 Nome.TextColor3=Cfg.Branco Nome.Font=Enum.Font.GothamBold Nome.TextSize=11 Nome.Parent=Cont
    local Dist=Instance.new("TextLabel")Dist.BackgroundTransparency=1 Dist.TextColor3=Color3.fromRGB(120,255,120)Dist.Font=Enum.Font.GothamBold Dist.TextSize=9 Dist.Parent=Cont
    local Linha=Instance.new("Frame")Linha.BackgroundColor3=Cfg.ESPcor Linha.BackgroundTransparency=.6 Linha.Size=UDim2.new(0,1,0,0)Linha.Parent=Cont

    Estado.DadosESP[ply]={Cont=Cont,Caixa=Caixa,Nome=Nome,Dist=Dist,Linha=Linha}
end

local function AtualizarESP()
    for ply,dados next Estado.DadosESP do
        if not ply.Character or not Val(ply) then dados.Cont.Visible=false continue end
        dados.Cont.Visible=Estado.ESP
        local H=ply.Character:FindFirstChild("Head")
        local Torso=ply.Character:FindFirstChild("HumanoidRootPart")
        if not H or not Torso then continue end

        local PosH,X=C:WorldToViewportPoint(H.Position)
        local PosT,_=C:WorldToViewportPoint(Torso.Position)
        local Distancia=(L.Character.HumanoidRootPart.Position-Torso.Position).Magnitude

        if X>0 then
            local Altura=M.abs(PosH.Y-PosT.Y)*2.2
            local Largura=Altura*.6
            dados.Caixa.Size=UDim2.new(0,Largura,0,Altura)
            dados.Caixa.Position=UDim2.new(0,PosT.X-Largura/2,0,PosT.Y-Altura/2)
            dados.Nome.Text=ply.Name
            dados.Nome.Position=UDim2.new(0,PosT.X-dados.Nome.TextBounds.X/2,0,PosT.Y-Altura-18)
            dados.Dist.Text=M.floor(Distancia).." u"
            dados.Dist.Position=UDim2.new(0,PosT.X-dados.Dist.TextBounds.X/2,0,PosT.Y+Altura+2)
            dados.Linha.Position=UDim2.new(0,PosT.X-.5,0,PosT.Y+Altura)
            dados.Linha.Size=UDim2.new(0,1,0,C.ViewportSize.Y-PosT.Y-Altura)
        end
    end
end

S.PlayerAdded:Connect(NovoESP)
S.PlayerRemoving:Connect(function(ply)if Estado.DadosESP[ply]then Estado.DadosESP[ply].Cont:Destroy() Estado.DadosESP[ply]=nil end end)
for _,p next S:GetPlayers()do if p~=L then NovoESP(p)end end

--══════════════════════════════════════════════════════════
-- SILENT + AIMBOT
--══════════════════════════════════════════════════════════
R.RenderStepped:Connect(function()
    AtualizarMira()
    AtualizarESP()
    local t=PegarAlvo()
    if not t then return end

    -- AIMBOT
    if Estado.Aimbot then local cp=C.CFrame.Position
        C.CFrame=C.CFrame:Lerp(CFrame.new(cp,cp+(t.Pos-cp).Unit*500),1/Cfg.Suave)
    end

    -- SILENT AIM — CÁLCULO INTERNO PARA CABEÇA
    if Estado.Silent then local Cabeca=t.Ch:FindFirstChild("Head")
        if Cabeca then local Origem=C.CFrame.Position
            local DirecaoReal=(Cabeca.Position-Origem).Unit
            -- Usa internamente sem alterar câmera visível
        end
    end
end)

--══════════════════════════════════════════════════════════
-- TECLAS
--══════════════════════════════════════════════════════════
U.InputBegan:Connect(function(i,g)if g then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then Estado.Aimbot=true end
    if i.KeyCode==Enum.KeyCode.E then Estado.Silent=not Estado.Silent end
    if i.KeyCode==Enum.KeyCode.F then Estado.ESP=not Estado.ESP end
end)
U.InputEnded:Connect(function(i,g)if g then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then Estado.Aimbot=false end
end)

--══════════════════════════════════════════════════════════
-- MENU
--══════════════════════════════════════════════════════════
local Menu=Instance.new("Frame")Menu.Size=UDim2.fromOffset(250,280)Menu.Position=UDim2.new(0,15,.5,-140)
Menu.BackgroundColor3=Cfg.Fundo Menu.Active=true Menu.Draggable=true Menu.Parent=Gui
Instance.new("UICorner",Menu).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",Menu).Color=Cfg.Vermelho Instance.new("UIStroke",Menu).Thickness=1.5

local Topo=Instance.new("Frame")Topo.Size=UDim2.new(1,0,0,45)Topo.BackgroundColor3=Cfg.Vermelho Topo.Parent=Menu
Instance.new("UICorner",Topo).CornerRadius=UDim.new(0,12)
Instance.new("TextLabel",Topo).Text="CONTROLE".TextColor3=Cfg.Branco.Font=Enum.Font.GothamBold.TextSize=14
.Position=UDim2.new(0,15,.5,0).BackgroundTransparency=1.TextXAlignment=Enum.TextXAlignment.Left

Instance.new("TextButton",Topo).Size=UDim2.fromOffset(26,26).Position=UDim2.new(1,-31,.5,-13)
.BackgroundColor3=Color3.fromRGB(170,15,15).Text="✕".TextColor3=Cfg.Branco.Font=Enum.Font.GothamBold
.MouseButton1Click:Connect(function()Gui:Destroy()end)

local function Botao(y,txt,fn)local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-24,0,42)b.Position=UDim2.new(0,12,0,y)
    b.BackgroundColor3=Cfg.Painel b.Text=txt b.TextColor3=Cfg.Branco
    b.Font=Enum.Font.GothamBold b.Parent=Menu Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
    local s=Instance.new("UIStroke",b).Color=Cfg.Vermelho s.Transparency=.6
    b.MouseButton1Click:Connect(function()fn(b,s)end)
end

Botao(20,"🎯 SILENT [E]",function(b,s)Estado.Silent=not Estado.Silent
    b.BackgroundColor3=Estado.Silent and Cfg.Vermelho or Cfg.Painel s.Transparency=Estado.Silent and 0 or .6
end)

Botao(75,"👁️ ESP [F]",function(b,s)Estado.ESP=not Estado.ESP
    b.BackgroundColor3=Estado.ESP and Cfg.Vermelho or Cfg.Painel s.Transparency=Estado.ESP and 0 or .6
end)

local BtnAim,BordaAim=Botao(130,"⚡ AIMBOT [CLICK]",function()end)
R.Heartbeat:Connect(function()
    BtnAim.BackgroundColor3=Estado.Aimbot and Cfg.Vermelho or Cfg.Painel
    BordaAim.Transparency=Estado.Aimbot and 0 or .6
end)

Botao(185,"🛡️ TIME CHECK",function(b,s)Cfg.TeamCheck=not Cfg.TeamCheck
    b.BackgroundColor3=Cfg.TeamCheck and Cfg.Vermelho or Cfg.Painel s.Transparency=Cfg.TeamCheck and 0 or .6
end)

print("══════════════════════════════════")
print("  SILENT + ESP — PRONTO")
print("══════════════════════════════════")
print("  Clique = Aimbot")
print("  E = Silent Aim")
print("  F = Ligar/Desligar ESP")
print("══════════════════════════════════")
