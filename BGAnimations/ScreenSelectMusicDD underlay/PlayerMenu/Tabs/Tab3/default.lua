--- Here is all the info necessary for Tab 3
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

-----------------------------------------------------------------------------------------------------

local AdvancedModsNames = {
THEME:GetString("OptionTitles","LifeMeterType"),
THEME:GetString("OptionTitles","DataVisualizations"),
THEME:GetString("OptionTitles","TargetScore"),
THEME:GetString("OptionTitles","ActionOnMissedTarget"),
THEME:GetString("OptionTitles","GameplayExtras"),
THEME:GetString("OptionTitles","GameplayExtras"),
THEME:GetString("OptionTitles","ErrorBar"),
THEME:GetString("OptionTitles","ErrorBarOptions"),
THEME:GetString("OptionTitles","MeasureCounter"),
THEME:GetString("OptionTitles","MeasureCounterOptions"),
THEME:GetString("OptionTitles","TimingWindowOptions"),
THEME:GetString("OptionTitles","FaPlus"),
THEME:GetString("OptionTitles","ColumnCues"),
THEME:GetString("OptionTitles","ColumnCueExtras"),
THEME:GetString("OptionTitles","ColumnCueExtras"),
}

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

for i=1, #AdvancedModsNames do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."AdvancedMods"..i,
		InitCommand=function(self)
			local zoom = 0.7
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:diffuse(color("#b0b0b0"))
				:x(XPos + padding/2 + border*2)
				:y(YPos - height/2 + border + (i*17.5) + 10)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(AdvancedModsNames[i]..":")
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local LifeBarTypes = {
THEME:GetString("SLPlayerOptions","Standard"),
THEME:GetString("SLPlayerOptions","Surround"),
THEME:GetString("SLPlayerOptions","Vertical"),
}

for i=1,#LifeBarTypes do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."LifeBarType"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods1")
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
				PastWidth = self:GetParent():GetChild(pn.."LifeBarType"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."LifeBarType"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(LifeBarTypes[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local PlayerLifebar = mods.LifeMeterType or "Vertical"
local LifebarNumber

if PlayerLifebar == "Standard" then
	LifebarNumber = 1
elseif PlayerLifebar == "Surround" then
	LifebarNumber = 2
elseif PlayerLifebar == "Vertical" then
	LifebarNumber = 3
end

--- Lifebar Selector
af[#af+1] = Def.Quad{
	Name=pn.."LifebarSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."LifeBarType"..LifebarNumber)
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab == 3 and CurrentRow == 1 then
			if CurrentColumn == 1 then
				LifebarNumber = 1
				mods.LifeMeterType = "Standard"
			elseif CurrentColumn == 2 then
				LifebarNumber = 2
				mods.LifeMeterType = "Surround"
			elseif CurrentColumn == 3 then
				LifebarNumber = 3
				mods.LifeMeterType = "Vertical"
			end
			local Parent = self:GetParent():GetChild(pn.."LifeBarType"..CurrentColumn)
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
		if CurrentTab ~= 3 then return end
		for j=1,#LifeBarTypes do
			local Parent = self:GetParent():GetChild(pn.."LifeBarType"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
				if j == 1 then
					if CurrentRow ~= 1 and LifebarNumber == 1 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif LifebarNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 1
					CurrentColumn = 1
					LifebarNumber = 1
					mods.LifeMeterType = "Standard"
				elseif j == 2 then
					if CurrentRow ~= 1 and LifebarNumber == 2 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif LifebarNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 1
					CurrentColumn = 2
					LifebarNumber = 2
					mods.LifeMeterType = "Surround"
				elseif j == 3 then
					if CurrentRow ~= 1 and LifebarNumber == 3 then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif LifebarNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 1
					CurrentColumn = 3
					LifebarNumber = 3
					mods.LifeMeterType = "Vertical"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."LifeBarType"..CurrentColumn)
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

local DataVisualizations = {
THEME:GetString("SLPlayerOptions","Off"),
THEME:GetString("SLPlayerOptions","Target Score Graph"),
THEME:GetString("SLPlayerOptions","Step Statistics"),
}

for i=1,#DataVisualizations do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."DataVisualization"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods2")
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
				PastWidth = self:GetParent():GetChild(pn.."DataVisualization"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."DataVisualization"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(DataVisualizations[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local PlayerDataVisualization = mods.DataVisualizations or "None"
local DataVisualizationNumber

if PlayerDataVisualization == "None" then
	DataVisualizationNumber = 1
elseif PlayerDataVisualization == "Target Score Graph" then
	DataVisualizationNumber = 2
elseif PlayerDataVisualization == "Step Statistics" then
	DataVisualizationNumber = 3
end

--- Data Selector
af[#af+1] = Def.Quad{
	Name=pn.."DataVisualizationSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."DataVisualization"..DataVisualizationNumber)
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab == 3 and CurrentRow == 2 then
			if CurrentColumn == 1 then
				DataVisualizationNumber = 1
				mods.DataVisualizations = "None"
			elseif CurrentColumn == 2 then
				DataVisualizationNumber = 2
				mods.DataVisualizations = "Target Score Graph"
			elseif CurrentColumn == 3 then
				DataVisualizationNumber = 3
				mods.DataVisualizations = "Step Statistics"
			end
			local Parent = self:GetParent():GetChild(pn.."DataVisualization"..CurrentColumn)
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
		if CurrentTab ~= 3 then return end
		for j=1,#DataVisualizations do
			local Parent = self:GetParent():GetChild(pn.."DataVisualization"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
				if j == 1 then
					if CurrentRow ~= 2 and DataVisualizationNumber == 1 then
						if CurrentRow < 2 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 2 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif DataVisualizationNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 2
					CurrentColumn = 1
					DataVisualizationNumber = 1
					mods.DataVisualizations = "None"
				elseif j == 2 then
					if CurrentRow ~= 2 and DataVisualizationNumber == 2 then
						if CurrentRow < 2 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 2 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif DataVisualizationNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 2
					CurrentColumn = 2
					DataVisualizationNumber = 2
					mods.DataVisualizations = "Target Score Graph"
				elseif j == 3 then
					if CurrentRow ~= 2 and DataVisualizationNumber == 3 then
						if CurrentRow < 2 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 2 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif DataVisualizationNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 2
					CurrentColumn = 3
					DataVisualizationNumber = 3
					mods.DataVisualizations = "Step Statistics"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."DataVisualization"..CurrentColumn)
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
--- Target Score box
af[#af+1] = Def.Quad{
	Name=pn.."TargetScoreBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."AdvancedMods3")
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab ~= 3 then return end
		local Parent = self:GetParent():GetChild(pn.."TargetScoreBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
			if CurrentRow ~= 3 then
				if CurrentRow < 3 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 3 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
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

local PlayerTargetScore = mods.TargetScore or 102
local MinTargetScore = 0
local MaxTargetScore = 102

--- Target Score Value
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."TargetScoreText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."AdvancedMods3")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."TargetScoreBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."TargetScoreBox1"):GetX()
		local TextYPosition = Parent:GetY()
		local TargetScoreText
		if PlayerTargetScore == 101 then
			TargetScoreText = "Machine Best"
		elseif PlayerTargetScore == 102 then
			TargetScoreText = "Personal Best"
		else
			TargetScoreText = PlayerTargetScore.."%"
		end
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:settext(TargetScoreText)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		
		if CurrentTab == 3 and CurrentRow == 3 then
			if params[1] == "left" then
				if PlayerTargetScore <= MinTargetScore then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerTargetScore = round(MaxTargetScore, 2)
					end
				elseif PlayerTargetScore <= 100 and PlayerTargetScore >= 99.01 then
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerTargetScore = round(PlayerTargetScore - 0.01, 2)
				elseif PlayerTargetScore <= 99 and PlayerTargetScore >= 90.1 then
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerTargetScore = round(PlayerTargetScore - 0.1, 2)
				elseif PlayerTargetScore <= 90 then
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerTargetScore = round(PlayerTargetScore - 1, 2)
				else
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerTargetScore = round(PlayerTargetScore - 1,2)
					end
				end
				mods.TargetScore = PlayerTargetScore
				local TargetScoreText
				if PlayerTargetScore == 101 then
					TargetScoreText = "Machine Best"
				elseif PlayerTargetScore == 102 then
					TargetScoreText = "Personal Best"
				else
					TargetScoreText = PlayerTargetScore.."%"
				end
				self:settext(TargetScoreText)
			elseif params[1] == "right" then
				if PlayerTargetScore >= MaxTargetScore then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerTargetScore = round(MinTargetScore, 2)
					end
				elseif PlayerTargetScore >= 100 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerTargetScore = round(PlayerTargetScore + 1, 2)
					end
				elseif PlayerTargetScore <= 99.99 and PlayerTargetScore >= 99 then
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerTargetScore = round(PlayerTargetScore + 0.01, 2)
				elseif PlayerTargetScore >= 90 and PlayerTargetScore <= 98.9 then
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerTargetScore = round(PlayerTargetScore + 0.1, 2)
				elseif PlayerTargetScore <= 89 then
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerTargetScore = round(PlayerTargetScore + 1, 2)
				else
					if not params[2] == true then	
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerTargetScore = round(PlayerTargetScore + 1, 2)
					end
				end
				mods.TargetScore = PlayerTargetScore
				local TargetScoreText
				if PlayerTargetScore == 101 then
					TargetScoreText = "Machine Best"
				elseif PlayerTargetScore == 102 then
					TargetScoreText = "Personal Best"
				else
					TargetScoreText = PlayerTargetScore.."%"
				end
				self:settext(TargetScoreText)
			end
		end
	end,
}

----------------------------------------------------------------------------

--- Target Actions
local TargetActions = {
THEME:GetString("SLPlayerOptions","Nothing"),
THEME:GetString("SLPlayerOptions","Fail"),
THEME:GetString("SLPlayerOptions","Restart"),
}

for i=1,#TargetActions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."TargetAction"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods4")
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
				PastWidth = self:GetParent():GetChild(pn.."TargetAction"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."TargetAction"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(TargetActions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local PlayerTargetAction = mods.ActionOnMissedTarget or "Nothing"
local ActionNumber

if PlayerTargetAction == "Nothing" then
	ActionNumber = 1
elseif PlayerTargetAction == "Fail" then
	ActionNumber = 2
elseif PlayerTargetAction == "Restart" then
	ActionNumber = 3
end

--- TargetAction Selector
af[#af+1] = Def.Quad{
	Name=pn.."TargetActionSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."TargetAction"..ActionNumber)
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab == 3 and CurrentRow == 4 then
			if CurrentColumn == 1 then
				ActionNumber = 1
				mods.ActionOnMissedTarget = "Nothing"
			elseif CurrentColumn == 2 then
				ActionNumber = 2
				mods.ActionOnMissedTarget = "Fail"
			elseif CurrentColumn == 3 then
				ActionNumber = 3
				mods.ActionOnMissedTarget = "Restart"
			end
			local Parent = self:GetParent():GetChild(pn.."TargetAction"..CurrentColumn)
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
		if CurrentTab ~= 3 then return end
		for j=1,#TargetActions do
			local Parent = self:GetParent():GetChild(pn.."TargetAction"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
				if j == 1 then
					if CurrentRow ~= 4 and ActionNumber == 1 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ActionNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 1
					ActionNumber = 1
					mods.ActionOnMissedTarget = "Nothing"
				elseif j == 2 then
					if CurrentRow ~= 4 and ActionNumber == 2 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ActionNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 2
					ActionNumber = 2
					mods.ActionOnMissedTarget = "Fail"
				elseif j == 3 then
					if CurrentRow ~= 4 and ActionNumber == 3 then
						if CurrentRow < 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 4 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ActionNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 4
					CurrentColumn = 3
					ActionNumber = 3
					mods.ActionOnMissedTarget = "Restart"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."TargetAction"..CurrentColumn)
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
--- Gameplay Extras 1
local GameplayExtras ={
THEME:GetString("SLPlayerOptions","ColumnFlashOnMiss"),
THEME:GetString("SLPlayerOptions","SubtractiveScoring"),
}

local GameplayExtras2 ={
THEME:GetString("SLPlayerOptions","Pacemaker"),
THEME:GetString("SLPlayerOptions","NPSGraphAtTop"),
}

for i=1,#GameplayExtras do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."GameplayExtra"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods5")
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
				PastWidth = self:GetParent():GetChild(pn.."GameplayExtra"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."GameplayExtra"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(GameplayExtras[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Extras Boxes 1
for i=1,#GameplayExtras do
	af[#af+1] = Def.Quad{
		Name=pn.."_1ExtraBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods5")
			local TextZoom = self:GetParent():GetChild(pn.."GameplayExtra"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."GameplayExtra"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."GameplayExtra"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local ColumnFlashOnMiss = mods.ColumnFlashOnMiss or false
local SubtractiveScoring = mods.SubtractiveScoring or false

--- Gameplay Extras Check Boxes 1
for i=1,#GameplayExtras do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Extras1Check"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."_1ExtraBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if ColumnFlashOnMiss then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if SubtractiveScoring then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 5 then
				if CurrentColumn == 1 and i == 1 then
					if ColumnFlashOnMiss then
						ColumnFlashOnMiss = false
						mods.ColumnFlashOnMiss = ColumnFlashOnMiss
						self:settext("")
					elseif not ColumnFlashOnMiss then
						ColumnFlashOnMiss = true
						mods.ColumnFlashOnMiss = ColumnFlashOnMiss
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if SubtractiveScoring then
						SubtractiveScoring = false
						mods.SubtractiveScoring = SubtractiveScoring
						self:settext("")
					elseif not SubtractiveScoring then
						SubtractiveScoring = true
						mods.SubtractiveScoring = SubtractiveScoring
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #GameplayExtras do
				local Parent = self:GetParent():GetChild(pn.."_1ExtraBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 5
						CurrentColumn = 1
						if ColumnFlashOnMiss then
							ColumnFlashOnMiss = false
							mods.ColumnFlashOnMiss = ColumnFlashOnMiss
							self:settext("")
						elseif not ColumnFlashOnMiss then
							ColumnFlashOnMiss = true
							mods.ColumnFlashOnMiss = ColumnFlashOnMiss
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 5
						CurrentColumn = 2
						if SubtractiveScoring then
							SubtractiveScoring = false
							mods.SubtractiveScoring = SubtractiveScoring
							self:settext("")
						elseif not SubtractiveScoring then
							SubtractiveScoring = true
							mods.SubtractiveScoring = SubtractiveScoring
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

for i=1,#GameplayExtras2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."GameplayExtra2_"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods6")
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
				PastWidth = self:GetParent():GetChild(pn.."GameplayExtra2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."GameplayExtra2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(GameplayExtras2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Extras Boxes 2
for i=1,#GameplayExtras2 do
	af[#af+1] = Def.Quad{
		Name=pn.."_2ExtraBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods6")
			local TextZoom = self:GetParent():GetChild(pn.."GameplayExtra2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."GameplayExtra2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."GameplayExtra2_"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Pacemaker = mods.Pacemaker or false
local NPSGraphAtTop = mods.NPSGraphAtTop or false

--- Gameplay Extras Check Boxes 2
for i=1,#GameplayExtras2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Extras2Check"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."_2ExtraBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Pacemaker then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if NPSGraphAtTop then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 6 then
				if CurrentColumn == 1 and i == 1 then
					if Pacemaker then
						Pacemaker = false
						mods.Pacemaker = Pacemaker
						self:settext("")
					elseif not Pacemaker then
						Pacemaker = true
						mods.Pacemaker = Pacemaker
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if NPSGraphAtTop then
						NPSGraphAtTop = false
						mods.NPSGraphAtTop = NPSGraphAtTop
						self:settext("")
					elseif not NPSGraphAtTop then
						NPSGraphAtTop = true
						mods.NPSGraphAtTop = NPSGraphAtTop
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #GameplayExtras2 do
				local Parent = self:GetParent():GetChild(pn.."_2ExtraBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 6
						CurrentColumn = 1
						if Pacemaker then
							Pacemaker = false
							mods.Pacemaker = Pacemaker
							self:settext("")
						elseif not Pacemaker then
							Pacemaker = true
							mods.Pacemaker = Pacemaker
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 6
						CurrentColumn = 2
						if NPSGraphAtTop then
							NPSGraphAtTop = false
							mods.NPSGraphAtTop = NPSGraphAtTop
							self:settext("")
						elseif not NPSGraphAtTop then
							NPSGraphAtTop = true
							mods.NPSGraphAtTop = NPSGraphAtTop
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

-- Error. Bars?
local ErrorBars={
THEME:GetString("SLPlayerOptions","None"),
THEME:GetString("SLPlayerOptions","Colorful"),
THEME:GetString("SLPlayerOptions","Monochrome"),
THEME:GetString("SLPlayerOptions","Text"),
}

for i=1,#ErrorBars do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."ErrorBar"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods7")
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
				PastWidth = self:GetParent():GetChild(pn.."ErrorBar"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."ErrorBar"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(ErrorBars[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local PlayerErrorBar = mods.ErrorBar or "None"
local ErrorBarNumber

if PlayerErrorBar == "None" then
	ErrorBarNumber = 1
elseif PlayerErrorBar == "Colorful" then
	ErrorBarNumber = 2
elseif PlayerErrorBar == "Monochrome" then
	ErrorBarNumber = 3
elseif PlayerErrorBar == "Text" then
	ErrorBarNumber = 4
end

--- ErrorBar Selector
af[#af+1] = Def.Quad{
	Name=pn.."ErrorBarSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."ErrorBar"..ErrorBarNumber)
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab == 3 and CurrentRow == 7 then
			if CurrentColumn == 1 then
				ErrorBarNumber = 1
				mods.ErrorBar = "None"
			elseif CurrentColumn == 2 then
				ErrorBarNumber = 2
				mods.ErrorBar = "Colorful"
			elseif CurrentColumn == 3 then
				ErrorBarNumber = 3
				mods.ErrorBar = "Monochrome"
			elseif CurrentColumn == 4 then
				ErrorBarNumber = 4
				mods.ErrorBar = "Text"
			end
			local Parent = self:GetParent():GetChild(pn.."ErrorBar"..CurrentColumn)
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
		if CurrentTab ~= 3 then return end
		for j=1,#ErrorBars do
			local Parent = self:GetParent():GetChild(pn.."ErrorBar"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
				if j == 1 then
					if CurrentRow ~= 7 and ErrorBarNumber == 1 then
						if CurrentRow < 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ErrorBarNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 7
					CurrentColumn = 1
					ErrorBarNumber = 1
					mods.ErrorBar = "None"
				elseif j == 2 then
					if CurrentRow ~= 7 and ErrorBarNumber == 2 then
						if CurrentRow < 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ErrorBarNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 7
					CurrentColumn = 2
					ErrorBarNumber = 2
					mods.ErrorBar = "Colorful"
				elseif j == 3 then
					if CurrentRow ~= 7 and ErrorBarNumber == 3 then
						if CurrentRow < 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ErrorBarNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 7
					CurrentColumn = 3
					ErrorBarNumber = 3
					mods.ErrorBar = "Monochrome"
				elseif j == 4 then
					if CurrentRow ~= 7 and ErrorBarNumber == 4 then
						if CurrentRow < 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 7 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif ErrorBarNumber ~= 4 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 7
					CurrentColumn = 4
					ErrorBarNumber = 4
					mods.ErrorBar = "Text"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."ErrorBar"..CurrentColumn)
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

-- Error Bar Options
local ErrorBarOptions={
THEME:GetString("SLPlayerOptions","ErrorBarUp"),
THEME:GetString("SLPlayerOptions","ErrorBarMultiTick"),
THEME:GetString("SLPlayerOptions","ErrorBarTrim"),
}

for i=1,#ErrorBarOptions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."ErrorBarOption"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods8")
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
				PastWidth = self:GetParent():GetChild(pn.."ErrorBarOption"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."ErrorBarOption"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(ErrorBarOptions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Error Bar Options Boxes
for i=1,#ErrorBarOptions do
	af[#af+1] = Def.Quad{
		Name=pn.."ErrorBarOptionsBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods8")
			local TextZoom = self:GetParent():GetChild(pn.."ErrorBarOption"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."ErrorBarOption"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."ErrorBarOption"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local ErrorBarUp = mods.ErrorBarUp or false
local ErrorBarMultiTick = mods.ErrorBarMultiTick or false
local ErrorBarTrim = mods.ErrorBarTrim or false

--- ErrorBar Options Check Boxes 2
for i=1,#ErrorBarOptions do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."ErrorCheck"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."ErrorBarOptionsBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if ErrorBarUp then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if ErrorBarMultiTick then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if ErrorBarTrim then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 8 then
				if CurrentColumn == 1 and i == 1 then
					if ErrorBarUp then
						ErrorBarUp = false
						mods.ErrorBarUp = ErrorBarUp
						self:settext("")
					elseif not ErrorBarUp then
						ErrorBarUp = true
						mods.ErrorBarUp = ErrorBarUp
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if ErrorBarMultiTick then
						ErrorBarMultiTick = false
						mods.ErrorBarMultiTick = ErrorBarMultiTick
						self:settext("")
					elseif not ErrorBarMultiTick then
						ErrorBarMultiTick = true
						mods.ErrorBarMultiTick = ErrorBarMultiTick
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if ErrorBarTrim then
						ErrorBarTrim = false
						mods.ErrorBarTrim = ErrorBarTrim
						self:settext("")
					elseif not ErrorBarTrim then
						ErrorBarTrim = true
						mods.ErrorBarTrim = ErrorBarTrim
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #ErrorBarOptions do
				local Parent = self:GetParent():GetChild(pn.."ErrorBarOptionsBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 8
						CurrentColumn = 1
						if ErrorBarUp then
							ErrorBarUp = false
							mods.ErrorBarUp = ErrorBarUp
							self:settext("")
						elseif not ErrorBarUp then
							ErrorBarUp = true
							mods.ErrorBarUp = ErrorBarUp
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 8
						CurrentColumn = 2
						if ErrorBarMultiTick then
							ErrorBarMultiTick = false
							mods.ErrorBarMultiTick = ErrorBarMultiTick
							self:settext("")
						elseif not ErrorBarMultiTick then
							ErrorBarMultiTick = true
							mods.ErrorBarMultiTick = ErrorBarMultiTick
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 8
						CurrentColumn = 3
						if ErrorBarTrim then
							ErrorBarTrim = false
							mods.ErrorBarTrim = ErrorBarTrim
							self:settext("")
						elseif not ErrorBarTrim then
							ErrorBarTrim = true
							mods.ErrorBarTrim = ErrorBarTrim
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

-- MeasureCounter
local MeasureCounter={
THEME:GetString("SLPlayerOptions","None"),
THEME:GetString("SLPlayerOptions","8th"),
THEME:GetString("SLPlayerOptions","12th"),
THEME:GetString("SLPlayerOptions","16th"),
THEME:GetString("SLPlayerOptions","24th"),
THEME:GetString("SLPlayerOptions","32nd"),
}

for i=1,#MeasureCounter do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."MeasureCounter"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods9")
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
				PastWidth = self:GetParent():GetChild(pn.."MeasureCounter"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."MeasureCounter"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(MeasureCounter[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local PlayerMeasureCounter = mods.MeasureCounter or "None"
local MeasureCounterNumber

if PlayerMeasureCounter == "None" then
	MeasureCounterNumber = 1
elseif PlayerMeasureCounter == "8th" then
	MeasureCounterNumber = 2
elseif PlayerMeasureCounter == "12th" then
	MeasureCounterNumber = 3
elseif PlayerMeasureCounter == "16th" then
	MeasureCounterNumber = 4
elseif PlayerMeasureCounter == "24th" then
	MeasureCounterNumber = 5
elseif PlayerMeasureCounter == "32nd" then
	MeasureCounterNumber = 6
end


--- MeasureCounter Selector
af[#af+1] = Def.Quad{
	Name=pn.."MeasureCounterSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."MeasureCounter"..MeasureCounterNumber)
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab == 3 and CurrentRow == 9 then
			if CurrentColumn == 1 then
				MeasureCounterNumber = 1
				mods.MeasureCounter = "None"
			elseif CurrentColumn == 2 then
				MeasureCounterNumber = 2
				mods.MeasureCounter = "8th"
			elseif CurrentColumn == 3 then
				MeasureCounterNumber = 3
				mods.MeasureCounter = "12th"
			elseif CurrentColumn == 4 then
				MeasureCounterNumber = 4
				mods.MeasureCounter = "16th"
			elseif CurrentColumn == 5 then
				MeasureCounterNumber = 5
				mods.MeasureCounter = "24th"
			elseif CurrentColumn == 6 then
				MeasureCounterNumber = 6
				mods.MeasureCounter = "32nd"
			end
			local Parent = self:GetParent():GetChild(pn.."MeasureCounter"..CurrentColumn)
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
		if CurrentTab ~= 3 then return end
		for j=1,#MeasureCounter do
			local Parent = self:GetParent():GetChild(pn.."MeasureCounter"..j)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
				if j == 1 then
					if CurrentRow ~= 9 and MeasureCounterNumber == 1 then
						if CurrentRow < 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif MeasureCounterNumber ~= 1 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 9
					CurrentColumn = 1
					MeasureCounterNumber = 1
					mods.MeasureCounter = "None"
				elseif j == 2 then
					if CurrentRow ~= 9 and MeasureCounterNumber == 2 then
						if CurrentRow < 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif MeasureCounterNumber ~= 2 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 9
					CurrentColumn = 2
					MeasureCounterNumber = 2
					mods.MeasureCounter = "8th"
				elseif j == 3 then
					if CurrentRow ~= 9 and MeasureCounterNumber == 3 then
						if CurrentRow < 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif MeasureCounterNumber ~= 3 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 9
					CurrentColumn = 3
					MeasureCounterNumber = 3
					mods.MeasureCounter = "12th"
				elseif j == 4 then
					if CurrentRow ~= 9 and MeasureCounterNumber == 4 then
						if CurrentRow < 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif MeasureCounterNumber ~= 4 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 9
					CurrentColumn = 4
					MeasureCounterNumber = 4
					mods.MeasureCounter = "16th"
				elseif j == 5 then
					if CurrentRow ~= 9 and MeasureCounterNumber == 5 then
						if CurrentRow < 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif MeasureCounterNumber ~= 5 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 9
					CurrentColumn = 5
					MeasureCounterNumber = 5
					mods.MeasureCounter = "24th"
				elseif j == 6 then
					if CurrentRow ~= 9 and MeasureCounterNumber == 6 then
						if CurrentRow < 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 9 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					elseif MeasureCounterNumber ~= 6 then
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					end
					CurrentRow = 9
					CurrentColumn = 6
					MeasureCounterNumber = 6
					mods.MeasureCounter = "32nd"
				end
				MadeSelection = true
			end
		end
		if MadeSelection then
			local Parent2 = self:GetParent():GetChild(pn.."MeasureCounter"..CurrentColumn)
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

-- Measure Counter Options
local MeasureCounterOptions={
THEME:GetString("SLPlayerOptions","MeasureCounterLeft"),
THEME:GetString("SLPlayerOptions","MeasureCounterUp"),
THEME:GetString("SLPlayerOptions","HideLookahead"),
}

for i=1,#MeasureCounterOptions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."MeasureCounterOption"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods10")
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
				PastWidth = self:GetParent():GetChild(pn.."MeasureCounterOption"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."MeasureCounterOption"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(MeasureCounterOptions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- MeasureCounterOptions Boxes
for i=1,#MeasureCounterOptions do
	af[#af+1] = Def.Quad{
		Name=pn.."MCBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods10")
			local TextZoom = self:GetParent():GetChild(pn.."MeasureCounterOption"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."MeasureCounterOption"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."MeasureCounterOption"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local MeasureCounterLeft = mods.MeasureCounterLeft or false
local MeasureCounterUp = mods.MeasureCounterUp or false
local HideLookahead = mods.HideLookahead or false

--- MeasureCounterOptions Check Boxes
for i=1,#MeasureCounterOptions do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."MCOptionsCheck"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."MCBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if MeasureCounterLeft then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if MeasureCounterUp then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if HideLookahead then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 10 then
				if CurrentColumn == 1 and i == 1 then
					if MeasureCounterLeft then
						MeasureCounterLeft = false
						mods.MeasureCounterLeft = MeasureCounterLeft
						self:settext("")
					elseif not MeasureCounterLeft then
						MeasureCounterLeft = true
						mods.MeasureCounterLeft = MeasureCounterLeft
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if MeasureCounterUp then
						MeasureCounterUp = false
						mods.MeasureCounterUp = MeasureCounterUp
						self:settext("")
					elseif not MeasureCounterUp then
						MeasureCounterUp = true
						mods.MeasureCounterUp = MeasureCounterUp
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if HideLookahead then
						HideLookahead = false
						mods.HideLookahead = HideLookahead
						self:settext("")
					elseif not HideLookahead then
						HideLookahead = true
						mods.HideLookahead = HideLookahead
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #MeasureCounterOptions do
				local Parent = self:GetParent():GetChild(pn.."MCBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 10
						CurrentColumn = 1
						if MeasureCounterLeft then
							MeasureCounterLeft = false
							mods.MeasureCounterLeft = MeasureCounterLeft
							self:settext("")
						elseif not MeasureCounterLeft then
							MeasureCounterLeft = true
							mods.MeasureCounterLeft = MeasureCounterLeft
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 10
						CurrentColumn = 2
						if MeasureCounterUp then
							MeasureCounterUp = false
							mods.MeasureCounterUp = MeasureCounterUp
							self:settext("")
						elseif not MeasureCounterUp then
							MeasureCounterUp = true
							mods.MeasureCounterUp = MeasureCounterUp
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 10
						CurrentColumn = 3
						if HideLookahead then
							HideLookahead = false
							mods.HideLookahead = HideLookahead
							self:settext("")
						elseif not HideLookahead then
							HideLookahead = true
							mods.HideLookahead = HideLookahead
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

-- Early Decent/Wayoff Options
local EarlyRescoreOptions={
THEME:GetString("SLPlayerOptions","HideEarlyDecentWayOffJudgments"),
THEME:GetString("SLPlayerOptions","HideEarlyDecentWayOffFlash"),
}

for i=1,#EarlyRescoreOptions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."EarlyRescoreOption"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods11")
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
				PastWidth = self:GetParent():GetChild(pn.."EarlyRescoreOption"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."EarlyRescoreOption"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(EarlyRescoreOptions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Rescore Boxes
for i=1,#EarlyRescoreOptions do
	af[#af+1] = Def.Quad{
		Name=pn.."RescoreBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods11")
			local TextZoom = self:GetParent():GetChild(pn.."EarlyRescoreOption"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."EarlyRescoreOption"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."EarlyRescoreOption"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local HideEarlyDecentWayOffJudgments = mods.HideEarlyDecentWayOffJudgments or false
local HideEarlyDecentWayOffFlash = mods.HideEarlyDecentWayOffFlash or false

--- Rescore Check Boxes
for i=1,#EarlyRescoreOptions do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."MCOptionsCheck"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."RescoreBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if HideEarlyDecentWayOffJudgments then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if HideEarlyDecentWayOffFlash then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 11 then
				if CurrentColumn == 1 and i == 1 then
					if HideEarlyDecentWayOffJudgments then
						HideEarlyDecentWayOffJudgments = false
						mods.HideEarlyDecentWayOffJudgments = HideEarlyDecentWayOffJudgments
						self:settext("")
					elseif not HideEarlyDecentWayOffJudgments then
						HideEarlyDecentWayOffJudgments = true
						mods.HideEarlyDecentWayOffJudgments = HideEarlyDecentWayOffJudgments
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if HideEarlyDecentWayOffFlash then
						HideEarlyDecentWayOffFlash = false
						mods.HideEarlyDecentWayOffFlash = HideEarlyDecentWayOffFlash
						self:settext("")
					elseif not HideEarlyDecentWayOffFlash then
						HideEarlyDecentWayOffFlash = true
						mods.HideEarlyDecentWayOffFlash = HideEarlyDecentWayOffFlash
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #EarlyRescoreOptions do
				local Parent = self:GetParent():GetChild(pn.."RescoreBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 11
						CurrentColumn = 1
						if HideEarlyDecentWayOffJudgments then
							HideEarlyDecentWayOffJudgments = false
							mods.HideEarlyDecentWayOffJudgments = HideEarlyDecentWayOffJudgments
							self:settext("")
						elseif not HideEarlyDecentWayOffJudgments then
							HideEarlyDecentWayOffJudgments = true
							mods.HideEarlyDecentWayOffJudgments = HideEarlyDecentWayOffJudgments
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 11
						CurrentColumn = 2
						if HideEarlyDecentWayOffFlash then
							HideEarlyDecentWayOffFlash = false
							mods.HideEarlyDecentWayOffFlash = HideEarlyDecentWayOffFlash
							self:settext("")
						elseif not HideEarlyDecentWayOffFlash then
							HideEarlyDecentWayOffFlash = true
							mods.HideEarlyDecentWayOffFlash = HideEarlyDecentWayOffFlash
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

-- FA+ Options
local FAPlusOptions={
THEME:GetString("SLPlayerOptions","ShowFaPlusWindow"),
THEME:GetString("SLPlayerOptions","ShowEXScore"),
}

for i=1,#FAPlusOptions do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."FAPlusOption"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods12")
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
				PastWidth = self:GetParent():GetChild(pn.."FAPlusOption"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."FAPlusOption"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(FAPlusOptions[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- FAPlus Boxes
for i=1,#FAPlusOptions do
	af[#af+1] = Def.Quad{
		Name=pn.."FAPlusBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods12")
			local TextZoom = self:GetParent():GetChild(pn.."FAPlusOption"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."FAPlusOption"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."FAPlusOption"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


local ShowFaPlusWindow = mods.ShowFaPlusWindow or false
local ShowEXScore = mods.ShowEXScore or false


--- FAPlusCheck Boxes
for i=1,#FAPlusOptions do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."FAPlusCheck"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."FAPlusBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if ShowFaPlusWindow then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if ShowEXScore then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 12 then
				if CurrentColumn == 1 and i == 1 then
					if ShowFaPlusWindow then
						ShowFaPlusWindow = false
						mods.ShowFaPlusWindow = ShowFaPlusWindow
						self:settext("")
					elseif not ShowFaPlusWindow then
						ShowFaPlusWindow = true
						mods.ShowFaPlusWindow = ShowFaPlusWindow
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					MESSAGEMAN:Broadcast("UpdateGhostWindow")
				elseif CurrentColumn == 2 and i == 2 then
					if ShowEXScore then
						ShowEXScore = false
						mods.ShowEXScore = ShowEXScore
						self:settext("")
					elseif not ShowEXScore then
						ShowEXScore = true
						mods.ShowEXScore = ShowEXScore
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					MESSAGEMAN:Broadcast("UpdateGhostWindow")
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #FAPlusOptions do
				local Parent = self:GetParent():GetChild(pn.."FAPlusBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 12
						CurrentColumn = 1
						if ShowFaPlusWindow then
							ShowFaPlusWindow = false
							mods.ShowFaPlusWindow = ShowFaPlusWindow
							self:settext("")
						elseif not ShowFaPlusWindow then
							ShowFaPlusWindow = true
							mods.ShowFaPlusWindow = ShowFaPlusWindow
							self:settext("✅")
						end
						MESSAGEMAN:Broadcast("UpdateGhostWindow")
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 12
						CurrentColumn = 2
						if ShowEXScore then
							ShowEXScore = false
							mods.ShowEXScore = ShowEXScore
							self:settext("")
						elseif not ShowEXScore then
							ShowEXScore = true
							mods.ShowEXScore = ShowEXScore
							self:settext("✅")
						end
						MESSAGEMAN:Broadcast("UpdateGhostWindow")
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

-- Column Cues Box
af[#af+1] = Def.Quad{
	Name=pn.."ColumnCuesBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."AdvancedMods13")
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
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		if CurrentTab ~= 3 then return end
		local Parent = self:GetParent():GetChild(pn.."ColumnCuesBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
			if CurrentRow ~= 13 then
				if CurrentRow < 13 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 13 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
			CurrentRow = 13
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

local PlayerColumnCue = tonumber(GetPlayerMod(pn, "ColumnCueTime"))
local MinColumnCue = 0
local MaxColumnCue = 5
local CueText

--- ColumnCue Value
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."ColumnCueText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."AdvancedMods13")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."ColumnCuesBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."ColumnCuesBox1"):GetX()
		local TextYPosition = Parent:GetY()
		if PlayerColumnCue == 0 then
			CueText = "Off"
		else
			CueText = PlayerColumnCue
		end
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:settext(PlayerColumnCue == 0 and CueText or PlayerColumnCue.."s")
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 3 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 3 then
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
		
		if CurrentTab == 3 and CurrentRow == 13 then
			if params[1] == "left" then
				if PlayerColumnCue <= MinColumnCue then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerColumnCue = MaxColumnCue
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerColumnCue = round(PlayerColumnCue - 0.1, 1)
				end
				if PlayerColumnCue == 0 then
					CueText = "Off"
				else
					CueText = PlayerColumnCue
				end
				SetPlayerMod(pn, "ColumnCueTime", PlayerColumnCue)
				self:settext(PlayerColumnCue == 0 and CueText or PlayerColumnCue.."s")
			elseif params[1] == "right" then
				if PlayerColumnCue >= MaxColumnCue then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerColumnCue = MinColumnCue
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerColumnCue = round(PlayerColumnCue + 0.1, 1)
				end
				if PlayerColumnCue == 0 then
					CueText = "Off"
				else
					CueText = PlayerColumnCue
				end
				SetPlayerMod(pn, "ColumnCueTime", PlayerColumnCue)
				self:settext(PlayerColumnCue == 0 and CueText or PlayerColumnCue.."s")
			end
		end
	end,
}

--- Column Cues Extras
local ColumnCueExtras={
THEME:GetString("SLPlayerOptions","CueMines"),
THEME:GetString("SLPlayerOptions","IgnoreHoldsRolls"),
}

local ColumnCueExtras2={
THEME:GetString("SLPlayerOptions","IgnoreNotes"),
THEME:GetString("SLPlayerOptions","CountdownBreaks"),
}

for i=1,#ColumnCueExtras do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."ColumnCueExtra"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods14")
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
				PastWidth = self:GetParent():GetChild(pn.."ColumnCueExtra"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."ColumnCueExtra"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(ColumnCueExtras[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- CC Extra Boxes1
for i=1,#ColumnCueExtras do
	af[#af+1] = Def.Quad{
		Name=pn.."CCBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods14")
			local TextZoom = self:GetParent():GetChild(pn.."ColumnCueExtra"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."ColumnCueExtra"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."ColumnCueExtra"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local CueMines = mods.CueMines or false
local IgnoreHoldsRolls = mods.IgnoreHoldsRolls or false

--- CC Extra Check Boxes
for i=1,#ColumnCueExtras do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."CCExtra1Check"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."CCBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if CueMines then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if IgnoreHoldsRolls then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 14 then
				if CurrentColumn == 1 and i == 1 then
					if CueMines then
						CueMines = false
						mods.CueMines = CueMines
						self:settext("")
					elseif not CueMines then
						CueMines = true
						mods.CueMines = CueMines
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if IgnoreHoldsRolls then
						IgnoreHoldsRolls = false
						mods.IgnoreHoldsRolls = IgnoreHoldsRolls
						self:settext("")
					elseif not IgnoreHoldsRolls then
						IgnoreHoldsRolls = true
						mods.IgnoreHoldsRolls = IgnoreHoldsRolls
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #ColumnCueExtras do
				local Parent = self:GetParent():GetChild(pn.."CCBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 14
						CurrentColumn = 1
						if CueMines then
							CueMines = false
							mods.CueMines = CueMines
							self:settext("")
						elseif not CueMines then
							CueMines = true
							mods.CueMines = CueMines
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 14
						CurrentColumn = 2
						if IgnoreHoldsRolls then
							IgnoreHoldsRolls = false
							mods.IgnoreHoldsRolls = IgnoreHoldsRolls
							self:settext("")
						elseif not IgnoreHoldsRolls then
							IgnoreHoldsRolls = true
							mods.IgnoreHoldsRolls = IgnoreHoldsRolls
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

for i=1,#ColumnCueExtras2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."ColumnCueExtra2_"..i,
		InitCommand=function(self)
			local zoom = 0.55
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods15")
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
				PastWidth = self:GetParent():GetChild(pn.."ColumnCueExtra2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."ColumnCueExtra2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(ColumnCueExtras2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- CC Extra Boxes1
for i=1,#ColumnCueExtras do
	af[#af+1] = Def.Quad{
		Name=pn.."CCBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."AdvancedMods15")
			local TextZoom = self:GetParent():GetChild(pn.."ColumnCueExtra2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."ColumnCueExtra2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."ColumnCueExtra2_"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.25)
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IgnoreNotes = mods.IgnoreNotes or false
local CountdownBreaks = mods.CountdownBreaks or false

--- CC Extra Check Boxes
for i=1,#ColumnCueExtras2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."CCExtra2Check"..i,
		InitCommand=function(self)
			local zoom = 0.366
			local Parent = self:GetParent():GetChild(pn.."CCBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if IgnoreNotes then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if CountdownBreaks then
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
				if CurrentTabP1 == 3 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 3 then
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
			if CurrentTab == 3 and CurrentRow == 15 then
				if CurrentColumn == 1 and i == 1 then
					if IgnoreNotes then
						IgnoreNotes = false
						mods.IgnoreNotes = IgnoreNotes
						self:settext("")
					elseif not IgnoreNotes then
						IgnoreNotes = true
						mods.IgnoreNotes = IgnoreNotes
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if CountdownBreaks then
						CountdownBreaks = false
						mods.CountdownBreaks = CountdownBreaks
						self:settext("")
					elseif not CountdownBreaks then
						CountdownBreaks = true
						mods.CountdownBreaks = CountdownBreaks
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
			if CurrentTab ~= 3 then return end
			-- yooooooo the j!!!!
			for j=1, #ColumnCueExtras2 do
				local Parent = self:GetParent():GetChild(pn.."CCBox2_"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 3 then
					if j == 1 and j == i then
						CurrentRow = 15
						CurrentColumn = 1
						if IgnoreNotes then
							IgnoreNotes = false
							mods.IgnoreNotes = IgnoreNotes
							self:settext("")
						elseif not IgnoreNotes then
							IgnoreNotes = true
							mods.IgnoreNotes = IgnoreNotes
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 15
						CurrentColumn = 2
						if CountdownBreaks then
							CountdownBreaks = false
							mods.CountdownBreaks = CountdownBreaks
							self:settext("")
						elseif not CountdownBreaks then
							CountdownBreaks = true
							mods.CountdownBreaks = CountdownBreaks
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

-------------------------------------------------------------
local Mod3Descriptions = {
THEME:GetString("OptionExplanations","LifeMeterType"),
THEME:GetString("OptionExplanations","DataVisualizations"),
THEME:GetString("OptionExplanations","TargetScore"),
THEME:GetString("OptionExplanations","ActionOnMissedTarget"),
THEME:GetString("OptionExplanations","GameplayExtras"),
THEME:GetString("OptionExplanations","GameplayExtras"),
THEME:GetString("OptionExplanations","ErrorBar"),
THEME:GetString("OptionExplanations","ErrorBarOptions"),
THEME:GetString("OptionExplanations","MeasureCounter"),
THEME:GetString("OptionExplanations","MeasureCounterOptions"),
THEME:GetString("OptionExplanations","TimingWindowOptions"),
THEME:GetString("OptionExplanations","FaPlus"),
THEME:GetString("OptionExplanations","ColumnCues"),
THEME:GetString("OptionExplanations","ColumnCueExtras"),
THEME:GetString("OptionExplanations","ColumnCueExtras"),
}

-- Bottom Information for mods
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."Mod3Descriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(Mod3Descriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 or CurrentTabP1 ~= 3 then
				self:visible(false)
			else
				self:settext(Mod3Descriptions[CurrentRowP1])
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0  or CurrentTabP2 ~= 3 then
				self:visible(false)
				
			else
				self:settext(Mod3Descriptions[CurrentRowP2])
				self:visible(true)
			end
		end
	end,
}