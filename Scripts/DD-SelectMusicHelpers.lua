-- ----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusicDD/ScreenSelectCourseDD

-- used by ScreenSelectMusicDD to play preview music of the current song
-- this is invoked each time the custom MusicWheel changes focus
-- Also used by ScreenSelectCourseDD to play menu music
-- this gets toggled on/off when the sort menu is opened/closed
play_sample_music = function()
	if GAMESTATE:IsCourseMode() then 
		if isSortMenuVisible == false then
			local musicpath = THEME:GetPathS("", "OfCourse.ogg")
			local sample_start = 0
			local sample_len = 32
			-- Dim Music doesn't seem to work at all???
			SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume")/20, math.huge)
			SOUND:PlayMusicPart(musicpath, sample_start, sample_len, 0,0, true, true)
		else
			stop_music()
		end
	else	
		local song = GAMESTATE:GetCurrentSong()

		if song then
			local songpath = song:GetMusicPath()
			local sample_start = song:GetSampleStart() or 0
			local sample_len = song:GetSampleLength() or 12

			if songpath then
				SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"), math.huge)
				SOUND:PlayMusicPart(songpath, sample_start,sample_len, 0.5, 1.5, false, true)
			else
				stop_music()
			end
		else
			stop_music()
		end
	end
end

-- used by ScreenSelectMusicDD to stop playing preview music,
-- this is invoked every time the custom MusicWheel changes focus
-- if the new focus is on song item, play_sample_music() will be invoked immediately afterwards
-- ths is also invoked when the player closes the current group to choose some other group
stop_music = function()
	SOUND:PlayMusicPart("", 0, 0)
end

update_sample_music = function(Xpos)
	stop_music()
	local song = GAMESTATE:GetCurrentSong()
	
	if song then
		local Xpos = Xpos
		local width = SCREEN_WIDTH/3
		local song_length = song:GetLastSecond()
		local ratio = song_length/width
		local songpath = song:GetMusicPath()
		local sample_start = Xpos * ratio
		local sample_len = song_length - sample_start

		if songpath and sample_start and sample_len then
			SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"), math.huge)
			SOUND:PlayMusicPart(songpath, sample_start,sample_len, 0.5, 1.5, false, true)
		else
			stop_music()
		end
	else
		stop_music()
	end
end

----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusic

-- TextBanner is an engine-defined ActorFrame that contains three BitmapText actors named
-- "Title", "Subtitle", and "Artist".  Digital Dance's MusicWheel only uses the first two.
--
-- It has two unique Metrics, "AfterSetCommand" and "ArtistPrependString"
-- Digital Dance is only concerned with "AfterSetCommand"
-- because the song Artist does not appear in each MusicWheelItem

TextBannerAfterSet = function(self)
	-- acquire handles to two of the BitmapText children of this TextBanner ActorFrame
	-- we'll use them to position each song's Title and Subtitle as they appear in the MusicWheel
	local Title = self:GetChild("Title")
	local Subtitle = self:GetChild("Subtitle")

	-- assume the song's Subtitle is an empty string by default and position the Title
	-- in the vertical middle of the MusicWheelItem
	Title:y(0)

	-- if the Subtitle isn't an empty string
	if Subtitle:GetText() ~= "" then
		-- offset the Title's y() by -6 pixels
		Title:y(-6)
		-- and offset the Subtitle's y() by 6 pixels
		Subtitle:y(6)
	end
end

----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusicDD

-- This is a quick way to check if a score is a quint.
-- Technically a hack until we actually get engine support for quints/tracking
-- W0 but this is good enough for now.
-- We do this by checking if:
--  1. Any score exists that has a percentDP of 1.0 (they've quadded)
--  2. The high score tracked whites (by determining if score < #Fantastics)
--  3. The number of whites is actually 0
function IsQuint(hsl)
	if hsl == nil then return false end
	for hs in ivalues(hsl:GetHighScores()) do
		if (hs:GetPercentDP() == 1.0 and
					hs:GetScore() < hs:GetTapNoteScore("TapNoteScore_W1")
					and hs:GetScore() == 0) then
			return true
		end
	end
	return false
end

--- Returns the grade for a given song and chart or nil if there isn't a high score.
--- @param player Enum
--- @param song Song
--- @param chart Steps
--- @param rateParam boolean
function GetTopGrade(player, song, chart)
	local grade = nil
	local pn = ToEnumShortString(player)
	
	if song then
		local scores = PROFILEMAN:GetProfile(pn):GetHighScoreList(song,chart):GetHighScores()

		for score in ivalues(scores) do
			if score:GetPercentDP() ~= 0 then
				local cur_grade = score:GetGrade()
				grade = cur_grade
				if grade ~= 'Grade_Failed' then
					break
				end
			end
		end

		if grade then
			-- plus 1 for quints
			local converted_grade = Grade:Reverse()[grade]+1
			if converted_grade > 18 then converted_grade = 18 end
			if 	converted_grade == 1 then
				if IsQuint(PROFILEMAN:GetProfile(pn):GetHighScoreList(song,chart)) then
					converted_grade = 0
				end
			end
			return converted_grade
		end
	else end
	return nil
end

GetMaxCursorPosition = function()
	local curSong = GAMESTATE:GetCurrentSong()
	local SongIsSelected
	
	if curSong then 
		SongIsSelected = true
	else
		SongIsSelected = false
	end
	
	-- the minimum amount of items
	local MaxCursorPosition = 14
	
	if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
		MaxCursorPosition = MaxCursorPosition + 1
	end
	
	if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' and GAMESTATE:IsPlayerEnabled(0) and SongIsSelected then
		MaxCursorPosition = MaxCursorPosition + 1
	end
	
	if IsServiceAllowed(SL.GrooveStats.Leaderboard) and SongIsSelected then
		MaxCursorPosition = MaxCursorPosition + 1
	end
	return tonumber(MaxCursorPosition)
end

GetFileContents = function(path)
	local contents = ""

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 1) then
			contents = file:Read()
		end

		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end

	-- split the contents of the file on newline
	-- to create a table of lines as strings
	local lines = {}
	for line in contents:gmatch("[^\r\n]+") do
		lines[#lines+1] = line
	end

	return lines
end

IsCurrentSongTagged = function(song, PlayerNum)
	-- Idk why this is being hit when switching between course/song select, but yeah.
	if GAMESTATE:GetPlayMode() ~= 'PlayMode_Regular' then return false end
	local style
	if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
		style = "double"
	else
		style = "single"
	end
	local PlayerNum = PlayerNum
	if song == nil then return false end
	local song = song
	local SongPath = song:GetSongDir():sub(7):sub(1, -2)
	
	local tag_path = PROFILEMAN:GetProfileDir(PlayerNum) .. "Tags-"..style..".txt"
	local tag_lines = GetFileContents(tag_path)
	local Value = false
	for line in ivalues(tag_lines) do
		if line == SongPath then
			Value = true
			break
		end
	end
	return Value
end

IsCurrentGroupTagged = function(group, PlayerNum)
	local style
	if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
		style = "double"
	else
		style = "single"
	end
	local PlayerNum = PlayerNum
	local song = song
	local Group = group
	local GroupName = "/"..Group.."/*"
	local tag_path = PROFILEMAN:GetProfileDir(PlayerNum) .. "Tags-"..style..".txt"
	local tag_lines = GetFileContents(tag_path)
	local Value = false
	for line in ivalues(tag_lines) do
		if line == GroupName then
			Value = true
			break
		end
	end
	return Value
end

GetCurrentPlayerTags = function(PlayerNum)
	local style
	if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
		style = "double"
	else
		style = "single"
	end
	local tag_path = PROFILEMAN:GetProfileDir(PlayerNum) .. "Tags-"..style..".txt"
	local tag_lines = GetFileContents(tag_path)
	local player_tags = {}
	for line in ivalues(tag_lines) do
		if line:sub(1,1) == "#" then
			player_tags[#player_tags+1] = line:sub(2)
		end
	end
	return player_tags
end

GetCurrentObjectTags = function(Object, PlayerNumber)
	local style
	if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
		style = "double"
	else
		style = "single"
	end
	local Object = Object
	local SongOrGroup
	local tag_path = PROFILEMAN:GetProfileDir(PlayerNumber) .. "Tags-"..style..".txt"
	local tag_lines = GetFileContents(tag_path)
	local Tag
	local NewTag
	
	if Object == NameOfGroup then
		SongOrGroup = "Group"
	else
		SongOrGroup = "Song"
	end
	
	local object_tags = {}
	for line in ivalues(tag_lines) do
		if line:sub(1,1) == "#" then
			Tag = line:sub(2)
			local FoundObject = false
			for line in ivalues(tag_lines) do
				if line:sub(1,1) == "#" then
					NewTag = line:sub(2)
				end
				if SongOrGroup == "Song" then
					if Object:GetSongDir():sub(7):sub(1, -2) == line then
						if NewTag == Tag then
							FoundObject = true
							break
						end
					end
				elseif SongOrGroup == "Group" then
					if "/"..Object.."/*" == line then
						if NewTag == Tag then
							FoundObject = true
							break
						end
					end
				end
			end
			if FoundObject then
				object_tags[#object_tags+1] = Tag
			end
		end
	end
	
	return object_tags
	
end

GetObjectsPerTag = function (Tag, PlayerNumber, Object)
	local style
	if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
		style = "double"
	else
		style = "single"
	end
	local tag_path = PROFILEMAN:GetProfileDir(PlayerNumber) .. "Tags-"..style..".txt"
	local tag_lines = GetFileContents(tag_path)
	local Objects = {}
	local Lines = {}
	local NewTag
	
	for line in ivalues(tag_lines) do
		if line:sub(1,1) == "#" then
			NewTag = line:sub(2)
		end
		if Tag == NewTag and line:sub(1,1) ~= "#" then
			if line:find("/%*") and Object == "Pack" then
				if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
					Objects[#Objects+1] = "Pack: "..line:sub(2):gsub("/.*", "")
					Lines[#Lines+1] = line
				end
			elseif Object == "Song" and not line:find("/%*") then
				local song = SONGMAN:FindSong(line)
				-- don't load songs that no longer exist.
				if SONGMAN:FindSong(line) then
					Objects[#Objects+1] = "Song: "..song:GetDisplayMainTitle()
					Lines[#Lines+1] = line
				end
			end
		end
	end
	
	return Objects, Lines
end

GetAvailableTagsToAdd = function(Object, PlayerNumber)
	local AllTags = GetCurrentPlayerTags(PlayerNumber)
	local TakenTags = GetCurrentObjectTags(Object, PlayerNumber)
	local TagsToBeAdded = {}
		
	for i=1, #AllTags do
		local IsMatch = false
		local CurrentAvail = AllTags[i]
		for j=1, #TakenTags do
			if CurrentAvail == TakenTags[j] then
				IsMatch = true
				break
			end
		end
		if not IsMatch then
			TagsToBeAdded[#TagsToBeAdded+1] = CurrentAvail
		end
	end
	
	return TagsToBeAdded
end

SetLocalCursor = function(pn)
	if pn == "P1" then
		return CurrentTabP1, CurrentRowP1, CurrentColumnP1
	elseif pn == "P2" then
		return CurrentTabP2, CurrentRowP2, CurrentColumnP2
	end
end


GetPlayerMenuVisibility = function(pn, ExpectedTab)
	if pn == "P1" then
		if CurrentTabP1 == ExpectedTab then
			return true
		else
			return false
		end
	elseif pn == "P2" then
		if CurrentTabP2 == ExpectedTab then
			return true
		else
			return false
		end
	end
end


SwitchSongCourseSelect=function(current_GameMode)
	if current_GameMode == 'PlayMode_Regular' or current_GameMode ~= 'PlayMode_Nonstop' then
		GAMESTATE:SetCurrentSong(nil)
		GAMESTATE:SetCurrentPlayMode(1)
		local value = "Course"
		for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
			DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
			DDStats.Save(playerNum)
		end
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSCDD")
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	elseif current_GameMode == 'PlayMode_Nonstop' then
		GAMESTATE:SetCurrentCourse(nil)
		GAMESTATE:SetCurrentPlayMode(0)
		local value = "Song"
		for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
			DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
			DDStats.Save(playerNum)
		end
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSMDD")
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end