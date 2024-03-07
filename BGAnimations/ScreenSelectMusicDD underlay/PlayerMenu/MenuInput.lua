--- I hate that I can't just make these like 'CurrentTab..pn' WHY?!?!?!?!?
CurrentTabP1 = 1
CurrentRowP1 = 0
CurrentColumnP1 = 1

CurrentTabP2 = 1
CurrentRowP2 = 0
CurrentColumnP2 = 1

local ColumnPerRow1 = {
3,
1,
1,
1,
1,
1,
1,
3,
4,
1,
}

local ColumnPerRow2 = {
5,
5,
4,
4,
3,
1,
1,
1,
}

local ColumnPerRow3 = {
3,
3,
1,
3,
2,
2,
4,
3,
6,
3,
2,
2,
1,
2,
2,
}

local ColumnPerRow4 = {
4,
3,
4,
4,
2,
2,
3,
2,
4,
5,
4,
3,
2,
}

local ColumnPerRow5 = {
1,
1,
1,
1,
1,
4,
2,
1,
1,
1,
1,
3,
3,
1,
}

-- Column 6 is special in that the list is dynamic based on the current game state.
-- load new songs
local ColumnPerRow6 = {
1,
}

-- downloads page option
if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
	ColumnPerRow6[#ColumnPerRow6+1] = 1
end

-- switch between single/double
if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
	ColumnPerRow6[#ColumnPerRow6+1] = 1
end

-- switch between song select and course mode
ColumnPerRow6[#ColumnPerRow6+1] = 1

-- GS Leaderboard
if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
	ColumnPerRow6[#ColumnPerRow6+1] = 1
end

-- test input
ColumnPerRow6[#ColumnPerRow6+1] = 1

-- Practice mode
if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' and GAMESTATE:IsPlayerEnabled(0) then 
	ColumnPerRow6[#ColumnPerRow6+1] = 1
end

local RowPerTab = {
#ColumnPerRow1,
#ColumnPerRow2,
#ColumnPerRow3,
#ColumnPerRow4,
#ColumnPerRow5,
#ColumnPerRow6,
}

local TabsTable = {
	ColumnPerRow1,
	ColumnPerRow2,
	ColumnPerRow3,
	ColumnPerRow4,
	ColumnPerRow5,
	ColumnPerRow6,
}


-- Thank god I can move this input here.
local InputHandler = function( event )
	
	-- Allow Mouse Input here
	if event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Release" and not IsSearchMenuVisible and not EscapeFromEventMode and IsMouseOnScreen() then
		if not LeadboardHasFocus and not InputMenuHasFocus then
			if event.DeviceInput.button == "DeviceButton_left mouse button" then
				MESSAGEMAN:Broadcast("LeftMouseClickUpdate")
			end
		end
	end
	
	if not ((event.PlayerNumber == "PlayerNumber_P1" and PlayerMenuP1) or (event.PlayerNumber == "PlayerNumber_P2" and PlayerMenuP2)) then return end
	local CurrentTab, CurrentRow, CurrentColumn
	local MaxRow, MaxColumn
	local Direction
	
	if event.PlayerNumber == "PlayerNumber_P1" then
		CurrentTab = CurrentTabP1
		CurrentRow = CurrentRowP1
		CurrentColumn = CurrentColumnP1
	elseif event.PlayerNumber == "PlayerNumber_P2" then
		CurrentTab = CurrentTabP2
		CurrentRow = CurrentRowP2
		CurrentColumn = CurrentColumnP2
	end
	
	if event.type ~= "InputEventType_Release" and not IsSearchMenuVisible and not LeadboardHasFocus and not InputMenuHasFocus and not EscapeFromEventMode then
		local IsHeld = false
		if event.GameButton == "MenuRight" then
			if CurrentRow == 0 then
				if CurrentTab == 6 then
					CurrentTab = 1
				else
					CurrentTab = CurrentTab + 1
				end
			else
				MaxColumn = TabsTable[CurrentTab][CurrentRow]
				if CurrentColumn == MaxColumn then
					CurrentColumn = 1
				else
					CurrentColumn = CurrentColumn + 1
				end
			end
			Direction = "right"
		elseif event.GameButton == "MenuLeft" then
			if CurrentRow == 0 then
				if CurrentTab == 1 then
					CurrentTab = 6
				else
					CurrentTab = CurrentTab - 1
				end
			else
				MaxColumn = TabsTable[CurrentTab][CurrentRow]
				if CurrentColumn == 1 then
					CurrentColumn = MaxColumn
				else
					CurrentColumn = CurrentColumn - 1
				end
			end
			Direction="left"
		elseif event.GameButton == "MenuUp" and event.type == "InputEventType_FirstPress" then
			MaxRow = RowPerTab[CurrentTab]
			CurrentColumn = 1
			if CurrentRow == 0 then
				CurrentRow = MaxRow
			else
				CurrentRow = CurrentRow - 1
			end
			Direction="up"
		elseif event.GameButton == "MenuDown" and event.type == "InputEventType_FirstPress" then
			MaxRow = RowPerTab[CurrentTab]
			CurrentColumn = 1
			if CurrentRow == MaxRow then
				CurrentRow = 0
			else
				CurrentRow = CurrentRow + 1
			end
			Direction="down"
		elseif event.GameButton == "Start" and event.type == "InputEventType_FirstPress" then
			if event.PlayerNumber == "PlayerNumber_P1" then
				MESSAGEMAN:Broadcast("PlayerMenuSelectionP1")
			elseif event.PlayerNumber == "PlayerNumber_P2" then
				MESSAGEMAN:Broadcast("PlayerMenuSelectionP2")
			end
		end
		if event.type ~= "InputEventType_Release" and event.type ~= "InputEventType_FirstPress" then
			IsHeld = true
		end
		
		if event.PlayerNumber == "PlayerNumber_P1" then
			CurrentTabP1 = CurrentTab
			CurrentRowP1 = CurrentRow
			CurrentColumnP1 = CurrentColumn
			MESSAGEMAN:Broadcast("UpdateMenuCursorPositionP1", {Direction, IsHeld})
		elseif event.PlayerNumber == "PlayerNumber_P2" then
			CurrentTabP2 = CurrentTab
			CurrentRowP2 = CurrentRow
			CurrentColumnP2 = CurrentColumn
			MESSAGEMAN:Broadcast("UpdateMenuCursorPositionP2", {Direction, IsHeld})
		end
	end
end

local t = Def.ActorFrame{
	Name="PlayerMenuInput",
	OnCommand=function(self)
		screen = SCREENMAN:GetTopScreen()
		screen:AddInputCallback(InputHandler)
	end,
}


return t