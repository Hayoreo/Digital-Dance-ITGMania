-- -----------------------------------------------------------------------
IsItlSong = function(player)
	local song = GAMESTATE:GetCurrentSong()
	local song_dir = song:GetSongDir()
	local group = string.lower(song:GetGroupName())
	local pn = ToEnumShortString(player)
	return string.find(group, "itl online 2025") or string.find(group, "itl 2025") or SL[pn].ITLData["pathMap"][song_dir] ~= nil
end


IsItlActive = function()
	-- The file is only written to while the event is active.
	-- These are just placeholder dates.
	-- local startTimestamp = 20230317
	-- local endTimestamp = 20240420

	-- local year = Year()
	-- local month = MonthOfYear()+1
	-- local day = DayOfMonth()
	-- local today = year * 10000 + month * 100 + day

	-- return startTimestamp <= today and today <= endTimestamp

	-- Assume ITL is always active. This helps when we close and reopen the event.
	return true
end


-- -----------------------------------------------------------------------
-- The ITL file is a JSON file that contains two mappings:
--
-- {
--    pathMap = {
--      '<song_dir>': '<song_hash>',
--    },
--    hashMap = {
--      '<song_hash': { ..itl metadata .. }
--    }
-- }
--
-- The pathMap maps a song directory corresponding to an ITL chart to its song hash
-- The hashMap is a mapping from that hash to the relevant data stored for the event.
--
-- This set up lets us display song wheel grades for ITL both from playing within the
-- ITL pack and also outside of it.
-- Note that songs resynced for ITL but played outside of the pack will not be covered in the pathMap.
local itlFilePath = "itl2025.json"

local TableContainsData = function(t)
	if t == nil then return false end

	for _, _ in pairs(t) do
			return true
	end
	return false
end

-- Takes the ITLData loaded in memory and writes it to the local profile.
WriteItlFile = function(player)
	local pn = ToEnumShortString(player)
	-- No data to write, return early.
	if (not TableContainsData(SL[pn].ITLData["pathMap"]) and
			not TableContainsData(SL[pn].ITLData["hashMap"])) then
		return
	end

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return end

	local path = dir .. itlFilePath
	local f = RageFileUtil:CreateRageFile()

	if f:Open(path, 2) then
		f:Write(JsonEncode(SL[pn].ITLData))
		f:Close()
	end
	f:destroy()
end

-- EX score is a number like 92.67
local GetPointsForSong = function(maxPoints, exScore)
	local thresholdEx = 50.0
	local percentPoints = 40.0

	-- Helper function to take the logarithm with a specific base.
	local logn = function(x, y)
		return math.log(x) / math.log(y)
	end

	-- The first half (logarithmic portion) of the scoring curve.
	local first = logn(
		math.min(exScore, thresholdEx) + 1,
		math.pow(thresholdEx + 1, 1 / percentPoints)
	)

	-- The seconf half (exponential portion) of the scoring curve.
	local second = math.pow(
		100 - percentPoints + 1,
		math.max(0, exScore - thresholdEx) / (100 - thresholdEx)
	) - 1

	-- Helper function to round to a specific number of decimal places.
	-- We want 100% EX to actually grant 100% of the points.
	-- We don't want to  lose out on any single points if possible. E.g. If
	-- 100% EX returns a number like 0.9999999999999997 and the chart points is
	-- 6500, then 6500 * 0.9999999999999997 = 6499.99999999999805, where
	-- flooring would give us 6499 which is wrong.
	local roundPlaces = function(x, places)
		local factor = 10 ^ places
		return math.floor(x * factor + 0.5) / factor
	end

	local percent = roundPlaces((first + second) / 100.0, 6)
	return math.floor(maxPoints * percent)
end

-- Generally to be called only once when a profile is loaded.
-- This parses the ITL data file and stores it in memory for the song wheel to reference.
ReadItlFile = function(player)
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local pn = ToEnumShortString(player)
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return end

	local path = dir .. itlFilePath
	local itlData = { 
		["pathMap"] = {},
		["hashMap"] = {},
	}
	if FILEMAN:DoesFileExist(path) then
		local f = RageFileUtil:CreateRageFile()
		local existing = ""
		if f:Open(path, 1) then
			existing = f:Read()
			f:Close()
		end
		f:destroy()
		itlData = JsonDecode(existing)
	end
	
	SL[pn].ITLData = itlData
end

-- EX score is a number like 92.67
-- NOTE: This function is not accurate for ITL 2025.
GetITLPointsForSong = function(passingPoints, maxScoringPoints, exScore)
	local scalar = 40.0
	local curve = (math.pow(scalar, math.max(0, exScore) / scalar) - 1) * (100.0 / (math.pow(scalar, 100 / scalar) - 1.0))
	
	-- Helper function to round to a specific number of decimal places.
	-- We want 100% EX to actually grant 100% of the points.
	-- We don't want to  lose out on any single points if possible. E.g. If
	-- 100% EX returns a number like 0.9999999999999997 and the chart points is
	-- 6500, then 6500 * 0.9999999999999997 = 6499.99999999999805, where
	-- flooring would give us 6499 which is wrong.
	local roundPlaces = function(x, places)
		local factor = 10 ^ places
		return math.floor(x * factor + 0.5) / factor
	end

	local percent = roundPlaces(curve / 100.0, 6)
	local scoringPoints = math.floor(maxScoringPoints * percent)
	return passingPoints + scoringPoints
end

-- Note that playing OUTSIDE of the ITL pack will result in 0 points for all upscores.
-- Technically this number isn't displayed, but players can opt to swap the EX score in the
-- wheel with this value instead if they prefer.
local function ParseNumbers(input)
	local num1, num2 = input:match("(%d+)%s+%(P%)%s+%+%s+(%d+)%s+%(S%)")
	return tonumber(num1) or nil, tonumber(num2) or nil
end
-- Helper function used within UpdateItlData() below.
-- Curates all the ITL data to be written to the ITL file for the played song.
local DataForSong = function(player, prevData)
	local GetClearType = function(judgments)
		-- 1 = Pass
		-- 2 = FGC
		-- 3 = FEC
		-- 4 = FFC
		-- 5 = FFPC
		local clearType = 1

		-- Dropping a hold or roll will always be a Pass
		local droppedHolds = judgments["totalRolls"] - judgments["Rolls"]
		local droppedRolls = (judgments["totalHolds"] - judgments["Holds"])
		if droppedHolds > 0 or droppedRolls > 0 then
			return 1
		end

		local totalTaps = judgments["Miss"]

		if judgments["W5"] ~= nil then
			totalTaps = totalTaps + judgments["W5"]
		end

		if judgments["W4"] ~= nil then
			totalTaps = totalTaps + judgments["W4"]
		end

		if totalTaps == 0 then clearType = 2 end

		totalTaps = totalTaps + judgments["W3"]
		if totalTaps == 0 then clearType = 3 end

		totalTaps = totalTaps + judgments["W2"]
		if totalTaps == 0 then clearType = 4 end

		totalTaps = totalTaps + judgments["W1"]
		if totalTaps == 0 then clearType = 5 end

		return clearType
	end

	local pn = ToEnumShortString(player)

	local steps = GAMESTATE:GetCurrentSteps(player)
	local chartName = steps:GetChartName()

	
	local passingPoints, maxScoringPoints = ParseNumbers(chartName)
	
	if passingPoints == nil then
		-- See if we already have these points stored if we failed to parse it.
		if prevData ~= nil and prevData["passingPoints"] ~= nil then
			passingPoints = prevData["passingPoints"]
		-- Otherwise we don't know how many points this chart is. Default to 0.
		else
			passingPoints = 0
		end
	end
	
	if maxScoringPoints == nil then
		-- See if we already have these points stored if we failed to parse it.
		if prevData ~= nil and prevData["maxScoringPoints"] ~= nil then
			maxScoringPoints = prevData["maxScoringPoints"]
		-- Otherwise we don't know how many points this chart is. Default to 0.
		else
			maxScoringPoints = 0
		end
	end
	local maxPoints = passingPoints + maxScoringPoints
	
	-- Assume C-Mod is okay by default.
	local noCmod = false

	if prevData == nil or prevData["noCmod"] == nil then
		-- If we have no prior play data data for this ITL song, or the noCmod bit hasn't been
		-- calculated, parse the subtitle to see if this chart explicitly calls for noCmod.
		local song = GAMESTATE:GetCurrentSong()
		local subtitle = song:GetDisplaySubTitle():lower()
		if string.find(subtitle, "no cmod") then
			noCmod = true
		end
	else
		-- If the bit exists then read it from the previous data.
		-- My boy De Morgan says the below condition is the exact same as the else but my
		-- computer brain is tired and I just want to make sure.
		if prevData ~= nil and prevData["noCmod"] ~= nil then
			noCmod = prevData["noCmod"]
		end
	end
	
	local year = Year()
	local month = MonthOfYear()+1
	local day = DayOfMonth()

	local judgments = GetExJudgmentCounts(player)
	local ex = CalculateExScore(player)
	local clearType = GetClearType(judgments)
	local points = GetITLPointsForSong(passingPoints, maxScoringPoints, ex)
	local usedCmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() ~= nil
	local date = ("%04d-%02d-%02d"):format(year, month, day)
	
	return {
		["judgments"] = judgments,
		["ex"] = ex * 100,
		["clearType"] = clearType,
		["points"] = points,
		["usedCmod"] = usedCmod,
		["date"] = date,
		["noCmod"] = noCmod,
		["passingPoints"] = passingPoints,
		["maxScoringPoints"] = maxScoringPoints,
		["maxPoints"] = maxPoints,
	}
end

-- Calculate Song Ranks
CalculateITLSongRanks = function(player)
	local pn = ToEnumShortString(player)
	
	-- Grab data from memory
	itlData = SL[pn].ITLData
	local songHashes = itlData["hashMap"]

	--TODO: delete this once it's confirmed working
	-- Create and populate tables to rank each hash score	
	local points = {}
	local songPoints = {}
	for key in pairs(songHashes) do
		songPoints[key] = songHashes[key]["points"]
		table.insert(points,songHashes[key]["points"])
	end		 
	-- Reverse sort points values
	table.sort(points,function(a,b) return a > b end)

	for key in pairs(songPoints) do
		local point = songPoints[key]
		-- search for the point value in the list
		for k, v in pairs(points) do
			if v == point then
				songHashes[key]["rank"] = k
				break
			end
		end		 	
	end
	itlData["hashMap"] = songHashes

	-- Write song scores sorted by point value descending into json
	itlData["points"] = points

	-- Create and populate tables to rank each hash score by stepsType
	local pointsSingle = {}
	local pointsDouble = {}
	
	local songPointsSingle = {}
	local songPointsDouble = {}
	for key in pairs(songHashes) do
		if songHashes[key]["stepsType"] == "single" then			
			songPointsSingle[key] = songHashes[key]["points"]
			table.insert(pointsSingle,songHashes[key]["points"])
		else -- don't need to specify doubles right? unless there will ITL Couples will become a thing lol
			songPointsDouble[key] = songHashes[key]["points"]
			table.insert(pointsDouble,songHashes[key]["points"])
		end
	end		 
	-- Reverse sort points values
	table.sort(pointsSingle,function(a,b) return a > b end)
	table.sort(pointsDouble,function(a,b) return a > b end)

	for k, v in pairs(pointsSingle) do
		for key in pairs(songHashes) do
			if songHashes[key]["stepsType"] == "single" and songHashes[key]["points"] == v then
				songHashes[key]["rank"] = k
				break
			end
		end
	end

	for k, v in pairs(pointsDouble) do
		for key in pairs(songHashes) do
			if songHashes[key]["stepsType"] == "double" and songHashes[key]["points"] == v then
				songHashes[key]["rank"] = k
				break
			end
		end
	end

	itlData["hashMap"] = songHashes

	-- Write song scores sorted by point value descending into json
	itlData["points"] = points

	itlData["pointsSingle"] = pointsSingle
	itlData["pointsDouble"] = pointsDouble

	-- Rewrite the data in memory
	SL[pn].ITLData = itlData
end

-- Quick function that overwrites EX score entry if the score found is higher than what is found locally
UpdateItlExScore = function(player, hash, exscore)
	local pn = ToEnumShortString(player)
	local hashMap = SL[pn].ITLData["hashMap"]
	if hashMap[hash] == nil then
		-- New score, just copy things over.
		local steps = GAMESTATE:GetCurrentSteps(player)

		hashMap[hash] = {
			["judgments"] = {},
			["ex"] = 0,
			["clearType"] = 1,
			["points"] = 0,
			--["points"] = data["points"],
			["usedCmod"] = false,
			["date"] = "",
			["maxPoints"] = 0,
			["noCmod"] = false,
			--["passingPoints"] = data["passingPoints"],
			--["maxScoringPoints"] = data["maxScoringPoints"],
			--["maxPoints"] = data["maxPoints"],
			-- ITL has double now. populate the steps type of the song
			["stepsType"] = steps:GetStepsType() == "StepsType_Dance_Single" and "single" or "double",
		}
		
		updated = true
	end

	if exscore >= hashMap[hash]["ex"] or hashMap[hash]["points"] == 0 then
		hashMap[hash]["ex"] = exscore
		
		local steps = GAMESTATE:GetCurrentSteps(player)
		local chartName = steps:GetChartName()
		
		local passingPoints, maxScoringPoints = ParseNumbers(chartName)
		local maxPoints = passingPoints + maxScoringPoints
		hashMap[hash]["points"] = GetITLPointsForSong(passingPoints, maxScoringPoints, exscore/100)
		hashMap[hash]["maxPoints"] = maxPoints
		hashMap[hash]["passingPoints"] = passingPoints
		hashMap[hash]["maxScoringPoints"] = maxScoringPoints

		-- Update the pathMap as needed.
		local song = GAMESTATE:GetCurrentSong()
		local song_dir = song:GetSongDir()
		if song_dir ~= nil and #song_dir ~= 0 then
			local pathMap = SL[pn].ITLData["pathMap"]
			pathMap[song_dir] = hash
		end
		
		updated = true
		
		if updated then
			CalculateITLSongRanks(player)
			WriteItlFile(player)
		end
	end
end

-- Should be called during ScreenEvaluation to update the ITL data loaded.
-- Will also write the contents to the file.
UpdateItlData = function(player)
	local pn = ToEnumShortString(player)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		
	-- Do the same validation as GrooveStats.
	-- This checks important things like timing windows, addition/removal of arrows, etc.
	local _, valid = ValidForGrooveStats(player)

	-- ITL additionally requires the music rate to be 1.00x.
	local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
	local rate = so:MusicRate()

	-- We also require mines to be on.
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
	local minesEnabled = not po:NoMines()

	-- We also require all the windows to be enabled.
	-- DD mode is the only mode that has all the windows enabled by default. (it's also the only mode, but ya know).
	local allWindowsEnabled = SL.Global.GameMode == "DD"
	for enabled in ivalues(SL[pn].ActiveModifiers.TimingWindows) do
		allWindowsEnabled = allWindowsEnabled and enabled
	end

	if (GAMESTATE:IsHumanPlayer(player) and
				valid and
				rate == 1.0 and
				minesEnabled and
				not stats:GetFailed() and
				allWindowsEnabled) then
		local hash = SL[pn].Streams.Hash
		local hashMap = SL[pn].ITLData["hashMap"]
		local steps = GAMESTATE:GetCurrentSteps(player)
		local prevData = nil
		if hashMap ~= nil and hashMap[hash] ~= nil then
			prevData = hashMap[hash]
		end

		local data = DataForSong(player, prevData)
		-- C-Modded a No CMOD chart. Don't save this score.
		if data["noCmod"] and data["usedCmod"] then
			return
		end

		-- Update the pathMap as needed.
		local song = GAMESTATE:GetCurrentSong()
		local song_dir = song:GetSongDir()
		if song_dir ~= nil and #song_dir ~= 0 then
			local pathMap = SL[pn].ITLData["pathMap"]
			pathMap[song_dir] = hash
		end
		
		-- Then maybe update the hashMap.
		local updated = false
		if hashMap[hash] == nil then
			-- New score, just copy things over.
			hashMap[hash] = {
				["judgments"] = DeepCopy(data["judgments"]),
				["ex"] = data["ex"],
				["clearType"] = data["clearType"],
				["points"] = data["points"],
				["stepsType"] = steps:GetStepsType() == "StepsType_Dance_Single" and "single" or "double",
				["usedCmod"] = data["usedCmod"],
				["date"] = data["date"],
				["maxPoints"] = data["maxPoints"],
				["noCmod"] = data["noCmod"],
			}
			updated = true
		else
			if data["ex"] >= hashMap[hash]["ex"] then
				hashMap[hash]["ex"] = data["ex"]
				--hashMap[hash]["points"] = data["points"]
				
				if data["ex"] > hashMap[hash]["ex"] then
					-- EX count is strictly better, copy the judgments over.
					hashMap[hash]["judgments"] = DeepCopy(data["judgments"])
					updated = true
				else
					-- EX count is tied.
					-- "Smart" update judgment counts by picking the one with the highest top judgment.
					local better = false
					local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss" }
					for key in ivalues(keys) do
						local prev = hashMap[hash]["judgments"][key]
						local cur = data["judgments"][key]
						-- If both windows are defined, take the greater one.
						-- If current is defined but previous is not, then current is better.
						if (cur ~= nil and prev ~= nil and cur > prev) or (cur ~= nil and prev == nil) then
							better = true
							break
						end
					end

					if better then
						hashMap[hash]["judgments"] = DeepCopy(data["judgments"])
						updated = true
					end
				end
			end	

			if data["clearType"] > hashMap[hash]["clearType"] then
				hashMap[hash]["clearType"] = data["clearType"]
				updated = true
			end

			if updated then
				hashMap[hash]["usedCmod"] = data["usedCmod"]
				hashMap[hash]["stepsType"] = steps:GetStepsType() == "StepsType_Dance_Single" and "single" or "double"
				hashMap[hash]["date"] = data["date"]
				hashMap[hash]["noCmod"] = data["noCmod"]
				hashMap[hash]["passingPoints"] = data["passingPoints"]
				hashMap[hash]["maxScoringPoints"] = data["maxScoringPoints"]
				hashMap[hash]["maxPoints"] = data["maxPoints"]
				hashMap[hash]["points"] = data["points"]
				CalculateITLSongRanks(player)
			end
		end

		if updated then
			WriteItlFile(player)
		end
	end
end