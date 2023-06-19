local difficulties = {
	'Difficulty_Beginner',
	'Difficulty_Easy',
	'Difficulty_Medium',
	'Difficulty_Hard',
	'Difficulty_Challenge',
	'Difficulty_Edit',
}

local difficultyToIndex={}
for k,v in pairs(difficulties) do
   difficultyToIndex[v]=k
end

local EasierDifficulty
local HarderDifficulty

local curDifficultyIndices = {}

local function GetStartingDifficultyIndex(playerNumber)
	local curSteps = GAMESTATE:GetCurrentSteps(playerNumber)

	if curSteps ~= nil then
		local difficulty = curSteps:GetDifficulty()
		local index = difficultyToIndex[difficulty]
		if index ~= nil then
			return index
		end
	end

	local difficulty = DDStats.GetStat(playerNumber, 'LastDifficulty')

	if difficulty ~= nil then
		local index = difficultyToIndex[difficulty]
		
		if index ~= nil then
			return index
		end
	end

	return 5
end

local function SetChart(playerNum, steps)
	curDifficultyIndices[playerNum] = difficultyToIndex[steps:GetDifficulty()]
	GAMESTATE:SetCurrentSteps(playerNum, steps)
	MESSAGEMAN:Broadcast('CurrentStepsChanged', {playerNum=playerNum, steps=steps})
end

local function UpdateChartClick(playerNum, targetDif, PlayerChart)
	local song = GAMESTATE:GetCurrentSong()
	if song == nil then
		return
	end
	local LastDifficulty = DDStats.GetStat(playerNum, 'LastDifficulty')
	local stepses = SongUtil.GetPlayableSteps(song)
	if #stepses == 0 then
		return
	end
	
	local minDifficultyDifference = 999
	local matchingSteps = nil
	
	local ChartIndexDiff = (difficultyToIndex[PlayerChart] - difficultyToIndex[targetDif])
	
	if ChartIndexDiff > 0 then
		EasierDifficulty = false
		HarderDifficulty = true
	elseif ChartIndexDiff < 0 then
		EasierDifficulty = true
		HarderDifficulty = false
	end
	
	for steps in ivalues(stepses) do
		local difficultyDifference = math.abs(difficultyToIndex[steps:GetDifficulty()] - difficultyToIndex[targetDif])
			
		if difficultyDifference < minDifficultyDifference and steps:GetDifficulty() == targetDif and steps:GetDifficulty() ~= PlayerChartDif then
			minDifficultyDifference = difficultyDifference
			matchingSteps = steps
		end
		if steps:GetDifficulty() == PlayerChartDif and LastDifficulty ~= PlayerChartDif then
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
				DDStats.SetStat(PLAYER_1, 'LastDifficulty', PlayerOneChart:GetDifficulty())
				DDStats.Save(PLAYER_1)
			end
			
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)
				DDStats.SetStat(PLAYER_2, 'LastDifficulty', PlayerTwoChart:GetDifficulty())
				DDStats.Save(PLAYER_2)
			end
		end
	end
	
	if matchingSteps ~= nil then
		SetChart(playerNum, matchingSteps)
		if EasierDifficulty then
			SOUND:PlayOnce( THEME:GetPathS("", "_easier.ogg") )
		elseif HarderDifficulty then
			SOUND:PlayOnce( THEME:GetPathS("", "_harder.ogg") )
		end
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
			DDStats.SetStat(PLAYER_1, 'LastDifficulty', PlayerOneChart:GetDifficulty())
			DDStats.Save(PLAYER_1)
		end
		
		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)
			DDStats.SetStat(PLAYER_2, 'LastDifficulty', PlayerTwoChart:GetDifficulty())
			DDStats.Save(PLAYER_2)
		end
		return
	end
	
end

local function UpdateChart(playerNum, difficultyChange)
	local song = GAMESTATE:GetCurrentSong()
	if song == nil then
		return
	end

	local stepses = SongUtil.GetPlayableSteps(song)
	if #stepses == 0 then
		return
	end

	-- If we're sorted by difficulty and difficultyChange == 0,
	-- try to keep the same meter
	if difficultyChange == 0 then
		if GetMainSortPreference() == 6 then
			local targetDifficulty
			local targetMeter = NameOfGroup
			
			if DDStats.GetStat(playerNum, 'LastDifficulty') ~= nil then
				targetDifficulty = DDStats.GetStat(playerNum, 'LastDifficulty')
			end

			local oldDifficulty = difficulties[curDifficultyIndices[playerNum]];
			local matchingSteps = nil
			-- Check for meter AND difficulty match
			for steps in ivalues(stepses) do
				-- first check to see if the last selected difficulty is the correct meter.
				if targetDifficulty ~= nil then
					if GetStepsDifficultyGroup(steps) == targetMeter and steps:GetDifficulty() == targetDifficulty then
						matchingSteps = steps
						break
					end
				-- if it's not, default to the first chart in the index that matches.
				elseif GetStepsDifficultyGroup(steps) == targetMeter and steps:GetDifficulty() == oldDifficulty then
					matchingSteps = steps
					break
				end
			end

			if matchingSteps == nil then
				for steps in ivalues(stepses) do
					if GetStepsDifficultyGroup(steps) == targetMeter then
						matchingSteps = steps
						break
					end
				end
			end

			if matchingSteps ~= nil then
				SetChart(playerNum, matchingSteps)
				return
			end
		elseif DDStats.GetStat(playerNum, 'LastDifficulty') ~= nil then 	--- Remember the last difficulty manually selected by the player and pick that, but only if they have a profile already).
			local targetDifficulty = DDStats.GetStat(playerNum, 'LastDifficulty')
			local minDifficultyDifference = 999
			local matchingSteps = nil
			
			for steps in ivalues(stepses) do
				local difficultyDifference = math.abs(difficultyToIndex[steps:GetDifficulty()] - difficultyToIndex[targetDifficulty])

				if difficultyDifference < minDifficultyDifference then
					minDifficultyDifference = difficultyDifference
					matchingSteps = steps
				end
			end

			if matchingSteps ~= nil then
				SetChart(playerNum, matchingSteps)
				return
			end
			
		end
	end

	local oldDifficultyIndex = curDifficultyIndices[playerNum]

	if oldDifficultyIndex == nil then
		oldDifficultyIndex = GetStartingDifficultyIndex(playerNum)
	end

	local selectedSteps = nil

	local editCount = 0

	for steps in ivalues(stepses) do
		local stepsDifficulty = steps:GetDifficulty()
		local stepsDifficultyIndex = difficultyToIndex[stepsDifficulty]

		if stepsDifficulty == 'Difficulty_Edit' then
			stepsDifficultyIndex = stepsDifficultyIndex + editCount
			editCount = editCount + 1
		end

		if difficultyChange > 0 then
			isValid = stepsDifficultyIndex > oldDifficultyIndex
		elseif difficultyChange < 0 then
			isValid = stepsDifficultyIndex < oldDifficultyIndex
		else
			isValid = true
		end
		if isValid then
			if selectedSteps == nil then
				selectedSteps = steps
			else
				local selectedDifficultyIndex = difficultyToIndex[selectedSteps:GetDifficulty()]
				local selectedDifference = math.abs(selectedDifficultyIndex-oldDifficultyIndex)
				local stepsDifference = math.abs(stepsDifficultyIndex-oldDifficultyIndex)

				if stepsDifference < selectedDifference then
					selectedSteps = steps
				end
			end
		end
	end

	if selectedSteps ~= nil then
		if EasierDifficulty then
			SOUND:PlayOnce( THEME:GetPathS("", "_easier.ogg") )
		elseif HarderDifficulty then
			SOUND:PlayOnce( THEME:GetPathS("", "_harder.ogg") )
		end
		SetChart(playerNum, selectedSteps)
		if difficultyChange > 0 or difficultyChange < 0 then
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
				DDStats.SetStat(PLAYER_1, 'LastDifficulty', PlayerOneChart:GetDifficulty())
				DDStats.Save(PLAYER_1)
			end
			
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)
				DDStats.SetStat(PLAYER_2, 'LastDifficulty', PlayerTwoChart:GetDifficulty())
				DDStats.Save(PLAYER_2)
			end
		end
		
	end
end


return {
	UpdateCharts=function()
		for _, playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
			EasierDifficulty = false
			HarderDifficulty = false
			UpdateChart(playerNum, 0)
		end
	end,
	IncreaseDifficulty=function(playerNum)
		EasierDifficulty = true
		HarderDifficulty = false
		UpdateChart(playerNum, 1)
	end,
	DecreaseDifficulty=function(playerNum)
		EasierDifficulty = false
		HarderDifficulty = true
		UpdateChart(playerNum, -1)
	end,
	ClickDifficulty=function(playerNum, targetDif)
		local PlayerChart = GAMESTATE:GetCurrentSteps(playerNum):GetDifficulty()
		
		if PlayerChart == targetDif then return end

		-- This only works if the chart has one edit, if it has multiple edit charts this does not work as intended.
		--(neither does the normal input for difficulty select for that matter)
		if PlayerChart == "Difficulty_Edit" then
			if targetDif == "Difficulty_Challenge" then
				targetDif = "Difficulty_Edit"
			elseif targetDif == "Difficulty_Hard" then
				targetDif = "Difficulty_Challenge"
			elseif targetDif == "Difficulty_Medium" then
				targetDif = "Difficulty_Hard"
			elseif targetDif == "Difficulty_Easy" then
				targetDif = "Difficulty_Medium"
			elseif targetDif == "Difficulty_Beginner" then
				targetDif = "Difficulty_Easy"
			end
		end
		
		UpdateChartClick(playerNum, targetDif, PlayerChart)
	end,
}