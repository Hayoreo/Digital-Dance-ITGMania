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
THEME:GetString("OptionTitles","NoteSkin"),
THEME:GetString("OptionTitles","JudgmentGraphic"),
THEME:GetString("OptionTitles","ComboFont"),
THEME:GetString("OptionTitles","HoldJudgment"),
THEME:GetString("OptionTitles","BackgroundFilter"),
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
				SetEngineMod(player, "Overhead", 1)
			elseif CurrentColumn == 2 then
				SetEngineMod(player, "Hallway", 1)
			elseif CurrentColumn == 3 then
				SetEngineMod(player, "Distant", 1)
			elseif CurrentColumn == 4 then
				SetEngineMod(player, "Incoming", 1)
			elseif CurrentColumn == 5 then
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
				end
			end
		end,
	}
end

-- Noteskins
--------------------------------------------------------------------
local Noteskins = NOTESKIN:GetNoteSkinNames()

local CurrentNoteskinIndex
local PlayerNoteSkin = PlayerState:GetPlayerOptions(0):NoteSkin() or "cel"
for i=1, #Noteskins do
	if PlayerNoteSkin == Noteskins[i] then
		CurrentNoteskinIndex = i
		break
	end
end

--- Noteskin Box
af[#af+1] = Def.Quad{
	Name=pn.."NoteskinBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods3")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(70, TextHeight)
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
}

--- Noteskin Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NoteskinName1",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods3")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."NoteskinBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."NoteskinBox1"):GetX()
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
			:settext(Noteskins[CurrentNoteskinIndex])
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
		
		if CurrentTab == 2 and CurrentRow == 3 then
			if params[1] == "left" then
				if CurrentNoteskinIndex == 1 then
					CurrentNoteskinIndex = #Noteskins
				else
					CurrentNoteskinIndex = CurrentNoteskinIndex - 1	
				end
				self:settext(Noteskins[CurrentNoteskinIndex])
					:queuecommand("SetMod")
			elseif params[1] == "right" then
				if CurrentNoteskinIndex == #Noteskins then
					CurrentNoteskinIndex = 1
				else
					CurrentNoteskinIndex = CurrentNoteskinIndex + 1
				end
				self:settext(Noteskins[CurrentNoteskinIndex])
					:queuecommand("SetMod")
			end
		end
	end,
	SetModCommand=function(self)
		SetEngineMod(player, "NoteSkin", Noteskins[CurrentNoteskinIndex])
	end,
}

--- I have no intention of supporting other game modes
--- This is ITGMania after all.
local ArrowDirection ={
	"Left",
	"Down",
	"Up",
	"Right",
}
for noteskin in ivalues(Noteskins) do
	for i=1, 4 do
		af[#af+1] = NOTESKIN:LoadActorForNoteSkin(ArrowDirection[i], "Tap Note", noteskin:lower())..{
			InitCommand=function(self)
				local Parent = self:GetParent():GetChild(pn.."VisualMods3")
				local NoteskinX = Parent:GetX()
				local NoteskinY = Parent:GetY()
				local TextZoom = Parent:GetZoom()
				local TextWidth = Parent:GetWidth() * TextZoom
				local TextHeight = Parent:GetHeight() * TextZoom
				self:horizalign(center):vertalign(middle)
					:draworder(1)
					:x(NoteskinX + TextWidth + 70 + (i*25))
					:y(NoteskinY + TextHeight/3)
					:zoom(0.33)
					:visible(false)
			end,
			UpdateDisplayedTabCommand=function(self)
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
				if CurrentTab ~= 2 then
					self:visible(false)
					return
				elseif Noteskins[CurrentNoteskinIndex] == noteskin:lower() then
					self:visible(true)
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
				if CurrentTab == 2 and CurrentRow == 3 then
					if params[1] == "left" or params[1] == "right" then
						self:queuecommand("UpdateNoteskin")
					end
				end
			end,
			UpdateNoteskinCommand=function(self)
				self:visible(false)
				if Noteskins[CurrentNoteskinIndex] == noteskin:lower() then
					self:visible(true)
				else
					self:visible(false)
				end
			end,
		}
	end
end


--------------------------------------------------------------------
-- Judgments
local Judgments = GetJudgmentGraphics() or "Ice 2x7.png"
local CurrentJudgmentIndex

--- Judgment Box
af[#af+1] = Def.Quad{
	Name=pn.."JudgmentBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods4")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(70, TextHeight)
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
}

--- Judgment Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."JudgmentName1",
	InitCommand=function(self)	
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods4")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."JudgmentBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."JudgmentBox1"):GetX()
		local TextYPosition = Parent:GetY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:settext("")
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:queuecommand("UpdateDisplayedTab")

		--- idk sm is dumb (same) and i can't have this earlier
		local PlayerJudge = mods.JudgmentGraphic or "Ice 2x7.png"
		for i=1, #Judgments do
			if Judgments[i] == PlayerJudge then
				CurrentJudgmentIndex = i
				self:queuecommand("UpdateJudgmentText")
				break
			end
		end
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
	UpdateJudgmentTextCommand=function(self)
		self:settext( StripSpriteHints(Judgments[CurrentJudgmentIndex]) )
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
		
		if CurrentTab == 2 and CurrentRow == 4 then
			if params[1] == "left" then
				if CurrentJudgmentIndex == 1 then
					CurrentJudgmentIndex = #Judgments
				else
					CurrentJudgmentIndex = CurrentJudgmentIndex - 1	
				end
				mods.JudgmentGraphic = Judgments[CurrentJudgmentIndex]
				self:settext(StripSpriteHints(Judgments[CurrentJudgmentIndex]))
			elseif params[1] == "right" then
				if CurrentJudgmentIndex == #Judgments then
					CurrentJudgmentIndex = 1
				else
					CurrentJudgmentIndex = CurrentJudgmentIndex + 1
				end
				mods.JudgmentGraphic = Judgments[CurrentJudgmentIndex]
				self:settext(StripSpriteHints(Judgments[CurrentJudgmentIndex]))
			end
		end
	end,
}


for JudgmentName in ivalues( Judgments ) do
	if JudgmentName ~= "None" then
		af[#af+1] = LoadActor( THEME:GetPathG("", "_judgments/" .. JudgmentName) )..{
			Name="JudgmentGraphic_"..StripSpriteHints(JudgmentName),
			InitCommand=function(self)
				local Parent = self:GetParent():GetChild(pn.."VisualMods4")
				local JudgmentX = self:GetParent():GetChild(pn.."JudgmentBox1"):GetX()
				local JudgmentY = Parent:GetY()
				local TextZoom = Parent:GetZoom()
				local TextWidth = Parent:GetWidth() * TextZoom
				local QuadHeight = self:GetParent():GetChild(pn.."JudgmentBox1"):GetZoomY()
				self:horizalign(center):vertalign(middle)
					:animate(false)
					:draworder(1)
					:x(JudgmentX + 120)
					:y(JudgmentY + QuadHeight/3)
					:zoom(0.3)
					:visible(false)
			end,
			UpdateDisplayedTabCommand=function(self)
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
				if CurrentTab ~= 2 then
					self:visible(false)
					return
				elseif Judgments[CurrentJudgmentIndex] == JudgmentName then
					self:visible(true)
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
				if CurrentTab == 2 and CurrentRow == 4 then
					if params[1] == "left" or params[1] == "right" then
						self:queuecommand("UpdateJudgment")
					end
				end
			end,
			UpdateJudgmentCommand=function(self)
				self:visible(false)
				if Judgments[CurrentJudgmentIndex] == JudgmentName then
					self:visible(true)
				else
					self:visible(false)
				end
			end,
		}
	else
		af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }
	end
end

--------------------------------------------------------------------
-- Combo Fonts

--- Combo Box
af[#af+1] = Def.Quad{
	Name=pn.."ComboBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods5")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(80, TextHeight)
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
}


local PlayerComboFont = mods.ComboFont or "Wendy"
local ComboFonts = GetComboFonts()
local CurrentComboIndex

for i=1, #ComboFonts do
	if ComboFonts[i] == PlayerComboFont then
		CurrentComboIndex = i
		break
	end
end

-- Combo Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."JudgmentName1",
	InitCommand=function(self)	
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods5")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."ComboBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."ComboBox1"):GetX()
		local TextYPosition = Parent:GetY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:settext(ComboFonts[CurrentComboIndex])
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
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
		
		if CurrentTab == 2 and CurrentRow == 5 then
			if params[1] == "left" then
				if CurrentComboIndex == 1 then
					CurrentComboIndex = #ComboFonts
				else
					CurrentComboIndex = CurrentComboIndex - 1	
				end
				mods.ComboFont = ComboFonts[CurrentComboIndex]
				self:settext(ComboFonts[CurrentComboIndex])
			elseif params[1] == "right" then
				if CurrentComboIndex == #ComboFonts then
					CurrentComboIndex = 1
				else
					CurrentComboIndex = CurrentComboIndex + 1
				end
				mods.ComboFont = ComboFonts[CurrentComboIndex]
				self:settext(ComboFonts[CurrentComboIndex])
			end
		end
	end,

}

--- combo preview
for combo_font in ivalues( ComboFonts ) do
	if combo_font ~= "None" then
	
		af[#af+1] = LoadFont("_Combo Fonts/" .. combo_font .."/" .. combo_font)..{
			Name=(pn.."_ComboFont_"..combo_font),
			Text="1",
			InitCommand=function(self)
				local Parent = self:GetParent():GetChild(pn.."VisualMods5")
				local ComboX = self:GetParent():GetChild(pn.."ComboBox1"):GetX()
				local ComboY = Parent:GetY()
				local TextZoom = Parent:GetZoom()
				local TextWidth = Parent:GetWidth() * TextZoom
				local QuadHeight = self:GetParent():GetChild(pn.."ComboBox1"):GetZoomY()
				self:horizalign(center):vertalign(middle)
					:draworder(1)
					:x(ComboX + 120)
					:y(ComboY + QuadHeight/3)
					:zoom(0.3)
					:visible(false)
			end,
			UpdateDisplayedTabCommand=function(self)
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
				if CurrentTab ~= 2 then
					self:visible(false)
					return
				elseif ComboFonts[CurrentComboIndex] == combo_font then
					self:visible(true)
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
				if CurrentTab == 2 and CurrentRow == 5 then
					self:queuecommand("Loop")
					if params[1] == "left" or params[1] == "right" then
						self:visible(false):queuecommand("UpdateComboFont")
					end
				end
			end,
			LoopCommand=function(self)
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
					if tonumber(self:GetText()) >= 999 then self:settext("1") end
					self:settext( tonumber(self:GetText())+1 )
					-- call stoptweening() to prevent tween overflow that could occur from rapid input from the player
					-- and re-queue this "Loop" every 600ms
					self:stoptweening():sleep(0.6):queuecommand("Loop")
				end
			end,
			UpdateComboFontCommand=function(self)
				self:visible(false)
				if ComboFonts[CurrentComboIndex] == combo_font then
					self:visible(true)
				else
					self:visible(false)
				end
			end,
		}
	else
		af[#af+1] = Def.Actor{ Name=(pn.."_ComboFont_None"), InitCommand=function(self) self:visible(false) end }
	end
end


--------------------------------------------------------------------
-- Hold Judgments

--- HoldJ Box
af[#af+1] = Def.Quad{
	Name=pn.."HoldJBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."VisualMods6")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(60, TextHeight)
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
}



local PlayerHoldJudge = mods.HoldJudgment or "Ice 1x2.png"
local HoldJudgments = GetHoldJudgments()
local CurrentHoldJIndex


for i=1, #HoldJudgments do
	if HoldJudgments[i] == PlayerHoldJudge then
		CurrentHoldJIndex = i
		break
	end
end


--- Hold Judgment Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."HoldJudgmentName1",
	InitCommand=function(self)	
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods6")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."HoldJBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."HoldJBox1"):GetX()
		local TextYPosition = Parent:GetY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:settext(StripSpriteHints(HoldJudgments[CurrentHoldJIndex]))
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
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
		
		if CurrentTab == 2 and CurrentRow == 6 then
			if params[1] == "left" then
				if CurrentHoldJIndex == 1 then
					CurrentHoldJIndex = #HoldJudgments
				else
					CurrentHoldJIndex = CurrentHoldJIndex - 1	
				end
				mods.HoldJudgment = HoldJudgments[CurrentHoldJIndex]
				self:settext(StripSpriteHints(HoldJudgments[CurrentHoldJIndex]))
			elseif params[1] == "right" then
				if CurrentHoldJIndex == #HoldJudgments then
					CurrentHoldJIndex = 1
				else
					CurrentHoldJIndex = CurrentHoldJIndex + 1
				end
				mods.HoldJudgment = HoldJudgments[CurrentHoldJIndex]
				self:settext(StripSpriteHints(HoldJudgments[CurrentHoldJIndex]))
			end
		end
	end,

}


--- Hold Judgment Preview
for hj_filename in ivalues( HoldJudgments ) do
	af[#af+1] = Def.ActorFrame{
		Name="HoldJudgment_"..StripSpriteHints(hj_filename),
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."VisualMods6")
			local JudgmentX = self:GetParent():GetChild(pn.."HoldJBox1"):GetX()
			local JudgmentY = Parent:GetY()
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local QuadHeight = self:GetParent():GetChild(pn.."HoldJBox1"):GetZoomY()
			self:horizalign(center):vertalign(middle)
				:animate(false)
				:draworder(1)
				:x(JudgmentX + 120)
				:y(JudgmentY + QuadHeight/3)
				:zoom(0.3)
				:visible(false)
		end,
			-- held
		Def.Sprite{
			Texture=THEME:GetPathG("", "_HoldJudgments/" .. hj_filename),
			InitCommand=function(self) self:animate(false):setstate(0):addx(-self:GetWidth()*0.4) end
		},
		-- let go
		Def.Sprite{
			Texture=THEME:GetPathG("", "_HoldJudgments/" .. hj_filename),
			InitCommand=function(self) self:animate(false):setstate(1):addx(self:GetWidth()*0.4) end
		},
		UpdateDisplayedTabCommand=function(self)
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
			if CurrentTab ~= 2 then
				self:visible(false)
				return
			elseif HoldJudgments[CurrentHoldJIndex] == hj_filename then
				self:visible(true)
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
			if CurrentTab == 2 and CurrentRow == 6 then
				if params[1] == "left" or params[1] == "right" then
					self:queuecommand("UpdateHoldJ")
				end
			end
		end,
		UpdateHoldJCommand=function(self)
			self:visible(false)
			if HoldJudgments[CurrentHoldJIndex] ==  hj_filename then
				self:visible(true)
			else
				self:visible(false)
			end
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
			local Parent = self:GetParent():GetChild(pn.."VisualMods7")
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
		if CurrentTab == 2 and CurrentRow == 7 then
			if CurrentColumn == 1 then
				mods.BackgroundFilter = "Off"
			elseif CurrentColumn == 2 then
				mods.BackgroundFilter = "Dark"
			elseif CurrentColumn == 3 then
				mods.BackgroundFilter = "Darker"
			elseif CurrentColumn == 4 then
				mods.BackgroundFilter = "Darkest"
			end
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
			local Parent = self:GetParent():GetChild(pn.."VisualMods8")
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
			local Parent = self:GetParent():GetChild(pn.."VisualMods8")
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
			if CurrentTab == 2 and CurrentRow == 8 then
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
				end
			end
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
			local Parent = self:GetParent():GetChild(pn.."VisualMods9")
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
			local Parent = self:GetParent():GetChild(pn.."VisualMods9")
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
			if CurrentTab == 2 and CurrentRow == 9 then
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
				end
			end
		end,
	}
end

--- Notefield XBox (360, no scope)
af[#af+1] = Def.Quad{
	Name=pn.."NotefieldXBox1",
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
		local Parent = self:GetParent():GetChild(pn.."VisualMods10")
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
		
		if CurrentTab == 2 and CurrentRow == 10 then
			if params[1] == "left" then
				if PlayerNotefieldX <= MinNotefield then
					PlayerNotefieldX = MaxNotefield
				else
					PlayerNotefieldX = PlayerNotefieldX - 1
				end
				mods.NoteFieldOffsetX = PlayerNotefieldX
				self:settext(PlayerNotefieldX)
			elseif params[1] == "right" then
				if PlayerNotefieldX >= MaxNotefield then
					PlayerNotefieldX = MinNotefield
				else
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
		local Parent = self:GetParent():GetChild(pn.."VisualMods11")
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
}

--- NotefieldY Value
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NotefieldYText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."VisualMods11")
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
		
		if CurrentTab == 2 and CurrentRow == 11 then
			if params[1] == "left" then
				if PlayerNotefieldY <= MinNotefield then
					PlayerNotefieldY = MaxNotefield
				else
					PlayerNotefieldY = PlayerNotefieldY - 1
				end
				mods.NoteFieldOffsetY = PlayerNotefieldY
				self:settext(PlayerNotefieldY)
			elseif params[1] == "right" then
				if PlayerNotefieldY >= MaxNotefield then
					PlayerNotefieldY = MinNotefield
				else
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
		local Parent = self:GetParent():GetChild(pn.."VisualMods12")
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
		local Parent = self:GetParent():GetChild(pn.."VisualMods12")
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
		
		if CurrentTab == 2 and CurrentRow == 12 then
			if params[1] == "left" then
				if PlayerVisualDelay <= MinVisualDelay then
					PlayerVisualDelay = MaxVisualDelay
				else
					PlayerVisualDelay = PlayerVisualDelay - 1
				end
				mods.VisualDelay = PlayerVisualDelay.."ms"
				GAMESTATE:GetPlayerState(player):GetPlayerOptions(0):VisualDelay( mods.VisualDelay:gsub("ms","")/1000 )
				self:settext(PlayerVisualDelay.."ms")
			elseif params[1] == "right" then
				if PlayerVisualDelay >= MaxVisualDelay then
					PlayerVisualDelay = MinVisualDelay
				else
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
THEME:GetString("OptionExplanations","NoteSkin"),
THEME:GetString("OptionExplanations","JudgmentGraphic"),
THEME:GetString("OptionExplanations","ComboFont"),
THEME:GetString("OptionExplanations","HoldJudgment"),
THEME:GetString("OptionExplanations","BackgroundFilter"),
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