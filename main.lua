-- [[ Mercury FFlag & Visuals Utility ]]
-- Version: 1.0.0
-- GitHub: https://github.com/1vly/Mercury

-- [ Initial Configuration ]
getgenv().sUNCDebug = {
    ["printcheckpoints"] = false,
    ["delaybetweentests"] = 0,
    ["printtesttimetaken"] = false,
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- [ Data Gathering ]
local executorName, executorVersion = identifyexecutor()
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- [ Function Support Check ]
local function checkRequirements()
    local unsupported = 0
    if not setfflag then unsupported = unsupported + 1 end
    if not getgenv then unsupported = unsupported + 1 end
    return unsupported
end

-- [ Window Setup ]
local Window = Rayfield:CreateWindow({
    Name = "Mercury | FFlag & Visuals",
    LoadingTitle = "Mercury FFlag Utility",
    LoadingSubtitle = "by 1vly",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "MercuryConfig",
       FileName = "MercurySettings"
    },
    KeySystem = false -- Key system logic handled via external Linkvertise gate
})

-- [ Home Tab: Info & Specs ]
local HomeTab = Window:CreateTab("Home", 4483362458)
local InfoSection = HomeTab:CreateSection("Executor Statistics")

HomeTab:CreateParagraph({Title = "Executor Info", Content = "Name: "..executorName.."\nHWID: "..hwid})

-- Run UNC Test automatically
local uncStatus = HomeTab:CreateLabel("UNC Check: Initializing...")
task.spawn(function()
    loadstring(game:HttpGet("https://script.sunc.su/"))()
    uncStatus:Set("UNC Check: Complete (Check Console for Score)")
end)

local reqCount = checkRequirements()
if reqCount > 0 then
    Rayfield:Notify({
        Title = "Compatibility Warning",
        Content = "Your executor is missing "..reqCount.." functions required for full script operation.",
        Duration = 10,
        Image = 4483362458,
    })
end

-- [ FFlag Tab: Injector & Presets ]
local FFlagTab = Window:CreateTab("FFlag Env", 4483362458)
local FFlagPreset = [[
{
"FLogNetwork": "7",
"FFlagHandleAltEnterFullscreenManually": "False",
"DFIntTaskSchedulerTargetFps": "260",
"FFlagDebugGraphicsPreferD3D11": "True",
"FIntFullscreenTitleBarTriggerDelayMillis": "3600000",
"FFlagDebugForceFutureIsBrightPhase3": "True",
"DFIntTextureQualityOverride": "1",
"DFFlagTextureQualityOverrideEnabled": "True",
"FFlagTaskSchedulerLimitTargetFpsTo2402": "False",
"FFlagDebugSkyGray": "True",
"FIntDebugForceMSAASamples": "1",
"FIntTerrainArraySliceSize": "0",
"DFFlagDisableDPIScale": "True",
"FIntRenderShadowIntensity": "0",
"FFlagDisablePostFx": "True",
"FFlagDebugGraphicsPreferD3D11FL10": "True",
"DFIntCanHideGuiGroupId": "32380007",
"FFlagLuaAppUseUIBloxColorPalettes1": "True",
"DFIntMaxFrameBufferSize": "5",
"FFlagUIBloxUseNewThemeColorPalettes": "True",
"FIntDebugTextureManagerSkipMips": "4",
"DFIntPerformanceControlTextureQualityBestUtility": "-1",
"DFIntDebugFRMQualityLevelOverride": "1"
}
]]

FFlagTab:CreateSection("Global Injection")
FFlagTab:CreateButton({
    Name = "Inject Optimization Presets (Boost FPS)",
    Callback = function()
        if not setfflag then return Rayfield:Notify({Title="Error", Content="Executor does not support setfflag"}) end
        
        local function inject(json)
            for i, v in pairs(HttpService:JSONDecode(json)) do
                local name = i:gsub("FFlag", ""):gsub("DFInt", ""):gsub("DFFlag", ""):gsub("FInt", "")
                setfflag(name, v)
            end
        end
        inject(FFlagPreset)
        Rayfield:Notify({Title="Success", Content="Optimization FFlags Injected!"})
    end,
})

FFlagTab:CreateSection("Custom FFlag Entry")
local customFlagName = ""
local customFlagVal = ""

FFlagTab:CreateInput({
    Name = "Flag Name",
    PlaceholderText = "e.g. TaskSchedulerTargetFps",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) customFlagName = Text end,
})

FFlagTab:CreateInput({
    Name = "Flag Value",
    PlaceholderText = "e.g. 144",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) customFlagVal = Text end,
})

FFlagTab:CreateButton({
    Name = "Inject Custom Flag",
    Callback = function()
        if setfflag and customFlagName ~= "" then
            setfflag(customFlagName, customFlagVal)
            Rayfield:Notify({Title="Success", Content="Injected: "..customFlagName})
        end
    end,
})

-- [ Visuals Tab: Dark, Stretched, No Texture ]
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateButton({
    Name = "Enable Dark Textures (Charcoal Map)",
    Callback = function()
        local function isMapPart(part)
            if not part:IsA("BasePart") then return false end
            if part:FindFirstAncestorOfClass("Tool") or (part.Parent and part.Parent:FindFirstChildOfClass("Humanoid")) then return false end
            if part:FindFirstChildWhichIsA("SpecialMesh") or part:FindFirstChildWhichIsA("MeshPart") then return false end
            if part.Size.Magnitude < 5 or part.Material == Enum.Material.Grass or not part.Anchored then return false end
            return true
        end
        
        for _, part in pairs(workspace:GetDescendants()) do
            if isMapPart(part) then
                part.Color = Color3.fromRGB(50, 50, 50)
                part.Material = Enum.Material.SmoothPlastic
            end
        end
    end,
})

local resValue = 1
local stretchConnection
VisualsTab:CreateSlider({
    Name = "Stretched Resolution",
    Info = "Vertical Scale (Lower = More Stretched)",
    Range = {0.1, 1},
    Increment = 0.05,
    Suffix = "Scale",
    CurrentValue = 1,
    Callback = function(Value)
        resValue = Value
        if stretchConnection then stretchConnection:Disconnect() end
        if Value < 1 then
            stretchConnection = RunService.RenderStepped:Connect(function()
                local Camera = workspace.CurrentCamera
                Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, resValue, 0, 0, 0, 1)
            end)
        end
    end,
})

VisualsTab:CreateButton({
    Name = "Disable All Textures (Potato Mode)",
    Callback = function()
        for _, v in next, game:GetDescendants() do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            if v:IsA("Decal") or v:IsA("Texture") then v.Texture = "" end
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false end
            if v:IsA("Sky") then v:Destroy() end
        end
        Rayfield:Notify({Title="Optimized", Content="Textures and Effects stripped."})
    end,
})

VisualsTab:CreateButton({
    Name = "FullBright / No Fog",
    Callback = function()
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    end,
})

-- [ Credits Tab ]
local CreditsTab = Window:CreateTab("Credits", 4483362458)
CreditsTab:CreateParagraph({Title = "Lead Dev", Content = "Mercury was developed by 1vly."})
CreditsTab:CreateParagraph({Title = "Supported Executors", Content = "Optimized specifically for Delta Mobile."})

Rayfield:LoadConfiguration()
