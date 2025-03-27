local player = ...
local args = ...
local GroupWheel = args.GroupWheel
local SongWheel = args.SongWheel
local nsj = GAMESTATE:GetNumSidesJoined()
local holdingCtrl
local CtrlHeld = 0
local WheelWidth = SCREEN_WIDTH/3

local ChartUpdater = LoadActor("./UpdateChart.lua")
local screen = SCREENMAN:GetTopScreen()
-- initialize Players to be any HumanPlayers at screen init
-- we'll update this later via latejoin if needed
local Players = GAMESTATE:GetHumanPlayers()

IsSearchMenuVisible = false
IsTagsMenuVisible = false
InputMenuHasFocus = false
LeadboardHasFocus = false
PlayerMenuP1 = false
PlayerMenuP2 = false
MusicWheelNeedsResetting = false

-----------------------------------------------------
-- input handler
local t = {}
-----------------------------------------------------


local SwitchInputFocus = function(button)
	if button == "Start" or "DeviceButton_left mouse button" and not IsSearchMenuVisible and not IsTagsMenuVisible then
		if t.WheelWithFocus == GroupWheel then
			if NameOfGroup == "RANDOM-PORTAL" then
				SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				t.WheelWithFocus = SongWheel
				SCREENMAN:GetTopScreen():SetNextScreenName( "ScreenGameplay" ):StartTransitioningScreen("SM_GoToNextScreen")
			else
				MESSAGEMAN:Broadcast("SwitchFocusToSongs")
				t.WheelWithFocus = SongWheel
			end

		elseif t.WheelWithFocus == SongWheel then
			SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
			SCREENMAN:GetTopScreen():SetNextScreenName( "ScreenGameplay" ):StartTransitioningScreen("SM_GoToNextScreen")
		end
	elseif button == "Select" or button == "Back" then
		if t.WheelWithFocus == SongWheel and not IsSearchMenuVisible and not IsTagsMenuVisible then
			t.WheelWithFocus = GroupWheel
		end

	end
end

-- calls needed to close the current group folder and return to choosing a group
local CloseCurrentFolder = function()
	-- if focus is already on the GroupWheel, we don't need to do anything more
	if t.WheelWithFocus == GroupWheel then 
	NameOfGroup = ""
	return end
	
	if SongSearchWheelNeedsResetting == true then
		SongSearchSSMDD = false
		SongSearchAnswer = nil
		SongSearchWheelNeedsResetting = false
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSMDD")
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	else	
		-- otherwise...
		t.Enabled = false
		MESSAGEMAN:Broadcast("SwitchFocusToGroups")
		t.WheelWithFocus.container:queuecommand("Hide")
		t.WheelWithFocus = GroupWheel
		t.WheelWithFocus.container:queuecommand("Unhide")
	end
end

t.AllowLateJoin = function()
	-- Only allow LateJoin if playing single and if enabled in the operator menu.
	if GAMESTATE:GetCurrentStyle():GetName() ~= "single" then return false end
	if not ThemePrefs.Get("AllowLateJoin") then return false end
	return true
end

-----------------------------------------------------
-- start internal functions

t.Init = function()
	-- flag used to determine whether input is permitted
	-- false at initialization
	t.Enabled = false
	-- initialize which wheel gets focus to start based on whether or not
	-- GAMESTATE has a CurrentSong (it always should at screen init)
	t.WheelWithFocus = GAMESTATE:GetCurrentSong() and SongWheel or GroupWheel
	
end

local lastMenuUpPressTime = 0
local lastMenuDownPressTime = 0

t.Handler = function(event)
	-- Input to open the song search menu or reload a single song on the wheel. Keep track of both left and right Ctrl being held.
	if event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Release" then
		if not IsSearchMenuVisible and not IsTagsMenuVisible then
			if event.DeviceInput.button == "DeviceButton_left ctrl" or event.DeviceInput.button == "DeviceButton_right ctrl" then
				CtrlHeld = CtrlHeld + 1
			end
			
			if CtrlHeld > 0 then
				holdingCtrl = true
			end
			
			if holdingCtrl then
				if event.DeviceInput.button == "DeviceButton_f" then
					stop_music()
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
					MESSAGEMAN:Broadcast("InitializeSearchMenu")
					MESSAGEMAN:Broadcast("ToggleSearchMenu")
				elseif event.DeviceInput.button == "DeviceButton_r" and GAMESTATE:GetCurrentSong() ~= nil then
					local song = GAMESTATE:GetCurrentSong()
					song:ReloadFromSongDir()
					MESSAGEMAN:Broadcast("SongIsReloading")
				elseif event.DeviceInput.button == "DeviceButton_t" then
					stop_music()
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
					MESSAGEMAN:Broadcast('ToggleTagsMenu')
				end
			end
		end
		
		if (event.DeviceInput.button == "DeviceButton_escape" or  event.GameButton == "Back") and IsSearchMenuVisible and not IsTagsMenuVisible then
			SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
			MESSAGEMAN:Broadcast("ToggleSearchMenu")
		end
	end
	
	if event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" or event.DeviceInput.button == "DeviceButton_right ctrl" then
			CtrlHeld = CtrlHeld - 1
			if CtrlHeld < 0 then
				CtrlHeld = 0
			end
		end
		if CtrlHeld == 0 then
			holdingCtrl = false
		end
	end
	
	-- Allow Mouse Input here
	if event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Release" and not IsSearchMenuVisible and not IsTagsMenuVisible then
		if IsMouseOnScreen() then
			if not LeadboardHasFocus and not InputMenuHasFocus then
				-- Close the song folder and switch to group wheel if mouse wheel is pressed.
				if event.DeviceInput.button == "DeviceButton_middle mouse button" and t.WheelWithFocus == SongWheel then
					stop_music()
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					MESSAGEMAN:Broadcast("CloseCurrentFolder")
					CloseCurrentFolder()
				end
				
				-- Scroll the song wheel up/down with the mouse wheel.
				if event.DeviceInput.button == "DeviceButton_mousewheel up" then
					-- don't scroll the wheel for P1 difficulty select if they are enabled
					if IsMouseGucci(0, _screen.h - 152, SCREEN_WIDTH/3, 50, "left", "bottom") and not PlayerMenuP1 then
						if GAMESTATE:IsHumanPlayer("PlayerNumber_P1") then
							ChartUpdater.DecreaseDifficulty("PlayerNumber_P1")
						else
							t.WheelWithFocus:scroll_by_amount(-1)
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
							stop_music()
							ChartUpdater.UpdateCharts()
						end
					-- don't scroll the wheel for P2 difficulty select if they are enabled
					elseif IsMouseGucci(SCREEN_RIGHT, _screen.h - 152, SCREEN_WIDTH/3, 50, "right", "bottom") and not PlayerMenuP2 then
						if GAMESTATE:IsHumanPlayer("PlayerNumber_P2") then
							ChartUpdater.DecreaseDifficulty("PlayerNumber_P2")
						else
							t.WheelWithFocus:scroll_by_amount(-1)
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
							stop_music()
							ChartUpdater.UpdateCharts()
						end
					-- don't scroll the wheel on the left side of the screen if p1 has their menu open
					elseif IsMouseGucci(0,SCREEN_CENTER_Y,SCREEN_WIDTH/3,SCREEN_HEIGHT,"left","middle") and not PlayerMenuP1 then
						t.WheelWithFocus:scroll_by_amount(-1)
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						stop_music()
						ChartUpdater.UpdateCharts()
					-- don't scroll the wheel on the right side of the screen if p2 has their menu open
					elseif IsMouseGucci((SCREEN_WIDTH) - (SCREEN_WIDTH/3),SCREEN_CENTER_Y,SCREEN_WIDTH/3,SCREEN_HEIGHT,"left","middle") and not PlayerMenuP2 then
						t.WheelWithFocus:scroll_by_amount(-1)
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						stop_music()
						ChartUpdater.UpdateCharts()
					elseif IsMouseGucci(SCREEN_WIDTH/3,SCREEN_CENTER_Y,SCREEN_WIDTH/3,SCREEN_HEIGHT,"left","middle") then
						t.WheelWithFocus:scroll_by_amount(-1)
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						stop_music()
						ChartUpdater.UpdateCharts()
					end
				elseif event.DeviceInput.button == "DeviceButton_mousewheel down" then
					-- don't scroll the wheel for P1 difficulty select if they are enabled
					if IsMouseGucci(0, _screen.h - 152, SCREEN_WIDTH/3, 50, "left", "bottom") and not PlayerMenuP1 then
						if GAMESTATE:IsHumanPlayer("PlayerNumber_P1") then
							ChartUpdater.IncreaseDifficulty("PlayerNumber_P1")
						else
							t.WheelWithFocus:scroll_by_amount(1)
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
							stop_music()
							ChartUpdater.UpdateCharts()
						end
					-- don't scroll the wheel for P2 difficulty select if they are enabled
					elseif IsMouseGucci(SCREEN_RIGHT, _screen.h - 152, SCREEN_WIDTH/3, 50, "right", "bottom") and not PlayerMenuP2 then
						if GAMESTATE:IsHumanPlayer("PlayerNumber_P2") then
							ChartUpdater.IncreaseDifficulty("PlayerNumber_P2")
						else
							t.WheelWithFocus:scroll_by_amount(1)
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
							stop_music()
							ChartUpdater.UpdateCharts()
						end
					-- don't scroll the wheel on the left side of the screen if p1 has their menu open
					elseif IsMouseGucci(0,SCREEN_CENTER_Y,SCREEN_WIDTH/3,SCREEN_HEIGHT,"left","middle") and not PlayerMenuP1 then
						t.WheelWithFocus:scroll_by_amount(1)
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						stop_music()
						ChartUpdater.UpdateCharts()
					-- don't scroll the wheel on the right side of the screen if p2 has their menu open
					elseif IsMouseGucci((SCREEN_WIDTH) - (SCREEN_WIDTH/3),SCREEN_CENTER_Y,SCREEN_WIDTH/3,SCREEN_HEIGHT,"left","middle") and not PlayerMenuP2 then
						t.WheelWithFocus:scroll_by_amount(1)
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						stop_music()
						ChartUpdater.UpdateCharts()
					elseif IsMouseGucci(SCREEN_WIDTH/3,SCREEN_CENTER_Y,SCREEN_WIDTH/3,SCREEN_HEIGHT,"left","middle") then
						t.WheelWithFocus:scroll_by_amount(1)
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						stop_music()
						ChartUpdater.UpdateCharts()
					end
				end
				
				-- Jump the songwheel to a song/group clicked on by the left mouse button. Or toggle player menu on.
				if event.DeviceInput.button == "DeviceButton_left mouse button" then
					for i=1, 5 do
						if IsMouseGucci(_screen.cx, (_screen.cy + 45) - (i*25), WheelWidth, 24) then
							t.WheelWithFocus:scroll_by_amount(-i)
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
							stop_music()
							ChartUpdater.UpdateCharts()
						end
					end
					
					for i=1, 6 do
						if IsMouseGucci(_screen.cx, (_screen.cy + 45) + (i*25), WheelWidth, 24) then
							t.WheelWithFocus:scroll_by_amount(i)
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
							stop_music()
							ChartUpdater.UpdateCharts()
						end
					end
					
					if IsMouseGucci(_screen.cx, (_screen.cy + 45), WheelWidth, 24) then
						if t.WheelWithFocus == SongWheel and (not PlayerMenuP1 and not PlayerMenuP2) then
							if t.WheelWithFocus:get_info_at_focus_pos() ~= "CloseThisFolder" then
								SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
								SCREENMAN:GetTopScreen():SetNextScreenName( "ScreenGameplay" ):StartTransitioningScreen("SM_GoToNextScreen")
							elseif t.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" then
								SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
								MESSAGEMAN:Broadcast("CloseCurrentFolder")
								CloseCurrentFolder()
								return false
							end
						elseif t.WheelWithFocus == GroupWheel then
							if NameOfGroup == "RANDOM-PORTAL" then
								SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
								SCREENMAN:GetTopScreen():SetNextScreenName( "ScreenGameplay" ):StartTransitioningScreen("SM_GoToNextScreen")
								t.WheelWithFocus = SongWheel
							else
								SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
								t.WheelWithFocus.container:queuecommand("Start")
								SwitchInputFocus(event.DeviceInput.button)

								if t.WheelWithFocus.container then
									t.WheelWithFocus.container:queuecommand("Unhide")
								end
							end
						--- We still want to be able to open/close the group wheel when another player has their menu open?
						elseif t.WheelWithFocus == SongWheel and t.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" and (PlayerMenuP1 or PlayerMenuP2) then
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
							MESSAGEMAN:Broadcast("CloseCurrentFolder")
							CloseCurrentFolder()
							return false
						end
					end
					
					-- Toggle the PlayerMenu on if the options button is clicked (and the menu isn't already open).
					if IsMouseGucci(SCREEN_WIDTH/3 - 20 - 60,148,65,21,"left","top") and not PlayerMenuP1 and GAMESTATE:IsSideJoined('PlayerNumber_P1') then
						PlayerMenuP1 = true
						stop_music()
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						MESSAGEMAN:Broadcast("ShowPlayerMenuP1")
					elseif IsMouseGucci( (SCREEN_WIDTH) - (SCREEN_WIDTH/3 - 20),148,65,21,"left","top") and not PlayerMenuP2 and GAMESTATE:IsSideJoined('PlayerNumber_P2') then
						PlayerMenuP2 = true
						stop_music()
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						MESSAGEMAN:Broadcast("ShowPlayerMenuP2")
					end
					
					-- Change the difficulty of the song when a player left clicks a chart.
					if GAMESTATE:IsSideJoined('PlayerNumber_P1') and not PlayerMenuP1 then
						-- Novice position
						if IsMouseGucci(3.5, _screen.h-157, 54, 42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty("PlayerNumber_P1", "Difficulty_Beginner")
						-- Easy Position
						elseif IsMouseGucci(59.5, _screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty('PlayerNumber_P1', "Difficulty_Easy")
						-- Medium Position
						elseif IsMouseGucci(115.5, _screen.h-157, 54,42, "left", "bottom", 1)  then
							ChartUpdater.ClickDifficulty('PlayerNumber_P1', "Difficulty_Medium")
						-- Hard Position
						elseif IsMouseGucci(171.5, _screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty('PlayerNumber_P1', "Difficulty_Hard")
						-- Expert/Edit Position
						elseif IsMouseGucci(227.5, _screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty('PlayerNumber_P1', "Difficulty_Challenge")
						end
					end
					if GAMESTATE:IsSideJoined('PlayerNumber_P2') and not PlayerMenuP2 then
						-- Novice position
						if IsMouseGucci((_screen.w/3*2 - 52.5) + 1*56, _screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty("PlayerNumber_P2", "Difficulty_Beginner")	
						-- Easy Position
						elseif IsMouseGucci((_screen.w/3*2 - 52.5) + 2*56,_screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty('PlayerNumber_P2', "Difficulty_Easy")
						-- Medium Position
						elseif IsMouseGucci((_screen.w/3*2 - 52.5) + 3*56, _screen.h-157, 54,42, "left", "bottom", 1)  then
							ChartUpdater.ClickDifficulty('PlayerNumber_P2', "Difficulty_Medium")
						-- Hard Position
						elseif IsMouseGucci((_screen.w/3*2 - 52.5) + 4*56, _screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty('PlayerNumber_P2', "Difficulty_Hard")
						-- Expert/Edit Position
						elseif IsMouseGucci((_screen.w/3*2 - 52.5) + 5*56, _screen.h-157, 54,42, "left", "bottom", 1) then
							ChartUpdater.ClickDifficulty('PlayerNumber_P2', "Difficulty_Challenge")
						end
					end
					-- update steps display pane if a tab is clicked.
					if GAMESTATE:IsSideJoined('PlayerNumber_P1') and not PlayerMenuP1 then
						-- the first and last tabs are slightly bigger than the middle tabs
						if IsMouseGucci(2.5,_screen.h-149.5,33, 14,"left","top",1) then
							MESSAGEMAN:Broadcast("TabClickedPlayerNumber_P1", {1})
						end
						for i=1,4 do
							if IsMouseGucci(3.5 + (i*32),_screen.h-149.5, i+1 == MaxTabs and 33 or 32, 14, "left", "top", 1) then
								local TabCount = i + 1
								if TabCount <= MaxTabs then
									MESSAGEMAN:Broadcast("TabClickedPlayerNumber_P1", {TabCount})
								end
							end
						end
						-- the first and last tabs are slightly bigger than the middle tabs
						if IsMouseGucci(163.5,_screen.h-149.5,33, 14,"left","top",1) then
							if MaxTabs == 6 then
								MESSAGEMAN:Broadcast("TabClickedPlayerNumber_P1", {6})
							end
						end
					end
					if GAMESTATE:IsSideJoined('PlayerNumber_P2') and not PlayerMenuP2 then
						-- the first and last tabs are slightly bigger than the middle tabs
						if IsMouseGucci((_screen.w - _screen.w/3) + 2.5,_screen.h-149.5,33, 14,"left","top",1) then
							MESSAGEMAN:Broadcast("TabClickedPlayerNumber_P2", {1})
						end
						for i=1,4 do
							if IsMouseGucci((_screen.w - _screen.w/3) + 3.5 + (i*32),_screen.h-149.5, i+1 == MaxTabs and 33 or 32, 14, "left", "top", 1) then
								local TabCount = i + 1
								if TabCount <= MaxTabs then
									MESSAGEMAN:Broadcast("TabClickedPlayerNumber_P2", {TabCount})
								end
							end
						end
						-- the first and last tabs are slightly bigger than the middle tabs
						if IsMouseGucci((_screen.w - _screen.w/3) + 3.5 + (5*32),_screen.h-149.5,33, 14,"left","top",1) then
							if MaxTabs == 6 then
								MESSAGEMAN:Broadcast("TabClickedPlayerNumber_P2", {6})
							end
						end
					end
					--- Change the preview music if clicking on the density graph.
					if IsMouseGucci(0,_screen.h - (235), SCREEN_WIDTH/3, 64, "left", "bottom") and GAMESTATE:IsSideJoined('PlayerNumber_P1') and not PlayerMenuP1 then
						update_sample_music(INPUTFILTER:GetMouseX())
						MESSAGEMAN:Broadcast('DrawCursorMouse', {"P1"})
					elseif IsMouseGucci(SCREEN_RIGHT - (SCREEN_WIDTH/3),_screen.h - (235), SCREEN_WIDTH/3, 64, "left", "bottom") and GAMESTATE:IsSideJoined('PlayerNumber_P2') and not PlayerMenuP2  then
						local Xpos = INPUTFILTER:GetMouseX()
						update_sample_music(Xpos - (SCREEN_WIDTH/3 * 2))
						MESSAGEMAN:Broadcast('DrawCursorMouse', {"P2"})
					end
					
				end
			--- Test input mouse controls
			elseif InputMenuHasFocus and not LeadboardHasFocus then
				if event.DeviceInput.button == "DeviceButton_right mouse button" then
					InputMenuHasFocus = false
					SOUND:PlayOnce( THEME:GetPathS("common", "start.ogg") )
					MESSAGEMAN:Broadcast("HideTestInput")
				end
				-- Leaderboard input mouse controls
			elseif LeadboardHasFocus and not InputMenuHasFocus then
				if event.DeviceInput.button == "DeviceButton_right mouse button" or event.DeviceInput.button == "DeviceButton_left mouse button" then
					LeadboardHasFocus = false
					SOUND:PlayOnce( THEME:GetPathS("common", "start.ogg") )
					MESSAGEMAN:Broadcast("HideLeaderboard")
				end
				if event.DeviceInput.button == "DeviceButton_mousewheel up" or event.DeviceInput.button == "DeviceButton_mousewheel down" then
					if event.type ~= "InputEventType_Repeat" then
						MESSAGEMAN:Broadcast("LeaderboardMouseInputEvent", event)
					end
				end
			end
		end
	end
	
	-- Toggle PlayerMenu Input on/off
	if event.type ~= "InputEventType_Release" and not IsSearchMenuVisible and not LeadboardHasFocus and not InputMenuHasFocus and not IsTagsMenuVisible then
			-- Toggle the PlayerMenu on/off with select.
		if event.GameButton == "Select" and event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Repeat"  then
			if event.PlayerNumber == "PlayerNumber_P1" and GAMESTATE:IsSideJoined(event.PlayerNumber) then
				if PlayerMenuP1 then
					PlayerMenuP1 = false
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					if MusicWheelNeedsResetting then
						MESSAGEMAN:Broadcast("ReloadSSMDD")
					else
						CurrentRowP1 = 0
						CurrentColumnP1 = 1
						MESSAGEMAN:Broadcast("UpdateMenuCursorPositionP1")
						MESSAGEMAN:Broadcast("HidePlayerMenuP1")
					end
				else
					PlayerMenuP1 = true
					SOUND:StopMusic()
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					MESSAGEMAN:Broadcast("ShowPlayerMenuP1")
				end
			elseif event.PlayerNumber == "PlayerNumber_P2" and GAMESTATE:IsSideJoined(event.PlayerNumber) then
				if PlayerMenuP2 then
					PlayerMenuP2 = false
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					if MusicWheelNeedsResetting then
						MESSAGEMAN:Broadcast("ReloadSSMDD")
					else
						CurrentRowP2 = 0
						CurrentColumnP2 = 1
						MESSAGEMAN:Broadcast("UpdateMenuCursorPositionP2")
						MESSAGEMAN:Broadcast("HidePlayerMenuP2")
					end
				else
					PlayerMenuP2 = true
					SOUND:StopMusic()
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					MESSAGEMAN:Broadcast("ShowPlayerMenuP2")
				end
			end
		end
		
		-- exit the player menu if escape is pressed
		if event.GameButton == "Back" and event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Repeat" then
			if event.PlayerNumber == "PlayerNumber_P1" and GAMESTATE:IsSideJoined(event.PlayerNumber) and PlayerMenuP1 then
				-- we have to make these nil otherwise we'll back out of the game x_x
				PlayerMenuP1 = nil
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				if MusicWheelNeedsResetting then
					MESSAGEMAN:Broadcast("ReloadSSMDD")
				else
					MESSAGEMAN:Broadcast("HidePlayerMenuP1")
				end
			elseif event.PlayerNumber == "PlayerNumber_P2" and GAMESTATE:IsSideJoined(event.PlayerNumber) and PlayerMenuP2 then
				-- we have to make these nil otherwise we'll back out of the game x_x
				PlayerMenuP2 = nil
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				if MusicWheelNeedsResetting then
					MESSAGEMAN:Broadcast("ReloadSSMDD")
				else
					MESSAGEMAN:Broadcast("HidePlayerMenuP2")
				end
			end
		end
	end
	
	-- if any of these, don't attempt to handle input
	if t.Enabled == false or not event or not event.PlayerNumber or not event.button or IsSearchMenuVisible or IsTagsMenuVisible then
		return false
	end


	--- Input handler for the Test Input screen
	if InputMenuHasFocus then
		if not (event and event.PlayerNumber and event.button) then
			return false
		end
		-- don't handle input for a non-joined player
		if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
			return false
		end

		SOUND:StopMusic()

		local screen   = SCREENMAN:GetTopScreen()
		local overlay  = screen:GetChild("Overlay")

		-- broadcast event data using MESSAGEMAN for the TestInput overlay to listen for
		if event.type ~= "InputEventType_Repeat" then
			MESSAGEMAN:Broadcast("TestInputEvent", event)
		end

		-- pressing Start or Back (typically Esc on a keyboard) will queue "DirectInputToEngine"
		-- but only if the event.type is not a Release
		-- as soon as TestInput is activated, the player is likely still holding Start
		-- and will soon release it to start testing their input, which would inadvertently close TestInput
		if event.GameButton == "Back" and event.type ~= "InputEventType_Release" then
			InputMenuHasFocus = false
			SOUND:PlayOnce( THEME:GetPathS("common", "start.ogg") )
			MESSAGEMAN:Broadcast("HideTestInput")
		end

		return false
	end
	
	--- Input handler for the GS/RPG leaderboards
	if LeadboardHasFocus then
		if not (event and event.PlayerNumber and event.button) then
			return false
		end
		-- Don't handle input for a non-joined player.
		if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
			return false
		end

		SOUND:StopMusic()

		local screen   = SCREENMAN:GetTopScreen()
		local overlay  = screen:GetChild("Overlay")

		-- Broadcast event data using MESSAGEMAN for the Leaderboard overlay to listen for.
		if event.type ~= "InputEventType_Repeat" then
			MESSAGEMAN:Broadcast("LeaderboardInputEvent", event)
		end

		-- Pressing Start or Back (typically Esc on a keyboard) will queue "DirectInputToEngine"
		-- but only if the event.type is not a Release.
		-- As soon as the Leaderboard is activated, the player is likely still holding Start
		-- and will soon release it, which would inadvertently close the Leaderboard.
		if event.GameButton == "Back" and event.type ~= "InputEventType_Release" then
			LeadboardHasFocus = false
			SOUND:PlayOnce( THEME:GetPathS("common", "start.ogg") )
			MESSAGEMAN:Broadcast("HideLeaderboard")
		end

		return false
	end
	
	-- Don't allow input if a player has their Menu open.
	if event.PlayerNumber == "PlayerNumber_P1" and PlayerMenuP1 == true then return false end
	if event.PlayerNumber == "PlayerNumber_P2" and PlayerMenuP2 == true then return false end
	
	if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
		if not t.AllowLateJoin() then return false end
		if IsSearchMenuVisible or LeadboardHasFocus or InputMenuHasFocus or IsTagsMenuVisible then return false end

		-- latejoin
		if event.GameButton == "Start" then
			GAMESTATE:JoinPlayer( event.PlayerNumber )
			Players = GAMESTATE:GetHumanPlayers()
			MESSAGEMAN:Broadcast("ReloadSSMDD")
		end
		return false
	end

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "Back" and event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Repeat" then
			if not PlayerMenuP1 and not PlayerMenuP2 then
				if event.PlayerNumber == "PlayerNumber_P1" and PlayerMenuP1 == nil then
					PlayerMenuP1 = false
					return false
				elseif event.PlayerNumber == "PlayerNumber_P2" and PlayerMenuP2 == nil then
					PlayerMenuP2 = false
					return false
				end
				for i=1,2 do
					local player
					local pn
					if i == 1 then
						player = PLAYER_1
						pn = 0
					elseif i == 2 then
						player = PLAYER_2
						pn = 1
					end
					
					if GAMESTATE:IsPlayerEnabled(pn) and (PROFILEMAN:GetProfile(pn):GetDisplayName() == nil or PROFILEMAN:GetProfile(pn):GetDisplayName() == "") then
						MESSAGEMAN:Broadcast('ResetGuestStats', {player})
					end
				end
				SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen")
			end
		end
		
		-------------------------------------------------------------
		UpdateGroupWheelMessageCommand = function(self)
			t.WheelWithFocus:scroll_by_amount(1)
		end
		--------------------------------------------------------------
		-- proceed to the next wheel
		if event.GameButton == "Start" and not IsSearchMenuVisible and not (PlayerMenuP1 or PlayerMenuP2) and not IsTagsMenuVisible then
			if event.type == "InputEventType_FirstPress" then
				if NameOfGroup == "RANDOM-PORTAL" then
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					SCREENMAN:GetTopScreen():SetNextScreenName( "ScreenGameplay" ):StartTransitioningScreen("SM_GoToNextScreen")
					return
				end

				if t.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" then
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					CloseCurrentFolder()
					return false
				end

				if t.WheelWithFocus == GroupWheel and NameOfGroup ~= "RANDOM-PORTAL" then
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				end

				t.WheelWithFocus.container:queuecommand("Start")
				SwitchInputFocus(event.GameButton)

				if t.WheelWithFocus.container then
					t.WheelWithFocus.container:queuecommand("Unhide")
				end
			end
		-- navigate the wheel left and right
		elseif event.GameButton == "MenuRight" and not holdingCtrl then
			t.WheelWithFocus:scroll_by_amount(1)
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			stop_music()
			ChartUpdater.UpdateCharts()
		elseif event.GameButton == "MenuLeft" and not holdingCtrl then
			t.WheelWithFocus:scroll_by_amount(-1)
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			stop_music()
			ChartUpdater.UpdateCharts()
		elseif event.GameButton == "MenuUp" or event.button == "Up" then
			if event.type == "InputEventType_FirstPress" then
				local t = GetTimeSinceStart()
				local dt = t - lastMenuUpPressTime
				lastMenuUpPressTime = t
				if dt < 0.5 then
					ChartUpdater.DecreaseDifficulty(event.PlayerNumber)
					lastMenuUpPressTime = 0
				end
			end
		elseif event.GameButton == "MenuDown" or event.button == "Down" then
			if event.type == "InputEventType_FirstPress" then
				local t = GetTimeSinceStart()
				local dt = t - lastMenuDownPressTime
				lastMenuDownPressTime = t
				if dt < 0.5 then
					ChartUpdater.IncreaseDifficulty(event.PlayerNumber)
					lastMenuDownPressTime = 0
				end
			end
		end
	end


	return false
end

return t