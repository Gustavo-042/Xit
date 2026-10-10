
local AimConfig = {
    Enabled = false,

    -- Intensidade da assistência
    Intensity = 50, -- 0 a 100

    -- Campo de visão da assistência
    FOV = 100,

    -- Distância máxima
    MaxDistance = 300,

    -- Configuração visual
    ShowFOV = true,
    FOVColor = Color3.fromRGB(167, 139, 250),
    FOVTransparency = 0.25,

    -- Compatibilidade com a câmera
    CameraModes = {
        FirstPerson = true,
        ThirdPerson = true,
    },
}

return AimConfig
