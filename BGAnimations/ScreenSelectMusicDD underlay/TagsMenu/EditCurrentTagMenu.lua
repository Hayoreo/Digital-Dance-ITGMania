local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]
local t = args[4]
local quadwidth = args[5]
local quadheight = args[6]
local quadborder = args[7]
local TagXPosition = SCREEN_CENTER_X - quadwidth/2 + 10
local TagYPosition = SCREEN_CENTER_Y - quadheight/2 + 74
local CurrentTagName
local MaxTagLength = 22
local PositionSong = nil
local PositionPack = nil


--- I still do not understand why i have to throw in a random actor frame before everything else will work????
t[#t+1] = Def.Quad{}

--- Rename tag?
t[#t+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="RenameTag?",
	InitCommand=function(self)
		self:visible(false)
		self:diffuse(color("#FFFFFF"))
		self:horizalign(left)
		self:vertalign(top)
		self:x(TagXPosition)
		self:y(TagYPosition - 32)
		self:zoom(1)
		self:draworder(150)
		self:settext("Rename Tag?")
		self:maxwidth((quadwidth-quadborder)/1.75)
	end,
	ToggleCurrentTagMenuMessageCommand=function(self)
		if self:GetVisible() then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
	MaybeDeleteTagMessageCommand=function(self)
		if CurrentTagSubMenu then
			self:settext("Delete Tag?")
		end
	end,
	DontDeleteTagMessageCommand=function(self)
		if CurrentTagSubMenu then
			self:settext("Rename Tag?")
		end
	end,
}

-- Text entry quad
t[#t+1] = Def.Quad{
	Name="RenameTagQuad",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild("RenameTag?")
		local TextWidth = Parent:GetWidth()
		local TextHeight = Parent:GetHeight()
		local XPos = Parent:GetX() + TextWidth + 5
		local YPos = Parent:GetY()
		self:vertalign(top)
		self:horizalign(left)
		self:xy(XPos, YPos - 2)
		self:zoomx(quadwidth - TextWidth - 25)
		self:zoomy(20)
		self:diffuse(color("#636363"))
		self:diffusealpha(1)
		self:visible(false)
	end,
	ToggleCurrentTagMenuMessageCommand=function(self)
		if self:GetVisible() then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
}

-- CurrentTagText
t[#t+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="CurrentTagText",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild("RenameTagQuad")
		local XPos = Parent:GetX() + 4
		local YPos = Parent:GetY() + 10
		self:visible(false)
		self:diffuse(color("#FFFFFF"))
		self:horizalign(left)
		self:xy(XPos, YPos)
		self:zoom(1)
		self:draworder(150)
		self:settext("")
		self:queuecommand('BlinkCursor')
	end,
	ToggleCurrentTagMenuMessageCommand=function(self, params)
		if CurrentTagSubMenu then
			if params then
				CurrentTagName = params[1]
				self:settext(CurrentTagName)
				MESSAGEMAN:Broadcast('UpdateTextCursor')
			end
			self:visible(true)
		else
			self:settext(""):visible(false)
			MESSAGEMAN:Broadcast('UpdateTextCursor')
		end
	
	end,
	UpdateTagTextMessageCommand=function(self, params)
		if CurrentTagSubMenu and params then
			local Text = self:GetText()
			if params[1] == "Backspace" and Text:len() > 0 then
				SOUND:PlayOnce( THEME:GetPathS("ScreenTextEntry", "backspace.ogg") )
				Text = Text:sub(1, Text:len()-1)
				self:settext(Text)
				if Text:len() == 0 then
					MESSAGEMAN:Broadcast("MaybeDeleteTag")
				end
				MESSAGEMAN:Broadcast('UpdateTextCursor')
			elseif Text:len() < MaxTagLength and params[1] ~= "Backspace" then
				if Text:len() == 0 then
					MESSAGEMAN:Broadcast("DontDeleteTag")
				end
				local letter = params[1]
				SOUND:PlayOnce( THEME:GetPathS("ScreenTextEntry", "type.ogg") )
				Text = Text..letter
				self:settext(Text)
				MESSAGEMAN:Broadcast('UpdateTextCursor')
			end
		end
	end,
	RenameCurrentTagTextMessageCommand=function(self,params)
		local PlayerNumber = params[1]
		local Tag = params[2]
		local Text = self:GetText()
		if Text:len() > 0 and Text ~= Tag then
			MESSAGEMAN:Broadcast("RenameCurrentTag", {PlayerNumber, Tag, Text})
		elseif Text:len() == 0 then
			MESSAGEMAN:Broadcast("DeleteCurrentTag", {PlayerNumber, Tag})
		end
	end,
}

-- Text entry Cursor
t[#t+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="TextEntryCursor",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild("CurrentTagText")
		local XPos = Parent:GetX()
		local YPos = Parent:GetY()
		local TextWidth = Parent:GetWidth()
		self:visible(false)
		self:diffuse(color("#FFFFFF"))
		self:horizalign(left)
		self:xy(XPos + TextWidth, YPos)
		self:zoom(1)
		self:draworder(150)
		self:settext("_")
		self:queuecommand('BlinkCursor')
	end,
	BlinkCursorCommand=function(self)
		if CurrentTagSubMenu then
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(true)
			end
			self:sleep(0.5):queuecommand('BlinkCursor')
		end
	end,
	ToggleCurrentTagMenuMessageCommand=function(self)
		if CurrentTagSubMenu then
			self:visible(true):queuecommand('BlinkCursor')
			MESSAGEMAN:Broadcast('UpdateTextCursor')
		else
			self:visible(false)
		end
	end,
	ToggleTextCursorMessageCommand=function(self, params)
		if CurrentTagSubMenu then
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
		local Parent = self:GetParent():GetChild("CurrentTagText")
		local XPos = Parent:GetX()
		local YPos = Parent:GetY()
		local TextWidth = Parent:GetWidth()
		self:xy(XPos + TextWidth, YPos):queuecommand('BlinkCursor')
	end,
}


--- Player songs for tag
for i=1, 6 do
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name="TagSongs"..i,
		InitCommand=function(self)
			self:visible(false)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(left)
			self:vertalign(top)
			self:x(TagXPosition)
			self:y(TagYPosition)
			self:zoom(0.75)
			self:draworder(150)
			self:settext("")
			self:maxwidth((quadwidth-quadborder)/1.75)
		end,
		ToggleCurrentTagMenuMessageCommand=function(self)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(true)
			end
			PositionSong = nil
		end,
		ManageCurrentTagMessageCommand=function(self, params)
			local TagSongs = params[1]
			if #TagSongs > 0 then
				if i > #TagSongs then
					self:settext("")
				else
					self:y( TagYPosition + (i-1)*20)
					self:settext(TagSongs[i])
				end
			else
				self:settext("")
			end
		end,
		UpdateRemovedObjectsMessageCommand=function(self,params)
			local PlayerNumber = params[1]
			local Tag = params[2]
			local TagSongs = GetObjectsPerTag(Tag, PlayerNumber, "Song")
			if #TagSongs > 0 then
				if i > #TagSongs then
					self:settext("")
				else
					self:y( TagYPosition + (i-1)*20)
					self:settext(TagSongs[i])
				end
			else
				self:settext("")
			end
		end,
		UpdateCurrentSongTagsTextMessageCommand=function(self, params)
			if not params then return end
			local PlayerNumber = params[1]
			local Tag = params[2]
			local Index = params[3]
			local Direction = params[4]
			local TagSongs = GetObjectsPerTag(Tag, PlayerNumber, "Song")
			
			local Difference = Index - 6
			
			if Difference < 0 then
				if Index > 1 then
					Difference = Index - 1
				else
					Difference = 0
				end
			end
			
			if Direction == "Left" or Direction == "Right" then
				Difference = 0
			end
			
			if #TagSongs > 0 then
				if i+Difference > #TagSongs then
					self:settext("")
				else
					self:y( TagYPosition + (i-1)*20)
					self:settext(TagSongs[i+Difference])
				end
			else
				self:settext("")
			end
		
		end,
	}
end


--- Player groups for tag
for i=1, 6 do
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name="TagPacks"..i,
		InitCommand=function(self)
			self:visible(false)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(right)
			self:vertalign(top)
			self:x(TagXPosition + quadwidth-20)
			self:y(TagYPosition)
			self:zoom(0.75)
			self:draworder(150)
			self:settext("")
			self:maxwidth((quadwidth-quadborder)/1.7)
		end,
		ToggleCurrentTagMenuMessageCommand=function(self, params)
			if self:GetVisible() then
				self:visible(false)
			else
				self:visible(true)
			end
		end,
		ManageCurrentTagMessageCommand=function(self, params)
			TagPacks = params[2]
			if #TagPacks > 0 then
				if i > #TagPacks then
					self:settext("")
				else
					self:y( TagYPosition + (i-1)*20 )
					self:settext(TagPacks[i])
				end
			else
				self:settext("")
			end
		end,
		UpdateRemovedObjectsMessageCommand=function(self,params)
			local PlayerNumber = params[1]
			local Tag = params[2]
			local TagPacks = GetObjectsPerTag(Tag, PlayerNumber, "Pack")
			if #TagPacks > 0 then
				if i > #TagPacks then
					self:settext("")
				else
					self:y( TagYPosition + (i-1)*20)
					self:settext(TagPacks[i])
				end
			else
				self:settext("")
			end
		end,
		UpdateCurrentPackTagsTextMessageCommand=function(self, params)
			if not params then return end
			local PlayerNumber = params[1]
			local Tag = params[2]
			local Index = params[3]
			local Direction = params[4]
			local TagPacks = GetObjectsPerTag(Tag, PlayerNumber, "Pack")
			
			local Difference = Index - 6
			
			if Difference < 0 then
				if Index > 1 then
					Difference = Index - 1
				else
					Difference = 0
				end
			end
			
			if Direction == "Left" or Direction == "Right" then
				Difference = 0
			end
			
			if #TagPacks > 0 then
				if i+Difference > #TagPacks then
					self:settext("")
				else
					self:y( TagYPosition + (i-1)*20)
					self:settext(TagPacks[i+Difference])
				end
			else
				self:settext("")
			end
			
		end
	}
end


return t