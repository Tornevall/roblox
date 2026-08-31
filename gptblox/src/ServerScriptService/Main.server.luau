local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local CourseGenerator = require(ServerStorage:WaitForChild("CourseGenerator"))

local previousCourse = Workspace:FindFirstChild("GPTBloxGenerated")
if previousCourse then
	previousCourse:Destroy()
end

local generated = Instance.new("Folder")
generated.Name = "GPTBloxGenerated"
generated.Parent = Workspace

local seed = math.floor(DateTime.now().UnixTimestamp / 86400)
Workspace:SetAttribute("GPTBloxSeed", seed)
Workspace:SetAttribute("GPTBloxStageCount", Config.StageCount)

local course = CourseGenerator.build(generated, seed, Config)
local finishDebounce = {}

local function getPlayerFromHit(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function getNextPrompt(stage)
	if stage >= Config.StageCount then
		return "FINAL RESPONSE: Reach the purple finish pad"
	end

	return course.StageNames[stage + 1] or "PROMPT: Continue"
end

local function setStage(player, stage)
	player:SetAttribute("CheckpointStage", stage)
	player:SetAttribute("CurrentPrompt", getNextPrompt(stage))

	local leaderstats = player:FindFirstChild("leaderstats")
	local stageValue = leaderstats and leaderstats:FindFirstChild("Stage")
	if stageValue then
		stageValue.Value = stage
	end
end

local function teleportToCheckpoint(player, character)
	local stage = player:GetAttribute("CheckpointStage") or 0
	local destination = course.CheckpointCFrames[stage] or course.CheckpointCFrames[0]
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end

	task.defer(function()
		if character.Parent and destination then
			character:PivotTo(destination)
		end
	end)
end

local function setupPlayer(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local stageValue = leaderstats:FindFirstChild("Stage")
	if not stageValue then
		stageValue = Instance.new("IntValue")
		stageValue.Name = "Stage"
		stageValue.Parent = leaderstats
	end

	local runsValue = leaderstats:FindFirstChild("Runs")
	if not runsValue then
		runsValue = Instance.new("IntValue")
		runsValue.Name = "Runs"
		runsValue.Parent = leaderstats
	end

	setStage(player, 0)

	player.CharacterAdded:Connect(function(character)
		teleportToCheckpoint(player, character)
	end)

	if player.Character then
		teleportToCheckpoint(player, player.Character)
	end
end

for stage, checkpoint in ipairs(course.CheckpointParts) do
	checkpoint.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)
		if not player then
			return
		end

		local currentStage = player:GetAttribute("CheckpointStage") or 0
		if stage > currentStage then
			setStage(player, stage)
		end
	end)
end

course.FinishPart.Touched:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	if not player or finishDebounce[player] then
		return
	end

	local currentStage = player:GetAttribute("CheckpointStage") or 0
	if currentStage < Config.StageCount then
		return
	end

	finishDebounce[player] = true
	local leaderstats = player:FindFirstChild("leaderstats")
	local runsValue = leaderstats and leaderstats:FindFirstChild("Runs")
	if runsValue then
		runsValue.Value += 1
	end

	player:SetAttribute("CurrentPrompt", "RUN COMPLETE: Generating another bad idea...")
	player:SetAttribute("CheckpointStage", 0)
	local stageValue = leaderstats and leaderstats:FindFirstChild("Stage")
	if stageValue then
		stageValue.Value = 0
	end

	task.delay(2, function()
		if not player.Parent then
			finishDebounce[player] = nil
			return
		end

		player:SetAttribute("CurrentPrompt", getNextPrompt(0))
		if player.Character then
			player.Character:PivotTo(course.CheckpointCFrames[0])
		end
		finishDebounce[player] = nil
	end)
end)

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	finishDebounce[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end
