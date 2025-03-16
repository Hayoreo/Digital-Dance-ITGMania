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
RequestResponseActor = function(x, y)
	local url_prefix = "https://api.groovestats.com/"

	return Def.ActorFrame{
		InitCommand=function(self)
			self.request_time = -1
			self.timeout = -1
			self.request_handler = nil
			self.leaving_screen = false
			self:xy(x, y)
		end,
		CancelCommand=function(self)
			self.leaving_screen = true
			-- Cancel the request if we pressed back on the screen.
			if self.request_handler then
				self.request_handler:Cancel()
				self.request_handler = nil
			end
		end,
		OffCommand=function(self)
			self.leaving_screen = true
			-- Cancel the request if this actor will be destructed soon.
			if self.request_handler then
				self.request_handler:Cancel()
				self.request_handler = nil
			end
		end,
		MakeGrooveStatsRequestCommand=function(self, params)
			self:stoptweening()
			if not params then
				Warn("No params specified for MakeGrooveStatsRequestCommand.")
				return
			end

			-- Cancel any existing requests if we're waiting on one at the moment.
			if self.request_handler then
				self.request_handler:Cancel()
				self.request_handler = nil
			end
			self:GetChild("Spinner"):visible(true)

			local timeout = params.timeout or 60
			local endpoint = params.endpoint or ""
			local method = params.method
			local body = params.body
			local headers = params.headers

			self.timeout = timeout

			-- Attempt to make the request
			self.request_handler = NETWORK:HttpRequest{
				url=url_prefix..endpoint,
				method=method,
				body=body,
				headers=headers,
				connectTimeout=timeout/2,
				transferTimeout=timeout/2,
				onResponse=function(response)
					self.request_handler = nil
					-- If we get a permanent error, make sure we "disconnect" from
					-- GrooveStats until we recheck on ScreenTitleMenu.
					if response.statusCode then
						local body = nil
						local code = response.statusCode
						if code == 200 then
							body = JsonDecode(response.body)
						end
						if (code >= 400 and code < 499 and code ~= 429) or (code == 200 and body and body.error and #body.error) then
							SL.GrooveStats.IsConnected = false
						end
					end

					if self.leaving_screen then
						return
					end
					
					if params.callback then
						if not response.error or ToEnumShortString(response.error) ~= "Cancelled" then
							params.callback(response, params.args)
						end
					end

					self:GetChild("Spinner"):visible(false)
				end,
			}
			-- Keep track of when we started making the request
			self.request_time = GetTimeSinceStart()
			-- Start looping for the spinner.
			self:queuecommand("GrooveStatsRequestLoop")
		end,
		GrooveStatsRequestLoopCommand=function(self)
			local now = GetTimeSinceStart()
			local remaining_time = self.timeout - (now - self.request_time)
			self:playcommand("UpdateSpinner", {
				timeout=self.timeout,
				remaining_time=remaining_time
			})
			-- Only loop if the request is still ongoing.
			-- The callback always resets the request_handler once its finished.
			if self.request_handler then
				self:sleep(0.5):queuecommand("GrooveStatsRequestLoop")
			end
		end,

		Def.ActorFrame{
			Name="Spinner",
			InitCommand=function(self)
				self:visible(false)
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("", "LoadingSpinner 10x3.png"),
				Frames=Sprite.LinearFrames(30,1),
				InitCommand=function(self)
					self:zoom(0.15)
					self:diffuse(GetHexColor(SL.Global.ActiveColorIndex, true))
				end,
				VisualStyleSelectedMessageCommand=function(self)
					self:diffuse(GetHexColor(SL.Global.ActiveColorIndex, true))
				end
			},
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					self:zoom(0.9)
					-- Leaderboard should be white since it's on a black background.
					self:diffuse(Color.White)
				end,
				UpdateSpinnerCommand=function(self, params)
					-- Only display the countdown after we've waiting for some amount of time.
					if params.timeout - params.remaining_time > 2 then
						self:visible(true)
					else
						self:visible(false)
					end
					if params.remaining_time > 1 then
						self:settext(math.floor(params.remaining_time))
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
		ThemePrefs.Get("EnableGrooveStats") and
		SL.GrooveStats.IsConnected and
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
	
	-- There's no point in disqualfying a player for using a harsher lifebar than stock ITG. It's harder man.
	valid[5] = PREFSMAN:GetPreference("TimingWindowScale") == 1
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
	
	local minTNSToScoreNotes = ToEnumShortString(PREFSMAN:GetPreference("MinTNSToScoreNotes"))

	valid[13] = minTNSToScoreNotes ~= "W1" and minTNSToScoreNotes ~= "W2"
	
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
	local isQuint = true
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
	
	if mods.ShowFaPlusWindow == true or mods.ShowEXScore == true then
		local FAsuffix = "w"
		local counts =  GetExJudgmentCounts(player)
		local WNumber = counts["W1"]
		
		if WNumber ~= 0 then
			if #comment ~= 0 then
				comment = comment .. ", "
			end
			comment = comment..WNumber..FAsuffix
			IsQuint = false
		end
	else
		isQuint = false
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
		comment = comment.."FBFC"
	elseif IsQuad and not IsQuint then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."FFC"
	end
	
	local pn = ToEnumShortString(player)
	-- Show player's scroll speed
	local cmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod()
	local mmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):MMod()
	local xmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):XMod()
	
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
	elseif xmod ~= nil then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment..tostring(xmod).."x"
	end
	
	-- Show the EX Score if FA+ or EX Score tracking is enabled.
	if mods.ShowFaPlusWindow or mods.ShowEXScore then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		local EXScore = ("%.2f"):format(CalculateExScore(player))
		comment = comment.."EX Score: "..EXScore
	end
	
	-- Let's show if people are playing with Early Rescores on or not.
	if ThemePrefs.Get("RescoreEarlyHits") then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."Early Rescores enabled"
	end
	
	--- This currently doesn't work, I probably need to completely change the structure of the Autosubmit code.
	-- Show that the score was untied when set if personal rank is 1
	--[[if IsUntiedWR then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."Untied WR when set."
	end--]]
	
	--Justin Case
	if #comment == 0 then
		comment = "yea"
	end

	return comment
end

-- -----------------------------------------------------------------------

ParseGrooveStatsDate = function(date)
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
LoadUnlocksCache = function()
	local cache_file = "/Songs/unlocks-cache.json"
	if FILEMAN:DoesFileExist(cache_file) then
		local f = RageFileUtil:CreateRageFile()
		local cache = {}
		if f:Open(cache_file, 1) then
			local data = JsonDecode(f:Read())
			if data ~= nil then
				cache = data
			end
		end
		f:destroy()
		return cache
	end
	return {}
end

-- -----------------------------------------------------------------------
WriteUnlocksCache = function()
	local cache_file = "/Songs/unlocks-cache.json"
	local f = RageFileUtil:CreateRageFile()
	if f:Open(cache_file, 2) then
		f:Write(JsonEncode(SL.GrooveStats.UnlocksCache))
	end
	f:destroy()
end

-- -----------------------------------------------------------------------
-- Downloads an Event unlock and unzips it. If a download with the same URL and
-- destination pack name exists, the download attempt is skipped.
-- 
-- Args are:
--   url: string, the file to download from the web.
--   unlockName: string, an identifier for the download.
--               Used to display on ScreenDownloads
--   packName: string, The pack name to unlock the contents of the unlock to.
DownloadEventUnlock = function(url, unlockName, packName)
	-- Forward slash is not allowed in both Linux or Windows.
	-- All others are not allowed in Windows.
	local invalidChars = {
			["/"]="",
			["<"]="",
			[">"]="",
			[":"]="",
			["\""]="",
			["\\"]="",
			["|"]="",
			["?"]="",
			["*"]=""
	}
	packName = string.gsub(packName, ".", invalidChars)

	-- Reserved file names for Windows.
	local invalidFilenames = {
			["CON"]=true,
			["PRN"]=true,
			["AUX"]=true,
			["NUL"]=true,
			["COM1"]=true,
			["COM2"]=true,
			["COM3"]=true,
			["COM4"]=true,
			["COM5"]=true,
			["COM6"]=true,
			["COM7"]=true,
			["COM8"]=true,
			["COM9"]=true,
			["LPT1"]=true,
			["LPT2"]=true,
			["LPT3"]=true,
			["LPT4"]=true,
			["LPT5"]=true,
			["LPT6"]=true,
			["LPT7"]=true,
			["LPT8"]=true,
			["LPT9"]=true
	}
	-- If the packName is invalid, just append a space to it so it's not.
	if invalidFilenames[packName] then
		packName = " "..packName.." "
	end

	-- Check the download cache to see if we have already downloaded this unlock
	-- successfully to the intended location.
	-- Unlocks are placed in the cache whenever unlocks are bot successfully
	-- downloaded and zipped.
	if SL.GrooveStats.UnlocksCache[url] and SL.GrooveStats.UnlocksCache[url][packName] then
		return
	end

	-- Then check that the same download isn't already active in the Downloads
	-- table.
	for _, downloadInfo in pairs(SL.Downloads) do
		if downloadInfo.Url == url and downloadInfo.Destination == packName then
			return
		end
	end

	local uuid = CRYPTMAN:GenerateRandomUUID()
	local downloadfile = uuid..".zip"

	SL.Downloads[uuid] = {
		Name=unlockName,
		Url=url,
		Destination=packName,
		CurrentBytes=0,
		TotalBytes=0,
		Complete=false
	}

	-- Create the request separately. If the host is blocked it's possible that
	-- the SL.Downloads[uuid] table is assigned.
	SL.Downloads[uuid].Request = NETWORK:HttpRequest{
		url=url,
		downloadFile=downloadfile,
		onProgress=function(currentBytes, totalBytes)
			local downloadInfo = SL.Downloads[uuid]
			if downloadInfo == nil then return end

			downloadInfo.CurrentBytes = currentBytes
			downloadInfo.TotalBytes = totalBytes
		end,
		onResponse=function(response)
			local downloadInfo = SL.Downloads[uuid]
			if downloadInfo == nil then return end
			
			downloadInfo.Complete = true
			if response.error ~= nil then
				downloadInfo.ErrorMessage = response.errorMessage
				return
			end

			if response.statusCode == 200 then
				if response.headers["Content-Type"] == "application/zip" then
					-- Downloads are usually of the form:
					--    /Downloads/<name>.zip/<song_folders/
					local destinationPack = "/Songs/"..packName.."/"
					if not FILEMAN:Unzip("/Downloads/"..downloadfile, "/Songs/"..packName.."/") then
						downloadInfo.ErrorMessage = "Failed to Unzip!"
					else
						if SL.GrooveStats.UnlocksCache[url] == nil then
							SL.GrooveStats.UnlocksCache[url] = {}
						end
						SL.GrooveStats.UnlocksCache[url][packName] = true
						-- If Pack.ini doesn't exist (new unlock for this player), create it.
						local group = string.lower(packName)
						local year = 2025
						if string.find(group, "itl online "..year.." unlocks") then
							local packIniPath = destinationPack.."Pack.ini"
							if not FILEMAN:DoesFileExist(packIniPath) then
								IniFile.WriteFile(packIniPath, {
									["Group"]={
										["Version"]=1,
										["DisplayTitle"]=packName,
										["TranslitTitle"]=packName,
										["SortTitle"]=packName,
										["Series"]="ITL Online",
										["Year"]=year,
										["Banner"]="",
										["SyncOffset"]="ITG",
									}
								})
							end
						end
						WriteUnlocksCache()
					end
				else
					downloadInfo.ErrorMessage = "Download is not a Zip!"
					Warn("Attempted to download from \""..url.."\" which is not a zip!")
				end
			else
				downloadInfo.ErrorMessage = "Network Error "..response.statusCode
			end
		end,
	}
end

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

