--- Here is all the info necessary for Tab 2
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
local mods = SL[pn].ActiveModifiers

local PlayerState = GAMESTATE:GetPlayerState(pn)
-----------------------------------------------------------------------------------------------------

local VisualModsNames = {
THEME:GetString("OptionTitles","Perspective"),
THEME:GetString("OptionTitles","Scroll"),
THEME:GetString("OptionTitles","BackgroundFilter"),
THEME:GetString("OptionTitles","MeasureLines"),
THEME:GetString("OptionTitles","JudgmentTilt"),
THEME:GetString("OptionNames","Hide"),
THEME:GetString("OptionNames","Hide"),
THEME:GetString("OptionTitles","NoteFieldOffsetX"),
THEME:GetString("OptionTitles","NoteFieldOffsetY"),
THEME:GetString("OptionTitles","VisualDelay"),
}

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

for i=1, #VisualModsNames do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."VisualMods"..i,
		InitCommand=function(self)
			local zoom = 0.7
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:diffuse(color("#b0b0b0"))
				:x(XPos + padding/2 + border*2)
				:y(YPos - height/2 + border + (i*20) + 10)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(VisualModsNames[i]..":")
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Perspectives ={
THEME:GetString("OptionNames","Overhead"),
THEME:GetString("OptionNames","Hallway"),
THEME:GetString("OptionNames","Distant"),
THEME:GetString("OptionNames","Incoming"),
THEME:GetString("OptionNames","Space"),
}

for i=1,#Perspectives do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Perspective"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."VisualMods1")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth*TextZoom + 5)
			else
				PastWidth = self:GetParent():GetChild(pn.."Perspective"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."Perspective"..i-1):GetX()
				CurrentX = PastX + (PastWidth*zoom) + 5
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/2)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Perspectives[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IsOverhead = PlayerState:GetPlayerOptions(0):Overhead()
local IsHallway = PlayerState:GetPlayerOptions(0):Hallway()
local IsDistant = PlayerState:GetPlayerOptions(0):Distant()
local IsIncoming = PlayerState:GetPlayerOptions(0):Incoming()
local IsSpace = PlayerState:GetPlayerOptions(0):Space()
local PerspectiveNumber

if IsOverhead then
	PerspectiveNumber = 1
elseif IsHallway then
	PerspectiveNumber = 2
elseif IsDistant then
	PerspectiveNumber = 3
elseif IsIncoming then
	PerspectiveNumber = 4
elseif IsSpace then
	PerspectiveNumber = 5
end

--- Perspective Selector
af[#af+1] = Def.Quad{
	Name=pn.."PerspectiveSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."Perspective"..PerspectiveNumber)
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local color = PlayerColor(player)
		self:diffuse(color)
			:draworder(1)
			:zoomto(TextWidth, 3)
			:vertalign(top):horizalign(left)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if CurrentTab == 2 and CurrentRow == 1 then
			if CurrentColumn == 1 then
				PerspectiveNumber = 1
				SetEngineMod(player, "Overhead", 1)
			elseif CurrentColumn == 2 then
				PerspectiveNumber = 2
				SetEngineMod(player, "Hallway", 1)
			elseif CurrentColumn == 3 then
				PerspectiveNumber = 3
				SetEngineMod(player, "Distant", 1)
			elseif CurrentColumn == 4 then
				PerspectiveNumber = 4
				SetEngineMod(player, "Incoming", 1)
			elseif CurrentColumn == 5 then
				PerspectiveNumber = 5
				SetEngineMod(player, "Space", 1)
			end
			local Parent = self:GetParent():GetChild(pn.."Perspective"..CurrentColumn)
			local TextZoom = Parent:GetZoom()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local TextHeight = Parent:GetHeight()
			local TextWidth = Parent:GetWidth() * TextZoom
			self:zoomto(TextWidth, 3)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
			SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		local MadeSelection = false
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		for j=1,#Perspectives do
			local Parent = self:GetParent():GetChild(pn.."Perspective"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
				if j == 1 then
					if CurrentRow ~= 1 and PerspectiveNumber == 1 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif PerspectiveNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					PerspectiveNumber = 1
					CurrentRow = 1
					CurrentColumn = 1
					SetEngineMod(player, "Overhead", 1)
				elseif j == 2 then
					if CurrentRow ~= 1 and PerspectiveNumber == 2 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif PerspectiveNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					PerspectiveNumber = 2
					CurrentRow = 1
					CurrentColumn = 2
					SetEngineMod(player, "Hallway", 1)
				elseif j == 3 then
					if CurrentRow ~= 1 and PerspectiveNumber == 3 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif PerspectiveNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					PerspectiveNumber = 3
					CurrentRow = 1
					CurrentColumn = 3
					SetEngineMod(player, "Distant", 1)
				elseif j == 4 then
					if CurrentRow ~= 1 and PerspectiveNumber == 4 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif PerspectiveNumber ~= 4 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					PerspectiveNumber = 4
					CurrentRow = 1
					CurrentColumn = 4
					SetEngineMod(player, "Incoming", 1)
				elseif j == 5 then
					if CurrentRow ~= 1 and PerspectiveNumber == 5 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif PerspectiveNumber ~= 5 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					PerspectiveNumber = 5
					CurrentRow = 1
					CurrentColumn = 5
					SetEngineMod(player, "Space", 1)
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."Perspective"..CurrentColumn)
			local TextZoom = Parent2:GetZoom()
			local TextXPosition = Parent2:GetX()
			local TextYPosition = Parent2:GetY()
			local TextHeight = Parent2:GetHeight()
			local TextWidth = Parent2:GetWidth() * TextZoom
			if pn == "P1" then
				CurrentTabP1 = CurrentTab
				CurrentRowP1 = CurrentRow
				CurrentColumnP1 = CurrentColumn
			elseif pn == "P2" then
				CurrentTabP2 = CurrentTab
				CurrentRowP2 = CurrentRow
				CurrentColumnP2 = CurrentColumn
			end
			self:zoomto(TextWidth, 3)
					:x(TextXPosition)
					:y(TextYPosition + TextHeight/3)
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end
	end,
}

----------------------------------------------------------------------------
local Scrolls ={
THEME:GetString("OptionNames","Reverse"),
THEME:GetString("OptionNames","Split"),
THEME:GetString("OptionNames","Alternate"),
THEME:GetString("OptionNames","Cross"),
THEME:GetString("OptionNames","Centered"),
}

-- Player Scrolls
for i=1,#Scrolls do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Scroll"..i,
		InitCommand=function(self)
			local zoom = 0.5
			local Parent = self:GetParent():GetChild(pn.."VisualMods2")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PreviousWidth
			local PastX
			local CurrentX
			if i > 1 then
				PreviousWidth = self:GetParent():GetChild(pn.."Scroll"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."Scroll"..i-1):GetX()
				CurrentX = (PastX + PreviousWidth*zoom) + 18
				self:x(CurrentX)
			else
				self:x(TextXPosition + TextWidth + TextHeight + 5)
			end
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/4)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Scrolls[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Scroll Boxes
for i=1,#Scrolls do
	af[#af+1] = Def.Quad{
		Name=pn.."ScrollBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."VisualMods2")
			local TextZoom = self:GetParent():GetChild(pn.."Scroll"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Scroll"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Scroll"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.1)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IsReverse, IsSplit, IsAlternate, IsCross, IsCentered

--- Scroll Check Boxes 1
for i=1,#Scrolls do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."ScrollCheck"..i,
		InitCommand=function(self)
			local zoom = 0.3333
			local Parent = self:GetParent():GetChild(pn.."ScrollBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			IsReverse = GetPlayerMod(pn, "Reverse") == 1 and true or false
			IsSplit = GetPlayerMod(pn, "Split")  == 1 and true or false
			IsAlternate = GetPlayerMod(pn, "Alternate")  == 1 and true or false
			IsCross = GetPlayerMod(pn, "Cross")  == 1 and true or false
			IsCentered = GetPlayerMod(pn, "Centered")  == 1 and true or false
			if i == 1 then
				if IsReverse then
					self:settext("✅")
					SetEngineMod(player, "Reverse", 1)
				else
					self:settext("")
					SetEngineMod(player, "Reverse", 0)
				end
			elseif i == 2 then
				if IsSplit then
					self:settext("✅")
					SetEngineMod(player, "Split", 1)
				else
					self:settext("")
					SetEngineMod(player, "Split", 0)
				end
			elseif i == 3 then
				if IsAlternate then
					self:settext("✅")
					SetEngineMod(player, "Alternate", 1)
				else
					self:settext("")
					SetEngineMod(player, "Alternate", 0)
				end
			elseif i == 4 then
				if IsCross then
					self:settext("✅")
					SetEngineMod(player, "Cross", 1)
				else
					self:settext("")
					SetEngineMod(player, "Cross", 0)
				end
			elseif i == 5 then
				if IsCentered then
					self:settext("✅")
					SetEngineMod(player, "Centered", 1)
				else
					self:settext("")
					SetEngineMod(player, "Centered", 0)
				end
			end
			self:x(QuadXPosition - QuadWidth/2)
				:horizalign(center):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(QuadYPosition)
				:zoom(zoom)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
		["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			if CurrentTab == 2 and CurrentRow == 2 then
				if CurrentColumn == 1 and i == 1 then
					if IsReverse then
						IsReverse = false
						SetEngineMod(player, "Reverse", 0)
						SetPlayerMod(pn, "Reverse", 0)
						self:settext("")
					elseif not IsReverse then
						IsReverse = true
						SetEngineMod(player, "Reverse", 1)
						SetPlayerMod(pn, "Reverse", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if IsSplit then
						IsSplit = false
						SetEngineMod(player, "Split", 0)
						SetPlayerMod(pn, "Split", 0)
						self:settext("")
					elseif not IsSplit then
						IsSplit = true
						SetEngineMod(player, "Split", 1)
						SetPlayerMod(pn, "Split", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if IsAlternate then
						IsAlternate = false
						SetEngineMod(player, "Alternate", 0)
						SetPlayerMod(pn, "Alternate", 0)
						self:settext("")
					elseif not IsAlternate then
						IsAlternate = true
						SetEngineMod(player, "Alternate", 1)
						SetPlayerMod(pn, "Alternate", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 4 and i == 4 then
					if IsCross then
						IsCross = false
						SetEngineMod(player, "Cross", 0)
						SetPlayerMod(pn, "Cross", 0)
						self:settext("")
					elseif not IsCross then
						IsCross = true
						SetEngineMod(player, "Cross", 1)
						SetPlayerMod(pn, "Cross", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 5 and i == 5 then
					if IsCentered then
						IsCentered = false
						SetEngineMod(player, "Centered", 0)
						SetPlayerMod(pn, "Centered", 0)
						self:settext("")
					elseif not IsCentered then
						IsCentered = true
						SetEngineMod(player, "Centered", 1)
						SetPlayerMod(pn, "Centered", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				end
			end
		end,
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			if pn == "P1" and not PlayerMenuP1 then return end
			if pn == "P2" and not PlayerMenuP2 then return end
			if CurrentTab ~= 2 then return end
			-- yooooooo the j!!!!
			for j=1, #Scrolls do
				local Parent = self:GetParent():GetChild(pn.."ScrollBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
					if j == 1 and j == i then
						CurrentRow = 2
						CurrentColumn = 1
						if IsReverse then
							IsReverse = false
							SetEngineMod(player, "Reverse", 0)
							SetPlayerMod(pn, "Reverse", 0)
							self:settext("")
						elseif not IsReverse then
							IsReverse = true
							SetEngineMod(player, "Reverse", 1)
							SetPlayerMod(pn, "Reverse", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow =2
						CurrentColumn = 2
						if IsSplit then
							IsSplit = false
							SetEngineMod(player, "Split", 0)
							SetPlayerMod(pn, "Split", 0)
							self:settext("")
						elseif not IsSplit then
							IsSplit = true
							SetEngineMod(player, "Split", 1)
							SetPlayerMod(pn, "Split", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 2
						CurrentColumn = 3
						if IsAlternate then
							IsAlternate = false
							SetEngineMod(player, "Alternate", 0)
							SetPlayerMod(pn, "Alternate", 0)
							self:settext("")
						elseif not IsAlternate then
							IsAlternate = true
							SetEngineMod(player, "Alternate", 1)
							SetPlayerMod(pn, "Alternate", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 4 and j == i then
						CurrentRow = 2
						CurrentColumn = 4
						if IsCross then
							IsCross = false
							SetEngineMod(player, "Cross", 0)
							SetPlayerMod(pn, "Cross", 0)
							self:settext("")
						elseif not IsCross then
							IsCross = true
							SetEngineMod(player, "Cross", 1)
							SetPlayerMod(pn, "Cross", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 5 and j == i then
						CurrentRow = 2
						CurrentColumn = 5
						if IsCentered then
							IsCentered = false
							SetEngineMod(player, "Centered", 0)
							SetPlayerMod(pn, "Centered", 0)
							self:settext("")
						elseif not IsCentered then
							IsCentered = true
							SetEngineMod(player, "Centered", 1)
							SetPlayerMod(pn, "Centered", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
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

--------------------------------------------------------------------
local ScreenFilters = {
THEME:GetString("SLPlayerOptions","Off"),
THEME:GetString("SLPlayerOptions","Dark"),
THEME:GetString("SLPlayerOptions","Darker"),
THEME:GetString("SLPlayerOptions","Darkest"),
}

for i=1,#ScreenFilters do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."ScreenFilter"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."VisualMods3")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth*TextZoom + 5)
			else
				PastWidth = self:GetParent():GetChild(pn.."ScreenFilter"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."ScreenFilter"..i-1):GetX()
				CurrentX = PastX + (PastWidth*zoom) + 10
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/2)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(ScreenFilters[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


local PlayerScreenFilter = mods.BackgroundFilter or "Off"
local ScreenFilterNumber

if PlayerScreenFilter == "Off" then
	ScreenFilterNumber = 1
elseif PlayerScreenFilter == "Dark" then
	ScreenFilterNumber = 2
elseif PlayerScreenFilter == "Darker" then
	ScreenFilterNumber = 3
elseif PlayerScreenFilter == "Darkest" then
	ScreenFilterNumber = 4
end


--- Screen Filter Selector
af[#af+1] = Def.Quad{
	Name=pn.."ScreenFilterSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."ScreenFilter"..ScreenFilterNumber)
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local color = PlayerColor(player)
		self:diffuse(color)
			:draworder(1)
			:zoomto(TextWidth, 3)
			:vertalign(top):horizalign(left)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if CurrentTab == 2 and CurrentRow == 3 then
			if CurrentColumn == 1 then
				ScreenFilterNumber = 1
				mods.BackgroundFilter = "Off"
			elseif CurrentColumn == 2 then
				ScreenFilterNumber = 2
				mods.BackgroundFilter = "Dark"
			elseif CurrentColumn == 3 then
				ScreenFilterNumber = 3
				mods.BackgroundFilter = "Darker"
			elseif CurrentColumn == 4 then
				ScreenFilterNumber = 4
				mods.BackgroundFilter = "Darkest"
			end
			SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
			local Parent = self:GetParent():GetChild(pn.."ScreenFilter"..CurrentColumn)
			local TextZoom = Parent:GetZoom()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local TextHeight = Parent:GetHeight()
			local TextWidth = Parent:GetWidth() * TextZoom
			self:zoomto(TextWidth, 3)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		local MadeSelection = false
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		for j=1,#ScreenFilters do
			local Parent = self:GetParent():GetChild(pn.."ScreenFilter"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
				if j == 1 then
					if CurrentRow ~= 3 and ScreenFilterNumber == 1 then
						if CurrentRow < 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenFilterNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 3
					CurrentColumn = 1
					ScreenFilterNumber = 1
					mods.BackgroundFilter = "Off"
				elseif j == 2 then
					if CurrentRow ~= 3 and ScreenFilterNumber == 2 then
						if CurrentRow < 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenFilterNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 3
					CurrentColumn = 2
					ScreenFilterNumber = 2
					mods.BackgroundFilter = "Dark"
				elseif j == 3 then
					if CurrentRow ~= 3 and ScreenFilterNumber == 3 then
						if CurrentRow < 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenFilterNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 3
					CurrentColumn = 3
					ScreenFilterNumber = 3
					mods.BackgroundFilter = "Darker"
				elseif j == 4 then
					if CurrentRow ~= 3 and ScreenFilterNumber == 4 then
						if CurrentRow < 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 3 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenFilterNumber ~= 4 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 3
					CurrentColumn = 4
					ScreenFilterNumber = 4
					mods.BackgroundFilter = "Darkest"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."ScreenFilter"..CurrentColumn)
			local TextZoom = Parent2:GetZoom()
			local TextXPosition = Parent2:GetX()
			local TextYPosition = Parent2:GetY()
			local TextHeight = Parent2:GetHeight()
			local TextWidth = Parent2:GetWidth() * TextZoom
			if pn == "P1" then
				CurrentTabP1 = CurrentTab
				CurrentRowP1 = CurrentRow
				CurrentColumnP1 = CurrentColumn
			elseif pn == "P2" then
				CurrentTabP2 = CurrentTab
				CurrentRowP2 = CurrentRow
				CurrentColumnP2 = CurrentColumn
			end
			self:zoomto(TextWidth, 3)
					:x(TextXPosition)
					:y(TextYPosition + TextHeight/3)
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end
	end,
}

-----------------------------------------------------------------------------------
local MeasureLines = {
	THEME:GetString("SLPlayerOptions","Off"),
	THEME:GetString("SLPlayerOptions","Measure"),
	THEME:GetString("SLPlayerOptions","Quarter"),
	THEME:GetString("SLPlayerOptions","Eighth"),
}

for i=1,#MeasureLines do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."MeasureLines"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."VisualMods4")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth*TextZoom + 5)
			else
				PastWidth = self:GetParent():GetChild(pn.."MeasureLines"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."MeasureLines"..i-1):GetX()
				CurrentX = PastX + (PastWidth*zoom) + 10
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/2)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(MeasureLines[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


local PlayerMeasureLines = mods.MeasureLines or "Off"
local ScreenMLNumber

if PlayerMeasureLines == "Off" then
	ScreenMLNumber = 1
elseif PlayerMeasureLines == "Measure" then
	ScreenMLNumber = 2
elseif PlayerMeasureLines == "Quarter" then
	ScreenMLNumber = 3
elseif PlayerMeasureLines == "Eighth" then
	ScreenMLNumber = 4
end

--- MeasureLines Selector
af[#af+1] = Def.Quad{
	Name=pn.."MeasureLinesSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."MeasureLines"..ScreenMLNumber)
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local color = PlayerColor(player)
		self:diffuse(color)
			:draworder(1)
			:zoomto(TextWidth, 3)
			:vertalign(top):horizalign(left)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if CurrentTab == 2 and CurrentRow == 4 then
			if CurrentColumn == 1 then
				ScreenMLNumber = 1
				mods.MeasureLines = "Off"
			elseif CurrentColumn == 2 then
				ScreenMLNumber = 2
				mods.MeasureLines = "Measure"
			elseif CurrentColumn == 3 then
				ScreenMLNumber = 3
				mods.MeasureLines = "Quarter"
			elseif CurrentColumn == 4 then
				ScreenMLNumber = 4
				mods.MeasureLines = "Eighth"
			end
			local Parent = self:GetParent():GetChild(pn.."MeasureLines"..CurrentColumn)
			local TextZoom = Parent:GetZoom()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local TextHeight = Parent:GetHeight()
			local TextWidth = Parent:GetWidth() * TextZoom
			self:zoomto(TextWidth, 3)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
			SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		local MadeSelection = false
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		for j=1,#ScreenFilters do
			local Parent = self:GetParent():GetChild(pn.."MeasureLines"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
				if j == 1 then
					if CurrentRow ~= 4 and ScreenMLNumber == 1 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenMLNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 1
					ScreenMLNumber = 1
					mods.MeasureLines = "Off"
				elseif j == 2 then
					if CurrentRow ~= 4 and ScreenMLNumber == 2 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenMLNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 2
					ScreenMLNumber = 2
					mods.MeasureLines = "Measure"
				elseif j == 3 then
					if CurrentRow ~= 4 and ScreenMLNumber == 3 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenMLNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 3
					ScreenMLNumber = 3
					mods.MeasureLines = "Quarter"
				elseif j == 4 then	
					if CurrentRow ~= 4 and ScreenMLNumber == 4 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ScreenMLNumber ~= 4 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 4
					ScreenMLNumber = 4
					mods.MeasureLines = "Eighth"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."MeasureLines"..CurrentColumn)
			local TextZoom = Parent2:GetZoom()
			local TextXPosition = Parent2:GetX()
			local TextYPosition = Parent2:GetY()
			local TextHeight = Parent2:GetHeight()
			local TextWidth = Parent2:GetWidth() * TextZoom
			if pn == "P1" then
				CurrentTabP1 = CurrentTab
				CurrentRowP1 = CurrentRow
				CurrentColumnP1 = CurrentColumn
			elseif pn == "P2" then
				CurrentTabP2 = CurrentTab
				CurrentRowP2 = CurrentRow
				CurrentColumnP2 = CurrentColumn
			end
			self:zoomto(TextWidth, 3)
					:x(TextXPosition)
					:y(TextYPosition + TextHeight/3)
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end
	end,
}

-----------------------------------------------------------------------------------
-- Judgment Tilt
local TiltMods={
THEME:GetString("OptionNames","Off"),
THEME:GetString("OptionNames","On"),
}

--- Judgment Tilt Options
for i=1,#TiltMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."TiltMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."VisualMods5")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth + 5)
			else
				PastWidth = self:GetParent():GetChild(pn.."TiltMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."TiltMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(TiltMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IsTilt = mods.JudgmentTilt or false

local TiltNumber = IsTilt == true and 2 or 1

--- Tilt Selector
af[#af+1] = Def.Quad{
	Name=pn.."TiltSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."TiltMod"..TiltNumber)
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local color = PlayerColor(player)
		self:diffuse(color)
			:draworder(1)
			:zoomto(TextWidth, 3)
			:vertalign(top):horizalign(left)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if CurrentTab == 2 and CurrentRow == 5 then
			SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
			if CurrentColumn == 1 then
				TiltNumber = 1
				mods.JudgmentTilt = false
			elseif CurrentColumn == 2 then
				TiltNumber = 2
				mods.JudgmentTilt = true
			end
			local Parent = self:GetParent():GetChild(pn.."TiltMod"..CurrentColumn)
			local TextZoom = Parent:GetZoom()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local TextHeight = Parent:GetHeight()
			local TextWidth = Parent:GetWidth() * TextZoom
			self:zoomto(TextWidth, 3)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		local MadeSelection = false
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		for j=1,#TiltMods do
			local Parent = self:GetParent():GetChild(pn.."TiltMod"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
				if j == 1 then
					if CurrentRow ~= 5 and TiltNumber == 1 then
						if CurrentRow < 5 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 5 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif TiltNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 5
					CurrentColumn = 1
					TiltNumber = 1
					mods.JudgmentTilt = false
				elseif j == 2 then
					if CurrentRow ~= 5 and TiltNumber == 2 then
						if CurrentRow < 5 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 5 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif TiltNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 5
					CurrentColumn = 2
					TiltNumber = 2
					mods.JudgmentTilt = true
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."TiltMod"..CurrentColumn)
			local TextZoom = Parent2:GetZoom()
			local TextXPosition = Parent2:GetX()
			local TextYPosition = Parent2:GetY()
			local TextHeight = Parent2:GetHeight()
			local TextWidth = Parent2:GetWidth() * TextZoom
			if pn == "P1" then
				CurrentTabP1 = CurrentTab
				CurrentRowP1 = CurrentRow
				CurrentColumnP1 = CurrentColumn
			elseif pn == "P2" then
				CurrentTabP2 = CurrentTab
				CurrentRowP2 = CurrentRow
				CurrentColumnP2 = CurrentColumn
			end
			self:zoomto(TextWidth, 3)
					:x(TextXPosition)
					:y(TextYPosition + TextHeight/3)
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end
	end,
}

-----------------------------------------------------------------------------------

local Hide = {
THEME:GetString("SLPlayerOptions","Targets"),
THEME:GetString("SLPlayerOptions","SongBG"),
THEME:GetString("SLPlayerOptions","Combo"),
THEME:GetString("SLPlayerOptions","Lifebar"),
}

local Hide2 = {
THEME:GetString("SLPlayerOptions","Score"),
THEME:GetString("SLPlayerOptions","Danger"),
THEME:GetString("SLPlayerOptions","ComboExplosions"),
}


-- Hide Mods1
for i=1,#Hide do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Hide"..i,
		InitCommand=function(self)
			local zoom = 0.5
			local Parent = self:GetParent():GetChild(pn.."VisualMods6")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PreviousWidth
			local PastX
			local CurrentX
			if i > 1 then
				PreviousWidth = self:GetParent():GetChild(pn.."Hide"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."Hide"..i-1):GetX()
				CurrentX = (PastX + PreviousWidth*zoom) + 18
				self:x(CurrentX)
			else
				self:x(TextXPosition + TextWidth + TextHeight + 5)
			end
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/4)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Hide[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--Hide Boxes 1
for i=1,#Hide do
	af[#af+1] = Def.Quad{
		Name=pn.."HideBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."VisualMods6")
			local TextZoom = self:GetParent():GetChild(pn.."Hide"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Hide"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Hide"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.1)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


local HideTargets = mods.HideTargets or false
local HideBackground = mods.HideSongBG or false
local HideCombo = mods.HideCombo or false
local HideLife = mods.HideLifebar or false

--- Hide Check Boxes 1
for i=1,#Hide do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Hide1Check"..i,
		InitCommand=function(self)
			local zoom = 0.3333
			local Parent = self:GetParent():GetChild(pn.."HideBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if HideTargets == true then
					SetEngineMod(player, "Dark", 1)
					self:settext("✅")
				else
					SetEngineMod(player, "Dark", 0)
					self:settext("")
				end
			elseif i == 2 then
				if HideBackground == true  then
					SetEngineMod(player, "Cover", 1)
					self:settext("✅")
				else
					SetEngineMod(player, "Cover", 0)
					self:settext("")
				end
			elseif i == 3 then
				if HideCombo == true  then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if HideLife == true  then
					self:settext("✅")
				else
					self:settext("")
				end
			end
			self:x(QuadXPosition - QuadWidth/2)
				:horizalign(center):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(QuadYPosition)
				:zoom(zoom)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
		["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			if CurrentTab == 2 and CurrentRow == 6 then
				if CurrentColumn == 1 and i == 1 then
					if HideTargets == true then
						HideTargets = false
						mods.HideTargets = false
						SetEngineMod(player, "Dark", 0)
						self:settext("")
					elseif HideTargets == false then
						HideTargets = true
						mods.HideTargets = true
						SetEngineMod(player, "Dark", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if HideBackground == true then
						HideBackground = false
						mods.HideSongBG = false
						SetEngineMod(player, "Cover", 0)
						self:settext("")
					elseif HideBackground == false then
						HideBackground = true
						mods.HideSongBG = true
						SetEngineMod(player, "Cover", 1)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if HideCombo == true then
						HideCombo = false
						mods.HideCombo = false
						self:settext("")
					elseif HideCombo == false then
						HideCombo = true
						mods.HideCombo = true
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 4 and i == 4 then
					if HideLife == true then
						HideLife = false
						mods.HideLifebar = false
						self:settext("")
					elseif HideLife == false then
						HideLife = true
						mods.HideLifebar = true
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				end
			end
		end,
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			if pn == "P1" and not PlayerMenuP1 then return end
			if pn == "P2" and not PlayerMenuP2 then return end
			if CurrentTab ~= 2 then return end
			-- yooooooo the j!!!!
			for j=1, #Hide do
				local Parent = self:GetParent():GetChild(pn.."HideBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
					if j == 1 and j == i then
						CurrentRow = 6
						CurrentColumn = 1
						if HideTargets == true then
							HideTargets = false
							mods.HideTargets = false
							SetEngineMod(player, "Dark", 0)
							self:settext("")
						elseif HideTargets == false then
							HideTargets = true
							mods.HideTargets = true
							SetEngineMod(player, "Dark", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 6
						CurrentColumn = 2
						if HideBackground == true then
							HideBackground = false
							mods.HideSongBG = false
							SetEngineMod(player, "Cover", 0)
							self:settext("")
						elseif HideBackground == false then
							HideBackground = true
							mods.HideSongBG = true
							SetEngineMod(player, "Cover", 1)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 6
						CurrentColumn = 3
						if HideCombo == true then
							HideCombo = false
							mods.HideCombo = false
							self:settext("")
						elseif HideCombo == false then
							HideCombo = true
							mods.HideCombo = true
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 4 and j == i then
						CurrentRow = 6
						CurrentColumn = 4
						if HideLife == true then
							HideLife = false
							mods.HideLifebar = false
							self:settext("")
						elseif HideLife == false then
							HideLife = true
							mods.HideLifebar = true
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
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

-- Hide Mods2
for i=1,#Hide2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Hide2_"..i,
		InitCommand=function(self)
			local zoom = 0.5
			local Parent = self:GetParent():GetChild(pn.."VisualMods7")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PreviousWidth
			local PastX
			local CurrentX
			if i > 1 then
				PreviousWidth = self:GetParent():GetChild(pn.."Hide2_"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."Hide2_"..i-1):GetX()
				CurrentX = (PastX + PreviousWidth*zoom) + 18
				self:x(CurrentX)
			else
				self:x(TextXPosition + TextWidth + TextHeight + 5)
			end
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/4)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Hide2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--Hide Boxes 2
for i=1,#Hide2 do
	af[#af+1] = Def.Quad{
		Name=pn.."HideBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."VisualMods7")
			local TextZoom = self:GetParent():GetChild(pn.."Hide2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Hide2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Hide2_"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.1)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local HideScore 			= mods.HideScore or false
local HideDanger 			= mods.HideDanger or false
local HideComboExplosions 	= mods.HideComboExplosions or false


--- Hide Check Boxes 2
for i=1,#Hide2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Hide2Check"..i,
		InitCommand=function(self)
			local zoom = 0.3333
			local Parent = self:GetParent():GetChild(pn.."HideBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if HideScore == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if HideDanger == true  then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if HideComboExplosions == true  then
					self:settext("✅")
				else
					self:settext("")
				end
			end
			self:x(QuadXPosition - QuadWidth/2)
				:horizalign(center):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(QuadYPosition)
				:zoom(zoom)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 2 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
		["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			if CurrentTab == 2 and CurrentRow == 7 then
				if CurrentColumn == 1 and i == 1 then
					if HideScore == true then
						HideScore = false
						mods.HideScore = false
						self:settext("")
					elseif HideScore == false then
						HideScore = true
						mods.HideScore = true
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if HideDanger == true then
						HideDanger = false
						mods.HideDanger = false
						self:settext("")
					elseif HideDanger == false then
						HideDanger = true
						mods.HideDanger = true
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if HideComboExplosions == true then
						HideComboExplosions = false
						mods.HideComboExplosions = false
						self:settext("")
					elseif HideComboExplosions == false then
						HideComboExplosions = true
						mods.HideComboExplosions = true
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				end
			end
		end,
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			if pn == "P1" and not PlayerMenuP1 then return end
			if pn == "P2" and not PlayerMenuP2 then return end
			if CurrentTab ~= 2 then return end
			-- yooooooo the j!!!!
			for j=1, #Hide2 do
				local Parent = self:GetParent():GetChild(pn.."HideBox2_"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
					if j == 1 and j == i then
						CurrentRow = 7
						CurrentColumn = 1
						if HideScore == true then
							HideScore = false
							mods.HideScore = false
							self:settext("")
						elseif HideScore == false then
							HideScore = true
							mods.HideScore = true
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 7
						CurrentColumn = 2
						if HideDanger == true then
							HideDanger = false
							mods.HideDanger = false
							self:settext("")
						elseif HideDanger == false then
							HideDanger = true
							mods.HideDanger = true
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 7
						CurrentColumn = 3
						if HideComboExplosions == true then
							HideComboExplosions = false
							mods.HideComboExplosions = false
							self:settext("")
						elseif HideComboExplosions == false then
							HideComboExplosions = true
							mods.HideComboExplosions = true
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
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

--- Notefield XBox (360, no scope)
af[#af+1] = Def.Quad{
	Name=pn.."NotefieldXBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods8")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(40, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 5)
			:y(TextYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		local Parent = self:GetParent():GetChild(pn.."NotefieldXBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
			if CurrentRow ~= 8 then
				if CurrentRow < 8 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 8 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
			CurrentRow = 8
			CurrentColumn = 1
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
		end
	
	end,
}

local PlayerNotefieldX = mods.NoteFieldOffsetX or 0
local PlayerNotefieldY = mods.NoteFieldOffsetY or 0
local MinNotefield = -50
local MaxNotefield = 50

--- NotefieldX Value
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NotefieldXText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods8")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."NotefieldXBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."NotefieldXBox1"):GetX()
		local TextYPosition = Parent:GetY()
		local PastWidth
		local PastX
		local CurrentX
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:settext(PlayerNotefieldX)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			 CurrentTab = CurrentTabP1
			 CurrentRow = CurrentRowP1
			 CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			 CurrentRow = CurrentRowP2
			 CurrentColumn = CurrentColumnP2
		end
		
		if CurrentTab == 2 and CurrentRow == 8 then
			if params[1] == "left" then
				if PlayerNotefieldX <= MinNotefield then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldX = MaxNotefield
					end
				elseif PlayerNotefieldX == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldX = PlayerNotefieldX - 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerNotefieldX = PlayerNotefieldX - 1
				end
				mods.NoteFieldOffsetX = PlayerNotefieldX
				self:settext(PlayerNotefieldX)
			elseif params[1] == "right" then
				if PlayerNotefieldX >= MaxNotefield then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldX = MinNotefield
					end
				elseif PlayerNotefieldX == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldX = PlayerNotefieldX + 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerNotefieldX = PlayerNotefieldX + 1
				end
				mods.NoteFieldOffsetX = PlayerNotefieldX
				self:settext(PlayerNotefieldX)
			end
		end
	end,
}

--- Notefield Y Box
af[#af+1] = Def.Quad{
	Name=pn.."NotefieldYBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods9")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(40, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 5)
			:y(TextYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		local Parent = self:GetParent():GetChild(pn.."NotefieldYBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
			if CurrentRow ~= 9 then
				if CurrentRow < 9 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 9 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
			CurrentRow = 9
			CurrentColumn = 1
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
		end
	
	end,
}

--- NotefieldY Value
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NotefieldYText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods9")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."NotefieldYBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."NotefieldYBox1"):GetX()
		local TextYPosition = Parent:GetY()
		local PastWidth
		local PastX
		local CurrentX
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:settext(PlayerNotefieldY)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			 CurrentTab = CurrentTabP1
			 CurrentRow = CurrentRowP1
			 CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			 CurrentRow = CurrentRowP2
			 CurrentColumn = CurrentColumnP2
		end
		
		if CurrentTab == 2 and CurrentRow == 9 then
			if params[1] == "left" then
				if PlayerNotefieldY <= MinNotefield then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldY = MaxNotefield
					end
				elseif PlayerNotefieldY == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldY = PlayerNotefieldY - 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerNotefieldY = PlayerNotefieldY - 1
				end
				mods.NoteFieldOffsetY = PlayerNotefieldY
				self:settext(PlayerNotefieldY)
			elseif params[1] == "right" then
				if PlayerNotefieldY >= MaxNotefield then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldY = MinNotefield
					end
				elseif PlayerNotefieldY == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerNotefieldY = PlayerNotefieldY + 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerNotefieldY = PlayerNotefieldY + 1
				end
				mods.NoteFieldOffsetY = PlayerNotefieldY
				self:settext(PlayerNotefieldY)
			end
		end
	end,
}

--- Visual Delay Box
af[#af+1] = Def.Quad{
	Name=pn.."VisualDelayBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods10")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(40, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 5)
			:y(TextYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			CurrentTab = CurrentTabP1
			CurrentRow = CurrentRowP1
			CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			CurrentRow = CurrentRowP2
			CurrentColumn = CurrentColumnP2
		end
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 2 then return end
		local Parent = self:GetParent():GetChild(pn.."VisualDelayBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 2 then
			if CurrentRow ~= 10 then
				if CurrentRow < 10 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 10 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
			CurrentRow = 10
			CurrentColumn = 1
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
		end
	
	end,
}

local PlayerVisualDelay = mods.VisualDelay:gsub("ms", "") or 0
PlayerVisualDelay = tonumber(PlayerVisualDelay)
local MinVisualDelay = -100
local MaxVisualDelay = 100

--- Visual Delay Value
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."VisualDelayText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods10")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."VisualDelayBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."VisualDelayBox1"):GetX()
		local TextYPosition = Parent:GetY()
		local PastWidth
		local PastX
		local CurrentX
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:settext(PlayerVisualDelay.."ms")
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 2 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn
		if pn == "P1" then
			 CurrentTab = CurrentTabP1
			 CurrentRow = CurrentRowP1
			 CurrentColumn = CurrentColumnP1
		elseif pn == "P2" then
			CurrentTab = CurrentTabP2
			 CurrentRow = CurrentRowP2
			 CurrentColumn = CurrentColumnP2
		end
		
		if CurrentTab == 2 and CurrentRow == 10 then
			if params[1] == "left" then
				if PlayerVisualDelay <= MinVisualDelay then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerVisualDelay = MaxVisualDelay
					end
				elseif PlayerVisualDelay == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerVisualDelay = PlayerVisualDelay - 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerVisualDelay = PlayerVisualDelay - 1
				end
				mods.VisualDelay = PlayerVisualDelay.."ms"
				GAMESTATE:GetPlayerState(player):GetPlayerOptions(0):VisualDelay( mods.VisualDelay:gsub("ms","")/1000 )
				self:settext(PlayerVisualDelay.."ms")
			elseif params[1] == "right" then
				if PlayerVisualDelay >= MaxVisualDelay then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerVisualDelay = MinVisualDelay
					end
				elseif PlayerVisualDelay == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerVisualDelay = PlayerVisualDelay + 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerVisualDelay = PlayerVisualDelay + 1
				end
				mods.VisualDelay = PlayerVisualDelay.."ms"
				GAMESTATE:GetPlayerState(player):GetPlayerOptions(0):VisualDelay( mods.VisualDelay:gsub("ms","")/1000 )
				self:settext(PlayerVisualDelay.."ms")
			end
		end
	end,
}

-------------------------------------------------------------
local Mod2Descriptions = {
THEME:GetString("OptionExplanations","Perspective"),
THEME:GetString("OptionExplanations","Scroll"),
THEME:GetString("OptionExplanations","BackgroundFilter"),
THEME:GetString("OptionExplanations","MeasureLines"),
THEME:GetString("OptionExplanations","JudgmentTilt"),
THEME:GetString("OptionExplanations","Hide"),
THEME:GetString("OptionExplanations","Hide"),
THEME:GetString("OptionExplanations","NoteFieldOffsetX"),
THEME:GetString("OptionExplanations","NoteFieldOffsetY"),
THEME:GetString("OptionExplanations","VisualDelay"),
}

-- Bottom Information for mods
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."Mod2Descriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(Mod2Descriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 or CurrentTabP1 ~= 2 then
				self:visible(false)
			else
				self:settext(Mod2Descriptions[CurrentRowP1])
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0  or CurrentTabP2 ~= 2 then
				self:visible(false)
				
			else
				self:settext(Mod2Descriptions[CurrentRowP2])
				self:visible(true)
			end
		end
	end,
}