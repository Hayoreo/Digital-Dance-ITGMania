-- Move as many functions that make sense here to clean up Input.lua
local current_style = GAMESTATE:GetCurrentStyle():GetStyleType()
local style
if current_style == "StyleType_OnePlayerOneSide" then
	style = "Double"
elseif current_style == "StyleType_OnePlayerTwoSides" then
	style = "Single"
end

local function GetLastStyle()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LastStyle')
	else
		value = DDStats.GetStat(PLAYER_2, 'LastStyle')
	end

	if value == nil then
		value = "Single"
	end

	return value
end


local function SetLastStyle(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LastStyle', value)
		DDStats.Save(playerNum)
	end
end


local t = Def.ActorFrame{
	
	ReloadSSMDDMessageCommand = function(self)
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSMDD")
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	
	DDResetSortsFiltersMessageCommand=function(self)
		----- Default preference values
		local DefaultMainSort = 1
		local DefaultSubSort = 2
		local DefaultSubSort2 = 2
		local DefaultLowerMeter = 0
		local DefaultUpperMeter = 0
		local DefaultDifficulty = 1
		local DefaultLowerBPM = 49
		local DefaultUpperBPM = 49
		local DefaultLowerLength = 0
		local DefaultUpperLength = 0
		local DefaultGroovestats = 1
		local DefaultAutogen = 1

		if 
		SongSearchWheelNeedsResetting == true or
		IsUsingSorts() or
		IsUsingFilters()
		then
			SetMainSortPreference(DefaultMainSort)
			SetSubSortPreference(DefaultSubSort)
			SetSubSort2Preference(DefaultSubSort2)
			SetLowerMeterFilter(DefaultLowerMeter)
			SetUpperMeterFilter(DefaultUpperMeter)
			SetShowDifficulty("Beginner", DefaultDifficulty)
			SetShowDifficulty("Easy", DefaultDifficulty)
			SetShowDifficulty("Medium", DefaultDifficulty)
			SetShowDifficulty("Hard", DefaultDifficulty)
			SetShowDifficulty("Challenge", DefaultDifficulty)
			SetShowDifficulty("Edit", DefaultDifficulty)
			SetLowerBPMFilter(DefaultLowerBPM)
			SetUpperBPMFilter(DefaultUpperBPM)
			SetLowerLengthFilter(DefaultLowerLength)
			SetUpperLengthFilter(DefaultUpperLength)
			SetGroovestatsFilter(DefaultGroovestats)
			SetAutogenFilter(DefaultAutogen)
			SongSearchWheelNeedsResetting = false
			MESSAGEMAN:Broadcast("ReloadSSMDD")
		else
			SM("Nothing to reset!")
		end
	end,

	DDSwitchStylesMessageCommand=function(self)
		SetLastStyle(style)
		GAMESTATE:SetCurrentStyle(style)
		SongSearchWheelNeedsResetting = false
		MESSAGEMAN:Broadcast("ReloadSSMDD")
	end,
	
	SwitchSongCourseSelectMessageCommand=function(self)
		local current_GameMode = GAMESTATE:GetPlayMode()
		if current_GameMode == 'PlayMode_Regular' then
			GAMESTATE:SetCurrentSong(nil)
			GAMESTATE:SetCurrentPlayMode(1)
			local value = "Course"
			for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
				DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
				DDStats.Save(playerNum)
			end
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectCourseDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		else
			GAMESTATE:SetCurrentCourse(nil)
			GAMESTATE:SetCurrentPlayMode(0)
			local value = "Song"
			for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
				DDStats.SetStat(playerNum, 'AreCourseOrSong', value)
				DDStats.Save(playerNum)
			end
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMusicDD")
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
	
	ResetGuestStatsMessageCommand=function(self, params)
		local playerNum = params[1]
		----- Default preference values
		local DefaultMainSort = 1
		local DefaultSubSort = 2
		local DefaultSubSort2 = 2
		local DefaultLowerMeter = 0
		local DefaultUpperMeter = 0
		local DefaultDifficulty = 1
		local DefaultLowerBPM = 49
		local DefaultUpperBPM = 49
		local DefaultLowerLength = 0
		local DefaultUpperLength = 0
		local DefaultGroovestats = 1
		local DefaultAutogen = 1
		--- other dd-stat variables that don't effect sort/filters
		local DefaultLastStyle = "Single"
		local DefaultLastTab = "Steps"
		local DefaultSongOrCourse = "Song"
		local DefaultLastSong = ""
		local DefaultLastDifficulty = ""
		local DefaultLastCourse = ""
		local DefaultLastCourseDifficulty = ""
		local DefaultDDColumnCueTime = 0
		
		
		DDStats.SetStat(playerNum, 'MainSortPreference', DefaultMainSort)
		DDStats.SetStat(playerNum, 'SubSortPreference', DefaultSubSort)
		DDStats.SetStat(playerNum, 'SubSort2Preference', DefaultSubSort2)
		DDStats.SetStat(playerNum, 'LowerMeterFilter', DefaultLowerMeter)
		DDStats.SetStat(playerNum, 'UpperMeterFilter', DefaultUpperMeter)
		DDStats.SetStat(playerNum, "Beginner", DefaultDifficulty)
		DDStats.SetStat(playerNum, "Easy", DefaultDifficulty)
		DDStats.SetStat(playerNum, "Medium", DefaultDifficulty)
		DDStats.SetStat(playerNum, "Hard", DefaultDifficulty)
		DDStats.SetStat(playerNum, "Challenge", DefaultDifficulty)
		DDStats.SetStat(playerNum, "Edit", DefaultDifficulty)
		DDStats.SetStat(playerNum, 'LowerBPMFilter', DefaultLowerBPM)
		DDStats.SetStat(playerNum, 'UpperBPMFilter', DefaultUpperBPM)
		DDStats.SetStat(playerNum, 'LowerLengthFilter', DefaultLowerLength)
		DDStats.SetStat(playerNum, 'UpperLengthFilter', DefaultUpperLength)
		DDStats.SetStat(playerNum, 'GroovestatsFilter', DefaultGroovestats)
		DDStats.SetStat(playerNum, 'AutogenFilter', DefaultAutogen)
		DDStats.SetStat(playerNum, 'LastStyle', DefaultLastStyle)
		DDStats.SetStat(playerNum, 'LastTab', DefaultLastTab)
		DDStats.SetStat(playerNum, 'AreCourseOrSong', DefaultSongOrCourse)
		DDStats.SetStat(playerNum, 'LastSong', DefaultLastSong)
		DDStats.SetStat(playerNum, 'LastDifficulty', DefaultLastDifficulty)
		DDStats.SetStat(playerNum, 'LastCourse', DefaultLastCourse)
		DDStats.SetStat(playerNum, 'LastCourseDifficulty', DefaultLastCourseDifficulty)
		DDStats.SetStat(playerNum, 'DDColumnCueTime', DefaultDDColumnCueTime)
		
		DDStats.Save(playerNum)
	end,
}

return t