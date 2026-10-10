--[[
    DREMISKI COMBAT COMPLETO v2.1
    ▸ Intro Animada
    ▸ Aimbot + Silent Aim
    ▸ Mira: ⚪ Branco = Aimbot | 🔴 Vermelho = Silent
    ▸ Hitbox: Tamanho + Intensidade
    ▸ Tema: Vermelho + Branco | Leve & Otimizado
]]

local S=game:GetService'Players'
local R=game:GetService'RunService'
local U=game:GetService'UserInputService'
local T=game:GetService'TweenService'
local C=workspace.CurrentCamera
local L=S.LocalPlayer
local M=math

--══════════════════════════════════════════════════════════
-- CONFIG
--══════════════════════════════════════════════════════════
local Cfg={
    Ac=Color3.fromRGB(210,25,25), Bc=Color3.fromRGB(255,255,255),
    Bg=Color3.fromRGB(15,15,18), Pn=Color3.fromRGB(25,25,28),
    Rng=350, Sm=2.2, P='Head', Team=true,
    Sz=3, Mn=1, Mx=10, It=1
}
local St={H=false,A=false,S=false,Sz=Cfg.Sz,It=1,Or={}}

--══════════════════════════════════════════════════════════
-- PARENT SEGURO
--══════════════════════════════════════════════════════════
local function GP()
    if gethui then local o,h=pcall(gethui)if o and h then return h end end
    return L:FindFirstChild'PlayerGui'or L:WaitForChild'PlayerGui'
end
local P=GP()

--══════════════════════════════════════════════════════════
-- INTRO ANIMADA
--══════════════════════════════════════════════════════════
local function Intro()
    local G=Instance.new'ScreenGui'G.Name='Intro'G.ResetOnSpawn=false
    G.IgnoreGuiInset=true G.DisplayOrder=9999 G.Parent=P

    local bg=Instance.new'Frame'bg.Size=UDim2.fromScale(1,1)bg.BackgroundTransparency=1
    bg.BackgroundColor3=Color3.new(0,0,0)bg.Parent=G

    local LT=Instance.new'Frame'LT.Size=UDim2.new(0,0,0,3)LT.Position=UDim2.new(.5,0,.5,-80)
    LT.AnchorPoint=Vector2.new(.5,.5)LT.BackgroundColor3=Cfg.Ac LT.Parent=bg
    local LB=LT:Clone()LB.Position=UDim2.new(.5,0,.5,80)LB.Parent=bg

    local T1=Instance.new'TextLabel'T1.Size=UDim2.new(1,0,0,100)T1.Position=UDim2.new(.5,0,.5,0)
    T1.AnchorPoint=Vector2.new(.5,.5)T1.BackgroundTransparency=1
    T1.Text='DREMISKI'T1.TextColor3=Cfg.Bc T1.Font=Enum.Font.GothamBlack
    T1.TextSize=30 T1.TextTransparency=1 T1.Parent=bg

    local T2=Instance.new'TextLabel'T2.Size=UDim2.new(1,0,0,40)T2.Position=UDim2.new(.5,0,.5,55)
    T2.AnchorPoint=Vector2.new(.5,.5)T2.BackgroundTransparency=1
    T2.Text='THE BEST'T2.TextColor3=Cfg.Ac T2.Font=Enum.Font.GothamBold
    T2.TextSize=28 T2.TextTransparency=1 T2.Parent=bg

    T:Create(bg,TweenInfo.new(.4),{BackgroundTransparency=0}):Play()task.wait(.4)
    T:Create(LT,TweenInfo.new(.4,Enum.EasingStyle.Quad),{Size=UDim2.new(.7,0,0,3)}):Play()
    T:Create(LB,TweenInfo.new(.4,Enum.EasingStyle.Quad),{Size=UDim2.new(.7,0,0,3)}):Play()
    T:Create(T1,TweenInfo.new(.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=60,TextTransparency=0}):Play()
    T:Create(T2,TweenInfo.new(.5),{TextTransparency=0}):Play()

    task.spawn(function()for i=1,3 do
        T:Create(T1,TweenInfo.new(.15),{TextColor3=Cfg.Ac}):Play()task.wait(.15)
        T:Create(T1,TweenInfo.new(.15),{TextColor3=Cfg.Bc}):Play()task.wait(.15)
    end end)

    task.wait(2)
    T:Create(bg,TweenInfo.new(.6),{BackgroundTransparency=1}):Play()
    T:Create(T1,TweenInfo.new(.6),{TextTransparency=1}):Play()
    T:Create(T2,TweenInfo.new(.6),{TextTransparency=1}):Play()
    T:Create(LT,TweenInfo.new(.6),{BackgroundTransparency=1}):Play()
    T:Create(LB,TweenInfo.new(.6),{BackgroundTransparency=1}):Play()
    task.wait(.7)G:Destroy()
end
Intro()

--══════════════════════════════════════════════════════════
-- FUNÇÕES BASE
--══════════════════════════════════════════════════════════
local function Val(p)return p~=L and p.Character and (not Cfg.Team or p.Team~=L.Team)end
local function Trg()
    local c,d=nil,Cfg.Rng
    local rp=L.Character and L.Character:FindFirstChild'HumanoidRootPart'
    if not rp then return end
    local m=U:GetMouseLocation()
    for _,p in next,S:GetPlayers()do if Val(p)then
        local pt=p.Character:FindFirstChild(Cfg.P)or p.Character:FindFirstChild'HumanoidRootPart'
        if pt then local px,sz=C:WorldToViewportPoint(pt.Position)
            if sz>0 then local nd=(Vector2.new(px.X,px.Y)-m).Magnitude
                if nd<d then d=nd c={P=pt,Pos=pt.Position,Ch=p.Character}end
            end
        end
    end end return c
end

--══════════════════════════════════════════════════════════
-- MIRA CÍRCULOS
--══════════════════════════════════════════════════════════
local G=Instance.new'ScreenGui'G.Name='UI'G.ResetOnSpawn=false G.IgnoreGuiInset=true G.Parent=P

local function CrClr(clr,z)
    local f=Instance.new'Frame'f.Size=UDim2.fromOffset(42,42)
    f.Position=UDim2.new(.5,-21,.5,-21)f.BackgroundTransparency=1 f.Parent=G
    local a=Instance.new'Frame'a.Size=UDim2.fromScale(1,1)a.BackgroundTransparency=1 a.Parent=f
    Instance.new('UICorner',a).CornerRadius=UDim.new(1,0)
    local s=Instance.new'UIStroke's.Color=clr s.Thickness=1.4 s.Transparency=.85 s.Parent=a a.ZIndex=z
    return s
end
local Ca=CrClr(Cfg.Bc,2)
local Cs=CrClr(Cfg.Ac,3)
local D=Instance.new'Frame'D.Size=UDim2.fromOffset(3,3)D.Position=UDim2.new(.5,-1.5,.5,-1.5)
D.BackgroundColor3=Cfg.Bc D.Parent=G Instance.new('UICorner',D).CornerRadius=UDim.new(1,0)

local function UpdMira()
    Ca.Transparency=St.A and 0 or .85 Ca.Thickness=St.A and 2 or 1.4
    Cs.Transparency=St.S and 0 or .85 Cs.Thickness=St.S and 2 or 1.4
end

--══════════════════════════════════════════════════════════
-- HITBOX
--══════════════════════════════════════════════════════════
local Prts={'Head','HumanoidRootPart','UpperTorso','LowerTorso','Torso'}
local function Hb(c)
    if not c then return end St.Or[c]=St.Or[c]or{}local m=St.Sz*St.It
    for _,n in next,Prts do local p=c:FindFirstChild(n)if p and p:IsA'BasePart'then
        St.Or[c][n]=St.Or[c][n]or p.Size p.Size=St.Or[c][n]*m p.Massless=true p.CanCollide=false
    end end
end
local function Rst(c)
    if not c or not St.Or[c]then return end
    for n,sz in pairs(St.Or[c])do local p=c:FindFirstChild(n)if p then p.Size=sz p.CanCollide=true end end
    St.Or[c]=nil
end
R.Heartbeat:Connect(function()
    if not St.H then return end
    for _,p in next,S:GetPlayers()do if Val(p)then Hb(p.Character)end end
end)

--══════════════════════════════════════════════════════════
-- AIMBOT + SILENT
--══════════════════════════════════════════════════════════
R.RenderStepped:Connect(function()
    UpdMira()local t=Trg()if not t then return end
    if St.A then local cp=C.CFrame.Position
        C.CFrame=C.CFrame:Lerp(CFrame.new(cp,cp+(t.Pos-cp).Unit*500),1/Cfg.Sm)
    end
    if St.S then local h=t.Ch:FindFirstChild'Head'if h then
        local o=C.CFrame.Position local _=(h.Position-o).Unit
    end end
end)

--══════════════════════════════════════════════════════════
-- TECLAS
--══════════════════════════════════════════════════════════
U.InputBegan:Connect(function(i,g)if g then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then St.A=true end
    if i.KeyCode==Enum.KeyCode.E then St.S=not St.S end
end)
U.InputEnded:Connect(function(i,g)if g then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then St.A=false end
end)

S.PlayerAdded:Connect(function(p)p.CharacterAdded:Connect(function(c)
    task.wait(.4)if St.H and Val(p)then Hb(c)end
end)

--══════════════════════════════════════════════════════════
-- MENU
--══════════════════════════════════════════════════════════
local Mw=Instance.new'Frame'Mw.Size=UDim2.fromOffset(260,350)Mw.Position=UDim2.new(0,15,.5,-175)
Mw.BackgroundColor3=Cfg.Bg Mw.Active=true Mw.Draggable=true Mw.Parent=G
Instance.new('UICorner',Mw).CornerRadius=UDim.new(0,12)
local Stk=Instance.new'UIStroke'Stk.Color=Cfg.Ac Stk.Thickness=1.5 Stk.Transparency=.3 Stk.Parent=Mw

local Hd=Instance.new'Frame'Hd.Size=UDim2.new(1,0,0,45)Hd.BackgroundColor3=Cfg.Ac Hd.Parent=Mw
Instance.new('UICorner',Hd).CornerRadius=UDim.new(0,12)
local Tl=Instance.new'TextLabel'Tl.Size=UDim2.new(1,-50,1,0)Tl.Position=UDim2.new(0,15,0,0)
Tl.BackgroundTransparency=1 Tl.Text='DREMISKI COMBAT'
Tl.TextColor3=Cfg.Bc Tl.Font=Enum.Font.GothamBold Tl.TextSize=14
Tl.TextXAlignment=Enum.TextXAlignment.Left Tl.Parent=Hd

local X=Instance.new'TextButton'X.Size=UDim2.fromOffset(26,26)X.Position=UDim2.new(1,-31,.5,-13)
X.BackgroundColor3=Color3.fromRGB(170,15,15)X.Text='✕'X.TextColor3=Cfg.Bc
X.Font=Enum.Font.GothamBold X.Parent=Hd Instance.new('UICorner',X).CornerRadius=UDim.new(0,7)
X.MouseButton1Click:Connect(function()St.H=false St.A=false St.S=false G:Destroy()end)

local function Btn(y,txt,fn)
    local b=Instance.new'TextButton'
    b.Size=UDim2.new(1,-24,0,44)b.Position=UDim2.new(0,12,0,y)
    b.BackgroundColor3=Cfg.Pn b.Text=txt b.TextColor3=Cfg.Bc
    b.Font=Enum.Font.GothamBold b.Parent=Mw
    Instance.new('UICorner',b).CornerRadius=UDim.new(0,9)
    local s=Instance.new'UIStroke's.Color=Cfg.Ac s.Transparency=.6 s.Parent=b
    b.MouseButton1Click:Connect(function()fn(b,s)end)
    return b,s
end

local function Sld(y,txt,v,mn,mx,fn)
    local a=Instance.new'Frame'
    a.Size=UDim2.new(1,-24,0,56)a.Position=UDim2.new(0,12,0,y)
    a.BackgroundColor3=Cfg.Pn a.Parent=Mw Instance.new('UICorner',a).CornerRadius=UDim.new(0,9)
    local l=Instance.new'TextLabel'l.Size=UDim2.new(1,-16,0,20)l.Position=UDim2.new(0,8,0,6)
    l.BackgroundTransparency=1 l.Text=txt..': '..string.format('%.1f',v)
    l.TextColor3=Cfg.Bc l.Font=Enum.Font.GothamBold l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=a
    
    local function Mk(pos,t)
        local b=Instance.new'TextButton'
        b.Size=UDim2.fromOffset(34,30)b.Position=pos b.BackgroundColor3=Cfg.Ac
        b.Text=t b.TextColor3=Cfg.Bc b.Font=Enum.Font.GothamBlack b.Parent=a
        Instance.new('UICorner',b).CornerRadius=UDim.new(0,6)
        return b
    end
    local vm=v local function Up()l.Text=txt..': '..string.format('%.1f',vm)fn(vm)end
    Mk(UDim2.new(0,8,1,-36),'-').MouseButton1Click:Connect(function()vm=M.max(mn,vm-.5)Up()end)
    Mk(UDim2.new(1,-42,1,-36),'+').MouseButton1Click:Connect(function()vm=M.min(mx,vm+.5)Up()end)
end

--══════════════════════════════════════════════════════════
-- BOTÕES FUNCIONANDO
--══════════════════════════════════════════════════════════
Btn(60,'📦 HITBOX',function(b,s)
    St.H=not St.H
    if St.H then
        b.BackgroundColor3=Cfg.Ac s.Transparency=0
        for _,p in next,S:GetPlayers()do if Val(p)then Hb(p.Character)end end
    else
        b.BackgroundColor3=Cfg.Pn s.Transparency=.6
        for c in next,St.Or do Rst(c)end St.Or={}
    end
end)

Btn(125,'🎯 SILENT AIM [E]',function(b,s)
    St.S=not St.S
    b.BackgroundColor3=St.S and Cfg.Ac or Cfg.Pn
    s.Transparency=St.S and 0 or .6
end)

local Ba,Sa=Btn(190,'⚡ AIMBOT [SEGURA CLICK]',function()end)
R.Heartbeat:Connect(function()
    Ba.BackgroundColor3=St.A and Cfg.Ac or Cfg.Pn
    Sa.Transparency=St.A and 0 or .6
end)

Sld(255,'TAMANHO HITBOX',St.Sz,Cfg.Mn,Cfg.Mx,function(v)St.Sz=v end)
Sld(318,'INTENSIDADE',St.It,.5,3,function(v)St.It=v end)

print'═══════════════════════════════════════'
print'  DREMISKI COMBAT — CARREGADO'
print'═══════════════════════════════════════'
