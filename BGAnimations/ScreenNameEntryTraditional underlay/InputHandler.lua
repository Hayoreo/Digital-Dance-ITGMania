-- a reference to the primary ActorFrame
local args = ...
local t = args[1]

-- Arbitrary name character limit
local CharacterLimit = 12
local holdingShift = 0
local textBlink = false

-- Because we use KB input rather than menu buttons we need to fake player number.
local pn = "P1"
local PlayerNum = "PlayerNumber_P1"

if GAMESTATE:GetNumSidesJoined() == 2 then
	if SL["P1"].HighScores.EnteringName then
		pn = "P1"
		PlayerNum = "PlayerNumber_P1"
	elseif SL["P2"].HighScores.EnteringName then
		pn = "P2"
		PlayerNum = "PlayerNumber_P2"
	end
elseif GAMESTATE:IsSideJoined(0) and SL["P1"].HighScores.EnteringName then
	pn = "P1"
	PlayerNum = "PlayerNumber_P1"
elseif GAMESTATE:IsSideJoined(1) and SL["P2"].HighScores.EnteringName  then
	pn = "P2"
	PlayerNum = "PlayerNumber_P2"
end

local lowercaseSpecialCharacters = {
	period='.',
	space=' ',
	backslash='\\',
	comma=',',
	['KP 0']='0',
	['KP 1']='1',
	['KP 2']='2',
	['KP 3']='3',
	['KP 4']='4',
	['KP 5']='5',
	['KP 6']='6',
	['KP 7']='7',
	['KP 8']='8',
	['KP 9']='9',
	['KP /']='/',
	['KP *']='*',
	['KP -']='-',
	['KP +']='+',
	['KP .']='.',
}

local uppercaseSpecialCharacters = {
	period='>',
	space=' ',
	backslash='|',
	comma='<',
	['1']='!',
	['2']='@',
	['3']='#',
	['4']='$',
	['5']='%',
	['6']='^',
	['7']='&',
	['8']='*',
	['9']='(',
	['0']=')',
	['-']='_',
	['=']='+',
	['`']='~',
	['/']='?',
	['[']='{',
	[']']='}',
	[';']=':',
	["'"]='"',
}

local getLetterForButton = function(button)
	local buttonStr = tostring(button):sub(14)

	local characterTable
	if holdingShift > 0 then
		characterTable = uppercaseSpecialCharacters
	else
		characterTable = lowercaseSpecialCharacters
	end

	local letter = characterTable[buttonStr]
	if letter ~= nil then
		return letter
	end

	if buttonStr:len() == 1 then
		if holdingShift > 0 then
			return buttonStr:upper()
		else
			return buttonStr
		end
	end

	return nil
end

-- Define the input handler
local InputHandler = function(event)

	if not event then return end
	-- a local function to delete a character from a player's highscore name
	local function RemoveLastCharacter(pn)
		if SL[pn].HighScores.Name:len() > 0 then
			-- remove the last character
			SL[pn].HighScores.Name = SL[pn].HighScores.Name:sub(1, -2)
			-- update the display
			MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
			-- play the "delete" sound
			t:GetChild("delete"):playforplayer(PlayerNum)
		else
			-- there's nothing to delete, so play the "invalid" sound
			t:GetChild("invalid"):playforplayer(PlayerNum)
		end
	end

	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left shift" or event.DeviceInput.button == "DeviceButton_right shift" then
			holdingShift = holdingShift + 1
		end
	end	
	
	if event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat" then
		if event.type ~= "InputEventType_Release" then
			if event.GameButton == "MenuRight" then
				-- Swap between P1 and P2 keyboard input
				if pn == "P1" then
					if SL["P2"].HighScores.EnteringName then
						pn = "P2"
						PlayerNum = "PlayerNumber_P2"
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
					end
				elseif pn == "P2" then
					if SL["P1"].HighScores.EnteringName then
						pn = "P1"
						PlayerNum = "PlayerNumber_P1"
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
					end
				end
				
			elseif event.GameButton == "MenuLeft" then
				-- Swap between P1 and P2 keyboard input
				if pn == "P1" then
					if SL["P2"].HighScores.EnteringName then
						pn = "P2"
						PlayerNum = "PlayerNumber_P2"
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
					end
				elseif pn == "P2" then
					if SL["P1"].HighScores.EnteringName then
						pn = "P1"
						PlayerNum = "PlayerNumber_P1"
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
					end
				end
				
			elseif event.DeviceInput.button == "DeviceButton_enter" then

				if SL[pn].HighScores.EnteringName then
					SL[pn].HighScores.EnteringName = false
					t:GetChild("enter"):playforplayer(PlayerNum)
					-- Swap input to the other player if they need to submit still.
					if pn == "P1" then
						if SL["P2"].HighScores.EnteringName then
							pn = "P2"
							PlayerNum = "PlayerNumber_P2"
						end
					elseif pn == "P2" then
						if SL["P1"].HighScores.EnteringName then
							pn = "P1"
							PlayerNum = "PlayerNumber_P1"
						end
					end
					MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
				end

				-- check if we're ready to save scores and proceed to the next screen
				t:queuecommand("AttemptToFinish")
			elseif event.DeviceInput.button == 'DeviceButton_backspace' and SL[pn].HighScores.EnteringName then
				RemoveLastCharacter(pn)
			elseif  SL[pn].HighScores.Name:len() < CharacterLimit then
				local letter = getLetterForButton(event.DeviceInput.button)
				if letter ~= nil then
					t:GetChild("type"):playforplayer(PlayerNum)
					SL[pn].HighScores.Name = SL[pn].HighScores.Name .. letter
					-- update the display
					MESSAGEMAN:Broadcast("SetNamePlayer", {pn})
				end
			
			end
		end
	elseif event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left shift" or event.DeviceInput.button == "DeviceButton_right shift" then
			holdingShift = holdingShift - 1
			if holdingShift < 0 then
				holdingShift = 0
			end
		end
	end
end

return InputHandler
