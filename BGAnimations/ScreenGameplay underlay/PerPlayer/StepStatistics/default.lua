local player = ...
local pn = ToEnumShortString(player)
local ar = GetScreenAspectRatio()
local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

-- -----------------------------------------------------------------------
-- if the conditions aren't right, don't bother

local stylename = GAMESTATE:GetCurrentStyle():GetName()

if (SL[pn].ActiveModifiers.DataVisualizations ~= "Step Statistics")
or (not IsUltraWide and stylename == "versus")
or (NoteFieldIsCentered and not IsUsingWideScreen())
or (not IsUltraWide and (not stylename == "single" or not stylename == "double") )
then
	return
end

-- -----------------------------------------------------------------------
-- positioning and sizing of side pane

local header_height   = 80
local notefield_width = GetNotefieldWidth()
local sidepane_width
local sidepane_pos_x

if stylename == "double" then
	sidepane_width  = _screen.w/7.2
	sidepane_pos_x  = _screen.w * 0.0693
else
	sidepane_pos_x  = _screen.w * (player==PLAYER_1 and 0.75 or 0.25)
	sidepane_width  = _screen.w/2
end

if not IsUltraWide then
	if NoteFieldIsCentered and IsUsingWideScreen() and stylename ~= "double"   then
		sidepane_width = (_screen.w - GetNotefieldWidth()) / 2
		if player==PLAYER_1 then
			sidepane_pos_x = _screen.cx + notefield_width + (sidepane_width-notefield_width)/2
		else
			sidepane_pos_x = _screen.cx - notefield_width - (sidepane_width-notefield_width)/2
		end
	end

-- ultrawide or wider
else
	if #GAMESTATE:GetHumanPlayers() > 1 then
		sidepane_width = _screen.w/5
		if player==PLAYER_1 then
			sidepane_pos_x = sidepane_width/2
		else
			sidepane_pos_x = _screen.w - (sidepane_width/2)
		end
	end
end


-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}

af.Name="StepStatsPane"..pn
af.InitCommand=function(self)
	self:x(sidepane_pos_x):y(_screen.cy + header_height)
end

af[#af+1] = LoadActor("./DarkBackground.lua", {player, header_height, sidepane_width})

-- banner, judgment labels, and judgment numbers will be collectively shrunk
-- if Center1Player is enabled to accommodate the smaller space
af[#af+1] = Def.ActorFrame{
	Name="BannerAndData",
	InitCommand=function(self)
		local zoomfactor = {
			ultrawide    = 0.725,
			sixteen_ten  = 0.825,
			sixteen_nine = 0.925
		}

		if not IsUltraWide then
			if (NoteFieldIsCentered and IsUsingWideScreen()) then
				local zoom = scale(GetScreenAspectRatio(), 16/10, 16/9, zoomfactor.sixteen_ten, zoomfactor.sixteen_nine)
				self:zoom( zoom )
			end

		else
			if #GAMESTATE:GetHumanPlayers() > 1 then
				self:zoom(zoomfactor.ultrawide):addy(-55)
			end
		end
	end,

	LoadActor("./Banner.lua", player),
	LoadActor("./TapNoteJudgments.lua", {player, true}), -- second argument is if it has labels or not
	LoadActor("./HoldsMinesRolls.lua", player),
	LoadActor("./Time.lua", player),
	LoadActor("./SongInformation.lua", player), -- Song title and artist (also #song in a course)
	
}

af[#af+1] = LoadActor("./DensityGraph.lua", {player, sidepane_width})

if (IsServiceAllowed(SL.GrooveStats.GetScores) and GAMESTATE:GetNumSidesJoined() == 1) or (GAMESTATE:GetNumSidesJoined() == 1 and GAMESTATE:IsCourseMode()) then
	af[#af+1] = LoadActor("./Scorebox.lua", player)
end

return af