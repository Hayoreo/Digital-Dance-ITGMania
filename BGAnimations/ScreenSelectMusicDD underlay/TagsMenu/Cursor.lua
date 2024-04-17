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
local FakeIndex
local CurrentColumn = 1
local Player_Tags
local NumTags = 1
local PlayerNumber
local AvailableTags
local TagSongs
local TagPacks
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
			if #Player_Tags > 0 then
				if Direction[1] == "Up" then
					if CurrentTagIndex == 1 then
						CurrentTagIndex = NumTags
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					elseif CurrentTagIndex == 2 or CurrentTagIndex == 3 or CurrentTagIndex == 4 then
						CurrentTagIndex = 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					else
						CurrentTagIndex = CurrentTagIndex - 3
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				elseif Direction[1] == "Down" then
					if CurrentTagIndex == NumTags then
						CurrentTagIndex = 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif CurrentTagIndex == 1 and NumTags > 1 then
						CurrentTagIndex = 2
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					else
						if CurrentTagIndex + 3 <= NumTags then
							CurrentTagIndex = CurrentTagIndex + 3
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						else
							CurrentTagIndex = 1
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
						
					end
				elseif Direction[1] == "Left" then
					if CurrentTagIndex == 2 or CurrentTagIndex == 5  or CurrentTagIndex == 8 or CurrentTagIndex == 11 or CurrentTagIndex == 14 then
						if CurrentTagIndex + 2 <= NumTags then
							CurrentTagIndex = CurrentTagIndex + 2
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						else
							CurrentTagIndex = NumTags
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					elseif CurrentTagIndex ~= 1 then
						CurrentTagIndex = CurrentTagIndex - 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				elseif Direction[1] == "Right" then
					if CurrentTagIndex == 4 or CurrentTagIndex == 7  or CurrentTagIndex == 10 or CurrentTagIndex == 13 or CurrentTagIndex == 16 then
						CurrentTagIndex = CurrentTagIndex - 2
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					else
						if CurrentTagIndex + 1 <= NumTags then
							CurrentTagIndex = CurrentTagIndex + 1
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						else
							CurrentTagIndex = NumTags
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					end
				end
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
				if CurrentTagIndex == 1 then
					if #AvailableTags >= 13 then
						CurrentTagIndex = 13
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 2 then
					if #AvailableTags >= 14 then
						CurrentTagIndex = 14
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 3 then
					if #AvailableTags >= 15 then
						CurrentTagIndex = 15
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					CurrentTagIndex = CurrentTagIndex - 3
				end
			elseif Direction[1] == "Down" then
				if CurrentTagIndex == 13 then
					CurrentTagIndex = 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 14 then
					CurrentTagIndex = 2
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 15 then
					CurrentTagIndex = 3
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				else
					if CurrentTagIndex + 3 <= #AvailableTags then
						CurrentTagIndex = CurrentTagIndex + 3
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				end
			elseif Direction[1] == "Left" then
				if CurrentTagIndex == 1 then
					if #AvailableTags >= 3 then
						CurrentTagIndex = 3
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 4 then
					if #AvailableTags >= 6 then
						CurrentTagIndex = 6
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 7 then
					if #AvailableTags >= 9 then
						CurrentTagIndex = 9
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 10 then
					if #AvailableTags >= 12 then
						CurrentTagIndex = 12
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 13 then
					if #AvailableTags >= 15 then
						CurrentTagIndex = 15
					else
						CurrentTagIndex = #AvailableTags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				else
					CurrentTagIndex = CurrentTagIndex - 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			elseif Direction[1] == "Right" then
				if CurrentTagIndex == 3 then
					CurrentTagIndex = 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 6 then
					CurrentTagIndex = 4
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 9 then
					CurrentTagIndex = 7
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 12 then
					CurrentTagIndex = 10
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 15 then
					CurrentTagIndex = 13
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex + 1 <= #AvailableTags then
					CurrentTagIndex = CurrentTagIndex + 1
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
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
				if CurrentTagIndex == 1 then
					if #Player_Tags >= 13 then
						CurrentTagIndex = 13
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 2 then
					if #Player_Tags >= 14 then
						CurrentTagIndex = 14
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 3 then
					if #Player_Tags >= 15 then
						CurrentTagIndex = 15
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				else
					CurrentTagIndex = CurrentTagIndex - 3
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			elseif Direction[1] == "Down" then
				if CurrentTagIndex == 13 then
					CurrentTagIndex = 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 14 then
					CurrentTagIndex = 2
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 15 then
					CurrentTagIndex = 3
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				else
					if CurrentTagIndex + 3 <= #Player_Tags then
						CurrentTagIndex = CurrentTagIndex + 3
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				end
			elseif Direction[1] == "Left" then
				if CurrentTagIndex == 1 then
					if #Player_Tags >= 3 then
						CurrentTagIndex = 3
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 4 then
					if #Player_Tags >= 6 then
						CurrentTagIndex = 6
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 7 then
					if #Player_Tags >= 9 then
						CurrentTagIndex = 9
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 10 then
					if #Player_Tags >= 12 then
						CurrentTagIndex = 12
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentTagIndex == 13 then
					if #Player_Tags >= 15 then
						CurrentTagIndex = 15
					else
						CurrentTagIndex = #Player_Tags
					end
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				else
					CurrentTagIndex = CurrentTagIndex - 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			elseif Direction[1] == "Right" then
				if CurrentTagIndex == 3 then
					CurrentTagIndex = 1
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 6 then
					CurrentTagIndex = 4
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 9 then
					CurrentTagIndex = 7
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 12 then
					CurrentTagIndex = 10
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex == 15 then
					CurrentTagIndex = 13
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				elseif CurrentTagIndex + 1 <= #Player_Tags then
					CurrentTagIndex = CurrentTagIndex + 1
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
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
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							elseif #TagSongs ~= 0 then
								CurrentTagIndex = #TagSongs + 1
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							elseif #TagPacks > 0 then
								CurrentColumn = 2
								if #TagPacks + 1 >= 7 then
									CurrentTagIndex = 7
								else
									CurrentTagIndex = #TagPacks + 1
								end
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							end
						elseif CurrentColumn == 2 then
							if #TagPacks + 1 >= 7 then
								CurrentTagIndex = 7
							else
								CurrentTagIndex = #TagPacks + 1
							end
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						end
					else
						CurrentTagIndex = CurrentTagIndex - 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
				elseif Direction[1] == "Down" then
					if CurrentTagIndex == 7 then
						CurrentTagIndex = 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif CurrentColumn == 1 and CurrentTagIndex == #TagSongs + 1 and #TagSongs ~= 0 then
						CurrentTagIndex = 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif CurrentColumn == 2 and CurrentTagIndex == #TagPacks + 1 and #TagPacks > 0 then
						CurrentTagIndex = 1
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					elseif #TagSongs == 0 and CurrentTagIndex == 1 and #TagPacks > 0 then
						CurrentColumn = 2
						CurrentTagIndex = CurrentTagIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					elseif #TagPacks == 0 and CurrentTagIndex == 1 and #TagSongs > 0 and CurrentColumn == 2 then
						CurrentColumn = 1
						CurrentTagIndex = CurrentTagIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					else
						CurrentTagIndex = CurrentTagIndex + 1
						SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
					end
				elseif Direction[1] == "Left" or Direction[1] == "Right" then
						if CurrentColumn == 1 and CurrentTagIndex ~= 1 then
							if #TagPacks + 1 > 0 then
								CurrentColumn = 2
								if CurrentTagIndex > #TagPacks + 1 then
									CurrentTagIndex = #TagPacks + 1
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
								end
							end
							if Direction[1] == "Right" then
								SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
							else
								SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
							end
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
				SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
				MESSAGEMAN:Broadcast("InitializeTagsMenu")
				MESSAGEMAN:Broadcast("ToggleTagsMenu")
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
				local TagObjects = GetObjectsPerTag(Player_Tags[CurrentTagIndex-1], PlayerNumber, SongOrGroup)
				local DoesObjectHaveTag = false
				for i=1, #TagObjects do
					if TagObjects[i] == Object then
						DoesObjectHaveTag = true
						break
					end
				end
				if not DoesObjectHaveTag then
					MESSAGEMAN:Broadcast('AddCurrentTag', {PlayerNumber, Player_Tags[CurrentTagIndex-1], SongOrGroup})
				else
					SM("This "..SongOrGroup:lower().." already has this tag!")
				end
			end
		elseif RemoveTagSubMenu and not AddTagSubMenu and not ManageTagsSubMenu and not CurrentTagSubMenu then
			AvailableTags = GetCurrentObjectTags(CurrentObject, PlayerNumber)
			Tag = AvailableTags[CurrentTagIndex]
			MESSAGEMAN:Broadcast('RemoveCurrentTag', {PlayerNumber, Tag, CurrentObject})
		elseif ManageTagsSubMenu and not RemoveTagSubMenu and not AddTagSubMenu and not CurrentTagSubMenu then
			Tag = Player_Tags[CurrentTagIndex]
			TagSongs = GetObjectsPerTag(Tag, PlayerNumber, "Song")
			TagPacks = GetObjectsPerTag(Tag, PlayerNumber, "Pack")
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
					MESSAGEMAN:Broadcast( "RemoveCurrentObject", {PlayerNumber, TagSongs[CurrentTagIndex-1], Tag} )
				elseif CurrentColumn == 2 then
					MESSAGEMAN:Broadcast( "RemoveCurrentObject", {PlayerNumber, TagPacks[CurrentTagIndex-1], Tag} )
				end
			end
			
		end
	end,
	ToggleAddTagsMenuMessageCommand=function(self)
		self:stoptweening()
		CurrentTagIndex = 1
		self:queuecommand('UpdateTagCursor')
	end,
	ToggleRemoveTagsMenuMessageCommand=function(self, params)
		self:stoptweening()
		CurrentTagIndex = 1
		self:queuecommand('UpdateTagCursor')
		if not params then return end
		Object = params[1]
		CurrentObject = params[1]
		AvailableTags = GetCurrentObjectTags(Object, PlayerNumber)
		
	end,
	ToggleManageTagsMenuMessageCommand=function(self)
		self:stoptweening()
		CurrentTagIndex = 1
		self:queuecommand('UpdateTagCursor')
	end,
	ToggleCurrentTagMenuMessageCommand=function(self)
		self:stoptweening()
		CurrentTagIndex = 1
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
		TagSongs = GetObjectsPerTag(CurrentTag, PlayerNumber, "Song")
		TagPacks = GetObjectsPerTag(CurrentTag, PlayerNumber, "Pack")
		self:stoptweening()
		CurrentTagIndex = 1
		self:queuecommand('UpdateTagCursor')
	end,
	UpdateRemovedTagMessageCommand=function(self, params)
		SM("HUH")
		Player_Tags = params[2]
	end,
}

return t