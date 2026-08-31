local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local stageValue = leaderstats:WaitForChild("Stage")
local runsValue = leaderstats:WaitForChild("Runs")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GPTBloxHud"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Position = UDim2.fromOffset(18, 18)
panel.Size = UDim2.fromOffset(430, 126)
panel.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 8)
title.Size = UDim2.fromOffset(402, 30)
title.Font = Enum.Font.GothamBold
title.Text = "GPTBlox // Prompt Panic"
title.TextColor3 = Color3.fromRGB(235, 220, 255)
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local status = Instance.new("TextLabel")
status.Name = "Status"
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(14, 40)
status.Size = UDim2.fromOffset(402, 24)
status.Font = Enum.Font.GothamMedium
status.TextColor3 = Color3.fromRGB(180, 190, 205)
status.TextSize = 15
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local prompt = Instance.new("TextLabel")
prompt.Name = "Prompt"
prompt.BackgroundTransparency = 1
prompt.Position = UDim2.fromOffset(14, 67)
prompt.Size = UDim2.fromOffset(402, 48)
prompt.Font = Enum.Font.GothamBold
prompt.TextColor3 = Color3.fromRGB(255, 255, 255)
prompt.TextSize = 16
prompt.TextWrapped = true
prompt.TextXAlignment = Enum.TextXAlignment.Left
prompt.TextYAlignment = Enum.TextYAlignment.Top
prompt.Parent = panel

local function refresh()
	local stageCount = Workspace:GetAttribute("GPTBloxStageCount") or 0
	local seed = Workspace:GetAttribute("GPTBloxSeed") or "?"
	status.Text = string.format("Stage %d/%d   |   Runs %d   |   Daily seed %s", stageValue.Value, stageCount, runsValue.Value, tostring(seed))
	prompt.Text = player:GetAttribute("CurrentPrompt") or "Generating prompt..."
end

stageValue.Changed:Connect(refresh)
runsValue.Changed:Connect(refresh)
player:GetAttributeChangedSignal("CurrentPrompt"):Connect(refresh)
Workspace:GetAttributeChangedSignal("GPTBloxSeed"):Connect(refresh)
Workspace:GetAttributeChangedSignal("GPTBloxStageCount"):Connect(refresh)

refresh()
