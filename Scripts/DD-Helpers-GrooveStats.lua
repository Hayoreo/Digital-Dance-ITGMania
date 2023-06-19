-- -----------------------------------------------------------------------
-- Returns an actor that can write a request, wait for its response, and then
-- perform some action. This actor will only wait for one response at a time.
-- If we make a new request while we are already waiting on a response, we
-- will ignore the response received from the previous request and wait for the
-- new response. 
--
-- Usage:
-- af[#af+1] = RequestResponseActor("GetScores", 10)
--
-- Which can then be triggered by:
--
-- af[#af+1] = Def.Actor{
--   OnCommand=function(self)
--     MESSAGEMAN:Broadcast("GetScores", {
--       data={..},
--       args={..},
--       callback=function(data, args)
--         SCREENMAN:SystemMessage(tostring(data)..tostring(args))
--       end
--     })
--   end
--  }
-- (The OnCommand can be concatenated to the returned actor itself.)

-- The params in the MESSAGEMAN:Broadcast() call must have the following:
-- data: A table that can be converted to JSON that will contains the
--       information for the request
-- args: Arguments that will be made accesible to the callback function. This
--       can of any type as long as the callback knows what to do with it.
-- callback: A function that processes the response. It must take at least two
--       parameters:
--           data: The JSON response which has been converted back to a lua table
--           args: The same args as listed above.
--       If data is nil then that means the request has timed out and can be
--       processed by the callback accordingly.

-- name: A name that will trigger the request for this actor.
--       It should generally be unique for each actor of this type.
-- timeout: A positive number in seconds between [1.0, 59.0] inclusive. It must
--       be less than 60 seconds as responses are expected to be cleaned up
--       by the launcher by then.

--    x: The x position of the loading spinner.
--    y: The y position of the loading spinner.
RequestResponseActor = function(name, timeout, x, y, zoom)
	-- Sanitize the timeout value.
	local timeout = clamp(timeout, 1.0, 59.0)
	local path_prefix = "/Save/GrooveStats/"

	return Def.ActorFrame{
		InitCommand=function(self)
			if not GAMESTATE:IsCourseMode() then
				self.request_id = nil
				self.request_time = nil
				self.args = nil
				self.callback = nil
				self:xy(x, y)
			else end
		end,
		WaitCommand=function(self)
			local Reset = function(self)
				self.request_id = nil
				self.request_time = nil
				self.args = nil
				self.callback = nil
				self:GetChild("Spinner"):visible(false)
			end
			local now = GetTimeSinceStart()
			local remaining_time = timeout - (now - self.request_time)
			-- Only display the spinner after we've waiting for some amount of time.
			if self.request_id ~= "ping" then
				-- Tell the spinner how much remaining time there is.
				self:playcommand("UpdateSpinner", {time=remaining_time})
			end
			
			-- We're waiting on a response.
			if self.request_id ~= nil then
				local f = RageFileUtil.CreateRageFile()
				-- Check to see if the response file was written.
				if f:Open(path_prefix.."responses/"..self.request_id..".json", 1) then
					local json_str = f:Read()
					local data = {}
					if #json_str ~= 0 then
						data = json.decode(json_str)
					end
					self.callback(data, self.args)
					f:Close()
					Reset(self)
				-- Have we timed out?
				elseif remaining_time < 0 then
					self.callback(nil, self.args)
					Reset(self)
				end
				f:destroy()
			end

			-- If the id wasn't reset, then we're still waiting. Loop again.
			if self.request_id ~= nil then
				self:sleep(0.5):queuecommand('Wait')
			end
		end,
		[name .. "MessageCommand"]=function(self, params)
			if not SL.GrooveStats.Launcher and params.data["action"] ~= "ping" then return end
			local id = nil
			-- We don't want to generate a bunch of files if they will never get processed.
			-- Specifically for the ping action, we will use a predetermined id.
			if params.data["action"] == "ping" then
				id = "ping"
			else
				id = CRYPTMAN:GenerateRandomUUID()
			end

			local f = RageFileUtil:CreateRageFile()
			if f:Open(path_prefix .. "requests/".. id .. ".json", 2) then
				f:Write(json.encode(params.data))
				f:Close()

				self:stoptweening()
				self.request_id = id
				self.request_time = GetTimeSinceStart()
				self.args = params.args
				self.callback = params.callback
				
				self:GetChild("Spinner"):visible(false)
				self:sleep(0.1):queuecommand('Wait')
			end
			f:destroy()
		end,

		Def.ActorFrame{
			Name="Spinner",
			InitCommand=function(self)
				self:visible(false)
			end,
			UpdateSpinnerCommand=function(self)
				if SL.GrooveStats.Launcher then
					self:visible(true)
				else
					self:visible(false)
				end
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("", "LoadingSpinner 10x3.png"),
				Frames=Sprite.LinearFrames(30,1),
				InitCommand=function(self)
					self:zoom(0.15)
				end
			},
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:zoom(0.9) end,
				UpdateSpinnerCommand=function(self, params)
					-- Only display the countdown after we've waiting for some amount of time.
					if timeout - params.time > 2 then
						self:visible(true)
					else
						self:visible(false)
					end
					if params.time > 1 then
						self:settext(math.floor(params.time))
					end
				end
			}
		},
	}
end

-- -----------------------------------------------------------------------
-- Sets the API key for a player if it's found in their profile.

ParseGrooveStatsIni = function(player)
	if not player then return "" end

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	if not profile_slot[player] then return "" end

	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local pn = ToEnumShortString(player)
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return "" end

	local path = dir.. "GrooveStats.ini"

	if not FILEMAN:DoesFileExist(path) then
		-- The file doesn't exist. We will create it for this profile, and then just return.
		IniFile.WriteFile(path, {
			["GrooveStats"]={
				["ApiKey"]="",
				["IsPadPlayer"]=0,
			}
		})
	else
		local contents = IniFile.ReadFile(path)
		for k,v in pairs(contents["GrooveStats"]) do
			if k == "ApiKey" then
				if #v ~= 64 then
					-- Print the error only if the ApiKey is non-empty.
					if #v ~= 0 then
						SM(ToEnumShortString(player).." has invalid ApiKey length!")
					end
					SL[pn].ApiKey = ""
				else
					SL[pn].ApiKey = v
				end
			elseif k == "IsPadPlayer" then
				-- Must be explicitly set to 1.
				if v == 1 then
					SL[pn].IsPadPlayer = true
				else
					SL[pn].IsPadPlayer = false
				end
			end
		end
	end
end

-- -----------------------------------------------------------------------
-- The common conditions required to use the GrooveStats services.
-- Currently the conditions are:
--  - We must be in the "dance" game mode (not "pump", etc)
--  - We must be in either ITG or FA+ mode.
--  - At least one Api Key must be available (this condition may be relaxed in the future)
--  - We must not be in course mode.
IsServiceAllowed = function(condition)
	return (condition and
		GAMESTATE:GetCurrentGame():GetName()=="dance" and
		(SL.P1.ApiKey ~= "" or SL.P2.ApiKey ~= "") and
		not GAMESTATE:IsCourseMode())
end

-- -----------------------------------------------------------------------
-- ValidForGrooveStats.lua contains various checks requested by Archi
-- to determine whether the score should be permitted on GrooveStats
-- and returns a table of booleans, one per check, and also a bool
-- indicating whether all the checks were satisfied or not.
--
-- Obviously, this is trivial to circumvent and not meant to keep
-- malicious users out of GrooveStats. It is intended to prevent
-- well-intentioned-but-unaware players from accidentally submitting
-- invalid scores to GrooveStats.
ValidForGrooveStats = function(player)
	local valid = {}

	-- ------------------------------------------
	-- First, check for modes not supported by GrooveStats.

	-- GrooveStats only supports dance for now (not pump, techno, etc.)
	valid[1] = GAMESTATE:GetCurrentGame():GetName() == "dance"

	-- GrooveStats does not support dance-solo (i.e. 6-panel dance like DDR Solo 4th Mix)
	-- https://en.wikipedia.org/wiki/Dance_Dance_Revolution_Solo
	valid[2] = GAMESTATE:GetCurrentStyle():GetName() ~= "solo"

	-- GrooveStats actually does rank Marathons from ITG1, ITG2, and ITG Home
	-- but there isn't QR support at this time.
	valid[3] = not GAMESTATE:IsCourseMode()

	-- GrooveStats was made with ITG settings in mind.
	-- FA+ is okay because it just halves ITG's TimingWindowW1 but keeps everything else the same.
	-- Casual (and Experimental, Demonic, etc.) uses different settings
	-- that are incompatible with GrooveStats ranking.
	valid[4] = (SL.Global.GameMode == "DD")

	-- ------------------------------------------
	-- Next, check global Preferences that would invalidate the score.

	-- TimingWindowScale and LifeDifficultyScale are a little confusing. Players can change these under
	-- Advanced Options in the operator menu on scales from [1 to Justice] and [1 to 7], respectively.
	--
	-- The OptionRow for TimingWindowScale offers [1, 2, 3, 4, 5, 6, 7, 8, Justice] as options
	-- and these map to [1.5, 1.33, 1.16, 1, 0.84, 0.66, 0.5, 0.33, 0.2] in Preferences.ini for internal use.
	--
	-- The OptionRow for LifeDifficultyScale offers [1, 2, 3, 4, 5, 6, 7] as options
	-- and these map to [1.6, 1.4, 1.2, 1, 0.8, 0.6, 0.4] in Preferences.ini for internal use.
	--
	-- I don't know the history here, but I suspect these preferences are holdovers from SM3.9 when
	-- themes were just visual skins and core mechanics like TimingWindows and Life scaling could only
	-- be handled by the SM engine.  Whatever the case, they're still exposed as options in the
	-- operator menu and players still play around with them, so we need to handle that here.
	--
	-- 4 (1, internally) is considered standard for ITG.
	-- GrooveStats expects players to have both these set to 4 (1, internally).
	--
	-- People can probably use some combination of LifeDifficultyScale,
	-- TimingWindowScale, and TimingWindowAdd to probably match up with ITG's windows, but that's a
	-- bit cumbersome to handle so just requre TimingWindowScale and LifeDifficultyScale these to be set
	-- to 4.
	
	-- There's no point in disqualfying a player for using harsher timing and/or lifebar mechanics than stock ITG. It's harder man.
	valid[5] = PREFSMAN:GetPreference("TimingWindowScale") <= 1
	valid[6] = PREFSMAN:GetPreference("LifeDifficultyScale") <= 1

	-- Validate all other metrics.
	local ExpectedTWA = 0.0015
	local ExpectedWindows = {
		0.021500 + ExpectedTWA,  -- Fantastics
		0.043000 + ExpectedTWA,  -- Excellents
		0.102000 + ExpectedTWA,  -- Greats
		0.135000 + ExpectedTWA,  -- Decents
		0.180000 + ExpectedTWA,  -- Way Offs
		0.320000 + ExpectedTWA,  -- Holds
		0.070000 + ExpectedTWA,  -- Mines
		0.350000 + ExpectedTWA,  -- Rolls
	}
	local TimingWindows = { "W1", "W2", "W3", "W4", "W5", "Hold", "Mine", "Roll" }
	local ExpectedLife = {
		 0.008,  -- Fantastics
		 0.008,  -- Excellents
		 0.004,  -- Greats
		 0.000,  -- Decents
		-0.050,  -- Way Offs
		-0.100,  -- Miss
		-0.080,  -- Let Go
		 0.008,  -- Held
		-0.050,  -- Hit Mine
	}
	local LifeWindows = { "W1", "W2", "W3", "W4", "W5", "Miss", "LetGo", "Held", "HitMine" }

	-- Originally verify the ComboToRegainLife metrics.
	valid[7] = (PREFSMAN:GetPreference("RegenComboAfterMiss") == 5 and PREFSMAN:GetPreference("MaxRegenComboAfterMiss") == 10)

	local FloatEquals = function(a, b)
		return math.abs(a-b) < 0.0001
	end

	valid[7] = valid[7] and FloatEquals(THEME:GetMetric("LifeMeterBar", "InitialValue"), 0.5)
	valid[7] = valid[7] and PREFSMAN:GetPreference("HarshHotLifePenalty")

	-- And then verify the windows themselves.
	local TWA = PREFSMAN:GetPreference("TimingWindowAdd")
	for i, window in ipairs(TimingWindows) do
		-- Only check if the Timing Window is actually "enabled".
		valid[7] = valid[7] and FloatEquals(PREFSMAN:GetPreference("TimingWindowSeconds"..window) + TWA, ExpectedWindows[i])
	end

	for i, window in ipairs(LifeWindows) do
		valid[7] = valid[7] and FloatEquals(THEME:GetMetric("LifeMeterBar", "LifePercentChange"..window), ExpectedLife[i])
	end


	-- Validate Rate Mod
	local rate = SL.Global.ActiveModifiers.MusicRate * 100
	valid[8] = 100 <= rate


	-- ------------------------------------------
	-- Finally, check player-specific modifiers used during this song that would invalidate the score.

	-- get playeroptions so we can check mods the player used
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")


	-- score is invalid if notes were removed
	valid[9] = not (
		po:Little()  or po:NoHolds() or po:NoStretch()
		or po:NoHands() or po:NoJumps() or po:NoFakes()
		or po:NoLifts() or po:NoQuads() or po:NoRolls()
	)

	-- score is invalid if notes were added
	valid[10] = not (
		po:Wide() or po:Skippy() or po:Quick()
		or po:Echo() or po:BMRize() or po:Stomp()
		or po:Big()
	)

	-- only FailTypes "Immediate" and "ImmediateContinue" are valid for GrooveStats
	valid[11] = (po:FailSetting() == "FailType_Immediate" or po:FailSetting() == "FailType_ImmediateContinue")

	-- AutoPlay/AutoplayCPU is not allowed
	valid[12] = IsHumanPlayer(player)
	
	local minTNSToScoreNores = ToEnumShortString(PREFSMAN:GetPreference("MinTNSToScoreNotes"))

	valid[13] = minTNSToScoreNores ~= "W1" and minTNSToScoreNores ~= "W2"
	
	-- ------------------------------------------
	-- return the entire table so that we can let the player know which settings,
	-- if any, prevented their score from being valid for GrooveStats

	local allChecksValid = true
	for _, passed_check in ipairs(valid) do
		if not passed_check then allChecksValid = false break end
	end

	return valid, allChecksValid
end

-- -----------------------------------------------------------------------

CreateCommentString = function(player)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local isQuint = false
	local isQuad = true

	local suffixes = {"w", "e", "g", "d", "wo"}

	local comment = ""

	local rate = SL.Global.ActiveModifiers.MusicRate
	if rate ~= 1 then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment..("%gx Rate"):format(rate)
	end

	-- Ignore the top window in all cases.
	
	--- First deal with FA+ white counts (if enabled)
	local sl_pn = SL[ToEnumShortString(player)]
	local mods = sl_pn.ActiveModifiers
	
	if mods.ShowFaPlusWindow or mods.ShowEXScore then
		local FAsuffix = "w"
		local counts =  GetExJudgmentCounts(player)
		local WNumber = counts["W1"]
		
		if WNumber ~= 0 then
			if #comment ~= 0 then
				comment = comment .. ", "
			end
			comment = comment..WNumber..FAsuffix
		elseif WNumber == 0 then
			IsQuint = true
		end
	end
	
	--- for all other judgements
	for i=2, 6 do
		local idx = i
		local suffix = i == 6 and "m" or suffixes[idx]
		local tns = i == 6 and "TapNoteScore_Miss" or "TapNoteScore_W"..i
		
		local number = pss:GetTapNoteScores(tns)

		if number ~= 0 then
			if #comment ~= 0 then
				comment = comment .. ", "
			end
			IsQuad = false
			comment = comment..number..suffix
		end
	end
	
	--If the player got a quint, first of all nice, but let other people know here.
	if IsQuint and IsQuad then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."Quint"
	elseif IsQuad and not IsQuint then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."FFC"
	end
	
	local pn = ToEnumShortString(player)
	-- If a player CModded or MModded, then add that as well.
	local cmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod()
	local mmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):MMod()
	
	if cmod ~= nil then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."C"..tostring(cmod)
	elseif mmod ~= nil then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."M"..tostring(mmod)
	end
	
	-- Show the EX Score if FA+ or EX Score tracking is enabled.
	if mods.ShowFaPlusWindow or mods.ShowEXScore then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		local EXScore = ("%.2f"):format(CalculateExScore(player))
		comment = comment.."EX Score: "..EXScore.."%"
	end
	
	-- Show that the score was untied when set if personal rank is 1
	if IsUntiedWR then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."Untied WR when set."
	end
	
	--Justin Case
	if #comment == 0 then
		comment = "yea"
	end

	return comment
end

-- -----------------------------------------------------------------------

ParseGroovestatsDate = function(date)
	if not date or #date == 0 then return "" end

	-- Dates are formatted like:
	-- YYYY-MM-DD HH:MM:SS
	local year, month, day, hour, min, sec = date:match("([%d]+)-([%d]+)-([%d]+) ([%d]+):([%d]+):([%d]+)")
	local monthMap = {
		["01"] = "Jan",
		["02"] = "Feb",
		["03"] = "Mar",
		["04"] = "Apr",
		["05"] = "May",
		["06"] = "Jun",
		["07"] = "Jul",
		["08"] = "Aug",
		["09"] = "Sep",
		["10"] = "Oct",
		["11"] = "Nov",
		["12"] = "Dec",
	}

	return monthMap[month].." "..tonumber(day)..", "..year
end

-- -----------------------------------------------------------------------
-- Iterates over the RequestCache and removes those entries that are older
-- than a certain amount of time.
RemoveStaleCachedRequests = function()
	local timeout = 1 * 60  -- One minute
	for requestCacheKey, data in pairs(SL.GrooveStats.RequestCache) do
		if GetTimeSinceStart() - data.Timestamp >= timeout then
			SL.GrooveStats.RequestCache[requestCacheKey] = nil
		end
	end
end

