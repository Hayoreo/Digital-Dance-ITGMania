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
			local sample_start = song:GetSampleStart()
			local sample_len = song:GetSampleLength()

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
-- functions used by both SSM and ScreenSelectMusicDD



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
			local converted_grade = Grade:Reverse()[grade]
			if converted_grade > 17 then converted_grade = 17 end
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