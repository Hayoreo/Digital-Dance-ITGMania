--- Here is all the info necessary for Tab 4
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

local UncommonModsNames = {
THEME:GetString("OptionTitles","Insert"),
THEME:GetString("OptionTitles","Insert"),
THEME:GetString("OptionTitles","Remove"),
THEME:GetString("OptionTitles","Remove"),
THEME:GetString("OptionTitles","Holds"),
THEME:GetString("OptionTitles","Holds"),
THEME:GetString("OptionTitles","Accel"),
THEME:GetString("OptionTitles","Accel"),
THEME:GetString("OptionTitles","Effect"),
"",
THEME:GetString("OptionTitles","Appearance"),
THEME:GetString("OptionTitles","Attacks"),
THEME:GetString("OptionNames","Haste"),
}

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

for i=1, #UncommonModsNames do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."UncommonMods"..i,
		InitCommand=function(self)
			local zoom = 0.7
			self:horizalign(left):vertalign(top):shadowlength(1)
				:draworder(1)
				:diffuse(color("#b0b0b0"))
				:x(XPos + padding/2 + border*2)
				:y(YPos - height/2 + border + (i*20) + 10)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(i ~= 10 and UncommonModsNames[i]..":" or UncommonModsNames[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Insert mods/boxes
local InsertMods={
THEME:GetString("OptionNames","Wide"),
THEME:GetString("OptionNames","Big"),
THEME:GetString("OptionNames","Quick"),
THEME:GetString("OptionNames","BMRize"),
}

--- Insert mods/boxes
local InsertMods2={
THEME:GetString("OptionNames","Skippy"),
THEME:GetString("OptionNames","Echo"),
THEME:GetString("OptionNames","Stomp"),
}

for i=1,#InsertMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."InsertMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods1")
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
				PastWidth = self:GetParent():GetChild(pn.."InsertMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."InsertMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(InsertMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Insert Boxes 1
for i=1,#InsertMods do
	af[#af+1] = Def.Quad{
		Name=pn.."InsertBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods1")
			local TextZoom = self:GetParent():GetChild(pn.."InsertMod"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."InsertMod"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."InsertMod"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IsWide = PlayerState:GetPlayerOptions(0):Wide()
local IsBig = PlayerState:GetPlayerOptions(0):Big()
local IsQuick = PlayerState:GetPlayerOptions(0):Quick()
local IsBMRize = PlayerState:GetPlayerOptions(0):BMRize()

--- Insert 1 check boxes
for i=1,#InsertMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Insert1Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."InsertBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if IsWide == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if IsBig == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if IsQuick == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if IsBMRize == true then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 1 then
				if CurrentColumn == 1 and i == 1 then
					if IsWide == true then
						IsWide = false
						SetEngineMod(player, "Wide", false)
						self:settext("")
					elseif IsWide == false then
						IsWide = true
						SetEngineMod(player, "Wide", true)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if IsBig then
						IsBig = false
						SetEngineMod(player, "Big", false)
						self:settext("")
					elseif not IsBig then
						IsBig = true
						SetEngineMod(player, "Big", true)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if IsQuick then
						IsQuick = false
						SetEngineMod(player, "Quick", false)
						self:settext("")
					elseif not IsQuick then
						IsQuick = true
						SetEngineMod(player, "Quick", true)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if IsBMRize then
						IsBMRize = false
						SetEngineMod(player, "BMRize", false)
						self:settext("")
					elseif not IsBMRize then
						IsBMRize = true
						SetEngineMod(player, "BMRize", true)
						self:settext("✅")
					end
				end
			end
		end,
	}
end



-- Insert mods 2
for i=1,#InsertMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."InsertMod2_"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods2")
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
				PastWidth = self:GetParent():GetChild(pn.."InsertMod2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."InsertMod2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(InsertMods2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


--- insert boxes 2
for i=1,#InsertMods2 do
	af[#af+1] = Def.Quad{
		Name=pn.."InsertBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods2")
			local TextZoom = self:GetParent():GetChild(pn.."InsertMod2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."InsertMod2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."InsertMod2_"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


local IsSkippy = PlayerState:GetPlayerOptions(0):Skippy()
local IsEcho = PlayerState:GetPlayerOptions(0):Echo()
local IsStomp = PlayerState:GetPlayerOptions(0):Stomp()

--- Insert 2 check boxes
for i=1,#InsertMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Insert2Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."InsertBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if IsSkippy == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if IsEcho == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if IsStomp == true then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 2 then
				if CurrentColumn == 1 and i == 1 then
					if IsSkippy == true then
						IsSkippy = false
						SetEngineMod(player, "Skippy", IsSkippy)
						self:settext("")
					elseif IsSkippy == false then
						IsSkippy = true
						SetEngineMod(player, "Skippy", IsSkippy)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if IsEcho then
						IsEcho = false
						SetEngineMod(player, "Echo", IsEcho)
						self:settext("")
					elseif not IsEcho then
						IsEcho = true
						SetEngineMod(player, "Echo", IsEcho)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if IsStomp then
						IsStomp = false
						SetEngineMod(player, "Stomp", IsStomp)
						self:settext("")
					elseif not IsStomp then
						IsStomp = true
						SetEngineMod(player, "Stomp", IsStomp)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

--- Remove Mods
local RemoveMods={
THEME:GetString("OptionNames","Little"),
THEME:GetString("OptionNames","NoMines"),
THEME:GetString("OptionNames","NoHolds"),
THEME:GetString("OptionNames","NoJumps"),
}

--- Remove Mods
local RemoveMods2={
THEME:GetString("OptionNames","NoHands"),
THEME:GetString("OptionNames","NoQuads"),
THEME:GetString("OptionNames","NoLifts"),
THEME:GetString("OptionNames","NoFakes"),
}

--- Remove mods 1
for i=1,#RemoveMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."RemoveMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods3")
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
				PastWidth = self:GetParent():GetChild(pn.."RemoveMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."RemoveMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(RemoveMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- remove boxes 1
for i=1,#RemoveMods do
	af[#af+1] = Def.Quad{
		Name=pn.."RemoveBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods3")
			local TextZoom = self:GetParent():GetChild(pn.."RemoveMod"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."RemoveMod"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."RemoveMod"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Little = PlayerState:GetPlayerOptions(0):Little()
local NoMines = PlayerState:GetPlayerOptions(0):NoMines()
local NoHolds = PlayerState:GetPlayerOptions(0):NoHolds()
local NoJumps = PlayerState:GetPlayerOptions(0):NoJumps()

--- Remove 1 check boxes
for i=1,#RemoveMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Remove1Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."RemoveBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Little == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if NoMines == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if NoHolds == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if NoJumps == true then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 3 then
				if CurrentColumn == 1 and i == 1 then
					if Little == true then
						Little = false
						SetEngineMod(player, "Little", Little)
						self:settext("")
					elseif Little == false then
						Little = true
						SetEngineMod(player, "Little", Little)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if NoMines then
						NoMines = false
						SetEngineMod(player, "NoMines", NoMines)
						self:settext("")
					elseif not NoMines then
						NoMines = true
						SetEngineMod(player, "NoMines", NoMines)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if NoHolds then
						NoHolds = false
						SetEngineMod(player, "NoHolds", NoHolds)
						self:settext("")
					elseif not NoHolds then
						NoHolds = true
						SetEngineMod(player, "NoHolds", NoHolds)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if NoJumps then
						NoJumps = false
						SetEngineMod(player, "NoJumps", NoJumps)
						self:settext("")
					elseif not NoJumps then
						NoJumps = true
						SetEngineMod(player, "NoJumps", NoJumps)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

--- Remove mods 2
for i=1,#RemoveMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."RemoveMod2_"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods4")
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
				PastWidth = self:GetParent():GetChild(pn.."RemoveMod2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."RemoveMod2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(RemoveMods2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


-- remove mods boxes 2
for i=1,#RemoveMods2 do
	af[#af+1] = Def.Quad{
		Name=pn.."RemoveBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods4")
			local TextZoom = self:GetParent():GetChild(pn.."RemoveMod2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."RemoveMod2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."RemoveMod2_"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local NoHands = PlayerState:GetPlayerOptions(0):NoHands()
local NoQuads = PlayerState:GetPlayerOptions(0):NoQuads()
local NoLifts = PlayerState:GetPlayerOptions(0):NoLifts()
local NoFakes = PlayerState:GetPlayerOptions(0):NoFakes()

--- Remove 2 check boxes
for i=1,#RemoveMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Remove1Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."RemoveBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if NoHands == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if NoQuads == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if NoLifts == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if NoFakes == true then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 4 then
				if CurrentColumn == 1 and i == 1 then
					if NoHands == true then
						NoHands = false
						SetEngineMod(player, "NoHands", NoHands)
						self:settext("")
					elseif NoHands == false then
						NoHands = true
						SetEngineMod(player, "NoHands", NoHands)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if NoQuads then
						NoQuads = false
						SetEngineMod(player, "NoQuads", NoQuads)
						self:settext("")
					elseif not NoQuads then
						NoQuads = true
						SetEngineMod(player, "NoQuads", NoQuads)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if NoLifts then
						NoLifts = false
						SetEngineMod(player, "NoLifts", NoLifts)
						self:settext("")
					elseif not NoLifts then
						NoLifts = true
						SetEngineMod(player, "NoLifts", NoLifts)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if NoFakes then
						NoFakes = false
						SetEngineMod(player, "NoFakes", NoFakes)
						self:settext("")
					elseif not NoFakes then
						NoFakes = true
						SetEngineMod(player, "NoFakes", NoFakes)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

-- Notes2HoldsMods
local Notes2HoldsMods ={
THEME:GetString("OptionNames","Planted"),
THEME:GetString("OptionNames","Floored"),
}

local Notes2HoldsMods2 ={
THEME:GetString("OptionNames","Twister"),
THEME:GetString("OptionNames","HoldsToRolls"),
}

--- Notes>Holds Mods
for i=1,#Notes2HoldsMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Notes2HoldsMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods5")
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
				PastWidth = self:GetParent():GetChild(pn.."Notes2HoldsMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."Notes2HoldsMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Notes2HoldsMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Notes>Holds boxes
for i=1,#Notes2HoldsMods do
	af[#af+1] = Def.Quad{
		Name=pn.."Notes2HoldsBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods5")
			local TextZoom = self:GetParent():GetChild(pn.."Notes2HoldsMod"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Notes2HoldsMod"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Notes2HoldsMod"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Planted = PlayerState:GetPlayerOptions(0):Planted()
local Floored = PlayerState:GetPlayerOptions(0):Floored()

--- Notes>Holds 1 check boxes
for i=1,#Notes2HoldsMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Notes2Holds1Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."Notes2HoldsBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Planted == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if Floored == true then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 5 then
				if CurrentColumn == 1 and i == 1 then
					if Planted == true then
						Planted = false
						SetEngineMod(player, "Planted", Planted)
						self:settext("")
					elseif Planted == false then
						Planted = true
						SetEngineMod(player, "Planted", Planted)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if Floored then
						Floored = false
						SetEngineMod(player, "Floored", Floored)
						self:settext("")
					elseif not Floored then
						Floored = true
						SetEngineMod(player, "Floored", Floored)
						self:settext("✅")
					end
				end
			end
		end,
	}
end


---notes>holds 2 options
for i=1,#Notes2HoldsMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."Notes2HoldsMod2_"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods6")
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
				PastWidth = self:GetParent():GetChild(pn.."Notes2HoldsMod2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."Notes2HoldsMod2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Notes2HoldsMods2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

---notes>holds 2 boxes
for i=1,#Notes2HoldsMods2 do
	af[#af+1] = Def.Quad{
		Name=pn.."Notes2HoldsBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods6")
			local TextZoom = self:GetParent():GetChild(pn.."Notes2HoldsMod2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."Notes2HoldsMod2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."Notes2HoldsMod2_"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Twister = PlayerState:GetPlayerOptions(0):Twister()
local HoldRolls = PlayerState:GetPlayerOptions(0):HoldRolls()

--- Notes>Holds 2 check boxes
for i=1,#Notes2HoldsMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Notes2Holds2Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."Notes2HoldsBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Twister == true then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if HoldRolls == true then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 6 then
				if CurrentColumn == 1 and i == 1 then
					if Twister == true then
						Twister = false
						SetEngineMod(player, "Twister", Twister)
						self:settext("")
					elseif Twister == false then
						Twister = true
						SetEngineMod(player, "Twister", Twister)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if HoldRolls then
						HoldRolls = false
						SetEngineMod(player, "HoldRolls", HoldRolls)
						self:settext("")
					elseif not HoldRolls then
						HoldRolls = true
						SetEngineMod(player, "HoldRolls", HoldRolls)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

-- Acceleration mods/boxes
local AccelMods={
THEME:GetString("OptionNames","Boost"),
THEME:GetString("OptionNames","Brake"),
THEME:GetString("OptionNames","Wave"),
}

local AccelMods2={
THEME:GetString("OptionNames","Expand"),
THEME:GetString("OptionNames","Boomerang"),
}

-- Accel mods 1
for i=1,#AccelMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."AccelMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods7")
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
				PastWidth = self:GetParent():GetChild(pn.."AccelMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."AccelMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(AccelMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Accel boxes 1
for i=1,#AccelMods do
	af[#af+1] = Def.Quad{
		Name=pn.."AccelModBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods7")
			local TextZoom = self:GetParent():GetChild(pn.."AccelMod"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."AccelMod"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."AccelMod"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Boost = PlayerState:GetPlayerOptions(0):Boost()
local Brake = PlayerState:GetPlayerOptions(0):Brake()
local Wave = PlayerState:GetPlayerOptions(0):Wave()

--- Accel check boxes
for i=1,#AccelMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Notes2Holds2Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."AccelModBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Boost == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if Brake == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if Wave == 1 then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 7 then
				if CurrentColumn == 1 and i == 1 then
					if Boost == 1 then
						Boost = 0
						SetEngineMod(player, "Boost", Boost)
						self:settext("")
					elseif Boost == 0 then
						Boost = 1
						SetEngineMod(player, "Boost", Boost)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if Brake == 1 then
						Brake = 0
						SetEngineMod(player, "Brake", Brake)
						self:settext("")
					elseif Brake == 0 then
						Brake = 1
						SetEngineMod(player, "Brake", Brake)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if Wave == 1 then
						Wave = 0
						SetEngineMod(player, "Wave", Wave)
						self:settext("")
					elseif Wave == 0 then
						Wave = 1
						SetEngineMod(player, "Wave", Wave)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

-- Accel mods 2
for i=1,#AccelMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."AccelMod2_"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods8")
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
				PastWidth = self:GetParent():GetChild(pn.."AccelMod2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."AccelMod2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(AccelMods2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


--Accel boxes 2
for i=1,#AccelMods2 do
	af[#af+1] = Def.Quad{
		Name=pn.."AccelModBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods8")
			local TextZoom = self:GetParent():GetChild(pn.."AccelMod2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."AccelMod2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."AccelMod2_"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Expand = PlayerState:GetPlayerOptions(0):Expand()
local Boomerang = PlayerState:GetPlayerOptions(0):Boomerang()

--- Accel 2 check boxes
for i=1,#AccelMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Notes2Holds2Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."AccelModBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Expand == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if Boomerang == 1 then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 8 then
				if CurrentColumn == 1 and i == 1 then
					if Expand == 1 then
						Expand = 0
						SetEngineMod(player, "Expand", Expand)
						self:settext("")
					elseif Expand == 0 then
						Expand = 1
						SetEngineMod(player, "Expand", Expand)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if Boomerang == 1 then
						Boomerang = 0
						SetEngineMod(player, "Boomerang", Boomerang)
						self:settext("")
					elseif Boomerang == 0 then
						Boomerang = 1
						SetEngineMod(player, "Boomerang", Boomerang)
						self:settext("✅")
					end
				end
			end
		end,
	}
end


-- EffectMods
local EffectMods={
THEME:GetString("OptionNames","Drunk"),
THEME:GetString("OptionNames","Dizzy"),
THEME:GetString("OptionNames","Confusion"),
THEME:GetString("OptionNames","Flip"),
}

local EffectMods2={
THEME:GetString("OptionNames","Invert"),
THEME:GetString("OptionNames","Tornado"),
THEME:GetString("OptionNames","Tipsy"),
THEME:GetString("OptionNames","Bumpy"),
THEME:GetString("OptionNames","Beat"),
}

--- Effect Mods 1
for i=1,#EffectMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."EffectMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods9")
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
				PastWidth = self:GetParent():GetChild(pn.."EffectMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."EffectMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(EffectMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Effect Mods box 1
for i=1,#EffectMods do
	af[#af+1] = Def.Quad{
		Name=pn.."EffectModBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods9")
			local TextZoom = self:GetParent():GetChild(pn.."EffectMod"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."EffectMod"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."EffectMod"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Drunk = PlayerState:GetPlayerOptions(0):Drunk()
local Dizzy = PlayerState:GetPlayerOptions(0):Dizzy()
local Confusion = PlayerState:GetPlayerOptions(0):Confusion()
local Flip = PlayerState:GetPlayerOptions(0):Flip()

--- Effect check boxes
for i=1,#EffectMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Effect1Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."EffectModBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Drunk == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if Dizzy == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if Confusion == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if Flip == 1 then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 9 then
				if CurrentColumn == 1 and i == 1 then
					if Drunk == 1 then
						Drunk = 0
						SetEngineMod(player, "Drunk", Drunk)
						self:settext("")
					elseif Drunk == 0 then
						Drunk = 1
						SetEngineMod(player, "Drunk", Drunk)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if Dizzy == 1 then
						Dizzy = 0
						SetEngineMod(player, "Dizzy", Dizzy)
						self:settext("")
					elseif Dizzy == 0 then
						Dizzy = 1
						SetEngineMod(player, "Dizzy", Dizzy)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if Confusion == 1 then
						Confusion = 0
						SetEngineMod(player, "Confusion", Confusion)
						self:settext("")
					elseif Confusion == 0 then
						Confusion = 1
						SetEngineMod(player, "Confusion", Confusion)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if Flip == 1 then
						Flip = 0
						SetEngineMod(player, "Flip", Flip)
						self:settext("")
					elseif Flip == 0 then
						Flip = 1
						SetEngineMod(player, "Flip", Flip)
						self:settext("✅")
					end
				end
			end
		end,
	}
end


--- Effect mods 2
for i=1,#EffectMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."EffectMod2_"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods10")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth + 12)
			else
				PastWidth = self:GetParent():GetChild(pn.."EffectMod2_"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."EffectMod2_"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + self:GetHeight()*6)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(EffectMods2[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

-- Effect Mod Boxes 2
for i=1,#EffectMods2 do
	af[#af+1] = Def.Quad{
		Name=pn.."EffectModBox2_"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods10")
			local TextZoom = self:GetParent():GetChild(pn.."EffectMod2_"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."EffectMod2_"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."EffectMod2_"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local Invert = PlayerState:GetPlayerOptions(0):Invert()
local Tornado = PlayerState:GetPlayerOptions(0):Tornado()
local Tipsy = PlayerState:GetPlayerOptions(0):Tipsy()
local Bumpy = PlayerState:GetPlayerOptions(0):Bumpy()
local Beat = PlayerState:GetPlayerOptions(0):Beat()

--- Effect2 check boxes
for i=1,#EffectMods2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."Effect2Check"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."EffectModBox2_"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Invert == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if Tornado == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if Tipsy == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if Bumpy == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 5 then
				if Beat == 1 then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 10 then
				if CurrentColumn == 1 and i == 1 then
					if Invert == 1 then
						Invert = 0
						SetEngineMod(player, "Invert", Invert)
						self:settext("")
					elseif Invert == 0 then
						Invert = 1
						SetEngineMod(player, "Invert", Invert)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if Tornado == 1 then
						Tornado = 0
						SetEngineMod(player, "Tornado", Tornado)
						self:settext("")
					elseif Tornado == 0 then
						Tornado = 1
						SetEngineMod(player, "Tornado", Tornado)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if Tipsy == 1 then
						Tipsy = 0
						SetEngineMod(player, "Tipsy", Tipsy)
						self:settext("")
					elseif Tipsy == 0 then
						Tipsy = 1
						SetEngineMod(player, "Tipsy", Tipsy)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if Bumpy == 1 then
						Bumpy = 0
						SetEngineMod(player, "Bumpy", Bumpy)
						self:settext("")
					elseif Bumpy == 0 then
						Bumpy = 1
						SetEngineMod(player, "Bumpy", Bumpy)
						self:settext("✅")
					end
				elseif CurrentColumn == 5 and i == 5 then
					if Beat == 1 then
						Beat = 0
						SetEngineMod(player, "Beat", Beat)
						self:settext("")
					elseif Beat == 0 then
						Beat = 1
						SetEngineMod(player, "Beat", Beat)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

-- Appearance Options
local AppearanceMods ={
THEME:GetString("OptionNames","Hidden"),
THEME:GetString("OptionNames","Sudden"),
THEME:GetString("OptionNames","Stealth"),
THEME:GetString("OptionNames","R.Vanish"),
}

--- Appearance mods
for i=1,#AppearanceMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."AppearanceMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods11")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastWidth
			local PastX
			local CurrentX
			if i == 1 then
				self:x(TextXPosition + TextWidth + 12)
			else
				PastWidth = self:GetParent():GetChild(pn.."AppearanceMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."AppearanceMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 18
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + self:GetHeight()*6)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(AppearanceMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Appearance Boxes
for i=1,#AppearanceMods do
	af[#af+1] = Def.Quad{
		Name=pn.."AppearanceModBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."UncommonMods11")
			local TextZoom = self:GetParent():GetChild(pn.."AppearanceMod"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."AppearanceMod"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."AppearanceMod"..i):GetX()
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end


local Hidden = PlayerState:GetPlayerOptions(0):Hidden()
local Sudden = PlayerState:GetPlayerOptions(0):Sudden()
local Stealth = PlayerState:GetPlayerOptions(0):Stealth()
local RandomVanish = PlayerState:GetPlayerOptions(0):RandomVanish()

--- Appearance check boxes
for i=1,#AppearanceMods do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."AppearanceCheck"..i,
		InitCommand=function(self)
			local zoom = 0.39
			local Parent = self:GetParent():GetChild(pn.."AppearanceModBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if Hidden == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if Sudden == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if Stealth == 1 then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if RandomVanish == 1 then
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
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
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
			if CurrentTab == 4 and CurrentRow == 11 then
				if CurrentColumn == 1 and i == 1 then
					if Hidden == 1 then
						Hidden = 0
						SetEngineMod(player, "Hidden", Hidden)
						self:settext("")
					elseif Hidden == 0 then
						Hidden = 1
						SetEngineMod(player, "Hidden", Hidden)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if Sudden == 1 then
						Sudden = 0
						SetEngineMod(player, "Sudden", Sudden)
						self:settext("")
					elseif Sudden == 0 then
						Sudden = 1
						SetEngineMod(player, "Sudden", Sudden)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if Stealth == 1 then
						Stealth = 0
						SetEngineMod(player, "Stealth", Stealth)
						self:settext("")
					elseif Stealth == 0 then
						Stealth = 1
						SetEngineMod(player, "Stealth", Stealth)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if RandomVanish == 1 then
						RandomVanish = 0
						SetEngineMod(player, "RandomVanish", RandomVanish)
						self:settext("")
					elseif RandomVanish == 0 then
						RandomVanish = 1
						SetEngineMod(player, "RandomVanish", RandomVanish)
						self:settext("✅")
					end
				end
			end
		end,
	}
end

-- Attack Mods
local AttackMods={
THEME:GetString("OptionNames","On"),
THEME:GetString("OptionNames","RandomAttacks"),
THEME:GetString("OptionNames","Off"),
}

for i=1,#AttackMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."AttackMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods12")
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
				PastWidth = self:GetParent():GetChild(pn.."AttackMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."AttackMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(AttackMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local RandAttack = PlayerState:GetPlayerOptions(0):RandAttack()
local NoAttack = PlayerState:GetPlayerOptions(0):NoAttack()
local AttackNumber

if RandAttack == 0 and NoAttack == 0 then
	AttackNumber = 1
elseif RandAttack == 1 then
	AttackNumber = 2
elseif NoAttack == 1 then
	AttackNumber = 3
end

--- Attack Selector
af[#af+1] = Def.Quad{
	Name=pn.."AttackSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."AttackMod"..AttackNumber)
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
			if CurrentTabP1 == 4 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 4 then
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
		if CurrentTab == 4 and CurrentRow == 12 then
			if CurrentColumn == 1 then
				-- attacks are on by default so disable the other mods
				SetEngineMod(player, "RandAttack", 0)
				SetEngineMod(player, "NoAttack", 0)
			elseif CurrentColumn == 2 then
				SetEngineMod(player, "NoAttack", 0)
				SetEngineMod(player, "RandAttack", 1)
			elseif CurrentColumn == 3 then
				SetEngineMod(player, "RandAttack", 0)
				SetEngineMod(player, "NoAttack", 1)
			end
			local Parent = self:GetParent():GetChild(pn.."AttackMod"..CurrentColumn)
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

--- Haste Mods
local HasteMods={
THEME:GetString("OptionNames","Off"),
THEME:GetString("OptionNames","On"),
}

--- Haste Options
for i=1,#HasteMods do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."HasteMod"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."UncommonMods13")
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
				PastWidth = self:GetParent():GetChild(pn.."HasteMod"..i-1):GetWidth() * zoom
				PastX = self:GetParent():GetChild(pn.."HasteMod"..i-1):GetX()
				CurrentX = PastX + PastWidth + 8
				self:x(CurrentX)
			end
			self:horizalign(left):vertalign(middle):shadowlength(1)
				:draworder(2)
				:y(TextYPosition + TextHeight/1.75 )
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(HasteMods[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 4 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IsHaste = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):Haste()
local HasteNumber = IsHaste > 0 and 2 or 1

--- Haste Selector
af[#af+1] = Def.Quad{
	Name=pn.."HasteSelector",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."HasteMod"..HasteNumber)
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
			if CurrentTabP1 == 4 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 4 then
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
		if CurrentTab == 4 and CurrentRow == 13 then
			if CurrentColumn == 1 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):Haste(0)
			elseif CurrentColumn == 2 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):Haste(1)
			end
			local Parent = self:GetParent():GetChild(pn.."HasteMod"..CurrentColumn)
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

-------------------------------------------------------------
local Mod4Descriptions = {
THEME:GetString("OptionExplanations","Insert"),
THEME:GetString("OptionExplanations","Insert"),
THEME:GetString("OptionExplanations","Remove"),
THEME:GetString("OptionExplanations","Remove"),
THEME:GetString("OptionExplanations","Holds"),
THEME:GetString("OptionExplanations","Holds"),
THEME:GetString("OptionExplanations","Accel"),
THEME:GetString("OptionExplanations","Accel"),
THEME:GetString("OptionExplanations","Effect"),
THEME:GetString("OptionExplanations","Effect"),
THEME:GetString("OptionExplanations","Appearance"),
THEME:GetString("OptionExplanations","Attacks"),
THEME:GetString("OptionExplanations","Haste"),
}

-- Bottom Information for mods
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."Mod4Descriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(Mod4Descriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 or CurrentTabP1 ~= 4 then
				self:visible(false)
			else
				self:settext(Mod4Descriptions[CurrentRowP1])
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0  or CurrentTabP2 ~= 4 then
				self:visible(false)
				
			else
				self:settext(Mod4Descriptions[CurrentRowP2])
				self:visible(true)
			end
		end
	end,
}