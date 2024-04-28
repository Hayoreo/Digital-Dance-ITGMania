local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]
local t = args[4]
local quadwidth = args[5]
local quadheight = args[6]
local quadborder = args[7]

AddTagSubMenu = false
RemoveTagSubMenu = false
ManageTagsSubMenu = false
CurrentTagSubMenu = false

local maxwidth = (quadwidth-quadborder)/2.75
local CurrentTagIndex = 1
local InfinityIndex = 0
local FakeIndex
local CurrentColumn = 1
local Player_Tags
local NumTags = 1
local PlayerNumber
local AvailableTags
local TagsToBeAdded
local TagSongs
local TagSongsLines
local TagPacks
local TagPacksLines
local Tag
local Object

local mpn = GAMESTATE:GetMasterPlayerNumber()
local Player
if mpn == "PlayerNumber_P1" then
	Player = PLAYER_1
	PlayerNumber = 0
elseif mpn == "PlayerNumber_P2" then
	Player = PLAYER_2
	PlayerNumber = 1
end
local NumPlayers = GAMESTATE:GetNumSidesJoined()
local CursorPositionNames = {}
local TagPositionNames = {
	"TextEntryQuad",
}

local RemoveTagPositionNames = {}
local ManageTagNames = {}
local CurrentTagSongNames = {"RenameTagQuad"}
local CurrentTagPackNames = {"RenameTagQuad"}
local MaxIndex = 6
if NumPlayers == 2 then
	CursorPositionNames[#CursorPositionNames+1] = "P1Header"
	CursorPositionNames[#CursorPositionNames+1] = "P2Header"
	MaxIndex = MaxIndex + 2
end

for i = 1, 6 do
	CursorPositionNames[#CursorPositionNames+1] = "TagMenuOption"..i
	CurrentTagSongNames[#CurrentTagSongNames+1] = "TagSongs"..i
	CurrentTagPackNames[#CurrentTagPackNames+1] = "TagPacks"..i
end

for i=1, 15 do
	TagPositionNames[#TagPositionNames+1] = "PlayerTags"..i
end

for i=1, 24 do
	RemoveTagPositionNames[#RemoveTagPositionNames+1] = "RemovePlayerTags" ..i
	ManageTagNames[#ManageTagNames+1] = "ManagePlayerTags"..i
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

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
t[#t+1] = Def.Quad{}

--- Thee Cursor
t[#t+1] = Def.Quad{
	Name="TagMenuCursor",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(CursorPositionNames[1])
		local XPos = Parent:GetX()
		local YPos = Parent:GetY()
		local CursorWidth = Parent:GetWidth()
		local CursorHeight = Parent:GetHeight()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		XPos = XPos + (0.5-HAlign)*CursorWidth
		YPos = YPos + (0.5-VAlign)*CursorHeight
		self:draworder(1)
		self:xy(XPos,YPos + 2)
		self:zoomx(CursorWidth)
		self:zoomy(CursorHeight + 5)
		self:diffuse(PlayerColor(Player))
		self:diffusealpha(0.4)
		self:queuecommand('DimCursor')
	end,
	UpdateDividerColorMessageCommand=function(self)
		-- This probably shouldn't be here, but im lazy. Eat my ass.
		self:playcommand('UpdateTagCursor')
	end,
	InitializeTagsMenuMessageCommand=function(self)
		AddTagSubMenu = false
		RemoveTagSubMenu = false
		ManageTagsSubMenu = false
		CurrentTagSubMenu = false
		CurrentTagIndex = 1
		CurrentColumn = 1
		InfinityIndex = 0
		self:playcommand('UpdateTagCursor')
	end,
	DimCursorCommand=function(self)
		self:stoptweening()
		self:linear(0.75):diffusealpha(0.2)
		self:queuecommand('BrightenCursor')
	end,
	BrightenCursorCommand=function(self)
		self:stoptweening()
		self:linear(0.75):diffusealpha(0.4)
		self:queuecommand('DimCursor')
	end,
	UpdatePlayerTagsTextMessageCommand=function(self, params)
		PlayerNumber = params[1]
		-- we're gonna use these later
		Player_Tags = GetCurrentPlayerTags(PlayerNumber)
		-- Plus one for the text entry field
		NumTags = #Player_Tags + 1
		local Object
		if IsSong() then
			Object = GAMESTATE:GetCurrentSong()
		elseif IsGroup() then
			Object = NameOfGroup
		end
		TagsToBeAdded = GetAvailableTagsToAdd(Object, PlayerNumber)
	end,
	UpdateTagCursorMessageCommand=function(self, Direction)
		self:stoptweening()
		local Direction = Direction
		if Direction == nil then Direction = "" end
		if not AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			if Direction[1] == "Up" or Direction[1] == "Left" then
				if CurrentTagIndex == 1 then
					CurrentTagIndex = MaxIndex
				else
					CurrentTagIndex = CurrentTagIndex - 1
				end
				SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
			elseif Direction[1] == "Down" or Direction[1] == "Right" then
				if CurrentTagIndex == MaxIndex then
					CurrentTagIndex = 1
				else
					CurrentTagIndex = CurrentTagIndex + 1
				end
				SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
			end
			local Parent = self:GetParent():GetChild(CursorPositionNames[CurrentTagIndex])
			local XPos = Parent:GetX()
			local YPos = Parent:GetY()
			local CursorWidth = Parent:GetWidth()
			local CursorHeight = Parent:GetHeight()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			XPos = XPos + (0.5-HAlign)*CursorWidth
			YPos = YPos + (0.5-VAlign)*CursorHeight
			self:linear(0.2)
			self:xy(XPos,YPos + 2)
			self:zoomx(CursorWidth)
			self:zoomy(CursorHeight + 5)
			self:queuecommand('BrightenCursor')
		elseif AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			if #TagsToBeAdded > 0 then
				if Direction[1] == "Up" then
					if CurrentTagIndex == 1 then
						if #TagsToBeAdded >= 15 and InfinityIndex == 0 then
							for i=1, #TagsToBeAdded do
								if i*3 + 1 == #TagsToBeAdded then
									CurrentTagIndex = 14
									InfinityIndex = #TagsToBeAdded
									break
								elseif i*3 + 2 == #TagsToBeAdded then
									CurrentTagIndex = 15
									InfinityIndex = #TagsToBeAdded
									break
								elseif i*3 == #TagsToBeAdded then	
									CurrentTagIndex = 16
									InfinityIndex = #TagsToBeAdded
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						else
							CurrentTagIndex = #TagsToBeAdded + 1
							InfinityIndex = #TagsToBeAdded
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					elseif CurrentTagIndex == 2 or CurrentTagIndex == 3 or CurrentTagIndex == 4 then
						if InfinityIndex < 4 then
							CurrentTagIndex = 1
							InfinityIndex = 0
						else
							InfinityIndex = InfinityIndex - 3
						end
						MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					else
						CurrentTagIndex = CurrentTagIndex - 3
						InfinityIndex = InfinityIndex - 3
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				elseif Direction[1] == "Down" then
					if CurrentTagIndex == 1 then
						CurrentTagIndex = 2
						InfinityIndex = 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					elseif CurrentTagIndex == 14 then
						if InfinityIndex + 3 <= #TagsToBeAdded then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )	
						else
							CurrentTagIndex = 1
							InfinityIndex = 0
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					elseif CurrentTagIndex == 15 then
						if InfinityIndex + 3 <= #TagsToBeAdded then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						elseif InfinityIndex + 2 <= #TagsToBeAdded  then
							InfinityIndex = #TagsToBeAdded
							CurrentTagIndex = 14
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 1
							InfinityIndex = 0
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					elseif CurrentTagIndex == 16 then
						if InfinityIndex + 3 <= #TagsToBeAdded then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						elseif #TagsToBeAdded > InfinityIndex then
							InfinityIndex = #TagsToBeAdded
							for i=1, #TagsToBeAdded do
								if i*3 + 1 == InfinityIndex then
									CurrentTagIndex = 14
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = 15
									break
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateAddTagsText", {PlayerNumber, TagsToBeAdded, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 1
							InfinityIndex = 0
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					else
						if InfinityIndex + 3 <= #TagsToBeAdded then
							CurrentTagIndex = CurrentTagIndex + 3
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #TagsToBeAdded > InfinityIndex and #TagsToBeAdded <= 15 then
							
							for i=1, #TagsToBeAdded do
								if i == 1 and i == InfinityIndex then
									if #TagsToBeAdded >= 4 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									else
										InfinityIndex = 0
										CurrentTagIndex = 1
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
									end
								elseif i == 2 and i == InfinityIndex then
									if #TagsToBeAdded >= 5 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									elseif #TagsToBeAdded == 4 then
										InfinityIndex = 4
										CurrentTagIndex = 5
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									else
										InfinityIndex = 0
										CurrentTagIndex = 1
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
									end
								elseif i == 3 and i == InfinityIndex then
									if #TagsToBeAdded >= 6 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									elseif #TagsToBeAdded == 5 then
										InfinityIndex = 5
										CurrentTagIndex = 6
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									elseif #TagsToBeAdded == 4 then
										InfinityIndex = 4
										CurrentTagIndex = 5
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									else
										InfinityIndex = 0
										CurrentTagIndex = 1
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
									end
								elseif i*3 + 1 == InfinityIndex then
									CurrentTagIndex = InfinityIndex + 1
									InfinityIndex = #TagsToBeAdded
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = InfinityIndex + 1
									InfinityIndex = #TagsToBeAdded
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								elseif i*3 == InfinityIndex then
									CurrentTagIndex = InfinityIndex + 1
									InfinityIndex = #TagsToBeAdded
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								end
							end
							
						elseif #TagsToBeAdded > InfinityIndex and #TagsToBeAdded > 15 then
							InfinityIndex = #TagsToBeAdded
							for i=1, #TagsToBeAdded do
								if i*3 + 1 == InfinityIndex then
									CurrentTagIndex = 14
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = 15
									break
								elseif i*3 == InfinityIndex then
									CurrentTagIndex = 16
									break
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						else
							CurrentTagIndex = 1
							InfinityIndex = 0
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
						
					end
				elseif Direction[1] == "Left" then
					if CurrentTagIndex == 2 or CurrentTagIndex == 5  or CurrentTagIndex == 8 or CurrentTagIndex == 11 or CurrentTagIndex == 14 then
						if #TagsToBeAdded >= InfinityIndex + 2 then
							CurrentTagIndex = CurrentTagIndex + 2
							InfinityIndex = InfinityIndex + 2
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #TagsToBeAdded >= InfinityIndex + 1 then
							CurrentTagIndex = CurrentTagIndex + 1
							InfinityIndex = InfinityIndex + 1
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					elseif CurrentTagIndex ~= 1 then
						CurrentTagIndex = CurrentTagIndex - 1
						InfinityIndex = InfinityIndex - 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				elseif Direction[1] == "Right" then
					if CurrentTagIndex == 4 or CurrentTagIndex == 7  or CurrentTagIndex == 10 or CurrentTagIndex == 13 or CurrentTagIndex == 16 then
						CurrentTagIndex = CurrentTagIndex - 2
						InfinityIndex = InfinityIndex - 2
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif InfinityIndex + 1 <= #TagsToBeAdded then
						CurrentTagIndex = CurrentTagIndex + 1
						InfinityIndex = InfinityIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					else
						for i=1, #TagsToBeAdded do
							if i*3 + 1 == InfinityIndex - 1 then
								CurrentTagIndex = CurrentTagIndex - 1
								InfinityIndex = InfinityIndex - 1
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
								break
							elseif i*3 + 1 == InfinityIndex - 2 then
								CurrentTagIndex = CurrentTagIndex - 2
								InfinityIndex = InfinityIndex - 2
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
								break
							end
						end
					end
				end
			elseif #TagsToBeAdded == 0 then
				CurrentTagIndex = 1
				InfinityIndex = 0
			end
			local Parent = self:GetParent():GetChild(TagPositionNames[CurrentTagIndex])
			local XPos = Parent:GetX()
			local YPos = Parent:GetY() - 2
			local CursorWidth
			local CursorHeight
			local Zoom = Parent:GetZoom()
			if CurrentTagIndex == 1 then
				CursorWidth = Parent:GetZoomX()
				CursorHeight = Parent:GetZoomY() - 5
				MESSAGEMAN:Broadcast("ToggleTextCursor", {"Show"})
			else
				CursorWidth = Parent:GetWidth() * Zoom
				CursorHeight = Parent:GetHeight() * Zoom
				if CursorWidth > maxwidth then CursorWidth = maxwidth * Zoom end
				MESSAGEMAN:Broadcast("ToggleTextCursor", {"Hide"})
			end
			
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			XPos = XPos + (0.5-HAlign)*CursorWidth
			YPos = YPos + (0.5-VAlign)*CursorHeight
			self:linear(0.2)
			self:xy(XPos,YPos + 2)
			self:zoomx(CursorWidth)
			self:zoomy(CursorHeight + 5)
			self:queuecommand('BrightenCursor')
		elseif RemoveTagSubMenu and not AddTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			if Direction[1] == "Up" then
				if #AvailableTags > 3 then
					if CurrentTagIndex == 1 then
						if #AvailableTags >= 22 and InfinityIndex == 1 then
							for i=1, #AvailableTags do
								CurrentTagIndex = 22
								if i*3 + 1 == #AvailableTags then
									InfinityIndex = #AvailableTags
									break
								elseif i*3 + 2 == #AvailableTags then
									InfinityIndex = #AvailableTags - 1
									break
								elseif i*3 == #AvailableTags then
									InfinityIndex = #AvailableTags - 2
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #AvailableTags <= 22 and InfinityIndex == 1 then
							for i=1, #AvailableTags do
								if i*3 + 1 == #AvailableTags then
									InfinityIndex = #AvailableTags
									CurrentTagIndex = #AvailableTags
									break
								elseif i*3 + 2 == #AvailableTags then
									InfinityIndex = #AvailableTags - 1
									CurrentTagIndex = #AvailableTags - 1
									break
								elseif i*3 == #AvailableTags then
									InfinityIndex = #AvailableTags - 2
									CurrentTagIndex = #AvailableTags - 2
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex ~= 1 then
							InfinityIndex = InfinityIndex - 3
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "Top", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif CurrentTagIndex == 2 then
						if #AvailableTags >= 23 and InfinityIndex == 2 then
							for i=1, #AvailableTags do
								CurrentTagIndex = 23
								if i*3 + 1 == #AvailableTags then
									CurrentTagIndex = 22
									InfinityIndex = #AvailableTags
									break
								elseif i*3 + 2 == #AvailableTags then
									InfinityIndex = #AvailableTags
									break
								elseif i*3 == #AvailableTags then
									InfinityIndex = #AvailableTags - 1
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #AvailableTags <= 23 and InfinityIndex == 1 then
							for i=1, #AvailableTags do
								if i*3 + 1 == #AvailableTags then
									InfinityIndex = #AvailableTags
									CurrentTagIndex = #AvailableTags
									break
								elseif i*3 + 2 == #AvailableTags then
									InfinityIndex = #AvailableTags - 1
									CurrentTagIndex = #AvailableTags - 1
									break
								elseif i*3 == #AvailableTags then
									InfinityIndex = #AvailableTags - 2
									CurrentTagIndex = #AvailableTags - 2
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex ~= 1 then
							InfinityIndex = InfinityIndex - 3
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "Top", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif CurrentTagIndex == 3 then
						if #AvailableTags >= 24 and InfinityIndex == 3 then
							for i=1, #AvailableTags do
								if i*3 + 1 == #AvailableTags then
									CurrentTagIndex = 22
									InfinityIndex = #AvailableTags
									break
								elseif i*3 + 2 == #AvailableTags then
									CurrentTagIndex = 23
									InfinityIndex = #AvailableTags
									break
								elseif i*3 == #AvailableTags then
									CurrentTagIndex = 24
									InfinityIndex = #AvailableTags
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #AvailableTags <= 24 and InfinityIndex == 1 then
							for i=1, #AvailableTags do
								if i*3 + 1 == #AvailableTags then
									InfinityIndex = #AvailableTags
									CurrentTagIndex = #AvailableTags
									break
								elseif i*3 + 2 == #AvailableTags then
									InfinityIndex = #AvailableTags - 1
									CurrentTagIndex = #AvailableTags - 1
									break
								elseif i*3 == #AvailableTags then
									InfinityIndex = #AvailableTags - 2
									CurrentTagIndex = #AvailableTags - 2
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex ~= 1 then
							InfinityIndex = InfinityIndex - 3
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "Top", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					else
						CurrentTagIndex = CurrentTagIndex - 3
						InfinityIndex = InfinityIndex - 3
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				end
			elseif Direction[1] == "Down" then
				if #AvailableTags > 3 then
					if CurrentTagIndex == 22 then
						if InfinityIndex + 3 <= #AvailableTags then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )	
						else
							CurrentTagIndex = 1
							InfinityIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					elseif CurrentTagIndex == 23 then
						if InfinityIndex + 3 <= #AvailableTags then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						elseif InfinityIndex + 2 <= #AvailableTags  then
							InfinityIndex = #AvailableTags
							CurrentTagIndex = 22
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 2
							InfinityIndex = 2
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					elseif CurrentTagIndex == 24 then
						if InfinityIndex + 3 <= #AvailableTags then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						elseif #AvailableTags > InfinityIndex then
							InfinityIndex = #AvailableTags
							for i=1, #AvailableTags do
								if i*3 + 1 == InfinityIndex then
									CurrentTagIndex = 22
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = 23
									break
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemoveTagsText", {PlayerNumber, AvailableTags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 3
							InfinityIndex = 3
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					else
						if InfinityIndex + 3 <= #AvailableTags then
							CurrentTagIndex = CurrentTagIndex + 3
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #AvailableTags > InfinityIndex and #AvailableTags > 24 then	
							InfinityIndex = #AvailableTags
							for i=1, #AvailableTags do
								if i*3 + 1 == InfinityIndex then
									CurrentTagIndex = 22
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = 23
									break
								elseif i*3 == InfinityIndex then
									CurrentTagIndex = 24
									break
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #AvailableTags > InfinityIndex and #AvailableTags < 24 then
							for i=1, #AvailableTags do
								if i == 1 and i == InfinityIndex then
									if #AvailableTags >= 4 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									end
								elseif i == 2 and i == InfinityIndex then
									if #AvailableTags >= 5 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									elseif #AvailableTags == 4 then
										InfinityIndex = 4
										CurrentTagIndex = 4
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									end
								elseif i == 3 and i == InfinityIndex then
									if #AvailableTags >= 6 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									elseif #AvailableTags == 5 then
										InfinityIndex = 5
										CurrentTagIndex = 5
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									elseif #AvailableTags == 4 then
										InfinityIndex = 4
										CurrentTagIndex = 4
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									end
								elseif i*3 + 1 == InfinityIndex then
									CurrentTagIndex = #AvailableTags
									InfinityIndex = #AvailableTags
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = #AvailableTags
									InfinityIndex = #AvailableTags
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								elseif i*3 == InfinityIndex then
									CurrentTagIndex = #AvailableTags
									InfinityIndex = #AvailableTags
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								end
							end
						else
							CurrentTagIndex = 1
							InfinityIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
						
					end
				end
			elseif Direction[1] == "Left" then
				if CurrentTagIndex == 1 or CurrentTagIndex == 4 or CurrentTagIndex == 7 or CurrentTagIndex == 10 or CurrentTagIndex == 13 or CurrentTagIndex == 16 or CurrentTagIndex == 19 or CurrentTagIndex == 22 then
					if #AvailableTags >= InfinityIndex + 2 then
						CurrentTagIndex = CurrentTagIndex + 2
						InfinityIndex = InfinityIndex + 2
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					elseif #AvailableTags >= InfinityIndex + 1 then
						CurrentTagIndex = CurrentTagIndex + 1
						InfinityIndex = InfinityIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					end
				else
					CurrentTagIndex = CurrentTagIndex - 1
					InfinityIndex = InfinityIndex - 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			elseif Direction[1] == "Right" then
				if CurrentTagIndex == 3 or CurrentTagIndex == 6 or CurrentTagIndex == 9 or CurrentTagIndex == 12 or CurrentTagIndex == 15 or CurrentTagIndex == 18 or CurrentTagIndex == 21 or CurrentTagIndex == 24 then
					CurrentTagIndex = CurrentTagIndex - 2
					InfinityIndex = InfinityIndex - 2
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif InfinityIndex + 1 <= #AvailableTags then
					CurrentTagIndex = CurrentTagIndex + 1
					InfinityIndex = InfinityIndex + 1
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				else
					for i=1, #AvailableTags do
						if i == 1 and #AvailableTags > 1 and i == InfinityIndex then
							CurrentTagIndex = CurrentTagIndex + 1
							InfinityIndex = InfinityIndex + 1
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif i == 2 and i == InfinityIndex then
							if #AvailableTags > InfinityIndex + 1 then
								CurrentTagIndex = CurrentTagIndex + 1
								InfinityIndex = InfinityIndex + 1
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							else
								CurrentTagIndex = 1
								InfinityIndex = 1
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							end
						elseif i == 3 and i == InfinityIndex then
							CurrentTagIndex = 1
							InfinityIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						elseif i*3 + 1 == InfinityIndex - 1 then
							CurrentTagIndex = CurrentTagIndex - 1
							InfinityIndex = InfinityIndex - 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							break
						elseif i*3 + 1 == InfinityIndex - 2 then
							CurrentTagIndex = CurrentTagIndex - 2
							InfinityIndex = InfinityIndex - 2
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							break
						end
					end
				end
			end
			local Parent = self:GetParent():GetChild(RemoveTagPositionNames[CurrentTagIndex])
			local XPos = Parent:GetX()
			local YPos = Parent:GetY() - 2
			local CursorWidth
			local CursorHeight
			local Zoom = Parent:GetZoom()
			CursorWidth = Parent:GetWidth() * Zoom
			CursorHeight = Parent:GetHeight() * Zoom
			if CursorWidth > maxwidth then CursorWidth = maxwidth * Zoom end
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			XPos = XPos + (0.5-HAlign)*CursorWidth
			YPos = YPos + (0.5-VAlign)*CursorHeight
			self:linear(0.2)
			self:xy(XPos,YPos + 2)
			self:zoomx(CursorWidth)
			self:zoomy(CursorHeight + 5)
			self:queuecommand('BrightenCursor')
		elseif ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu and not CurrentTagSubMenu then
			if Direction[1] == "Up" then
				if #Player_Tags > 3 then
					if CurrentTagIndex == 1 then
						if #Player_Tags >= 22 and InfinityIndex == 1 then
							for i=1, #Player_Tags do
								CurrentTagIndex = 22
								if i*3 + 1 == #Player_Tags then
									InfinityIndex = #Player_Tags
									break
								elseif i*3 + 2 == #Player_Tags then
									InfinityIndex = #Player_Tags - 1
									break
								elseif i*3 == #Player_Tags then
									InfinityIndex = #Player_Tags - 2
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #Player_Tags <= 22 and InfinityIndex == 1 then
							for i=1, #Player_Tags do
								if i*3 + 1 == #Player_Tags then
									InfinityIndex = #Player_Tags
									CurrentTagIndex = #Player_Tags
									break
								elseif i*3 + 2 == #Player_Tags then
									InfinityIndex = #Player_Tags - 1
									CurrentTagIndex = #Player_Tags - 1
									break
								elseif i*3 == #Player_Tags then
									InfinityIndex = #Player_Tags - 2
									CurrentTagIndex = #Player_Tags - 2
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex >= 4 then
							InfinityIndex = InfinityIndex - 3
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex ~= #Player_Tags and #Player_Tags < 4 then
							InfinityIndex = #Player_Tags
							CurrentTagIndex = #Player_Tags
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					elseif CurrentTagIndex == 2 then
						if #Player_Tags >= 23 and InfinityIndex == 2 then
							for i=1, #Player_Tags do
								CurrentTagIndex = 23
								if i*3 + 1 == #Player_Tags then
									CurrentTagIndex = 22
									InfinityIndex = #Player_Tags
									break
								elseif i*3 + 2 == #Player_Tags then
									InfinityIndex = #Player_Tags
									break
								elseif i*3 == #Player_Tags then
									InfinityIndex = #Player_Tags - 1
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #Player_Tags <= 23 and InfinityIndex == 2 then
							for i=1, #Player_Tags do
								if i*3 + 1 == #Player_Tags then
									CurrentTagIndex = #Player_Tags
									InfinityIndex = #Player_Tags
									break
								elseif i*3 + 2 == #Player_Tags then
									CurrentTagIndex = #Player_Tags
									InfinityIndex = #Player_Tags
									break
								elseif i*3 == #Player_Tags then
									CurrentTagIndex = #Player_Tags - 1
									InfinityIndex = #Player_Tags - 1
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex >= 4 then
							InfinityIndex = InfinityIndex - 3
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex ~= #Player_Tags and #Player_Tags < 4 then
							InfinityIndex = #Player_Tags
							CurrentTagIndex = #Player_Tags
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					elseif CurrentTagIndex == 3 then
						if #Player_Tags >= 24 and InfinityIndex == 3 then
							for i=1, #Player_Tags do
								if i*3 + 1 == #Player_Tags then
									CurrentTagIndex = 22
									InfinityIndex = #Player_Tags
									break
								elseif i*3 + 2 == #Player_Tags then
									CurrentTagIndex = 23
									InfinityIndex = #Player_Tags
									break
								elseif i*3 == #Player_Tags then
									CurrentTagIndex = 24
									InfinityIndex = #Player_Tags
									break
								end
							end
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #Player_Tags <= 24 and InfinityIndex == 3 then
							CurrentTagIndex = #Player_Tags
							InfinityIndex = #Player_Tags
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex >= 4 then
							InfinityIndex = InfinityIndex - 3
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif InfinityIndex ~= #Player_Tags and #Player_Tags < 4 then
							InfinityIndex = #Player_Tags
							CurrentTagIndex = #Player_Tags
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					else
						CurrentTagIndex = CurrentTagIndex - 3
						InfinityIndex = InfinityIndex - 3
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				end
			elseif Direction[1] == "Down" then
				if #Player_Tags > 3 then
					if CurrentTagIndex == 22 then
						if InfinityIndex + 3 <= #Player_Tags then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 1
							InfinityIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemovedTag", {PlayerNumber, Player_Tags} )
						end
					elseif CurrentTagIndex == 23 then
						if InfinityIndex + 3 <= #Player_Tags then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						elseif InfinityIndex + 2 <= #Player_Tags  then
							InfinityIndex = #Player_Tags
							CurrentTagIndex = 22
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 2
							InfinityIndex = 2
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemovedTag", {PlayerNumber, Player_Tags} )
						end
					elseif CurrentTagIndex == 24 then
						if InfinityIndex + 3 <= #Player_Tags then
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						elseif #Player_Tags > InfinityIndex then
							InfinityIndex = #Player_Tags
							for i=1, #Player_Tags do
								if i*3 + 1 == InfinityIndex then
									CurrentTagIndex = 22
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = 23
									break
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							MESSAGEMAN:Broadcast("UpdateManageTagsText", {PlayerNumber, Player_Tags, InfinityIndex, CurrentTagIndex, "None", Direction[1]} )
						else
							CurrentTagIndex = 3
							InfinityIndex = 3
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdateRemovedTag", {PlayerNumber, Player_Tags} )
						end
					else
						if InfinityIndex + 3 <= #Player_Tags then
							CurrentTagIndex = CurrentTagIndex + 3
							InfinityIndex = InfinityIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #Player_Tags > InfinityIndex and #Player_Tags > 24 then
							InfinityIndex = #Player_Tags
							for i=1, #Player_Tags do
								if i*3 + 1 == InfinityIndex then
									CurrentTagIndex = 22
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = 23
									break
								elseif i*3 == InfinityIndex then
									CurrentTagIndex = 24
									break
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif #Player_Tags > InfinityIndex and #Player_Tags < 24 then
							for i=1, #Player_Tags do
								if i == 1 and i == InfinityIndex then
									if #Player_Tags >= 4 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									end
								elseif i == 2 and i == InfinityIndex then
									if #Player_Tags >= 5 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									elseif #Player_Tags == 4 then
										InfinityIndex = 4
										CurrentTagIndex = 4
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									end
								elseif i == 3 and i == InfinityIndex then
									if #Player_Tags >= 6 then
										InfinityIndex = InfinityIndex + 3
										CurrentTagIndex = CurrentTagIndex + 3
										SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
										break
									elseif #Player_Tags == 5 then
										InfinityIndex = 5
										CurrentTagIndex = 5
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									elseif #Player_Tags == 4 then
										InfinityIndex = 4
										CurrentTagIndex = 4
										SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
										break
									end
								elseif i*3 + 1 == InfinityIndex then
									CurrentTagIndex = #Player_Tags
									InfinityIndex = #Player_Tags
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								elseif i*3 + 2 == InfinityIndex then
									CurrentTagIndex = #Player_Tags
									InfinityIndex = #Player_Tags
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								elseif i*3 == InfinityIndex then
									CurrentTagIndex = #Player_Tags
									InfinityIndex = #Player_Tags
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
									break
								end
							end
						else
							CurrentTagIndex = 1
							InfinityIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
						end
					end
				end
			elseif Direction[1] == "Left" then
				if CurrentTagIndex == 1 or CurrentTagIndex == 4 or CurrentTagIndex == 7 or CurrentTagIndex == 10 or CurrentTagIndex == 13 or CurrentTagIndex == 16 or CurrentTagIndex == 19 or CurrentTagIndex == 22 then
					if #Player_Tags >= InfinityIndex + 2 then
						CurrentTagIndex = CurrentTagIndex + 2
						InfinityIndex = InfinityIndex + 2
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					elseif #Player_Tags >= InfinityIndex + 1 then
						CurrentTagIndex = CurrentTagIndex + 1
						InfinityIndex = InfinityIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					end
				else
					CurrentTagIndex = CurrentTagIndex - 1
					InfinityIndex = InfinityIndex - 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			elseif Direction[1] == "Right" then
				if CurrentTagIndex == 3 or CurrentTagIndex == 6 or CurrentTagIndex == 9 or CurrentTagIndex == 12 or CurrentTagIndex == 15 or CurrentTagIndex == 18 or CurrentTagIndex == 21 or CurrentTagIndex == 24 then
					CurrentTagIndex = CurrentTagIndex - 2
					InfinityIndex = InfinityIndex - 2
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif InfinityIndex + 1 <= #Player_Tags then
					CurrentTagIndex = CurrentTagIndex + 1
					InfinityIndex = InfinityIndex + 1
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				else
					for i=1, #Player_Tags do
						if i == 1 and #Player_Tags > 1 and i == InfinityIndex then
							CurrentTagIndex = CurrentTagIndex + 1
							InfinityIndex = InfinityIndex + 1
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif i == 2 and i == InfinityIndex then
							if #Player_Tags > InfinityIndex + 1 then
								CurrentTagIndex = CurrentTagIndex + 1
								InfinityIndex = InfinityIndex + 1
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							else
								CurrentTagIndex = 1
								InfinityIndex = 1
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							end
						elseif i == 3 and i == InfinityIndex then
							CurrentTagIndex = 1
							InfinityIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						elseif i*3 + 1 == InfinityIndex - 1 then
							CurrentTagIndex = CurrentTagIndex - 1
							InfinityIndex = InfinityIndex - 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							break
						elseif i*3 + 1 == InfinityIndex - 2 then
							CurrentTagIndex = CurrentTagIndex - 2
							InfinityIndex = InfinityIndex - 2
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							break
						end
					end
				end
			end
			local Parent = self:GetParent():GetChild(ManageTagNames[CurrentTagIndex])
			local XPos = Parent:GetX()
			local YPos = Parent:GetY() - 2
			local CursorWidth
			local CursorHeight
			local Zoom = Parent:GetZoom()
			CursorWidth = Parent:GetWidth() * Zoom
			CursorHeight = Parent:GetHeight() * Zoom
			if CursorWidth > maxwidth then CursorWidth = maxwidth * Zoom end
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			XPos = XPos + (0.5-HAlign)*CursorWidth
			YPos = YPos + (0.5-VAlign)*CursorHeight
			self:linear(0.2)
			self:xy(XPos,YPos + 2)
			self:zoomx(CursorWidth)
			self:zoomy(CursorHeight + 5)
			self:queuecommand('BrightenCursor')
		elseif CurrentTagSubMenu and not ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu then
			if #TagSongs > 0 or #TagPacks > 0 then
				if Direction[1] == "Up" then
					if CurrentTagIndex == 1 then
						if CurrentColumn == 1 then
							if #TagSongs + 1 >= 7 then
								CurrentTagIndex = 7
								InfinityIndex = #TagSongs
								if #TagSongs > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							elseif #TagSongs ~= 0 then
								InfinityIndex = #TagSongs
								CurrentTagIndex = #TagSongs + 1
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							elseif #TagPacks > 0 then
								CurrentColumn = 2
								if #TagPacks + 1 >= 7 then
									CurrentTagIndex = 7
								else
									CurrentTagIndex = #TagPacks + 1
								end
								if #TagPacks > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							end
						elseif CurrentColumn == 2 then
							if #TagPacks > 0 then
								if #TagPacks + 1 >= 7 then
									CurrentTagIndex = 7
									InfinityIndex = #TagPacks
								else
									CurrentTagIndex = #TagPacks + 1
									InfinityIndex = #TagPacks
								end
								if #TagPacks > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
							elseif #TagSongs > 0 then
								CurrentColumn = 1
								if #TagSongs + 1 >= 7 then
									CurrentTagIndex = 7
									InfinityIndex = #TagSongs
									if #TagSongs > 6 then
										MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
									end
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
								else 
									InfinityIndex = #TagSongs
									CurrentTagIndex = #TagSongs + 1
									SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
								end
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					else
						if CurrentTagIndex == 2 and InfinityIndex > 1 then
							InfinityIndex = InfinityIndex - 1
							if CurrentColumn == 1 then
								if #TagSongs > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
							elseif CurrentColumn == 2 then
								if #TagPacks > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
							end
						else
							InfinityIndex = InfinityIndex - 1
							CurrentTagIndex = CurrentTagIndex - 1
						end
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				elseif Direction[1] == "Down" then
					if CurrentTagIndex == 7 then
						if CurrentColumn == 1 then
							if #TagSongs + 1 <= 7 or InfinityIndex == #TagSongs then
								InfinityIndex = 0
								CurrentTagIndex = 1
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
								if #TagSongs > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
							else
								InfinityIndex = InfinityIndex + 1
								if #TagSongs > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							end
						elseif CurrentColumn == 2 then
							if #TagPacks + 1 < 7 or InfinityIndex == #TagPacks then
								InfinityIndex = 0
								CurrentTagIndex = 1
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
								if #TagPacks > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
							else
								InfinityIndex = InfinityIndex + 1
								if #TagPacks > 6 then
									MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
								end
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							end
						end
					elseif CurrentColumn == 1 and CurrentTagIndex == #TagSongs + 1 and #TagSongs ~= 0 then
						CurrentTagIndex = 1
						InfinityIndex = 0
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif CurrentColumn == 2 and CurrentTagIndex == #TagPacks + 1 and #TagPacks > 0 then
						CurrentTagIndex = 1
						InfinityIndex = 0
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif #TagSongs == 0 and CurrentTagIndex == 1 and #TagPacks > 0 then
						CurrentColumn = 2
						CurrentTagIndex = CurrentTagIndex + 1
						InfinityIndex = InfinityIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					elseif #TagPacks == 0 and CurrentTagIndex == 1 and #TagSongs > 0 and CurrentColumn == 2 then
						CurrentColumn = 1
						InfinityIndex = 0
						CurrentTagIndex = CurrentTagIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					else
						InfinityIndex = InfinityIndex + 1
						CurrentTagIndex = CurrentTagIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					end
				elseif Direction[1] == "Left" or Direction[1] == "Right" then		
						if CurrentColumn == 1 and CurrentTagIndex ~= 1 then
							if #TagPacks + 1 > 0 then
								CurrentColumn = 2
								if CurrentTagIndex > #TagPacks + 1 then
									CurrentTagIndex = #TagPacks + 1
									InfinityIndex = CurrentTagIndex - 1
								end
							end
							if Direction[1] == "Right" then
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							else
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							end
						elseif CurrentColumn == 2 and CurrentTagIndex ~= 1 then
							if #TagSongs + 1 > 0 then
								CurrentColumn = 1
								if CurrentTagIndex > #TagSongs + 1 then
									CurrentTagIndex = #TagSongs + 1
									InfinityIndex = CurrentTagIndex - 1	
								end
							end
							if Direction[1] == "Right" then
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							else
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							end
						end
						if #TagSongs > 6 then
							InfinityIndex = CurrentTagIndex - 1
							MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
						end
						if #TagPacks > 6 then
							MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, Direction[1]})
							InfinityIndex = CurrentTagIndex - 1
						end
				end
			end
			local Parent 
			if CurrentColumn == 1 or CurrentTagIndex == 1 then
				Parent = self:GetParent():GetChild(CurrentTagSongNames[CurrentTagIndex])
			elseif CurrentColumn == 2 then
				Parent = self:GetParent():GetChild(CurrentTagPackNames[CurrentTagIndex])
			end
			local XPos = Parent:GetX()
			local YPos = Parent:GetY()
			local CursorWidth
			local CursorHeight
			local Zoom = Parent:GetZoom()
			if CurrentTagIndex == 1 then
				CursorWidth = Parent:GetZoomX()
				CursorHeight = Parent:GetZoomY() - 5
				YPos = YPos + 2.5
				MESSAGEMAN:Broadcast("ToggleTextCursor", {"Show"})
			else
				CursorWidth = Parent:GetWidth() * Zoom
				CursorHeight = Parent:GetHeight() * Zoom
				if CursorWidth > ((quadwidth-quadborder)/1.7) then CursorWidth = ((quadwidth-quadborder)/1.7) * Zoom end
				MESSAGEMAN:Broadcast("ToggleTextCursor", {"Hide"})
			end
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			XPos = XPos + (0.5-HAlign)*CursorWidth
			YPos = YPos + (0.5-VAlign)*CursorHeight
			self:linear(0.2)
			self:xy(XPos,YPos)
			self:zoomx(CursorWidth)
			self:zoomy(CursorHeight + 5)
			self:queuecommand('BrightenCursor')
		end
	end,
	TagSelectionMadeMessageCommand=function(self)
		-- don't do anything if we're in a sub menu
		if not AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			if NumPlayers == 2 then
				if CurrentTagIndex == 1 then
					if Player == PLAYER_2 or Player == "PlayerNumber_P2" then
						Player = PLAYER_1
						PlayerNumber = 0
						self:stoptweening():diffuse(PlayerColor(Player)):diffusealpha(0.4):queuecommand('DimCursor')
						MESSAGEMAN:Broadcast("ChangeTabPlayerColor")
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						return
					end
				elseif CurrentTagIndex == 2 then
					if Player == PLAYER_1 or Player == "PlayerNumber_P1" then
						Player = PLAYER_2
						PlayerNumber = 1
						self:stoptweening():diffuse(PlayerColor(Player)):diffusealpha(0.4):queuecommand('DimCursor')
						MESSAGEMAN:Broadcast("ChangeTabPlayerColor")
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						return
					end
				end
				FakeIndex = CurrentTagIndex - 2
			else
				FakeIndex = CurrentTagIndex
			end
			if FakeIndex == 1 and IsSong() then
				AddTagSubMenu = true
				local Song = GAMESTATE:GetCurrentSong()
				MESSAGEMAN:Broadcast("ToggleAddTagsMenu", {Song, Player})
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
			elseif FakeIndex == 2 then
				if IsGroup() then
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					AddTagSubMenu = true
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					MESSAGEMAN:Broadcast("ToggleAddTagsMenu", {NameOfGroup, Player})
				elseif (Input.WheelWithFocus == GroupWheel and Input.WheelWithFocus:get_info_at_focus_pos() ~= "RANDOM-PORTAL") or 
						(Input.WheelWithFocus == SongWheel and Input.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder") then
					if GetMainSortPreference ~= 1 then
						SM('Main sort must be set to "GROUP"!')
					end
				end
			elseif FakeIndex == 3 then
				if IsSong() and IsCurrentSongTagged(GAMESTATE:GetCurrentSong(), PlayerNumber) then
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					RemoveTagSubMenu = true
					local Song = GAMESTATE:GetCurrentSong()
					MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu", {Song, Player})
				end
			elseif FakeIndex == 4 then
				if IsGroup() and IsCurrentGroupTagged(NameOfGroup, PlayerNumber) then
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					RemoveTagSubMenu = true
					MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu", {NameOfGroup, Player})
				elseif IsSong() and IsCurrentGroupTagged(NameOfGroup, PlayerNumber) then	
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					RemoveTagSubMenu = true
					MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu", {NameOfGroup, Player, "GroupTag"})
				end
			elseif FakeIndex == 5 then
				if #GetCurrentPlayerTags(PlayerNumber) > 0 then
					ManageTagsSubMenu = true
					MESSAGEMAN:Broadcast("ToggleManageTagsMenu", {PlayerNumber})
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				else
					SM("No tags to manage!")
				end
			end
			if CurrentTagIndex == MaxIndex then
				if not HaveTagsChanged then
					SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
					MESSAGEMAN:Broadcast("InitializeTagsMenu")
					MESSAGEMAN:Broadcast("ToggleTagsMenu")
				else
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
					MESSAGEMAN:Broadcast("ReloadSSMDD")
				end
			end
		elseif AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			local SongOrGroup
			local Object
			if IsSong() then
				SongOrGroup = "Song"
				Object = "Song: "..GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
			elseif IsGroup() then
				SongOrGroup = "Pack"
				Object = "Pack: "..NameOfGroup
			end
			if CurrentTagIndex == 1 then
				MESSAGEMAN:Broadcast('AddCurrentTagText', {PlayerNumber, SongOrGroup, Player_Tags})
			else
				MESSAGEMAN:Broadcast('AddCurrentTag', {PlayerNumber, TagsToBeAdded[InfinityIndex], SongOrGroup})
			end
		elseif RemoveTagSubMenu and not AddTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			AvailableTags = GetCurrentObjectTags(CurrentObject, PlayerNumber)
			Tag = AvailableTags[InfinityIndex]
			MESSAGEMAN:Broadcast('RemoveCurrentTag', {PlayerNumber, Tag, CurrentObject})
		elseif ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu and not CurrentTagSubMenu then
			Tag = Player_Tags[InfinityIndex]
			TagSongs, TagSongsLines = GetObjectsPerTag(Tag, PlayerNumber, "Song")
			TagPacks, TagPacksLines = GetObjectsPerTag(Tag, PlayerNumber, "Pack")
			CurrentTagSubMenu = true
			ManageTagsSubMenu = false
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
			MESSAGEMAN:Broadcast('ToggleCurrentTagMenu', {Tag, PlayerNumber})
			MESSAGEMAN:Broadcast('ManageCurrentTag', {TagSongs, TagPacks})
		elseif CurrentTagSubMenu and not ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu then
			if CurrentTagIndex == 1 then
				MESSAGEMAN:Broadcast("RenameCurrentTagText", {PlayerNumber, Tag})
			else
				if CurrentColumn == 1 then
					MESSAGEMAN:Broadcast( "RemoveCurrentObject", {PlayerNumber, Tag, TagSongsLines[InfinityIndex]} )
				elseif CurrentColumn == 2 then
					MESSAGEMAN:Broadcast( "RemoveCurrentObject", {PlayerNumber, Tag, TagPacksLines[InfinityIndex]} )
				end
			end
			
		end
	end,
	TagMenuLeftClickMessageCommand=function(self)
		local MouseIndex
		local ClickConnect = false
		-- Main menu of tag menu
		if not AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			for i=1, #CursorPositionNames do
				local Parent = self:GetParent():GetChild(CursorPositionNames[i])
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local ObjectWidth = Parent:GetWidth()
				local ObjectHeight = Parent:GetHeight()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					MouseIndex = i
					ClickConnect = true
					break
				end
			end
			
			if ClickConnect then
				if NumPlayers == 2 then
					FakeIndex = MouseIndex - 2
					if FakeIndex == -1 then
						CurrentTagIndex = 1
						if Player == PLAYER_2 or Player == "PlayerNumber_P2" then
							Player = PLAYER_1
							PlayerNumber = 0
							self:stoptweening():diffuse(PlayerColor(Player)):diffusealpha(0.4):queuecommand('DimCursor')
							MESSAGEMAN:Broadcast("ChangeTabPlayerColor")
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
							return
						end
					elseif FakeIndex == 0 then
						CurrentTagIndex = 2
						if Player == PLAYER_1 or Player == "PlayerNumber_P1" then
							Player = PLAYER_2
							PlayerNumber = 1
							self:stoptweening():diffuse(PlayerColor(Player)):diffusealpha(0.4):queuecommand('DimCursor')
							MESSAGEMAN:Broadcast("ChangeTabPlayerColor")
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
							return
						end
					end
				else
					FakeIndex = MouseIndex
				end
				if FakeIndex == 1 then
					CurrentTagIndex = 1
					if IsSong() then
						AddTagSubMenu = true
						local Song = GAMESTATE:GetCurrentSong()
						MESSAGEMAN:Broadcast("ToggleAddTagsMenu", {Song, Player})
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					else
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					end
				elseif FakeIndex == 2 then
					CurrentTagIndex = 2
					if IsGroup() then
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						AddTagSubMenu = true
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						MESSAGEMAN:Broadcast("ToggleAddTagsMenu", {NameOfGroup, Player})
					elseif (Input.WheelWithFocus == GroupWheel and Input.WheelWithFocus:get_info_at_focus_pos() ~= "RANDOM-PORTAL") or 
							(Input.WheelWithFocus == SongWheel and Input.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder") then
						if GetMainSortPreference ~= 1 then
							SM('Main sort must be set to "GROUP"!')
						end
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					else
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					end
				elseif FakeIndex == 3 then
					CurrentTagIndex = 3
					if IsSong() and IsCurrentSongTagged(GAMESTATE:GetCurrentSong(), PlayerNumber) then
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						RemoveTagSubMenu = true
						local Song = GAMESTATE:GetCurrentSong()
						MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu", {Song, Player})
					else
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					end
				elseif FakeIndex == 4 then
					CurrentTagIndex = 4
					if IsGroup() and IsCurrentGroupTagged(NameOfGroup, PlayerNumber) then
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						RemoveTagSubMenu = true
						MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu", {NameOfGroup, Player})
					elseif IsSong() and IsCurrentGroupTagged(NameOfGroup, PlayerNumber) then	
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						RemoveTagSubMenu = true
						MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu", {NameOfGroup, Player, "GroupTag"})
					else
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					end
				elseif FakeIndex == 5 then
					CurrentTagIndex = 5
					if #GetCurrentPlayerTags(PlayerNumber) > 0 then
						ManageTagsSubMenu = true
						MESSAGEMAN:Broadcast("ToggleManageTagsMenu", {PlayerNumber})
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					else
						SM("No tags to manage!")
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					end
				end
				if FakeIndex == 6 then
					CurrentTagIndex = MaxIndex
					if not HaveTagsChanged then
						SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
						MESSAGEMAN:Broadcast("InitializeTagsMenu")
						MESSAGEMAN:Broadcast("ToggleTagsMenu")
					else
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
						MESSAGEMAN:Broadcast("ReloadSSMDD")
					end
				end
				
				if NumPlayers == 2 then
					CurrentTagIndex = FakeIndex + 2
				end
				MESSAGEMAN:Broadcast('UpdateTagCursor')
			end
		--- Add tags menu	
		elseif AddTagSubMenu and not RemoveTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			for i=1, #TagPositionNames do
				local Parent = self:GetParent():GetChild(TagPositionNames[i])
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local ObjectWidth
				local ObjectHeight
				if i == 1 then
					ObjectWidth = Parent:GetZoomX()
					ObjectHeight = Parent:GetZoomY()
				else
					ObjectWidth = Parent:GetWidth()
					ObjectHeight = Parent:GetHeight()
				end
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					MouseIndex = i
					ClickConnect = true
					break
				end
			end
			if ClickConnect then
				if MouseIndex == 1 then
					CurrentTagIndex = 1
					InfinityIndex = 0
					MESSAGEMAN:Broadcast("UpdateTagCursor")
					MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber, Object} )
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
				else
					local Difference = MouseIndex - CurrentTagIndex
					CurrentTagIndex = CurrentTagIndex + Difference
					InfinityIndex = InfinityIndex + Difference
					MESSAGEMAN:Broadcast("UpdateTagCursor")
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
				end
			end
		-- Remove tags menu
		elseif RemoveTagSubMenu and not AddTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			for i=1, #RemoveTagPositionNames do
				local Parent = self:GetParent():GetChild(RemoveTagPositionNames[i])
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local ObjectWidth = Parent:GetWidth()
				local ObjectHeight = Parent:GetHeight()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					MouseIndex = i
					ClickConnect = true
					break
				end
			end
			
			if ClickConnect then
				local Difference = MouseIndex - CurrentTagIndex
				CurrentTagIndex = CurrentTagIndex + Difference
				InfinityIndex = InfinityIndex + Difference
				MESSAGEMAN:Broadcast("UpdateTagCursor")
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			end
		--- Manage tags menu	
		elseif ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu and not CurrentTagSubMenu then
			for i=1, #ManageTagNames do
				local Parent = self:GetParent():GetChild(ManageTagNames[i])
				local Zoom = Parent:GetZoom()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local ObjectWidth = Parent:GetWidth() * Zoom
				local ObjectHeight = Parent:GetHeight() * Zoom
				if ObjectWidth > (quadwidth-quadborder)/2.75 then
					ObjectWidth = (quadwidth-quadborder)/2.75 * Zoom
				end
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					MouseIndex = i
					ClickConnect = true
					break
				end
			end
			
			if ClickConnect then
				local Difference = MouseIndex - CurrentTagIndex
				CurrentTagIndex = CurrentTagIndex + Difference
				InfinityIndex = InfinityIndex + Difference
				MESSAGEMAN:Broadcast("UpdateTagCursor")
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			end
			
		--- Current Tag menu
		elseif CurrentTagSubMenu and not ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu then
			-- Text Entry Quad
			local ParentQuad = self:GetParent():GetChild("RenameTagQuad")
			local QuadX = ParentQuad:GetX()
			local QuadY = ParentQuad:GetY()
			local QuadWidth = ParentQuad:GetZoomX()
			local QuadHeight = ParentQuad:GetZoomY()
			local HAlignQuad = ParentQuad:GetHAlign()
			local VAlignQuad = ParentQuad:GetVAlign()
			QuadX = QuadX + (0.5-HAlignQuad)*QuadWidth
			QuadY = QuadY + (0.5-VAlignQuad)*QuadHeight
			if IsMouseGucci(QuadX, QuadY, QuadWidth, QuadHeight) then
				CurrentTagIndex = 1
				InfinityIndex = 0
				MESSAGEMAN:Broadcast("UpdateTagCursor")
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			end
			-- Tag Songs
			for i=1, #CurrentTagSongNames do
				local SongParent = self:GetParent():GetChild(CurrentTagSongNames[i])
				local Zoom = SongParent:GetZoom()
				local ObjectX = SongParent:GetX()
				local ObjectY = SongParent:GetY()
				local ObjectWidth = SongParent:GetWidth()
				local ObjectHeight = SongParent:GetHeight()
				
				if ObjectWidth > (quadwidth-quadborder)/1.75 then
					ObjectWidth = (quadwidth-quadborder)/1.75
				end
				
				local HAlign = SongParent:GetHAlign()
				local VAlign = SongParent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth * Zoom
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight * Zoom
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					if CurrentColumn == 2 then
						CurrentColumn = 1
						CurrentTagIndex = i
						InfinityIndex = i - 1
						MESSAGEMAN:Broadcast("UpdateCurrentPackTagsText", {PlayerNumber, Tag, InfinityIndex, "Left"})
						MESSAGEMAN:Broadcast("UpdateTagCursor")
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						break
					else
						MouseIndex = i
						ClickConnect = true
						break
					end
				end
			end
			-- Tag packs
			for i=1, #CurrentTagPackNames do
				local PackParent = self:GetParent():GetChild(CurrentTagPackNames[i])
				local Zoom = PackParent:GetZoom()
				local ObjectX = PackParent:GetX()
				local ObjectY = PackParent:GetY()
				local ObjectWidth = PackParent:GetWidth()
				local ObjectHeight = PackParent:GetHeight()
				if ObjectWidth > (quadwidth-quadborder)/1.75 then
					ObjectWidth = (quadwidth-quadborder)/1.75
				end
				
				local HAlign = PackParent:GetHAlign()
				local VAlign = PackParent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth * Zoom
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight * Zoom
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					if CurrentColumn == 1 then
						CurrentColumn = 2
						CurrentTagIndex = i
						InfinityIndex = i - 1
						MESSAGEMAN:Broadcast("UpdateCurrentSongTagsText", {PlayerNumber, Tag, InfinityIndex, "Right"})
						MESSAGEMAN:Broadcast("UpdateTagCursor")
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						break
					else
						MouseIndex = i
						ClickConnect = true
						MESSAGEMAN:Broadcast("UpdateTagCursor")
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
						break
					end
				end
			end
			if ClickConnect then
				local Difference = MouseIndex - CurrentTagIndex
				CurrentTagIndex = CurrentTagIndex + Difference
				InfinityIndex = InfinityIndex + Difference
				MESSAGEMAN:Broadcast("UpdateTagCursor")
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			end
		end
	end,
	ToggleAddTagsMenuMessageCommand=function(self)
		self:stoptweening()
		CurrentTagIndex = 1
		InfinityIndex = 0
		local Object
		if IsSong() then
			Object = GAMESTATE:GetCurrentSong()
		elseif IsGroup() then
			Object = NameOfGroup
		end
		TagsToBeAdded = GetAvailableTagsToAdd(Object, PlayerNumber)
		self:queuecommand('UpdateTagCursor')
	end,
	ToggleRemoveTagsMenuMessageCommand=function(self, params)
		self:stoptweening()
		CurrentTagIndex = 1
		self:queuecommand('UpdateTagCursor')
		InfinityIndex = 1
		if not params then return end
		Object = params[1]
		CurrentObject = params[1]
		AvailableTags = GetCurrentObjectTags(Object, PlayerNumber)
	end,
	ToggleManageTagsMenuMessageCommand=function(self)
		self:stoptweening()
		CurrentTagIndex = 1
		InfinityIndex = 1
		self:queuecommand('UpdateTagCursor')
	end,
	ToggleCurrentTagMenuMessageCommand=function(self)
		self:stoptweening()
		CurrentTagIndex = 1
		if CurrentTagSubMenu then
			InfinityIndex = 0
		else
			MESSAGEMAN:Broadcast('UpdateRemovedTag', {PlayerNumber, Player_Tags})
			InfinityIndex = 1
		end
		self:queuecommand('UpdateTagCursor')
	end,
	-- i hate that I need to do this but im lazy so
	CheckUpdateTagTextMessageCommand=function(self, params)
		local input = params[1]
		if CurrentTagSubMenu then
			if CurrentTagIndex == 1 then
				MESSAGEMAN:Broadcast('UpdateTagText', {input})
			end
		elseif AddTagSubMenu then
			if CurrentTagIndex == 1 then
				MESSAGEMAN:Broadcast('UpdateTagText', {input})
			end
		end
	end,
	UpdateRenamedTagMessageCommand=function(self, params)
		local PlayerNum = params[2]
		Player_Tags = GetCurrentPlayerTags(PlayerNumber)
	end,
	UpdateRemovedObjectsMessageCommand=function(self, params)
		local PlayerNum = params[1]
		local CurrentTag = params[2]
		TagSongs, TagSongsLines = GetObjectsPerTag(CurrentTag, PlayerNumber, "Song")
		TagPacks, TagPacksLines = GetObjectsPerTag(CurrentTag, PlayerNumber, "Pack")
		self:stoptweening()
		CurrentTagIndex = 1
		InfinityIndex = 0
		self:queuecommand('UpdateTagCursor')
	end,
	UpdateRemovedTagMessageCommand=function(self, params)
		Player_Tags = params[2]
	end,
	UpdateAddedTagsMessageCommand=function(self, params)
		local PlayerNum = params[1]
		self:stoptweening()
		CurrentTagIndex = 1
		InfinityIndex = 0
		local Object
		if IsSong() then
			Object = GAMESTATE:GetCurrentSong()
		elseif IsGroup() then
			Object = NameOfGroup
		end
		TagsToBeAdded = GetAvailableTagsToAdd(Object, PlayerNumber)
		self:queuecommand('UpdateTagCursor')
	end,
}

return t