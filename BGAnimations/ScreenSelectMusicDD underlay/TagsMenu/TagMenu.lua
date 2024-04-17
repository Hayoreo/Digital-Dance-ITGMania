local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]

local quadwidth = 300
local quadheight = 190
local quadborder = 6
local NumPlayers = GAMESTATE:GetNumPlayersEnabled()
local mpn = GAMESTATE:GetMasterPlayerNumber()
local pn
local player
local HeaderText
local HeaderTextP1 = ""
local HeaderTextP2 = ""
local P1Name
local P2Name
local PlayerNum
local Player_Tags


local TagMenuOptions = {
	"Add tag to current song",
	"Add tag to curent group",
	"Remove current song's tags",
	"Remove current group's tags",
	"Manage all tags",
	"Exit",
}

if NumPlayers == 2 then
	-- default to P1 when both players are enabled, but still set P2 name.
	player = PLAYER_1
	pn = 'P1'
	P1Name = PROFILEMAN:GetPlayerName(0)
	P2Name = PROFILEMAN:GetPlayerName(1)
	HeaderTextP1 = P1Name.."'s ".."tags"
	HeaderTextP2 = P2Name.."'s ".."tags"
	HeaderText = "Manage tabs"
	PlayerNum = 0
elseif mpn == 'PlayerNumber_P1' then
	player = PLAYER_1
	pn = 'P1'
	P1Name = PROFILEMAN:GetPlayerName(pn)
	HeaderText = "Manage "..PROFILEMAN:GetPlayerName(pn).."'s ".."tags"
	PlayerNum = 0
elseif mpn == 'PlayerNumber_P2' then
	player = PLAYER_2
	pn = 'P2'
	P2Name = PROFILEMAN:GetPlayerName(pn)
	HeaderText = "Manage "..PROFILEMAN:GetPlayerName(pn).."'s ".."tags"
	PlayerNum = 1
end

local function IsSong()
	if (Input.WheelWithFocus == SongWheel and Input.WheelWithFocus:get_info_at_focus_pos() ~= "CloseThisFolder") or
	(Input.WheelWithFocus == GroupWheel and Input.WheelWithFocus:get_info_at_focus_pos() == "RANDOM-PORTAL") then
		return true
	else
		return false
	end
end

local function IsGroup()
	if (Input.WheelWithFocus == GroupWheel and Input.WheelWithFocus:get_info_at_focus_pos() ~= "RANDOM-PORTAL") or 
		(Input.WheelWithFocus == SongWheel and Input.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder") then 
		if GetMainSortPreference() == 1 then
			return true
		end
	else
		return false
	end
end

local t = Def.ActorFrame{}

--- Dim background for tab menu ------
	t[#t+1] = Def.Quad{
		Name="DimBg",
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
			self:zoomx(SCREEN_RIGHT)
			self:zoomy(SCREEN_BOTTOM)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.9)
		end,
	}
	
	--- border for Tag Menu ------
	t[#t+1] = Def.Quad{
		Name="Border",
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
			self:zoomx(quadwidth+quadborder)
			self:zoomy(quadheight+quadborder)
			self:diffuse(PlayerColor(player))
			self:diffusealpha(1)
		end,
		ChangeTabPlayerColorMessageCommand=function(self)
			if player == PLAYER_1 then
				player = PLAYER_2
				PlayerNum = 1
			elseif player == PLAYER_2 then
				player = PLAYER_1
				PlayerNum = 0
			end
			self:diffuse(PlayerColor(player))
			MESSAGEMAN:Broadcast('UpdateDividerColor')
		end,
	}
	
	--- BG quad for tag menu
	t[#t+1] = Def.Quad{
		Name="MenuQuad",
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
			self:zoomx(quadwidth)
			self:zoomy(quadheight)
			self:diffuse(color("#111111"))
			self:diffusealpha(1)
		end,
	}
	
	-- header text
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:visible(NumPlayers == 1 and true or false)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:x(SCREEN_CENTER_X)
			self:y(SCREEN_CENTER_Y - quadheight/2 + quadborder*2)
			self:zoom(1)
			self:settext(HeaderText)
		end,
		ToggleAddTagsMenuMessageCommand=function(self)
			if AddTagSubMenu then
				self:visible(false)
			end
		end,
		ToggleRemoveTagsMenuMessageCommand=function(self)
			if RemoveTagSubMenu then
				self:visible(false)
			end
		end,
		ToggleManageTagsMenuMessageCommand=function(self)
			if ManageTagsSubMenu then
				self:visible(false)
			end
		end,
		ToggleCurrentTagMenuMessageCommand=function(self)
			if CurrentTagSubMenu then
				self:visible(false)
			end
		end,
		InitializeTagsMenuMessageCommand=function(self)
			self:visible(NumPlayers == 1 and true or false)
		end,
	}
	
	--- Divider quad for tab menu
	t[#t+1] = Def.Quad{
		Name="Divider",
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X ,SCREEN_CENTER_Y - quadheight/2 + 28)
			self:zoomx(quadwidth)
			self:zoomy(quadborder/2)
			self:diffuse(PlayerColor(player))
			self:diffusealpha(1)
		end,
		UpdateDividerColorMessageCommand=function(self)
			self:diffuse(PlayerColor(player))
		end,
	}
	
		
	-- player 1 header (2 player mode)
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name="P1Header",
		InitCommand=function(self)
			self:visible(NumPlayers == 2 and true or false)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(left)
			self:x(SCREEN_CENTER_X - quadwidth/2 + quadborder*4)
			self:y(SCREEN_CENTER_Y - quadheight/2 + quadborder*2)
			self:zoom(1)
			self:draworder(150)
			self:settext(HeaderTextP1)
		end,
		ToggleAddTagsMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(NumPlayers == 2 and true or false)
			end
		end,
		ToggleRemoveTagsMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(NumPlayers == 2 and true or false)
			end
		end,
		ToggleManageTagsMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(NumPlayers == 2 and true or false)
			end
		end,
	}
	
	-- player 2 header (2 player mode)
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name="P2Header",
		InitCommand=function(self)
			self:visible(NumPlayers == 2 and true or false)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(right)
			self:x(SCREEN_CENTER_X + quadwidth/2 - quadborder*4)
			self:y(SCREEN_CENTER_Y - quadheight/2 + quadborder*2)
			self:zoom(1)
			self:draworder(150)
			self:settext(HeaderTextP2)
		end,
		ToggleAddTagsMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(NumPlayers == 2 and true or false)
			end
		end,
		ToggleRemoveTagsMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(NumPlayers == 2 and true or false)
			end
		end,
		ToggleManageTagsMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(NumPlayers == 2 and true or false)
			end
		end,
	}
	
	-- Add tag header text
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name="AddTextHeader",
		InitCommand=function(self)
			self:visible(false)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:x(SCREEN_CENTER_X)
			self:y(SCREEN_CENTER_Y - quadheight/2 + quadborder*2)
			self:zoom(1)
			self:settext("")
			self:maxwidth(quadwidth - quadborder)
		end,
		ToggleAddTagsMenuMessageCommand=function(self, params)
			if AddTagSubMenu then
				self:visible(true)
			end
			if not params then return end
			local SongOrGroup = params[1]
			local AddTagHeaderText
			local PlayerNumber
			if  params[2] == "PlayerNumber_P1" then
				PlayerNumber = 0
			elseif  params[2] == "PlayerNumber_P2"  then
				PlayerNumber = 1
			end
			
			-- we have a song
			if IsSong() then
				AddTagHeaderText = 'Add tag to "'..SongOrGroup:GetDisplayMainTitle()..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)
			-- we have a group
			elseif IsGroup then
				AddTagHeaderText = 'Add tag to pack "'..SongOrGroup..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)
			end
			self:settext(AddTagHeaderText)
			MESSAGEMAN:Broadcast('UpdatePlayerTagsText', {PlayerNumber})
			
		end,
		ToggleRemoveTagsMenuMessageCommand=function(self, params)
			if RemoveTagSubMenu then
				self:visible(true)
			end
			if not params then return end
			local SongOrGroup = params[1]
			local AddTagHeaderText
			local PlayerNumber
			if  params[2] == "PlayerNumber_P1" then
				PlayerNumber = 0
			elseif  params[2] == "PlayerNumber_P2"  then
				PlayerNumber = 1
			end
			if params[3] == "GroupTag" then
				AddTagHeaderText = 'Remove tags from pack "'..SongOrGroup..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)
			elseif IsSong() then
				AddTagHeaderText = 'Remove tags from "'..SongOrGroup:GetDisplayMainTitle()..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)
			-- we have a group
			elseif IsGroup then
				AddTagHeaderText = 'Remove tags from pack "'..SongOrGroup..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)
			end
			self:settext(AddTagHeaderText)
			MESSAGEMAN:Broadcast('UpdatePlayerTagsText', {PlayerNumber, SongOrGroup})
			
		end,
		ToggleManageTagsMenuMessageCommand=function(self, params)
			if not params then return end
			if ManageTagsSubMenu then
				self:visible(true)
				local SongOrGroup = params[1]
				local AddTagHeaderText
				local PlayerNumber = params[1]
				AddTagHeaderText = 'Manage '..PROFILEMAN:GetPlayerName(PlayerNumber).."'s tags"
				self:settext(AddTagHeaderText)
				MESSAGEMAN:Broadcast('UpdatePlayerTagsText', {PlayerNumber, SongOrGroup})
			elseif not CurrentTagSubMenu and not ManageTagsSubMenu then
				self:visible(false)
			end
		end,
		ReshowManageTagsHeaderMessageCommand=function(self)
			AddTagHeaderText = 'Manage '..PROFILEMAN:GetPlayerName(PlayerNum).."'s tags"
			self:settext(AddTagHeaderText)
		end,
		ToggleCurrentTagMenuMessageCommand=function(self, params)
			if not params then return end
			if CurrentTagSubMenu and not ManageTagsSubMenu then
				self:visible(true)
				local Tag = params[1]
				local PlayerNumber = params[2]
				AddTagHeaderText = 'Remove items for tag: '.. Tag..'?'
				self:settext(AddTagHeaderText)
			elseif not CurrentTagSubMenu or not ManageTagsSubMenu then
				self:visible(false)
			end
		end,
		UpdateRenamedTagMessageCommand=function(self, params)
			if not params then return end
			if CurrentTagSubMenu and not ManageTagsSubMenu then
				self:visible(true)
				local Tag = params[1]
				local PlayerNumber = params[2]
				AddTagHeaderText = 'Edit items for tag: '.. Tag..'?'
				self:settext(AddTagHeaderText)
			elseif not CurrentTagSubMenu or not ManageTagsSubMenu then
				self:visible(false)
			end
		end,
		InitializeTagsMenuMessageCommand=function(self)
			self:visible(false)
		end,
	}


for i=1, #TagMenuOptions do
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name="TagMenuOption"..i,
		InitCommand=function(self)
			-- we're never starting in a group so we can "deactive" the group options right away.
			if i== 2 or i == 4 then
				self:diffuse(color("#636363"))
			else
				self:diffuse(color("#FFFFFF"))
			end
			self:draworder(150)
			self:horizalign(center)
			self:x(SCREEN_CENTER_X)
			self:y(SCREEN_CENTER_Y - quadheight/2 + quadborder*2 + 36 + ((i-1)*25))
			self:zoom(1)
			self:settext(TagMenuOptions[i])
			self:sleep(0.5):queuecommand('UpdateTextColors')
		end,
		CurrentSongChangedMessageCommand=function(self)
			self:queuecommand('UpdateTextColors')
		end,
		ChangeTabPlayerColorMessageCommand=function(self)
			self:queuecommand('UpdateTextColors')
		end,
		UpdateTextColorsCommand=function(self)
			if i == 1 then
				if not IsSong() then
					self:diffuse(color("#636363"))
				elseif IsSong() then
					self:diffuse(color("#FFFFFF"))
				end
			elseif i == 3 then
				if ( IsSong() and not IsCurrentSongTagged(GAMESTATE:GetCurrentSong(), PlayerNum) ) or not IsSong() then
					self:diffuse(color("#636363"))
				else
					self:diffuse(color("#FFFFFF"))	
				end
			end
			if i == 2 then
				if not IsGroup() then
					self:diffuse(color("#636363"))
				else
					self:diffuse(color("#FFFFFF"))
				end
			elseif i == 4 then
				if not IsCurrentGroupTagged(NameOfGroup, PlayerNum) or not IsGroup() then
					if IsSong() and IsCurrentGroupTagged(NameOfGroup, PlayerNum) then
						self:diffuse(color("#FFFFFF"))
					else
						self:diffuse(color("#636363"))
					end
				else
					self:diffuse(color("#FFFFFF"))
				end
			elseif i == 5 then
				if #GetCurrentPlayerTags(PlayerNum) > 0 then
					self:diffuse(color("#FFFFFF"))
				else
					self:diffuse(color("#636363"))
				end
			end
		end,
		ToggleAddTagsMenuMessageCommand=function(self)
			if AddTagSubMenu then
				self:visible(false)
			end
		end,
		ToggleRemoveTagsMenuMessageCommand=function(self)
			if RemoveTagSubMenu then
				self:visible(false)
			end
		end,
		ToggleManageTagsMenuMessageCommand=function(self)
			if ManageTagsSubMenu then
				self:visible(false)
			end
		end,
		ToggleCurrentTagMenuMessageCommand=function(self)
			if CurrentTagSubMenu then
				self:visible(false)
			end
		end,
		InitializeTagsMenuMessageCommand=function(self)
			self:visible(true):queuecommand('UpdateTextColors')
		end,
		UpdateRemovedTagsMessageCommand=function(self)
			self:queuecommand('UpdateTextColors')
		end,
		UpdateRemovedObjectsMessageCommand=function(self)
			self:queuecommand('UpdateTextColors')
		end,
	}
end

-- Menu Cursor
t[#t+1] = LoadActor("./Cursor.lua", {GroupWheel,SongWheel,Input, t, quadwidth, quadheight, quadborder})
-- The menu to add tags
t[#t+1] = LoadActor("./AddTagsMenu.lua", {GroupWheel,SongWheel,Input, t, quadwidth, quadheight, quadborder})
-- The menu to remove tags
t[#t+1] = LoadActor("./RemoveTagsMenu.lua", {GroupWheel,SongWheel,Input, t, quadwidth, quadheight, quadborder})
-- The menu to manage tags
t[#t+1] = LoadActor("./ManageTagsMenu.lua", {GroupWheel,SongWheel,Input, t, quadwidth, quadheight, quadborder})
-- The menu to edit the current tag
t[#t+1] = LoadActor("./EditCurrentTagMenu.lua", {GroupWheel,SongWheel,Input, t, quadwidth, quadheight, quadborder})
-- The functions that edit the player's tag file.
t[#t+1] = LoadActor("./EditTagFunctions.lua")

return t