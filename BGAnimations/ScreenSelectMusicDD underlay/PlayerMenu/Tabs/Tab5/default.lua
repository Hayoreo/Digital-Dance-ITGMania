--- Here is all the info necessary for Tab 5
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


local InitialMainSort = GetMainSortPreference()
local CurrentMainSort = InitialMainSort

local InitialSubSort1 = GetSubSortPreference()
local CurrentSubSort1 = InitialSubSort1

local InitialSubSort2 = GetSubSort2Preference()
local CurrentSubSort2 = InitialSubSort2

local InitialLowerMeter = GetLowerMeterFilter()
local CurrentLowerMeter = InitialLowerMeter

local InitialUpperMeter = GetUpperMeterFilter()
local CurrentUpperMeter = InitialUpperMeter

local InitialLowerBPM = GetLowerBPMFilter()
local CurrentLowerBPM = InitialLowerBPM

local InitialUpperBPM = GetUpperBPMFilter()
local CurrentUpperBPM = InitialUpperBPM

local InitialLowerLength = GetLowerLengthFilter()
local CurrentLowerLength = InitialLowerLength

local InitialUpperLength = GetUpperLengthFilter()
local CurrentUpperLength = InitialUpperLength

local InitialGroovestats = GetGroovestatsFilter()
local CurrentGroovestats = InitialGroovestats

local InitialAutogen = GetAutogenFilter()
local CurrentAutogen = InitialAutogen

local InitialBeginner = GetShowDifficulty("Beginner")
local CurrentBeginner = InitialBeginner

local InitialEasy = GetShowDifficulty("Easy")
local CurrentEasy = InitialEasy

local InitialMedium = GetShowDifficulty("Medium")
local CurrentMedium = InitialMedium

local InitialHard = GetShowDifficulty("Hard")
local CurrentHard = InitialHard

local InitialChallenge = GetShowDifficulty("Challenge")
local CurrentChallenge = InitialChallenge

local InitialEdit = GetShowDifficulty("Edit")
local CurrentEdit = InitialEdit

local HaveSortsFiltersChanged = function(self)
	if CurrentMainSort ~= InitialMainSort then return true
	elseif CurrentSubSort1 ~= InitialSubSort1 then return true
	elseif CurrentSubSort2 ~= InitialSubSort2 then return true
	elseif CurrentLowerMeter ~= InitialLowerMeter then return true
	elseif CurrentUpperMeter ~= InitialUpperMeter then return true
	elseif CurrentBeginner ~= InitialBeginner then return true
	elseif CurrentEasy ~= InitialEasy then return true
	elseif CurrentMedium ~= InitialMedium then return true
	elseif CurrentHard ~= InitialHard then return true
	elseif CurrentChallenge ~= InitialChallenge then return true
	elseif CurrentLowerBPM ~= InitialLowerBPM then return true
	elseif CurrentUpperBPM ~= InitialUpperBPM then return true
	elseif CurrentLowerLength ~= InitialLowerLength then return true
	elseif CurrentUpperLength ~= InitialUpperLength then return true
	elseif CurrentGroovestats ~= InitialGroovestats then return true
	elseif CurrentAutogen ~= InitialAutogen then return true
	end
	
	return false
end
-----------------------------------------------------------------------------------------------------

local SortsFiltersNames = {
THEME:GetString("DDPlayerMenu","MainSort"),
THEME:GetString("DDPlayerMenu","SubSort"),
THEME:GetString("DDPlayerMenu","SubSort2"),
THEME:GetString("DDPlayerMenu","FilterMeter"),
THEME:GetString("DDPlayerMenu","FilterDifficulty"),
THEME:GetString("DDPlayerMenu","FilterDifficulty"),
THEME:GetString("DDPlayerMenu","FilterBPM"),
THEME:GetString("DDPlayerMenu","FilterLength"),
THEME:GetString("DDPlayerMenu","FilterGroovestats"),
THEME:GetString("DDPlayerMenu","FilterAutogen"),
"",
"",
"",
"",
}

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

for i=1, #SortsFiltersNames do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."SortsFilters"..i,
		InitCommand=function(self)
			local zoom = 0.7
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:diffuse(color("#b0b0b0"))
				:x(XPos + padding/2 + border*2)
				:y(YPos - height/2 + border + (i*20) + 10)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(i < 11 and SortsFiltersNames[i]..":" or SortsFiltersNames[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Main Sort Box
af[#af+1] = Def.Quad{
	Name=pn.."MainSortBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."SortsFilters1")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local QuadWidth = width - TextWidth - 25
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(QuadWidth, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 5)
			:y(TextYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."MainSortBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 1
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


-- Main Sort Texts
local MainSortText = {
	"GROUP",
	"TITLE",
	"ARTIST",
	"LENGTH",
	"BPM",
	"METER",
}


-- The Main sort Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."MainSortText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."MainSortBox1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(MainSortText[CurrentMainSort])
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 1 then
			local MaxSorts = #MainSortText
			if params[1] == "right" then
				if CurrentMainSort == #MainSortText then
					CurrentMainSort = 1
					SetMainSortPreference(CurrentMainSort)
					self:settext(MainSortText[CurrentMainSort])
				else
					CurrentMainSort = CurrentMainSort + 1
					SetMainSortPreference(CurrentMainSort)
					self:settext(MainSortText[CurrentMainSort])
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentMainSort == 1 then
					CurrentMainSort = #MainSortText
					SetMainSortPreference(CurrentMainSort)
					self:settext(MainSortText[CurrentMainSort])
				else
					CurrentMainSort = CurrentMainSort - 1
					SetMainSortPreference(CurrentMainSort)
					self:settext(MainSortText[CurrentMainSort])
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}

-- SubSort1 Box
af[#af+1] = Def.Quad{
	Name=pn.."SubSort1Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."SortsFilters2")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local QuadWidth = width - TextWidth - 25
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(QuadWidth, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 5)
			:y(TextYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."SubSort1Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 2
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


-- Main Sort Texts
local SubSortText = {
	"GROUP",
	"TITLE",
	"ARTIST",
	"LENGTH",
	"BPM",
	"# OF STEPS",
	"METER",
}

-- The Sub Sort Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."SubSort1Text",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."SubSort1Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(SubSortText[CurrentSubSort1])
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 2 then
			local MaxSorts = #SubSortText
			if params[1] == "right" then
				if CurrentSubSort1 == #SubSortText then
					CurrentSubSort1 = 1
					SetSubSortPreference(CurrentSubSort1)
					self:settext(SubSortText[CurrentSubSort1])
				else
					CurrentSubSort1 = CurrentSubSort1 + 1
					SetSubSortPreference(CurrentSubSort1)
					self:settext(SubSortText[CurrentSubSort1])
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentSubSort1 == 1 then
					CurrentSubSort1 = #SubSortText
					SetSubSortPreference(CurrentSubSort1)
					self:settext(SubSortText[CurrentSubSort1])
				else
					CurrentSubSort1 = CurrentSubSort1 - 1
					SetSubSortPreference(CurrentSubSort1)
					self:settext(SubSortText[CurrentSubSort1])
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}

-- SubSort2 Box
af[#af+1] = Def.Quad{
	Name=pn.."SubSort2Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."SortsFilters3")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local QuadWidth = width - TextWidth - 25
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(QuadWidth, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 5)
			:y(TextYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."SubSort2Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 3
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

-- The Sub Sort2 Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."SubSort2Text",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."SubSort2Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(SubSortText[CurrentSubSort2])
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 3 then
			local MaxSorts = #SubSortText
			if params[1] == "right" then
				if CurrentSubSort2 == #SubSortText then
					CurrentSubSort2 = 1
					SetSubSort2Preference(CurrentSubSort2)
					self:settext(SubSortText[CurrentSubSort2])
				else
					CurrentSubSort2 = CurrentSubSort2 + 1
					SetSubSort2Preference(CurrentSubSort2)
					self:settext(SubSortText[CurrentSubSort2])
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentSubSort2 == 1 then
					CurrentSubSort2 = #SubSortText
					SetSubSort2Preference(CurrentSubSort2)
					self:settext(SubSortText[CurrentSubSort2])
				else
					CurrentSubSort2 = CurrentSubSort2 - 1
					SetSubSort2Preference(CurrentSubSort2)
					self:settext(SubSortText[CurrentSubSort2])
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}


--- Meters
local MaxMeter = 99

-- Meter Filter Box1
af[#af+1] = Def.Quad{
	Name=pn.."MeterFilter1Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."SortsFilters4")
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
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."MeterFilter1Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 4
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



-- The lower meter text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."LowerMeterText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."MeterFilter1Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(CurrentLowerMeter == 0 and "none" or CurrentLowerMeter)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 4 then
			if params[1] == "right" then
				if CurrentLowerMeter == MaxMeter then
					CurrentLowerMeter = 0
					SetLowerMeterFilter(CurrentLowerMeter)
					self:settext(CurrentLowerMeter == 0 and "none" or CurrentLowerMeter)
				else
					CurrentLowerMeter = CurrentLowerMeter + 1
					SetLowerMeterFilter(CurrentLowerMeter)
					self:settext(CurrentLowerMeter == 0 and "none" or CurrentLowerMeter)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentLowerMeter == 0 then
					CurrentLowerMeter = MaxMeter
					SetLowerMeterFilter(CurrentLowerMeter)
					self:settext(CurrentLowerMeter == 0 and "none" or CurrentLowerMeter)
				else
					CurrentLowerMeter = CurrentLowerMeter - 1
					SetLowerMeterFilter(CurrentLowerMeter)
					self:settext(CurrentLowerMeter == 0 and "none" or CurrentLowerMeter)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}

-- Meter Filter To
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."MeterFilterTo",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."MeterFilter1Box1")
		local QuadWidth = Parent:GetWidth()
		local QuadHeight = Parent:GetHeight()
		local QuadXPosition = Parent:GetX()
		local QuadYPosition = Parent:GetY()
		self:horizalign(left):vertalign(top):shadowlength(1)
			:draworder(1)
			:diffuse(color("#b0b0b0"))
			:x(QuadXPosition + 50)
			:y(QuadYPosition + self:GetHeight()*1.5)
			:maxwidth((width/zoom) - 20)
			:zoom(zoom)
			:settext(THEME:GetString("DDPlayerMenu","To"))
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

-- Meter Filter Box2
af[#af+1] = Def.Quad{
	Name=pn.."MeterFilter2Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."MeterFilterTo")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local QuadYPosition = self:GetParent():GetChild(pn.."SortsFilters4"):GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(40, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 10)
			:y(QuadYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."MeterFilter2Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 5
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

-- The upper meter text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."UpperMeterText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."MeterFilter2Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(CurrentUpperMeter == 0 and "none" or CurrentUpperMeter)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 5 then
			if params[1] == "right" then
				if CurrentUpperMeter == MaxMeter then
					CurrentUpperMeter = 0
					SetUpperMeterFilter(CurrentUpperMeter)
					self:settext(CurrentUpperMeter == 0 and "none" or CurrentUpperMeter)
				else
					CurrentUpperMeter = CurrentUpperMeter + 1
					SetUpperMeterFilter(CurrentUpperMeter)
					self:settext(CurrentUpperMeter == 0 and "none" or CurrentUpperMeter)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentUpperMeter == 0 then
					CurrentUpperMeter = MaxMeter
					SetUpperMeterFilter(CurrentUpperMeter)
					self:settext(CurrentUpperMeter == 0 and "none" or CurrentUpperMeter)
				else
					CurrentUpperMeter = CurrentUpperMeter - 1
					SetUpperMeterFilter(CurrentUpperMeter)
					self:settext(CurrentUpperMeter == 0 and "none" or CurrentUpperMeter)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}

--- Difficulty filter
local Difficulties={
THEME:GetString("CustomDifficulty","Easy"),
THEME:GetString("CustomDifficulty","Medium"),
THEME:GetString("CustomDifficulty","Hard"),
THEME:GetString("CustomDifficulty","Challenge"),
}

local Difficulties2={
THEME:GetString("Difficulty","Beginner"),
THEME:GetString("CustomDifficulty","Edit"),
}

--- Difficulty names 1
for i=1,#Difficulties do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Difficulty"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."SortsFilters5")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth + 15)
			else
				PastWidth = self:GetParent():GetChild(pn.."Difficulty"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."Difficulty"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Difficulties[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--Difficulty Boxes 1
for i=1,#Difficulties do
	af[#af+1] = Def.Quad{
		Name=pn.."DifficultyModBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."SortsFilters5")
			local TextZoom = self:GetParent():GetChild(pn.."Difficulty"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Difficulty"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Difficulty"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.5)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Difficulty Check Boxes 1
for i=1,#Difficulties do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."DiffCheck"..i,
		InitCommand=function(self)
			local zoom = 0.37
			local Parent = self:GetParent():GetChild(pn.."DifficultyModBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if CurrentEasy == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if CurrentMedium == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if CurrentHard == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if CurrentChallenge == 1 then
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
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
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
			if CurrentTab == 5 and CurrentRow == 6 then
				if CurrentColumn == 1 and i == 1 then
					if CurrentEasy == 1 then
						CurrentEasy = 0
						SetShowDifficulty("Easy", CurrentEasy)
						self:settext("")
					elseif CurrentEasy == 0 then
						CurrentEasy = 1
						SetShowDifficulty("Easy", CurrentEasy)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if CurrentMedium == 1 then
						CurrentMedium = 0
						SetShowDifficulty("Medium", CurrentMedium)
						self:settext("")
					elseif CurrentMedium == 0 then
						CurrentMedium = 1
						SetShowDifficulty("Medium", CurrentMedium)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if CurrentHard == 1 then
						CurrentHard = 0
						SetShowDifficulty("Hard", CurrentHard)
						self:settext("")
					elseif CurrentHard == 0 then
						CurrentHard = 1
						SetShowDifficulty("Hard", CurrentHard)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if CurrentChallenge == 1 then
						CurrentChallenge = 0
						SetShowDifficulty("Challenge", CurrentChallenge)
						self:settext("")
					elseif CurrentChallenge == 0 then
						CurrentChallenge = 1
						SetShowDifficulty("Challenge", CurrentChallenge)
						self:settext("✅")
					end
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
			if CurrentTab ~= 5 then return end
			-- yooooooo the j!!!!
			for j=1, #Difficulties do
				local Parent = self:GetParent():GetChild(pn.."DifficultyModBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
					if j == 1 and j == i then
						CurrentRow = 6
						CurrentColumn = 1
						if CurrentEasy == 1 then
							CurrentEasy = 0
							SetShowDifficulty("Easy", CurrentEasy)
							self:settext("")
						elseif CurrentEasy == 0 then
							CurrentEasy = 1
							SetShowDifficulty("Easy", CurrentEasy)
							self:settext("✅")
						end
						break
					elseif j == 2 and j == i then
						CurrentRow = 6
						CurrentColumn = 2
						if CurrentMedium == 1 then
							CurrentMedium = 0
							SetShowDifficulty("Medium", CurrentMedium)
							self:settext("")
						elseif CurrentMedium == 0 then
							CurrentMedium = 1
							SetShowDifficulty("Medium", CurrentMedium)
							self:settext("✅")
						end
						break
					elseif j == 3 and j == i then
						CurrentRow = 6
						CurrentColumn = 3
						if CurrentHard == 1 then
							CurrentHard = 0
							SetShowDifficulty("Hard", CurrentHard)
							self:settext("")
						elseif CurrentHard == 0 then
							CurrentHard = 1
							SetShowDifficulty("Hard", CurrentHard)
							self:settext("✅")
						end
						break
					elseif j == 4 and j == i then
						CurrentRow = 6
						CurrentColumn = 4
						if CurrentChallenge == 1 then
							CurrentChallenge = 0
							SetShowDifficulty("Challenge", CurrentChallenge)
							self:settext("")
						elseif CurrentChallenge == 0 then
							CurrentChallenge = 1
							SetShowDifficulty("Challenge", CurrentChallenge)
							self:settext("✅")
						end
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
			if HaveSortsFiltersChanged() then
				MusicWheelNeedsResetting = true
			else
				MusicWheelNeedsResetting = false
			end
			if IsUsingFilters() or IsUsingSorts() then
				MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
			else
				MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
			end
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end,
	}
end


--- Difficulty names 2
for i=1,#Difficulties2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Difficulty2_"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."SortsFilters6")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth + 15)
			else
				PastWidth = self:GetParent():GetChild(pn.."Difficulty2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."Difficulty2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Difficulties2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Difficulty Boxes 2
for i=1,#Difficulties2 do
	af[#af+1] = Def.Quad{
		Name=pn.."Difficulty2ModBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."SortsFilters6")
			local TextZoom = self:GetParent():GetChild(pn.."Difficulty2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Difficulty2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Difficulty2_"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.5)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


--- Difficulty Check Boxes 2
for i=1,#Difficulties2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Diff2Check"..i,
		InitCommand=function(self)
			local zoom = 0.37
			local Parent = self:GetParent():GetChild(pn.."Difficulty2ModBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if CurrentBeginner == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if CurrentEdit == 1 then
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
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
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
			if CurrentTab == 5 and CurrentRow == 7 then
				if CurrentColumn == 1 and i == 1 then
					if CurrentBeginner == 1 then
						CurrentBeginner = 0
						SetShowDifficulty("Beginner", CurrentBeginner)
						self:settext("")
					elseif CurrentBeginner == 0 then
						CurrentBeginner = 1
						SetShowDifficulty("Beginner", CurrentBeginner)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if CurrentEdit == 1 then
						CurrentEdit = 0
						SetShowDifficulty("Edit", CurrentEdit)
						self:settext("")
					elseif CurrentEdit == 0 then
						CurrentEdit = 1
						SetShowDifficulty("Edit", CurrentEdit)
						self:settext("✅")
					end
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
			if CurrentTab ~= 5 then return end
			-- yooooooo the j!!!!
			for j=1, #Difficulties2 do
				local Parent = self:GetParent():GetChild(pn.."Difficulty2ModBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
					if j == 1 and j == i then
						CurrentRow = 7
						CurrentColumn = 1
						if CurrentBeginner == 1 then
							CurrentBeginner = 0
							SetShowDifficulty("Beginner", CurrentBeginner)
							self:settext("")
						elseif CurrentBeginner == 0 then
							CurrentBeginner = 1
							SetShowDifficulty("Beginner", CurrentBeginner)
							self:settext("✅")
						end
						break
					elseif j == 2 and j == i then
						CurrentRow = 7
						CurrentColumn = 2
						if CurrentEdit == 1 then
							CurrentEdit = 0
							SetShowDifficulty("Edit", CurrentEdit)
							self:settext("")
						elseif CurrentEdit == 0 then
							CurrentEdit = 1
							SetShowDifficulty("Edit", CurrentEdit)
							self:settext("✅")
						end
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
			if HaveSortsFiltersChanged() then
				MusicWheelNeedsResetting = true
			else
				MusicWheelNeedsResetting = false
			end
			if IsUsingFilters() or IsUsingSorts() then
				MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
			else
				MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
			end
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end,
	}
end



-----------------------------------------------------------
--BPMS
local MaxBPM = 500



-- BPM Filter Box1
af[#af+1] = Def.Quad{
	Name=pn.."BPMFilter1Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."SortsFilters7")
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
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."BPMFilter1Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
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

-- The lower bpm text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."LowerBPMText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."BPMFilter1Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(CurrentLowerBPM == 49 and "none" or CurrentLowerBPM)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 8 then
			if params[1] == "right" then
				if CurrentLowerBPM == MaxBPM then
					CurrentLowerBPM = 49
					SetLowerBPMFilter(CurrentLowerBPM)
					self:settext(CurrentLowerBPM == 49 and "none" or CurrentLowerBPM)
				else
					CurrentLowerBPM = CurrentLowerBPM + 1
					SetLowerBPMFilter(CurrentLowerBPM)
					self:settext(CurrentLowerBPM == 49 and "none" or CurrentLowerBPM)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentLowerBPM == 49 then
					CurrentLowerBPM = MaxBPM
					SetLowerBPMFilter(CurrentLowerBPM)
					self:settext(CurrentLowerBPM == 49 and "none" or CurrentLowerBPM)
				else
					CurrentLowerBPM = CurrentLowerBPM - 1
					SetLowerBPMFilter(CurrentLowerBPM)
					self:settext(CurrentLowerBPM == 49 and "none" or CurrentLowerBPM)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}

-- BPM Filter To
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."BPMFilterTo",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."BPMFilter1Box1")
		local QuadWidth = Parent:GetWidth()
		local QuadHeight = Parent:GetHeight()
		local QuadXPosition = Parent:GetX()
		local QuadYPosition = Parent:GetY()
		self:horizalign(left):vertalign(top):shadowlength(1)
			:draworder(1)
			:diffuse(color("#b0b0b0"))
			:x(QuadXPosition + 50)
			:y(QuadYPosition + self:GetHeight()*1.5)
			:maxwidth((width/zoom) - 20)
			:zoom(zoom)
			:settext(THEME:GetString("DDPlayerMenu","To"))
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

-- BPM Filter Box2
af[#af+1] = Def.Quad{
	Name=pn.."BPMFilter2Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."BPMFilterTo")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local QuadYPosition = self:GetParent():GetChild(pn.."SortsFilters7"):GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(40, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 10)
			:y(QuadYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."BPMFilter2Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
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

-- The upper bpm text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."UpperBPMText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."BPMFilter2Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:settext(CurrentUpperBPM == 49 and "none" or CurrentUpperBPM)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 9 then
			if params[1] == "right" then
				if CurrentUpperBPM == MaxBPM then
					CurrentUpperBPM = 49
					SetUpperBPMFilter(CurrentUpperBPM)
					self:settext(CurrentUpperBPM == 49 and "none" or CurrentUpperBPM)
				else
					CurrentUpperBPM = CurrentUpperBPM + 1
					SetUpperBPMFilter(CurrentUpperBPM)
					self:settext(CurrentUpperBPM == 49 and "none" or CurrentUpperBPM)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentUpperBPM == 49 then
					CurrentUpperBPM = MaxBPM
					SetUpperBPMFilter(CurrentUpperBPM)
					self:settext(CurrentUpperBPM == 49 and "none" or CurrentUpperBPM)
				else
					CurrentUpperBPM = CurrentUpperBPM - 1
					SetUpperBPMFilter(CurrentUpperBPM)
					self:settext(CurrentUpperBPM == 49 and "none" or CurrentUpperBPM)
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			end
		end
	end,
}

-------------------------------------------------------

-- Length Filter Box1
af[#af+1] = Def.Quad{
	Name=pn.."LengthFilter1Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."SortsFilters8")
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
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."LengthFilter1Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
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

-- The lower length text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."LowerLengthText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."LengthFilter1Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		if CurrentLowerLength == 0 then
			self:settext("none")
		elseif CurrentLowerLength > 0 and CurrentLowerLength < 600 then
			self:settext(SecondsToMSS(CurrentLowerLength))
		elseif CurrentLowerLength >= 600 and CurrentLowerLength < 3600 then
			self:settext(SecondsToMMSS(CurrentLowerLength))
		elseif CurrentLowerLength == 3600 then
			self:settext("1:00:00")
		end
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:queuecommand("UpdateDisplayedTab")
			:queuecommand("UpdateLength")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 10 then
			if params[1] == "right" then
				if CurrentLowerLength == 3600 then
					CurrentLowerLength = 0
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 30sec for songs less than 1 minute
				elseif CurrentLowerLength >= 0 and CurrentLowerLength < 60 then
					CurrentLowerLength = CurrentLowerLength + 30
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 5sec for songs between 1min and 10min
				elseif CurrentLowerLength >= 60 and CurrentLowerLength < 600 then
					CurrentLowerLength = CurrentLowerLength + 5
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 1min for songs between 10min and 30min
				elseif CurrentLowerLength >= 600 and CurrentLowerLength < 1800 then
					CurrentLowerLength = CurrentLowerLength + 60
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 10min for songs longer than 30min
				elseif CurrentLowerLength >= 1800 and CurrentLowerLength < 3600 then
					CurrentLowerLength = CurrentLowerLength + 600
					self:queuecommand('UpdateLowerLength')
				end
				if HaveSortsFiltersChanged() then
					MusicWheelNeedsResetting = true
				else
					MusicWheelNeedsResetting = false
				end
				if IsUsingFilters() or IsUsingSorts() then
					MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
				else
					MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
				end
			elseif params[1] == "left" then
				if CurrentLowerLength == 0 then
					CurrentLowerLength = 3600
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 30sec for songs less than 1 minute
				elseif CurrentLowerLength > 0 and CurrentLowerLength <= 60 then
					CurrentLowerLength = CurrentLowerLength - 30
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 5sec for songs between 1min and 10min
				elseif CurrentLowerLength > 60 and CurrentLowerLength <= 600 then
					CurrentLowerLength = CurrentLowerLength - 5
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 1min for songs between 10min and 30min
				elseif CurrentLowerLength > 600 and CurrentLowerLength <= 1800 then
					CurrentLowerLength = CurrentLowerLength - 60
					self:queuecommand('UpdateLowerLength')
				--- go in increments of 10min for songs longer than 30min
				elseif CurrentLowerLength > 1800 and CurrentLowerLength <= 3600 then
					CurrentLowerLength = CurrentLowerLength - 600
					self:queuecommand('UpdateLowerLength')
				end
			end
		end
	end,
	UpdateLowerLengthCommand=function(self)
		if CurrentLowerLength == 0 then
			self:settext("none")
		elseif CurrentLowerLength > 0 and CurrentLowerLength < 600 then
			self:settext(SecondsToMSS(CurrentLowerLength))
		elseif CurrentLowerLength >= 600 and CurrentLowerLength < 3600 then
			self:settext(SecondsToMMSS(CurrentLowerLength))
		elseif CurrentLowerLength == 3600 then
			self:settext("1:00:00")
		end
		SetLowerLengthFilter(CurrentLowerLength)
		if IsUsingFilters() or IsUsingSorts() then
			MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
		else
			MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
		end
		if HaveSortsFiltersChanged() then
			MusicWheelNeedsResetting = true
		else
			MusicWheelNeedsResetting = false
		end
	end,
}

-- Length Filter To
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."LengthFilterTo",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."LengthFilter1Box1")
		local QuadWidth = Parent:GetWidth()
		local QuadHeight = Parent:GetHeight()
		local QuadXPosition = Parent:GetX()
		local QuadYPosition = Parent:GetY()
		self:horizalign(left):vertalign(top):shadowlength(1)
			:draworder(1)
			:diffuse(color("#b0b0b0"))
			:x(QuadXPosition + 70)
			:y(QuadYPosition + self:GetHeight()*1.5)
			:maxwidth((width/zoom) - 20)
			:zoom(zoom)
			:settext(THEME:GetString("DDPlayerMenu","To"))
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

-- Length Filter Box2
af[#af+1] = Def.Quad{
	Name=pn.."LengthFilter2Box1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."LengthFilterTo")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local QuadYPosition = self:GetParent():GetChild(pn.."SortsFilters8"):GetY()
		self:diffuse(color("#4d4d4d"))
			:draworder(1)
			:zoomto(60, TextHeight)
			:vertalign(top):horizalign(left)
			:x(TextXPosition + TextWidth + 10)
			:y(QuadYPosition - (TextHeight*TextZoom)/4)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."LengthFilter2Box1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 11
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

-- The upper length text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."LowerLengthText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."LengthFilter2Box1")
		local TextX = Parent:GetX()
		local TextY = Parent:GetY()
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		if CurrentUpperLength == 0 then
			self:settext("none")
		elseif CurrentUpperLength > 0 and CurrentUpperLength < 600 then
			self:settext(SecondsToMSS(CurrentUpperLength))
		elseif CurrentUpperLength >= 600 and CurrentUpperLength < 3600 then
			self:settext(SecondsToMMSS(CurrentUpperLength))
		elseif CurrentUpperLength == 3600 then
			self:settext("1:00:00")
		end
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:x(TextX + QuadWidth/2)
			:y(TextY + QuadHeight/2)
			:maxwidth(QuadWidth - 5)
			:zoom(zoom)
			:queuecommand("UpdateDisplayedTab")
			:queuecommand("UpdateLength")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentTabP2 ~= 5 then
				self:visible(false)
			else
				self:visible(true)
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
		if CurrentTab == 5 and CurrentRow == 11 then
			if params[1] == "right" then
				if CurrentUpperLength == 3600 then
					CurrentUpperLength = 0
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 30sec for songs less than 1 minute
				elseif CurrentUpperLength >= 0 and CurrentUpperLength < 60 then
					CurrentUpperLength = CurrentUpperLength + 30
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 5sec for songs between 1min and 10min
				elseif CurrentUpperLength >= 60 and CurrentUpperLength < 600 then
					CurrentUpperLength = CurrentUpperLength + 5
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 1min for songs between 10min and 30min
				elseif CurrentUpperLength >= 600 and CurrentUpperLength < 1800 then
					CurrentUpperLength = CurrentUpperLength + 60
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 10min for songs longer than 30min
				elseif CurrentUpperLength >= 1800 and CurrentUpperLength < 3600 then
					CurrentUpperLength = CurrentUpperLength + 600
					self:queuecommand('UpdateUpperLength')
				end
			elseif params[1] == "left" then
				if CurrentUpperLength == 0 then
					CurrentUpperLength = 3600
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 30sec for songs less than 1 minute
				elseif CurrentUpperLength > 0 and CurrentUpperLength <= 60 then
					CurrentUpperLength = CurrentUpperLength - 30
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 5sec for songs between 1min and 10min
				elseif CurrentUpperLength > 60 and CurrentUpperLength <= 600 then
					CurrentUpperLength = CurrentUpperLength - 5
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 1min for songs between 10min and 30min
				elseif CurrentUpperLength > 600 and CurrentUpperLength <= 1800 then
					CurrentUpperLength = CurrentUpperLength - 60
					self:queuecommand('UpdateUpperLength')
				--- go in increments of 10min for songs longer than 30min
				elseif CurrentUpperLength > 1800 and CurrentUpperLength <= 3600 then
					CurrentUpperLength = CurrentUpperLength - 600
					self:queuecommand('UpdateUpperLength')
				end
			end
		end
	end,
	UpdateUpperLengthCommand=function(self)
		SetUpperLengthFilter(CurrentUpperLength)
		if CurrentUpperLength == 0 then
			self:settext("none")
		elseif CurrentUpperLength > 0 and CurrentUpperLength < 600 then
			self:settext(SecondsToMSS(CurrentUpperLength))
		elseif CurrentUpperLength >= 600 and CurrentUpperLength < 3600 then
			self:settext(SecondsToMMSS(CurrentUpperLength))
		elseif CurrentUpperLength == 3600 then
			self:settext("1:00:00")
		end
		if IsUsingFilters() or IsUsingSorts() then
			MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
		else
			MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
		end
		if HaveSortsFiltersChanged() then
			MusicWheelNeedsResetting = true
		else
			MusicWheelNeedsResetting = false
		end
	end,
}


------------------------------------------------------------------------
--- Filter options
local FilterOptions={
THEME:GetString("SLPlayerOptions","Off"),
THEME:GetString("DDPlayerMenu","OnlyShow"),
THEME:GetString("DDPlayerMenu","HideAll"),
}

-- Groovestats Filter
for i=1,#FilterOptions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Groovestats"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."SortsFilters9")
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
				PastWidth = self:GetParent():GetChild(pn.."Groovestats"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."Groovestats"..i-1):GetX()
				CurrentX = PastX + PastWidth + 10
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(FilterOptions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Groovestats Selector
af[#af+1] = Def.Quad{
	Name=pn.."GroovestatsSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."Groovestats"..CurrentGroovestats)
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
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab == 5 and CurrentRow == 12 then
			if CurrentColumn == 1 then
				CurrentGroovestats = 1
				SetGroovestatsFilter(CurrentGroovestats)
			elseif CurrentColumn == 2 then
				CurrentGroovestats = 2
				SetGroovestatsFilter(CurrentGroovestats)
			elseif CurrentColumn == 3 then
				CurrentGroovestats = 3
				SetGroovestatsFilter(CurrentGroovestats)
			end
			local Parent = self:GetParent():GetChild(pn.."Groovestats"..CurrentColumn)
			local TextZoom = Parent:GetZoom()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local TextHeight = Parent:GetHeight()
			local TextWidth = Parent:GetWidth() * TextZoom
			self:zoomto(TextWidth, 3)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
		end
		if HaveSortsFiltersChanged() then
			MusicWheelNeedsResetting = true
		else
			MusicWheelNeedsResetting = false
		end
		if IsUsingFilters() or IsUsingSorts() then
			MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
		else
			MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
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
		if CurrentTab ~= 5 then return end
		for j=1,#FilterOptions do
			local Parent = self:GetParent():GetChild(pn.."Groovestats"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
				if j == 1 then
					CurrentRow = 12
					CurrentColumn = 1
					CurrentGroovestats = 1
					SetGroovestatsFilter(CurrentGroovestats)
				elseif j == 2 then
					CurrentRow = 12
					CurrentColumn = 2
					CurrentGroovestats = 2
					SetGroovestatsFilter(CurrentGroovestats)
				elseif j == 3 then
					CurrentRow = 12
					CurrentColumn = 3
					CurrentGroovestats = 3
					SetGroovestatsFilter(CurrentGroovestats)
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."Groovestats"..CurrentColumn)
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
			if HaveSortsFiltersChanged() then
				MusicWheelNeedsResetting = true
			else
				MusicWheelNeedsResetting = false
			end
			if IsUsingFilters() or IsUsingSorts() then
				MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
			else
				MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
			end
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end
	end,
}


--- Autogen Filter
for i=1,#FilterOptions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Autogen"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."SortsFilters10")
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
				PastWidth = self:GetParent():GetChild(pn.."Autogen"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."Autogen"..i-1):GetX()
				CurrentX = PastX + PastWidth + 10
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(FilterOptions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Autogen Selector
af[#af+1] = Def.Quad{
	Name=pn.."GroovestatsSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."Autogen"..CurrentAutogen)
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
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
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
		if CurrentTab == 5 and CurrentRow == 13 then
			if CurrentColumn == 1 then
				CurrentAutogen = 1
				SetAutogenFilter(CurrentColumn)
			elseif CurrentColumn == 2 then
				CurrentAutogen = 2
				SetAutogenFilter(CurrentColumn)
			elseif CurrentColumn == 3 then
				CurrentAutogen = 3
				SetAutogenFilter(CurrentColumn)
			end
			local Parent = self:GetParent():GetChild(pn.."Autogen"..CurrentColumn)
			local TextZoom = Parent:GetZoom()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local TextHeight = Parent:GetHeight()
			local TextWidth = Parent:GetWidth() * TextZoom
			self:zoomto(TextWidth, 3)
			:x(TextXPosition)
			:y(TextYPosition + TextHeight/3)
		end
		if HaveSortsFiltersChanged() then
			MusicWheelNeedsResetting = true
		else
			MusicWheelNeedsResetting = false
		end
		if IsUsingFilters() or IsUsingSorts() then
			MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
		else
			MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
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
		if CurrentTab ~= 5 then return end
		for j=1,#FilterOptions do
			local Parent = self:GetParent():GetChild(pn.."Autogen"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
				if j == 1 then
					CurrentRow = 13
					CurrentColumn = 1
					CurrentAutogen = 1
					SetAutogenFilter(CurrentAutogen)
				elseif j == 2 then
					CurrentRow = 13
					CurrentColumn = 2
					CurrentAutogen = 2
					SetAutogenFilter(CurrentAutogen)
				elseif j == 3 then
					CurrentRow = 13
					CurrentColumn = 3
					CurrentAutogen = 3
					SetAutogenFilter(CurrentAutogen)
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."Autogen"..CurrentColumn)
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
			if HaveSortsFiltersChanged() then
				MusicWheelNeedsResetting = true
			else
				MusicWheelNeedsResetting = false
			end
			if IsUsingFilters() or IsUsingSorts() then
				MESSAGEMAN:Broadcast("UpdateResetColor", {"green"})
			else
				MESSAGEMAN:Broadcast("UpdateResetColor", {"red"})
			end
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
		end
	end,
}

-- Reset text
af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Reset",
		InitCommand=function(self)
			local zoom = 0.7
			local Parent = self:GetParent():GetChild(pn.."SortsFilters11")
			local TextYPosition = Parent:GetY()
			self:horizalign(center):vertalign(top):shadowlength(1)
				:x(XPos + padding/2 + border/2 + width/2)
				:y(TextYPosition + 10)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:draworder(2)
				:settext(THEME:GetString("DDPlayerMenu","Reset"))
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 5 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
}


--- Reset Button Outline
af[#af+1] = Def.Quad{
	Name=pn.."ResetButton",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."Reset")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadYPosition = Parent:GetY()
		if IsUsingFilters() or IsUsingSorts() then
			self:diffuse(color("#32a852"))
		else 
			self:diffuse(color("#bd5c5c"))
		end
		self:draworder(1)
			:zoomto(TextWidth + border*2, TextHeight + border*2)
			:vertalign(middle):horizalign(center)
			:x(XPos + padding/2 + border/2 + width/2)
			:y(QuadYPosition + TextHeight/2)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	UpdateResetColorMessageCommand=function(self, params)
		if params[1] == "green" then
			self:diffuse(color("#32a852"))
		elseif params[1] == "red" then
			self:diffuse(color("#bd5c5c"))
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
		if CurrentTab == 5 and CurrentRow == #SortsFiltersNames then
			MESSAGEMAN:Broadcast("DDResetSortsFilters")
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
		if CurrentTab ~= 5 then return end
		local Parent = self:GetParent():GetChild(pn.."ResetButton")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 5 then
			CurrentRow = 14
			CurrentColumn = 1
			MESSAGEMAN:Broadcast("DDResetSortsFilters")
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

-- Reset Button inline
af[#af+1] = Def.Quad{
	Name=pn.."ResetButtonOutline1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."Reset")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadYPosition = Parent:GetY()
		self:diffuse(color("#4d4d4d"))
			:zoomto(TextWidth + border, TextHeight + border)
			:draworder(1)
			:vertalign(middle):horizalign(center)
			:x(XPos + padding/2 + border/2 + width/2)
			:y(QuadYPosition + TextHeight/2)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 5 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

-------------------------------------------------------------
local Mod5Descriptions = {
THEME:GetString("OptionExplanations","MainSort"),
THEME:GetString("OptionExplanations","SubSort1"),
THEME:GetString("OptionExplanations","SubSort2"),
THEME:GetString("OptionExplanations","MeterFilter"),
THEME:GetString("OptionExplanations","MeterFilter"),
THEME:GetString("OptionExplanations","DifficultyFilter"),
THEME:GetString("OptionExplanations","DifficultyFilter"),
THEME:GetString("OptionExplanations","BPMFilter"),
THEME:GetString("OptionExplanations","BPMFilter"),
THEME:GetString("OptionExplanations","LengthFilter"),
THEME:GetString("OptionExplanations","LengthFilter"),
THEME:GetString("OptionExplanations","GroovestatsFilter"),
THEME:GetString("OptionExplanations","AutogenFilter"),
THEME:GetString("OptionExplanations","ResetSortsFilters"),
"",
"",
"",
}

-- Bottom Information for mods
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."Mod5Descriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(Mod5Descriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 or CurrentTabP1 ~= 5 then
				self:visible(false)
			else
				self:settext(Mod5Descriptions[CurrentRowP1])
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0  or CurrentTabP2 ~= 5 then
				self:visible(false)
				
			else
				self:settext(Mod5Descriptions[CurrentRowP2])
				self:visible(true)
			end
		end
	end,
}