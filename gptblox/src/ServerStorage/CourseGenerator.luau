local CourseGenerator = {}

local COLORS = {
	Floor = Color3.fromRGB(45, 48, 58),
	Safe = Color3.fromRGB(90, 180, 255),
	Checkpoint = Color3.fromRGB(90, 255, 150),
	Danger = Color3.fromRGB(255, 70, 70),
	Prompt = Color3.fromRGB(190, 120, 255),
	Hallucination = Color3.fromRGB(255, 220, 120),
}

local function createPart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function findHumanoid(hit)
	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then
		return nil
	end

	return model:FindFirstChildOfClass("Humanoid")
end

local function makeKillPart(parent, name, size, cframe)
	local part = createPart(parent, name, size, cframe, COLORS.Danger, Enum.Material.Neon)
	part.Touched:Connect(function(hit)
		local humanoid = findHumanoid(hit)
		if humanoid then
			humanoid.Health = 0
		end
	end)
	return part
end

local function addPromptSign(parent, text, position)
	local post = createPart(
		parent,
		"PromptSign",
		Vector3.new(1, 6, 1),
		CFrame.new(position),
		COLORS.Prompt,
		Enum.Material.Neon
	)

	local gui = Instance.new("BillboardGui")
	gui.Name = "PromptBillboard"
	gui.Size = UDim2.fromOffset(340, 90)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = post

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
	label.BorderSizePixel = 0
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function addEntranceAndExit(parent, startZ, config)
	createPart(
		parent,
		"Entrance",
		Vector3.new(16, 2, 10),
		CFrame.new(0, config.BaseY, startZ + 4),
		COLORS.Floor,
		Enum.Material.Metal
	)

	createPart(
		parent,
		"Exit",
		Vector3.new(16, 2, 10),
		CFrame.new(0, config.BaseY, startZ + config.StageLength - 4),
		COLORS.Floor,
		Enum.Material.Metal
	)
end

local function buildSteppingStones(parent, startZ, random, config)
	local count = 8
	for index = 1, count do
		local progress = index / (count + 1)
		local z = startZ + 8 + progress * (config.StageLength - 16)
		local x = index % 2 == 0 and 7 or -7
		createPart(
			parent,
			"Stone" .. index,
			Vector3.new(10, 2, 8),
			CFrame.new(x, config.BaseY, z),
			COLORS.Safe,
			Enum.Material.SmoothPlastic
		)
	end
end

local function buildNeedleBeams(parent, startZ, random, config)
	local count = 5
	for index = 1, count do
		local progress = index / (count + 1)
		local z = startZ + 8 + progress * (config.StageLength - 16)
		local xPattern = { -6, 0, 6 }
		local x = xPattern[((index - 1) % #xPattern) + 1]
		local yaw = math.rad(index % 2 == 0 and 14 or -14)
		createPart(
			parent,
			"NeedleBeam" .. index,
			Vector3.new(4, 2, 14),
			CFrame.new(x, config.BaseY, z) * CFrame.Angles(0, yaw, 0),
			COLORS.Safe,
			Enum.Material.Metal
		)
	end
end

local function buildLavaPath(parent, startZ, random, config)
	makeKillPart(
		parent,
		"LavaFloor",
		Vector3.new(32, 1, config.StageLength - 12),
		CFrame.new(0, config.BaseY - 4, startZ + config.StageLength / 2)
	)

	local count = 9
	for index = 1, count do
		local progress = index / (count + 1)
		local z = startZ + 8 + progress * (config.StageLength - 16)
		local x = random:NextInteger(-8, 8)
		createPart(
			parent,
			"SafeTile" .. index,
			Vector3.new(8, 2, 7),
			CFrame.new(x, config.BaseY, z),
			COLORS.Safe,
			Enum.Material.Concrete
		)
	end
end

local function buildHallucination(parent, startZ, random, config)
	makeKillPart(
		parent,
		"HallucinationVoid",
		Vector3.new(34, 1, config.StageLength - 12),
		CFrame.new(0, config.BaseY - 4, startZ + config.StageLength / 2)
	)

	local rows = 7
	for row = 1, rows do
		local progress = row / (rows + 1)
		local z = startZ + 8 + progress * (config.StageLength - 16)
		local safeSide = random:NextInteger(1, 2)

		for side = 1, 2 do
			local x = side == 1 and -6 or 6
			local tile = createPart(
				parent,
				string.format("Hallucination_%d_%d", row, side),
				Vector3.new(9, 2, 7),
				CFrame.new(x, config.BaseY, z),
				COLORS.Hallucination,
				Enum.Material.SmoothPlastic
			)

			if side ~= safeSide then
				tile.CanCollide = false
				tile.Transparency = 0.18
			else
				tile.Transparency = 0.04
			end
		end
	end
end

local function buildVanishingContext(parent, startZ, random, config)
	local count = 10
	for index = 1, count do
		local progress = index / (count + 1)
		local z = startZ + 8 + progress * (config.StageLength - 16)
		local x = index % 2 == 0 and 5 or -5
		local tile = createPart(
			parent,
			"ContextTile" .. index,
			Vector3.new(9, 2, 7),
			CFrame.new(x, config.BaseY, z),
			COLORS.Safe,
			Enum.Material.Glass
		)

		local busy = false
		tile.Touched:Connect(function(hit)
			if busy or not findHumanoid(hit) then
				return
			end

			busy = true
			task.delay(0.18, function()
				if not tile.Parent then
					return
				end

				tile.CanCollide = false
				tile.Transparency = 0.82
				task.delay(1.7, function()
					if not tile.Parent then
						return
					end

					tile.CanCollide = true
					tile.Transparency = 0
					busy = false
				end)
			end)
		end)
	end
end

local function buildTokenLimit(parent, startZ, random, config)
	local count = 12
	for index = 1, count do
		local progress = index / (count + 1)
		local z = startZ + 8 + progress * (config.StageLength - 16)
		local x = ((index % 3) - 1) * 4
		local height = ((index - 1) % 4) * 1.3
		createPart(
			parent,
			"Token" .. index,
			Vector3.new(5, 2, 5),
			CFrame.new(x, config.BaseY + height, z),
			COLORS.Safe,
			Enum.Material.Metal
		)
	end
end

local STAGES = {
	{ name = "PROMPT: Cross the stepping stones", build = buildSteppingStones },
	{ name = "PROMPT: Be precise. Very precise.", build = buildNeedleBeams },
	{ name = "PROMPT: Avoid the confident red answer", build = buildLavaPath },
	{ name = "HALLUCINATION: Some platforms are not real", build = buildHallucination },
	{ name = "CONTEXT WINDOW: Keep moving", build = buildVanishingContext },
	{ name = "TOKEN LIMIT: Spend your jumps carefully", build = buildTokenLimit },
}

local function stagePool()
	local pool = {}
	for index, stage in ipairs(STAGES) do
		pool[index] = stage
	end
	return pool
end

function CourseGenerator.build(parent, seed, config)
	local random = Random.new(seed)
	local result = {
		CheckpointCFrames = {},
		CheckpointParts = {},
		StageNames = {},
	}

	local lobby = createPart(
		parent,
		"PromptLobby",
		Vector3.new(config.LobbySize, 2, config.LobbySize),
		CFrame.new(0, config.BaseY, 0),
		COLORS.Floor,
		Enum.Material.Metal
	)
	lobby:SetAttribute("GPTBloxLobby", true)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "GPTBloxSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, config.BaseY + 1.5, 0)
	spawn.Color = COLORS.Checkpoint
	spawn.Material = Enum.Material.Neon
	spawn.Parent = parent

	result.CheckpointCFrames[0] = CFrame.new(0, config.BaseY + config.RespawnLift, 0)

	createPart(
		parent,
		"LobbyBridge",
		Vector3.new(12, 2, 26),
		CFrame.new(0, config.BaseY, 28),
		COLORS.Floor,
		Enum.Material.Metal
	)

	local pool = stagePool()
	local firstStageZ = 40
	for stageIndex = 1, config.StageCount do
		if #pool == 0 then
			pool = stagePool()
		end

		local choiceIndex = random:NextInteger(1, #pool)
		local stage = table.remove(pool, choiceIndex)
		local startZ = firstStageZ + (stageIndex - 1) * (config.StageLength + config.StageGap)
		local stageFolder = Instance.new("Folder")
		stageFolder.Name = string.format("Stage_%02d", stageIndex)
		stageFolder.Parent = parent

		addEntranceAndExit(stageFolder, startZ, config)
		addPromptSign(stageFolder, stage.name, Vector3.new(-14, config.BaseY + 2, startZ + 4))
		stage.build(stageFolder, startZ, random, config)

		local checkpointZ = startZ + config.StageLength + 5
		local checkpoint = createPart(
			parent,
			"Checkpoint_" .. stageIndex,
			Vector3.new(18, 2, 8),
			CFrame.new(0, config.BaseY, checkpointZ),
			COLORS.Checkpoint,
			Enum.Material.Neon
		)
		checkpoint:SetAttribute("Stage", stageIndex)

		result.CheckpointParts[stageIndex] = checkpoint
		result.CheckpointCFrames[stageIndex] = CFrame.new(0, config.BaseY + config.RespawnLift, checkpointZ)
		result.StageNames[stageIndex] = stage.name
	end

	local finalStartZ = firstStageZ + (config.StageCount - 1) * (config.StageLength + config.StageGap)
	local finishZ = finalStartZ + config.StageLength + 24
	createPart(
		parent,
		"FinishBridge",
		Vector3.new(12, 2, 28),
		CFrame.new(0, config.BaseY, finishZ - 12),
		COLORS.Floor,
		Enum.Material.Metal
	)

	local finish = createPart(
		parent,
		"FinalResponse",
		Vector3.new(24, 2, 18),
		CFrame.new(0, config.BaseY, finishZ),
		COLORS.Prompt,
		Enum.Material.Neon
	)
	finish:SetAttribute("GPTBloxFinish", true)
	result.FinishPart = finish
	addPromptSign(parent, "FINAL RESPONSE: Ship it", Vector3.new(-15, config.BaseY + 2, finishZ))

	local courseLength = finishZ + 40
	result.KillPart = makeKillPart(
		parent,
		"GlobalKillPlane",
		Vector3.new(120, 2, courseLength),
		CFrame.new(0, config.BaseY - config.KillPlaneDepth, courseLength / 2 - 20)
	)

	return result
end

return CourseGenerator
