-- Currently the Density Graph in SSM doesn't work for Courses.
-- Disable the functionality.
local nsj = GAMESTATE:GetNumSidesJoined()

if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)
if not GAMESTATE:IsHumanPlayer(pn) then return end
local seconds = 0
local ElapsedTime = 0
local CurrentTime = 0
local CurrentX
local CurrentSong
local NewSong
local FirstPass = true

-- Get the Y position for this section
local FooterHeight = 32
local PaneHeight = 120
local DifficultyHeight = 50
local StepsHeight = 16
local YPosition = _screen.h - (FooterHeight + PaneHeight + DifficultyHeight + StepsHeight)

-- Height and width of the density graph.
local height = 64
local width = IsUsingWideScreen() and SCREEN_WIDTH/3 or 309

local function getInputHandler(actor, player)
	return (function(event)
		if event.GameButton == "Start" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
			actor:visible(true)
		end
	end)
end

local UpdateCursor = function(af, delta)
	local song = GAMESTATE:GetCurrentSong()
	if not song then 
		ElapsedTime = 0
		return 
	end
	ElapsedTime = (GetTimeSinceStart() - CurrentTime) * SL.Global.ActiveModifiers.MusicRate
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction(UpdateCursor)
		CurrentSong = GAMESTATE:GetCurrentSong()
		if not IsUsingWideScreen() and nsj == 2 then
			self:visible(false)
		else
			self:visible( GAMESTATE:IsHumanPlayer(player) )
		end
		self:y(IsUsingWideScreen() and YPosition or _screen.cy+60)

		if player == PLAYER_2 then
			self:x(SCREEN_RIGHT - width)
		end
		if not IsUsingWideScreen() and nsj == 2 then
			self:visible(false)
		return end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if not IsUsingWideScreen() then
			self:visible(false)
		elseif params.Player == player then
			self:visible(true)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if not IsUsingWideScreen() then
			self:visible(false)
		elseif params.Player == player then
			self:visible(false)
		end
	end,
}

af[#af+1] = Def.ActorFrame{
	Name="ChartParser",
	OnCommand=function(self)
		self:queuecommand('ShowDensityGraph')
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		self:stoptweening():sleep(0.2):queuecommand('ShowDensityGraph')
	end,
	CloseThisFolderHasFocusMessageCommand=function(self)
		self:stoptweening()
		self:stoptweening():sleep(0.2):queuecommand('Hide')
	end,
	GroupsHaveFocusMessageCommand=function(self)
		self:stoptweening()
		self:stoptweening():sleep(0.2):queuecommand('Hide')
	end,
	SongIsReloadingMessageCommand=function(self)
		self:stoptweening():sleep(0.2):queuecommand('ShowDensityGraph')
	end,
	ShowDensityGraphCommand=function(self)
		-- I don't like how it looks when the bg quad dissappears while scrolling so gonna not do that for now.
		--self:GetChild("DensityQuad"):visible(false)
		self:GetChild("DensityGraph"):visible(false)
		self:GetChild("NPS"):settext("Peak NPS: ")
		self:GetChild("NPS"):visible(false)
		self:GetChild("Breakdown"):GetChild("BreakdownText"):settext("")
		self:GetChild("Breakdown"):visible(false)
		self:GetChild("Total Measures"):GetChild("Total Measures Text"):settext("")
		self:GetChild("Total Measures"):visible(false)
		self:GetChild("ProgressBar"):visible(false)
		
		self:stoptweening()
		self:sleep(0.2)
		self:queuecommand("ParseChart")
	end,
	ParseChartCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			MESSAGEMAN:Broadcast(pn.."ChartParsing")
			ParseChartInfo(steps, pn)
			self:queuecommand("Unhide")
		end
	end,
	UnhideCommand=function(self)
		if GAMESTATE:GetCurrentSteps(player) then
			MESSAGEMAN:Broadcast(pn.."ChartParsed")
			self:GetChild("DensityQuad"):visible(true)
			self:GetChild("DensityGraph"):visible(true)
			self:GetChild("NPS"):visible(true)
			self:GetChild("Breakdown"):visible(true)
			self:GetChild("Total Measures"):visible(true)
			self:GetChild("ProgressBar"):visible(true)
			self:queuecommand("Redraw")
		end
	end,
	HideCommand=function(self)
		self:stoptweening()
		self:GetChild("DensityGraph"):visible(false)
		self:GetChild("NPS"):visible(false)
		self:GetChild("Breakdown"):visible(false)
		self:GetChild("Total Measures"):visible(false)
		self:GetChild("DensityQuad"):visible(false)
		self:GetChild("ProgressBar"):visible(false)
	end,
}

local af2 = af[#af]

-- Background quad for the density graph
af2[#af2+1] = Def.Quad{
	Name="DensityQuad",
	InitCommand=function(self)
		self:diffuse(color("#1e282f")):zoomto(width, height):vertalign(bottom):horizalign(left)
		self:y(-17)
	end,
}

-- The Density Graph itself. It already has a "RedrawCommand".
af2[#af2+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:horizalign(left):y(-17)
	end,
}
-- Don't let the density graph parse the chart.
-- We do this in parent actorframe because we want to "stall" before we parse.
af2[#af2]["CurrentSteps"..pn.."ChangedMessageCommand"] = nil

-- The Peak NPS text
af2[#af2+1] = LoadFont("Miso/_miso")..{
	Name="NPS",
	Text="Peak NPS: ",
	InitCommand=function(self)
		self:y(-20 - height):horizalign(player == PLAYER_1 and left or right):vertalign(bottom):zoom(0.8)
		if player == PLAYER_1 then
			self:x(5)
		elseif player == PLAYER_2 then
			self:x(SCREEN_WIDTH/3 - 5)
		end
		-- We want white text.
		self:diffuse({1, 1, 1, 1})
	end,
	RedrawCommand=function(self)
		local npsBPM = round((SL[pn].Streams.PeakNPS * SL.Global.ActiveModifiers.MusicRate) * 15, 2)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS * SL.Global.ActiveModifiers.MusicRate).. " ("..npsBPM..")")
		end
	end,
	UpdateRateModTextMessageCommand=function(self)
		self:queuecommand("Redraw")
	end,
}

-- Breakdown
af2[#af2+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
	end,

	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 17
			self:diffuse(color("#000000")):zoomto(width, bgHeight):vertalign(bottom):horizalign(left):diffusealpha(0.85)
		end
	},
	
	LoadFont("Miso/_miso")..{
		Text="",
		Name="BreakdownText",
		InitCommand=function(self)
			local textHeight = 17
			local textZoom = 0.8
			self:maxwidth(width/textZoom):zoom(textZoom):vertalign(bottom):horizalign(center)
			self:y(-2)
			self:x(width/2)
		end,
		RedrawCommand=function(self)
			local textZoom = 0.8
			self:settext(GenerateBreakdownText(pn, 0))
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
				self:settext(GenerateBreakdownText(pn, minimization_level))
				minimization_level = minimization_level + 1
			end
		end,
	}
}

-- Total Measures Text
af2[#af2+1] = Def.ActorFrame{
	Name="Total Measures",
	InitCommand=function(self)
		self:y(-42 - height):vertalign(bottom)
		if player == PLAYER_1 then
			self:x(5):horizalign(left)
		elseif player == PLAYER_2 then
			self:x(SCREEN_WIDTH/3 - 5):horizalign(right)
		end
	end,
	
	LoadFont("Miso/_miso")..{
		Text="",
		Name="Total Measures Text",
		InitCommand=function(self)
			local textHeight = 17
			local textZoom = 0.8
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		RedrawCommand=function(self)
			local textZoom = 0.8
			local streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(pn)
			local totalMeasures = streamMeasures + breakMeasures
			local SongDensity = " (".. round( (streamMeasures/totalMeasures)*100 ,2) .."%)"
			if player == PLAYER_1 then
				self:horizalign(left)
			elseif player == PLAYER_2 then
				self:horizalign(right)
			end
			self:settext(streamMeasures == 0 and "" or "Total Measures: "..streamMeasures..SongDensity)
		end,
	}
}

-- Progress bar
af2[#af2+1] = Def.Quad{
	Name="ProgressBar",
	InitCommand=function(self)
		self:diffuse(color("#FFFFFF")):zoomto(1, height):vertalign(bottom):horizalign(left)
		self:y(-17)
	end,
	RedrawCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song then
			NewSong = GAMESTATE:GetCurrentSong()
			if CurrentSong ~= NewSong or FirstPass then
				FirstPass = false
				self:stoptweening()
				CurrentSong = NewSong
				local SongLength = song:GetLastSecond()
				local SongPosition = song:GetSampleStart()
				local Ratio = width/SongLength
				local XPos = SongPosition * Ratio
				self:x(XPos)
				self:queuecommand('DrawCursor')
			end
		end
	end,
	DrawCursorCommand=function(self)
		self:stoptweening()
		local song = GAMESTATE:GetCurrentSong()
		if song then
			local SongLength = song:GetLastSecond()
			local SongPosition = song:GetSampleStart() + ElapsedTime
			local Ratio = width/SongLength
			local XPos = SongPosition * Ratio
			self:x(XPos)
			if XPos > width - 1 then
				self:visible(false)
				return
			end
			self:sleep(0.1):queuecommand('DrawCursor')
		end
	end,
	DrawCursorMouseMessageCommand = function(self, WhoClicked)
		self:stoptweening()
		local song = GAMESTATE:GetCurrentSong()
		if song then
			CurrentTime = GetTimeSinceStart()
			ElapsedTime = 0
			local WhoClicked = WhoClicked[1]
			if WhoClicked == "P1" then
				if pn == "P1" then
					CurrentX = INPUTFILTER:GetMouseX()
					self:x(CurrentX)
				elseif pn == "P2" then
					CurrentX = INPUTFILTER:GetMouseX()
					self:x(CurrentX)
				end
			elseif WhoClicked == "P2" then
				if pn == "P1" then
					CurrentX = INPUTFILTER:GetMouseX() - SCREEN_WIDTH/3 * 2
					self:x(CurrentX)
				elseif pn == "P2" then
					CurrentX = INPUTFILTER:GetMouseX() - SCREEN_WIDTH/3 * 2
					self:x(CurrentX)
				end
			end
			
			self:sleep(0.1):queuecommand('UpdateCursorMouse')
		end
	end,
	UpdateCursorMouseCommand=function(self)
		self:stoptweening()
		local song = GAMESTATE:GetCurrentSong()
		if song then
			local SongLength = song:GetLastSecond()
			local Ratio = width/SongLength
			local SongPosition = ElapsedTime * Ratio
			self:x(SongPosition + CurrentX)
			
			-- hide the cursor if the song ends
			if pn == "P1" then
				if SongPosition + CurrentX > width - 1 then
					self:visible(false)
					return
				else
					self:visible(true)
				end
			elseif pn == "P2" then
				if SongPosition + CurrentX > width - 1 then
					self:visible(false)
					return
				else
					self:visible(true)
				end
			end
			self:sleep(0.1):queuecommand('UpdateCursorMouse')
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		ElapsedTime = 0
		CurrentTime = GetTimeSinceStart()
	end,
}

return af