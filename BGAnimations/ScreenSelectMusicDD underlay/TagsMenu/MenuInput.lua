local holdingShift = 0

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

local IllegalCharacters = {
 "/",
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

local IsIllegalCharacter = function(letter)
	for i=1, #IllegalCharacters do
		if letter == IllegalCharacters[i] then
			return true
		end
	end
	return false
end

-- Thank god I can move this input here.
local InputHandler = function( event )
	if not IsTagsMenuVisible then return end
	local Direction
	if event.type == "InputEventType_FirstPress" and (event.DeviceInput.button == "DeviceButton_left shift" or event.DeviceInput.button == "DeviceButton_right shift") then
		holdingShift = holdingShift + 1
	end
	-- Mouse input here
	if event.type == "InputEventType_FirstPress" and event.type ~= "InputEventType_Release" and event.DeviceInput.button == "DeviceButton_left mouse button" and IsMouseOnScreen() then
		MESSAGEMAN:Broadcast('TagMenuLeftClick')
	end
	-- Handle keyboard input for text entry
	if event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat" then
		if event.DeviceInput.device == "InputDevice_Key" then
			if CurrentTagSubMenu or AddTagSubMenu then
				if event.DeviceInput.button == 'DeviceButton_backspace' then
					MESSAGEMAN:Broadcast('CheckUpdateTagText', {"Backspace"})				
				else
					local letter = getLetterForButton(event.DeviceInput.button)
					if letter ~= nil and not IsIllegalCharacter(letter) then
						MESSAGEMAN:Broadcast('CheckUpdateTagText', {letter})
					end
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
	
	
	if event.type ~= "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_down" then
			Direction = "Down"
			MESSAGEMAN:Broadcast("UpdateTagCursor", {Direction})
		elseif event.DeviceInput.button == "DeviceButton_up" then
			Direction = "Up"
			MESSAGEMAN:Broadcast("UpdateTagCursor", {Direction})
		elseif event.DeviceInput.button == "DeviceButton_right" then
			Direction = "Right"
			MESSAGEMAN:Broadcast("UpdateTagCursor", {Direction})
		elseif event.DeviceInput.button == "DeviceButton_left" then
			Direction = "Left"
			MESSAGEMAN:Broadcast("UpdateTagCursor", {Direction})
		elseif event.GameButton == "Start" then
			MESSAGEMAN:Broadcast("TagSelectionMade")
		elseif (event.DeviceInput.button == "DeviceButton_escape" or  event.GameButton == "Back") then
			if not AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
				if not HaveTagsChanged then
					SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
					MESSAGEMAN:Broadcast("InitializeTagsMenu")
					MESSAGEMAN:Broadcast("ToggleTagsMenu")
				else
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
					MESSAGEMAN:Broadcast("ReloadSSMDD")
				end
			elseif AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				MESSAGEMAN:Broadcast("InitializeTagsMenu")
				MESSAGEMAN:Broadcast("ToggleAddTagsMenu")
			elseif RemoveTagSubMenu and not AddTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				MESSAGEMAN:Broadcast("InitializeTagsMenu")
				MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu")
			elseif ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu and not CurrentTagSubMenu then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				MESSAGEMAN:Broadcast("InitializeTagsMenu")
				MESSAGEMAN:Broadcast("ToggleManageTagsMenu")
			elseif CurrentTagSubMenu and not ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				CurrentTagSubMenu = false
				ManageTagsSubMenu = true
				MESSAGEMAN:Broadcast("ToggleCurrentTagMenu")
				MESSAGEMAN:Broadcast("ReshowManageTagsHeader")
			end
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