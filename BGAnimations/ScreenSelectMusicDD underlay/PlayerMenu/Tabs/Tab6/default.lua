--- Here is all the info necessary for Tab 6
local args = ...

local player = args.player
local padding = args.padding
local border = args.border
local width = args.width
local height = args.height
local XPos = args.XPos
local YPos = args.YPos
local TabWidth = args.TabWidth
local af = args.af

local pn = ToEnumShortString(player)
local Style = GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerOneSide" and  THEME:GetString("ScreenSelectMusicDD","Double") or THEME:GetString("ScreenSelectMusicDD","Single")
local Mode = GAMESTATE:IsCourseMode() and THEME:GetString("DDPlayerMenu","SongWheel") or THEME:GetString("DDPlayerMenu","CourseMode")
local ExpectedTab = 6
-----------------------------------------------------------------------------------------------------

local SystemNames = {
-- load in new songs
THEME:GetString("DDPlayerMenu","LoadNewSongs"),
}

-- Don't show downloads page if not connected to the internet.
if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
	SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","Downloads")
end

-- Don't show switching styles if both players are in.
if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
	SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","SwitchStyle").." "..Style
end

-- switch between song select and course mode
SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","SwitchMode").." "..Mode

-- Don't show if not connected to GS
if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
	SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","Leaderboards")
end

-- Show player set summary mid set only if they've played at least one song.
if SL.Global.Stages.PlayedThisGame > 0 then
	SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","ViewSetSummary")
end

-- test input
SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","TestInput")


-- Practice mode
SystemNames[#SystemNames+1] = THEME:GetString("DDPlayerMenu","Practice")

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

for i=1, #SystemNames do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."System"..i,
		InitCommand=function(self)
			local zoom = 0.8
			self:horizalign(center):vertalign(middle):shadowlength(1)
				:draworder(2)
				:x(XPos + padding/2 + border/2 + width/2)
				:y(YPos - height/2 + border + (i*20) + 15)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(SystemNames[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
		["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab == 6 then
				-- This lets us have a dynamic list more easily
				local CurrentText
				if CurrentRow ~= 0 then
					CurrentText = self:GetParent():GetChild(pn.."System"..CurrentRow):GetText()
				else
					CurrentText = ""
				end
				
				if CurrentText == THEME:GetString("DDPlayerMenu","LoadNewSongs") then
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSongsSSM")
					SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
				elseif CurrentText == THEME:GetString("DDPlayerMenu","Downloads") then
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenViewDownloads")
					SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
				elseif CurrentText == THEME:GetString("DDPlayerMenu","SwitchStyle").." "..Style then
					MESSAGEMAN:Broadcast("DDSwitchStyles")
				elseif CurrentText == THEME:GetString("DDPlayerMenu","SwitchMode").." "..Mode then
					MESSAGEMAN:Broadcast("DDSwitchPlayMode")
				elseif CurrentText == THEME:GetString("DDPlayerMenu","Leaderboards") then
					local curSong = GAMESTATE:GetCurrentSong()
					if curSong then
						LeadboardHasFocus = true
						MESSAGEMAN:Broadcast("ShowLeaderboard")
					else
						SM("No song selected!")
					end
				elseif CurrentText == THEME:GetString("DDPlayerMenu","ViewSetSummary") then
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenEvaluationSummarySet")
					SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
				elseif CurrentText == THEME:GetString("DDPlayerMenu","TestInput") then
					InputMenuHasFocus = true
					MESSAGEMAN:Broadcast("ShowTestInput")
				elseif CurrentText == THEME:GetString("DDPlayerMenu","Practice") then
					if GAMESTATE:GetCurrentSong() ~= nil then
						SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPractice")
						SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
					else
						SM("No song selected!")
					end
				end
				if i == CurrentRow then
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				end
			end
		end,
		CurrentSongChangedMessageCommand=function(self)
			if GAMESTATE:GetCurrentSong() == nil then
				-- make leaderboard and practice mode text grey if no song is selected
				for i=1, #SystemNames do
					if self:GetParent():GetChild(pn.."System"..i):GetText() == THEME:GetString("DDPlayerMenu","Leaderboards") or
						self:GetParent():GetChild(pn.."System"..i):GetText() == THEME:GetString("DDPlayerMenu","Practice") then
							self:GetParent():GetChild(pn.."System"..i):diffuse(color("#4d4d4d"))
					end
				end
			else
				-- make sure they are white when a song is selected however.
				for i=1, #SystemNames do
					if self:GetParent():GetChild(pn.."System"..i):GetText() == THEME:GetString("DDPlayerMenu","Leaderboards") or
						self:GetParent():GetChild(pn.."System"..i):GetText() == THEME:GetString("DDPlayerMenu","Practice") then
							self:GetParent():GetChild(pn.."System"..i):diffuse(color("#FFFFFF"))
					end
				end
			end
		end,
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if pn == "P1" and not PlayerMenuP1 then return end
			if pn == "P2" and not PlayerMenuP2 then return end
			if CurrentTab ~= 6 then return end
			for j=1, #SystemNames do
				local Parent = self:GetParent():GetChild(pn.."System"..j)
				local ObjectZoom = Parent:GetZoom()
				local ObjectWidth = Parent:GetWidth() * ObjectZoom
				local ObjectHeight = Parent:GetHeight()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 6 then
					CurrentRow = j
					local CurrentText
					if CurrentRow ~= 0 then
						CurrentText = self:GetParent():GetChild(pn.."System"..j):GetText()
					else
						CurrentText = ""
					end
					
					if CurrentText == THEME:GetString("DDPlayerMenu","LoadNewSongs") then
						SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSongsSSM")
						SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
					elseif CurrentText == THEME:GetString("DDPlayerMenu","Downloads") then
						SCREENMAN:GetTopScreen():SetNextScreenName("ScreenViewDownloads")
						SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
					elseif CurrentText == THEME:GetString("DDPlayerMenu","SwitchStyle").." "..Style then
						MESSAGEMAN:Broadcast("DDSwitchStyles")
					elseif CurrentText == THEME:GetString("DDPlayerMenu","SwitchMode").." "..Mode then
						MESSAGEMAN:Broadcast("DDSwitchPlayMode")
					elseif CurrentText == THEME:GetString("DDPlayerMenu","Leaderboards") then
						local curSong = GAMESTATE:GetCurrentSong()
						if curSong then
							LeadboardHasFocus = true
							MESSAGEMAN:Broadcast("ShowLeaderboard")
						else
							SM("No song selected!")
						end
					elseif CurrentText == THEME:GetString("DDPlayerMenu","ViewSetSummary") then
						SCREENMAN:GetTopScreen():SetNextScreenName("ScreenEvaluationSummarySet")
						SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
					elseif CurrentText == THEME:GetString("DDPlayerMenu","TestInput") then
						InputMenuHasFocus = true
						MESSAGEMAN:Broadcast("ShowTestInput")
					elseif CurrentText == THEME:GetString("DDPlayerMenu","Practice") then
						if GAMESTATE:GetCurrentSong() ~= nil then
							SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPractice")
							SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
						else
							SM("No song selected!")
						end
					end
					if j == i then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					
				end
			end
			if pn == "P1" then
				CurrentTabP1 = CurrentTab
				CurrentRowP1 = CurrentRow
				CurrentColumnP1 = CurrentColumn
			elseif pn == "P2" then
				CurrentTabP2 = CurrentTab
				CurrentRowP2 = CurrentRow
				CurrentColumnP2 = CurrentColumn
			end
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		
		end,
	}
end

-------------------------------------------------------------
local Mod6Descriptions = {
-- load new songs
THEME:GetString("OptionExplanations","LoadNewSongs"),
}

-- downloads
if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
	Mod6Descriptions[#Mod6Descriptions+1] = THEME:GetString("OptionExplanations","ViewDownloads")
end

-- switch between single/double
if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
	Mod6Descriptions[#Mod6Descriptions+1] = THEME:GetString("OptionExplanations","SwitchTo")
end

-- switch between song select and course mode
Mod6Descriptions[#Mod6Descriptions+1] =  THEME:GetString("OptionExplanations","GoTo")

-- GS Leaderboard
if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
	Mod6Descriptions[#Mod6Descriptions+1] =  THEME:GetString("OptionExplanations","Leaderboards")
end

-- View Set Summary
if SL.Global.Stages.PlayedThisGame > 0 then
	Mod6Descriptions[#Mod6Descriptions+1] =  THEME:GetString("OptionExplanations","ViewSetSummary")
end

-- test input
Mod6Descriptions[#Mod6Descriptions+1] =  THEME:GetString("OptionExplanations","TestInput")

-- Practice mode
Mod6Descriptions[#Mod6Descriptions+1] =  THEME:GetString("OptionExplanations","PracticeSong")

-- Bottom Information for mods
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."Mod6Descriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(Mod6Descriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 or CurrentTabP1 ~= 6 then
				self:visible(false)
			else
				self:settext(Mod6Descriptions[CurrentRowP1])
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0  or CurrentTabP2 ~= 6 then
				self:visible(false)
				
			else
				self:settext(Mod6Descriptions[CurrentRowP2])
				self:visible(true)
			end
		end
	end,
	DDSwitchPlayModeMessageCommand=function(self)
		self:sleep(0.2):queuecommand('UpdatePlayMode')
	end,
	UpdatePlayModeCommand=function(self)
		SwitchSongCourseSelect(GAMESTATE:GetPlayMode())
	end,
}