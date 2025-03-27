local Players = GAMESTATE:GetHumanPlayers()

---------------------------------------------------------------------------
-- The number of stages that were played this game cycle
local NumStages = SL.Global.Stages.PlayedThisGame
-- The duration (in seconds) each stage should display onscreen before cycling to the next
local DurationPerStage = 4

---------------------------------------------------------------------------
-- Primary ActorFrame
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:queuecommand("CaptureInput")
	end,
	CaptureInputCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		-- actually attach the InputHandler function to our screen
		topscreen:AddInputCallback( LoadActor("InputHandler.lua", {self, AlphabetWheels}) )
	end,
	AttemptToFinishCommand=function(self)
		if not SL.P1.HighScores.EnteringName and not SL.P2.HighScores.EnteringName then
			self:playcommand("Finish")
		end
	end,
	FinishCommand=function(self)
		-- store the highscore name for this game
		for player in ivalues(Players) do
			GAMESTATE:StoreRankingName(player, SL[ToEnumShortString(player)].HighScores.Name)

			-- if a profile is in use
			if PROFILEMAN:IsPersistentProfile(player) then
				-- update that profile's LastUsedHighScoreName attribute
				PROFILEMAN:GetProfile(player):SetLastUsedHighScoreName( SL[ToEnumShortString(player)].HighScores.Name )
			end
		end

		-- manually transition to the next screen (defined in Metrics)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

-- Things that are constantly on the screen (fallback banner + masks)
t[#t+1] = Def.ActorFrame {

	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusicDD", "underlay/default banner.png"))..{
		OnCommand=cmd(xy, _screen.cx, 107; zoom, 0.7)
	},

	Def.Quad{
		Name="LeftMask";
		InitCommand=cmd(halign,0),
		OnCommand=cmd(xy, 0, _screen.cy; zoomto, _screen.cx-272, _screen.h; MaskSource)
	},

	Def.Quad{
		Name="CenterMask",
		OnCommand=cmd(Center; zoomto, 110, _screen.h; MaskSource)
	},

	Def.Quad{
		Name="RightMask",
		InitCommand=cmd(halign,1),
		OnCommand=cmd(xy, _screen.w, _screen.cy; zoomto, _screen.cx-272, _screen.h; MaskSource)
	},
	
	-- Song name
	Def.Quad{
		Name="SongTitleQuad",
		OnCommand=function(self)
			self:setsize(418,30)
				:xy(SCREEN_CENTER_X,39)
				:diffuse(color("0,0,0,0.7"))
				:zoom(0.7)
		end
	},
}

-- Banner(s) and Title(s)
for i=1,NumStages do

	local SongOrCourse = SL.Global.Stages.Stats[i].song

	-- Create an ActorFrame for each (Name + Banner) pair
	-- so that we can display/hide all children simultaneously.
	local SongNameAndBanner = Def.ActorFrame{
		InitCommand=function(self) self:visible(false) end,
		OnCommand=function(self)
			self:sleep(DurationPerStage * (i-1) );
			self:queuecommand("Display")
		end,
		DisplayCommand=function(self)
			self:visible(true)
			self:sleep(DurationPerStage)
			self:queuecommand("Wait")
		end,
		WaitCommand=function(self)
			self:visible(false)
			self:sleep(DurationPerStage * (NumStages-1))
			self:queuecommand("Display")
		end
	}

	-- song name
	SongNameAndBanner[#SongNameAndBanner+1] = LoadFont("Miso/_miso")..{
		Name="SongName"..i,
		InitCommand=cmd(xy, _screen.cx, 38; maxwidth, 294),
		OnCommand=function(self)
			if string.match(tostring(SongOrCourse), "Course") then
				self:settext(SongOrCourse:GetDisplayFullTitle() or "???")
			else
				self:settext(SongOrCourse:GetDisplayMainTitle())
			end
		end
	}

	-- song banner
	SongNameAndBanner[#SongNameAndBanner+1] = Def.Banner{
		Name="SongBanner"..i,
		InitCommand=cmd(xy, _screen.cx, 107),
		OnCommand=function(self)
			if SongOrCourse then
				if string.match(tostring(SongOrCourse), "Course") then
					self:LoadFromCourse(SongOrCourse)
				else
					self:LoadFromSong(SongOrCourse)
				end
				self:setsize(418,164):zoom(0.7)
				self:SetDecodeMovie(ThemePrefs.Get("AnimateBanners"))
			end
		end
	}

	-- add each SongNameAndBanner ActorFrame to the primary ActorFrame
	t[#t+1] = SongNameAndBanner
end


for player in ivalues(Players) do
	local pn = ToEnumShortString(player)
	local x_offset = (player == PLAYER_1 and -120) or 200

	t[#t+1] = LoadActor("PlayerNameAndDecorations.lua", player)
	t[#t+1] = LoadActor("./HighScores.lua", player)

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	-- create_actors() takes five arguments
	--		a name
	--		the number of wheel actors to actually create onscreen
	--			note that this is NOT equal to how many items you want to be able to scroll through
	--			it is how many you want visually onscreen at a given moment
	--		a metatable defining a generic item in the wheel
	--		x position
	--		y position
	if SL[pn].HighScores.EnteringName then end
end

-- ActorSounds
t[#t+1] = LoadActor( THEME:GetPathS("ScreenTextEntry", "backspace"))..{ Name="delete", SupportPan = true }
t[#t+1] = LoadActor( THEME:GetPathS("Common", "start"))..{ Name="enter", SupportPan = true }
t[#t+1] = LoadActor( THEME:GetPathS("common", "invalid"))..{ Name="invalid", SupportPan = true }
t[#t+1] = LoadActor( THEME:GetPathS("ScreenTextEntry", "type.ogg"))..{ Name="type", SupportPan = true }

-- Header
t[#t+1] = LoadActor("Header.lua")

--
return t
