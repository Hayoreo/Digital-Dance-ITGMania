local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]
local t = args[4]
local quadwidth = args[5]
local quadheight = args[6]
local quadborder = args[7]
local TagXPosition = SCREEN_CENTER_X - quadwidth/2 + 45
local TagYPosition = SCREEN_CENTER_Y - quadheight/2 + 88
local Player_Tags
local MaxTagLength = 22

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


-- Text entry header
t[#t+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="TextEntryHeader",
	InitCommand=function(self)
		self:visible(false)
		self:diffuse(color("#FFFFFF"))
		self:horizalign(center)
		self:xy(SCREEN_CENTER_X ,SCREEN_CENTER_Y - quadheight/2 + quadborder*2 + 32)
		self:zoom(1)
		self:draworder(150)
		self:settext("Add new tag?")
	end,
	ToggleAddTagsMenuMessageCommand=function(self)
		if self:GetVisible() then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
	ToggleRemoveTagsMenuMessageCommand=function(self)
		self:visible(false)
	end,
}

-- Text entry quad
t[#t+1] = Def.Quad{
	Name="TextEntryQuad",
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X ,SCREEN_CENTER_Y - quadheight/2 + quadborder*2 + 58)
		self:zoomx(quadwidth/1.2)
		self:zoomy(20)
		self:diffuse(color("#636363"))
		self:diffusealpha(1)
		self:visible(false)
	end,
	ToggleAddTagsMenuMessageCommand=function(self)
		if self:GetVisible() then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
	ToggleRemoveTagsMenuMessageCommand=function(self)
		self:visible(false)
	end,
}

-- Add New Tag Text
t[#t+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="NewTagText",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild("TextEntryQuad")
		local XPos = Parent:GetX()
		local YPos = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		XPos = XPos - QuadWidth/2 + 4
		self:visible(false)
		self:diffuse(color("#FFFFFF"))
		self:horizalign(left)
		self:xy(XPos, YPos)
		self:zoom(1)
		self:draworder(150)
		self:settext("")
	end,
	ToggleAddTagsMenuMessageCommand=function(self)
		if AddTagSubMenu then
			self:visible(true)
		else
			self:settext(""):visible(false)
			MESSAGEMAN:Broadcast('UpdateTextCursor')
		end
	
	end,
	UpdateTagTextMessageCommand=function(self, params)
		if AddTagSubMenu and params then
			local Text = self:GetText()
			if params[1] == "Backspace" and Text:len() > 0 then
				SOUND:PlayOnce( THEME:GetPathS("ScreenTextEntry", "backspace.ogg") )
				Text = Text:sub(1, Text:len()-1)
				self:settext(Text)
				MESSAGEMAN:Broadcast('UpdateTextCursor')
			elseif Text:len() < MaxTagLength and params[1] ~= "Backspace" then
				local letter = params[1]
				SOUND:PlayOnce( THEME:GetPathS("ScreenTextEntry", "type.ogg") )
				Text = Text..letter
				self:settext(Text)
				MESSAGEMAN:Broadcast('UpdateTextCursor')
			end
		end
	end,
	AddCurrentTagTextMessageCommand=function(self, params)
		local PlayerNumber = params[1]
		local SongOrGroup = params[2]
		local AllTags = params[3]
		local Text = self:GetText()
		local IsNewTag = true
		for i=1, #AllTags do
			if AllTags[i] == Text then
				IsNewTag = false
				break
			end
		end
		if Text:len() > 0 and IsNewTag then
			MESSAGEMAN:Broadcast("CreateNewTagFromText", {PlayerNumber, SongOrGroup, Text})
		elseif not IsNewTag then
			SM("This tag already exists!")
		end
	end,
	UpdatePlayerTagsTextMessageCommand=function(self)
		self:settext("")
		MESSAGEMAN:Broadcast('UpdateTextCursor')
	end,
}

-- Text entry Cursor
t[#t+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="TextEntryCursor",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild("NewTagText")
		local XPos = Parent:GetX()
		local YPos = Parent:GetY()
		self:visible(false)
		self:diffuse(color("#FFFFFF"))
		self:horizalign(left)
		self:xy(XPos,YPos)
		self:zoom(1)
		self:draworder(150)
		self:settext("_")
		self:queuecommand('BlinkCursor')
	end,
	BlinkCursorCommand=function(self)
		if AddTagSubMenu then
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(true)
			end
			self:sleep(0.5):queuecommand('BlinkCursor')
		end
	end,
	ToggleAddTagsMenuMessageCommand=function(self)
		if AddTagSubMenu then
			self:visible(true):queuecommand('BlinkCursor')
		else
			self:visible(false)
		end
	end,
	ToggleRemoveTagsMenuMessageCommand=function(self)
		self:visible(false)
	end,
	ToggleTextCursorMessageCommand=function(self, params)
		if AddTagSubMenu then
			self:stoptweening()
			if params[1] == "Show" then
				self:visible(true):queuecommand('BlinkCursor')
			elseif params[1] == "Hide" then
				self:visible(false)
			end
		end
	end,
	UpdateTextCursorMessageCommand=function(self)
		self:stoptweening()
		local Parent = self:GetParent():GetChild("NewTagText")
		local XPos = Parent:GetX()
		local YPos = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local TextWidth = Parent:GetWidth()
		self:xy(XPos + TextWidth, YPos):queuecommand('BlinkCursor')
	end,
}

-- player tags
for i=1, 15 do
		t[#t+1] = Def.BitmapText{
			Font="Miso/_miso",
			Name="PlayerTags"..i,
			InitCommand=function(self)
				self:visible(false)
				self:diffuse(color("#FFFFFF"))
				self:horizalign(center)
				self:vertalign(top)
				self:x(TagXPosition)
				self:y(TagYPosition)
				self:zoom(0.75)
				self:draworder(150)
				self:settext("")
				self:maxwidth((quadwidth-quadborder)/2.75)
			end,
			UpdatePlayerTagsTextMessageCommand=function(self, params)
				if not params then return end
				local PlayerNumber = params[1]
				local text = ""
				local Object
				if IsSong() then
					Object = GAMESTATE:GetCurrentSong()
				elseif IsGroup() then
					Object = NameOfGroup
				end
				TagsToBeAdded = GetAvailableTagsToAdd(Object, PlayerNumber)
				if i > #TagsToBeAdded then
					self:settext("")
				else
					self:settext(TagsToBeAdded[i])	
				end
				if i == 2 or i == 5 or i == 8 or i == 11 or i == 14 then
					self:x(TagXPosition + 100)
				elseif i == 3 or i == 6 or i == 9 or i == 12 or i == 15 then
					self:x(TagXPosition + 200)
				end
				
				if i == 4 or i == 5 or i == 6 then
					self:y(TagYPosition + 20)
				elseif  i == 7 or i == 8 or i == 9 then
					self:y(TagYPosition + 40)
				elseif  i == 10 or i == 11 or i == 12 then
					self:y(TagYPosition + 60)
				elseif i == 13 or i == 14 or i == 15 then
					self:y(TagYPosition + 80)
				end
			end,
			UpdateAddTagsTextMessageCommand=function(self, params)
				if not params then return end
				local PlayerNumber = params[1]
				local Tags = params[2]
				local Index = params [3]
				local FakeIndex = params[4] - 1
				local Wrap = params[5]
				local Direction = params[6]
				local text = ""
				
				local Difference = 0
				if FakeIndex ~= nil then
					Difference = Index - FakeIndex
				else
					Difference = -24
				end
				
				if Wrap == "Top" then 
					Difference = 0
				end
				
				if Direction == "Down" then
					if Difference < 3 then
						if Difference < 0 then
							Difference = 0
						else
							Difference = 3
						end
					end
				end
				
				
				if i + Difference > #Tags then
					self:settext("")
				else
					self:settext(Tags[i + Difference])	
				end
				if i == 2 or i == 5 or i == 8 or i == 11 or i == 14 then
					self:x(TagXPosition + 100)
				elseif i == 3 or i == 6 or i == 9 or i == 12 or i == 15 then
					self:x(TagXPosition + 200)
				end
				
				if i == 4 or i == 5 or i == 6 then
					self:y(TagYPosition + 20)
				elseif  i == 7 or i == 8 or i == 9 then
					self:y(TagYPosition + 40)
				elseif  i == 10 or i == 11 or i == 12 then
					self:y(TagYPosition + 60)
				elseif i == 13 or i == 14 or i == 15 then
					self:y(TagYPosition + 80)
				end
			end,
			ToggleAddTagsMenuMessageCommand=function(self)
				if self:GetVisible() then
					self:visible(false)
				else
					self:visible(true)
				end
			end,
			ToggleRemoveTagsMenuMessageCommand=function(self)
				self:visible(false)
			end,
			ToggleManageTagsMenuMessageCommand=function(self)
				self:visible(false)
			end,
			ToggleCurrentTagMenuMessageCommand=function(self)
				self:visible(false)
			end,
		}
end


return t