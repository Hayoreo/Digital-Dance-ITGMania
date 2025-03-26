local HasResetFilterPreferences = false
local HelpText

----- Default preference values
local DefaultLowerMeter = 0
local DefaultUpperMeter = 0
local DefaultLowerBPM = 49
local DefaultUpperBPM = 49
local DefaultLowerNPS = 0
local DefaultUpperNPS = 0
local DefaultLowerLength = 0
local DefaultUpperLength = 0
local DefaultGrooveStats = 1
local DefaultAutogen = 1
local DefaultDifficulty = 1
local DefaultMainSort = 1
if
GetMainSortPreference() == 8 or
GetLowerMeterFilter() ~= DefaultLowerMeter or
GetUpperMeterFilter() ~= DefaultUpperMeter or
GetShowDifficulty("Beginner") ~= DefaultDifficulty or
GetShowDifficulty("Easy") ~= DefaultDifficulty or
GetShowDifficulty("Medium") ~= DefaultDifficulty or
GetShowDifficulty("Hard") ~= DefaultDifficulty or
GetShowDifficulty("Challenge") ~= DefaultDifficulty or
GetShowDifficulty("Edit") ~= DefaultDifficulty or
GetLowerBPMFilter() ~= DefaultLowerBPM or
GetUpperBPMFilter() ~= DefaultUpperBPM or
GetLowerNPSFilter() ~= DefaultLowerNPS or
GetUpperNPSFilter() ~= DefaultUpperNPS or
GetLowerLengthFilter() ~= DefaultLowerLength or
GetUpperLengthFilter() ~= DefaultUpperLength or
GetGrooveStatsFilter() ~= DefaultGrooveStats or
GetAutogenFilter() ~= DefaultAutogen then
	SetMainSortPreference(DefaultMainSort)
	SetLowerMeterFilter(DefaultLowerMeter)
	SetUpperMeterFilter(DefaultUpperMeter)
	SetShowDifficulty("Beginner")
	SetShowDifficulty("Easy")
	SetShowDifficulty("Medium")
	SetShowDifficulty("Hard")
	SetShowDifficulty("Challenge")
	SetShowDifficulty("Edit")
	SetLowerBPMFilter(DefaultLowerBPM)
	SetUpperBPMFilter(DefaultUpperBPM)
	SetLowerNPSFilter(DefaultLowerNPS)
	SetUpperNPSFilter(DefaultUpperNPS)
	SetLowerLengthFilter(DefaultLowerLength)
	SetUpperLengthFilter(DefaultUpperLength)
	SetGrooveStatsFilter(DefaultGrooveStats)
	SetAutogenFilter(DefaultAutogen)
	HasResetFilterPreferences = true
end

local Input = function(event)
	-- if any of these, don't attempt to handle input
	if not event or not event.button then return false end

	if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
		local topscreen = SCREENMAN:GetTopScreen()
		if HasResetFilterPreferences == true or SongSearchSSMDD == true then
			SongSearchSSMDD = false
			SongSearchAnswer = nil
			topscreen:SetNextScreenName("ScreenReloadSSMDD")
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		else
			topscreen:SetNextScreenName("ScreenGameOver")
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

--- Show text letting the player know if they have no songs or if they messed things up with their filters.
if HasResetFilterPreferences == false then
	HelpText = ScreenString("NoValidSongs")
else
	HelpText = ScreenString("NoValidFilters")
end

if SongSearchSSMDD then
	HelpText = ScreenString("NoValidFilters")
end

local af = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( Input ) end,

	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse(0,0,0,0.6) end
	},

	Def.BitmapText{
		Font="Common Normal",
		Text=HelpText,
		InitCommand=function(self) self:Center():zoom(1.1):_wrapwidthpixels(320) end
	},
}

return af