-- Move as many functions that make sense here to clean up Input.lua

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

	DDResetSortsFiltersMessageCommand=function(self)
		----- Default preference values
		local DefaultMainCourseSort = 1
		local DefaultSubSort = 2
		local DefaultLowerMeter = 0
		local DefaultUpperMeter = 0
		local DefaultLowerBPM = 49
		local DefaultUpperBPM = 49
		local DefaultLowerLength = 0
		local DefaultUpperLength = 0
		local DefaultGrooveStats = 1
		local DefaultAutogen = 1

		if 
		SongSearchWheelNeedsResetting == true or
		SortMenuNeedsUpdating == true or
		GetMainCourseSortPreference() ~= DefaultMainSort or
		GetLowerMeterFilter() ~= DefaultLowerMeter or
		GetUpperMeterFilter() ~= DefaultUpperMeter or
		GetLowerBPMFilter() ~= DefaultLowerBPM or
		GetUpperBPMFilter() ~= DefaultUpperBPM or
		GetLowerLengthFilter() ~= DefaultLowerLength or
		GetUpperLengthFilter() ~= DefaultUpperLength or
		GetGrooveStatsFilter() ~= DefaultGrooveStats or
		GetAutogenFilter() ~= DefaultAutogen
		then
			SetMainCourseSortPreference(DefaultMainCourseSort)
			SetSubSortPreference(DefaultSubSort)
			SetLowerMeterFilter(DefaultLowerMeter)
			SetUpperMeterFilter(DefaultUpperMeter)
			SetLowerBPMFilter(DefaultLowerBPM)
			SetUpperBPMFilter(DefaultUpperBPM)
			SetLowerLengthFilter(DefaultLowerLength)
			SetUpperLengthFilter(DefaultUpperLength)
			SetGrooveStatsFilter(DefaultGrooveStats)
			SetAutogenFilter(DefaultAutogen)
			SongSearchWheelNeedsResetting = false
			SortMenuNeedsUpdating = false
			MESSAGEMAN:Broadcast("ReloadSSCDD")
		else
			SM("Nothing to reset!")
		end
	end,


	DDSwitchStylesMessageCommand=function(self)
		local current_style = GAMESTATE:GetCurrentStyle():GetStyleType()
		if current_style == "StyleType_OnePlayerOneSide" then
			SetLastStyle("Double")
			GAMESTATE:SetCurrentStyle("Double")
		else
			SetLastStyle("Single")
			GAMESTATE:SetCurrentStyle("Single")
		end
		SongSearchWheelNeedsResetting = false
		MESSAGEMAN:Broadcast("ReloadSSCDD")

	end,
}

return t