--- Here is all the info necessary for Tab 1
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
local PlayerState = GAMESTATE:GetPlayerState(pn)
local mods = SL[pn].ActiveModifiers

-----------------------------------------------------------------------------------------------------
-- the left side mod types
local QuickModsNames = {
THEME:GetString("OptionTitles","SpeedModType"),
THEME:GetString("OptionTitles","SpeedMod"),
THEME:GetString("OptionTitles","Mini"),
THEME:GetString("OptionTitles","Turn"),
THEME:GetString("OptionTitles","MusicRate"),
}

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

for i=1, #QuickModsNames do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."QuickMods"..i,
		InitCommand=function(self)
			local zoom = 0.7
			self:horizalign(left):vertalign(top):shadowlength(1)
				:x(XPos + padding/2 + border*2)
				:y(YPos - height/2 + border + (i*20) + 10)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:draworder(1)
				:settext(QuickModsNames[i]..":")
				:queuecommand("UpdateDisplayedTab")
				:diffuse(color("#b0b0b0"))
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}

end


-----------------------------------------------------------------------------------------------------
local SpeedTypes ={
"C",
"M",
"X",
}

local PlayerSpeedType, PlayerSpeedMod, PastSpeedType
local MaxCMod = 2000
local MinCMod = 5

local MaxXMod = 20
local MinXMod = 0
local FirstPass = false

--- Speed Types
for i=1, #SpeedTypes do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."SpeedTypes"..i,
		InitCommand=function(self)
			local zoom = 0.7
			local Parent = self:GetParent():GetChild(pn.."QuickMods1")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth()*TextZoom
			local TextHeight = Parent:GetHeight()
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PastX
			local PastWidth
			local CurrentX
			if i ==1 then
				self:x(TextXPosition + TextWidth + 10)
			else
				PastX = self:GetParent():GetChild(pn.."SpeedTypes"..i-1):GetX()
				PastWidth = self:GetParent():GetChild(pn.."SpeedTypes"..i-1):GetWidth() * zoom
				CurrentX = PastX + PastWidth + 15
				self:x(CurrentX)
			end
			self:vertalign(middle)
				:draworder(2)
				:zoom(zoom)
				:horizalign(left)
				:y(TextYPosition + TextHeight/3)
				:settext(SpeedTypes[i])
				:queuecommand("UpdateDisplayedTab")
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Speed Type Selector
af[#af+1] = Def.Quad{
	Name=pn.."SpeedTypeSelector",
	InitCommand=function(self)
		PlayerSpeedType = mods.SpeedModType or "X"
		PlayerSpeedMod = mods.SpeedMod or "1"
		PastSpeedType =  PlayerSpeedType
		local SpeedNumber
		for i=1, #SpeedTypes do
			if SpeedTypes[i] == PlayerSpeedType then
				SpeedNumber = i
				break
			end
		end
		local Parent = self:GetParent():GetChild(pn.."SpeedTypes"..SpeedNumber)
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
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
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
		if CurrentTab == 1 and CurrentRow == 1 then
			if CurrentColumn == 1 then
				if PlayerSpeedType ~= "C" then
					PlayerSpeedType = "C"
					mods.SpeedModType = "C"
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged", {PastSpeedType, PlayerSpeedType})
				end
			elseif CurrentColumn == 2 then
				if PlayerSpeedType ~= "M" then
					PlayerSpeedType = "M"
					mods.SpeedModType = "M"
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged", {PastSpeedType, PlayerSpeedType})
				end
			elseif CurrentColumn == 3 then
				if PlayerSpeedType ~= "X" then
					PlayerSpeedType = "X"
					mods.SpeedModType = "X"
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged", {PastSpeedType, PlayerSpeedType})
				end
			end
			local Parent = self:GetParent():GetChild(pn.."SpeedTypes"..CurrentColumn)
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

-----------------------------------------------------------------------------------------------------
--- Speed Mod Box
af[#af+1] = Def.Quad{
	Name=pn.."SpeedModBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."QuickMods2")
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
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

--- Speed Mod Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."SpeedModText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods2")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."SpeedModBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."SpeedModBox1"):GetX()
		local TextYPosition = Parent:GetY()
		local PastWidth
		local PastX
		local CurrentX
		if PlayerSpeedType == "X" then
			self:settext(PlayerSpeedMod.."x")
		else
			self:settext(PlayerSpeedMod)
		end
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
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
		
		if CurrentTab == 1 and CurrentRow == 2 then
			if params[1] == "left" then
				if PlayerSpeedType == "X" then
					if PlayerSpeedMod <= MinXMod then
						PlayerSpeedMod = MaxXMod
					else
						PlayerSpeedMod = PlayerSpeedMod - 0.05
					end
				elseif PlayerSpeedType == "C" or PlayerSpeedType == "M" then
					if PlayerSpeedMod <= MinCMod then
						PlayerSpeedMod = MaxCMod
					else
						PlayerSpeedMod = PlayerSpeedMod - 5
					end
				end
				--- literally why. I said set to 0 not 0.000000000000000000000000000000000000000000000000000000000001
				if PlayerSpeedMod < 0.05 then PlayerSpeedMod = round(PlayerSpeedMod) end
				mods.SpeedMod = PlayerSpeedMod
				if PlayerSpeedType == "X" then
					self:settext(PlayerSpeedMod.."x")
				else
					self:settext(PlayerSpeedMod)
				end
				self:queuecommand("SetMod")
				MESSAGEMAN:Broadcast("SpeedModHasChanged", {PlayerSpeedType})
			elseif params[1] == "right" then
				if PlayerSpeedType == "X" then
					if PlayerSpeedMod >= MaxXMod then
						PlayerSpeedMod = MinXMod
					else
						PlayerSpeedMod = PlayerSpeedMod + 0.05
					end
				elseif PlayerSpeedType == "C" or PlayerSpeedType == "M" then
					if PlayerSpeedMod >= MaxCMod then
						PlayerSpeedMod = MinCMod
					else
						PlayerSpeedMod = PlayerSpeedMod + 5
					end
				end
				--- literally why
				if PlayerSpeedMod < 0.05 then PlayerSpeedMod = round(PlayerSpeedMod) end
				mods.SpeedMod = PlayerSpeedMod
				if PlayerSpeedType == "X" then
					self:settext(PlayerSpeedMod.."x")
				else
					self:settext(PlayerSpeedMod)
				end
				self:queuecommand("SetMod")
				MESSAGEMAN:Broadcast("SpeedModHasChanged", {PlayerSpeedType})
			end
		end
	end,
	SpeedTypeHasChangedMessageCommand=function(self, params)
		PastSpeedType = PlayerSpeedType
		local CurBPM = 150
		if GAMESTATE:GetCurrentSong() ~= nil then
			CurBPM = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
		end
		if params[1] == "X" and (params[2] == "C" or params[2] == "M") then
			PlayerSpeedMod = PlayerSpeedMod * CurBPM
			PlayerSpeedMod = round(PlayerSpeedMod/5)*5
			mods.SpeedMod = PlayerSpeedMod
			self:settext(PlayerSpeedMod)
		elseif (params[1] == "C" or params[1] == "M") and params[2] == "X" then
			PlayerSpeedMod = PlayerSpeedMod/CurBPM
			PlayerSpeedMod = round(PlayerSpeedMod/0.05)*0.05
			mods.SpeedMod = PlayerSpeedMod
			self:settext(PlayerSpeedMod.."x")
		end
		self:queuecommand("SetMod")
		MESSAGEMAN:Broadcast("UpdateScrollSpeedText")
	end,
	SetModCommand=function(self)
		if PlayerSpeedType == "X" then
			SetEngineMod(player, "XMod", PlayerSpeedMod)
		elseif PlayerSpeedType == "M" then
			SetEngineMod(player, "MMod", PlayerSpeedMod)
		elseif PlayerSpeedType == "C" then
			SetEngineMod(player, "CMod", PlayerSpeedMod)
		end
	
	end,
}

--- Scroll Speed label
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."ScrollSpeedLabel",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."SpeedModBox1")
		local QuadWidth = Parent:GetZoomX()
		local QuadHeight = Parent:GetZoomY()
		local QuadXPosition = Parent:GetX()
		local QuadYPosition = Parent:GetY()
		local SpeedText
		self:horizalign(left):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(QuadYPosition + QuadHeight/2)
			:x(QuadXPosition + QuadWidth + 10) 
			:zoom(zoom)
			:settext(THEME:GetString("DDPlayerMenu","ScrollSpeed")..":")
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

--- Fixed speed
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."FixedSpeedText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."ScrollSpeedLabel")
		local TextZoom = Parent:GetZoom()
		local TextWidth = Parent:GetWidth() * TextZoom
		local TextHeight = Parent:GetHeight()
		local TextXPosition = Parent:GetX()
		local TextYPosition = Parent:GetY()
		local SpeedText
		local Scroll1, Scroll2
		local BPM1 = 150
		local BPM2 = 150
		local OneBPM
		if GAMESTATE:GetCurrentSong() ~= nil then
			BPM1 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
			BPM2 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
			if BPM1 == BPM2 then
				OneBPM = BPM2
			end
		end
		if PlayerSpeedType == "X" then
			if OneBPM ~= nil then
				SpeedText = PlayerSpeedMod * OneBPM
				self:settext(round(SpeedText))
			else
				Scroll1 = round(PlayerSpeedMod * BPM1)
				Scroll2 = round(PlayerSpeedMod * BPM2)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		
		else
			self:settext(PlayerSpeedMod)
		end
		self:horizalign(left):vertalign(middle):shadowlength(1)
			:draworder(2)
			:y(TextYPosition)
			:x(TextXPosition + TextWidth + 5) 
			:zoom(zoom)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
	UpdateScrollSpeedTextMessageCommand=function(self, params)
		local SpeedText
		local Scroll1, Scroll2
		local BPM1 = 150
		local BPM2 = 150
		local OneBPM
		if GAMESTATE:GetCurrentSong() ~= nil then
			BPM1 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
			BPM2 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
			if BPM1 == BPM2 then
				OneBPM = BPM2
			end
		end
		 
		if PlayerSpeedType == "X" then
			if OneBPM ~= nil then
				SpeedText = PlayerSpeedMod * OneBPM
				self:settext(round(SpeedText))
			else
				Scroll1 = round(PlayerSpeedMod * BPM1)
				Scroll2 = round(PlayerSpeedMod * BPM2)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif PlayerSpeedType == "M" then
			if OneBPM ~= nil then
				self:settext(PlayerSpeedMod)
			else
				Scroll1 = round(BPM1/BPM2 * PlayerSpeedMod)
				Scroll2 = round(PlayerSpeedMod)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif PlayerSpeedType == "C" then
			self:settext(PlayerSpeedMod)
		end
	end,
	SpeedModHasChangedMessageCommand=function(self, params)
		local SpeedText
		local Scroll1, Scroll2
		local BPM1 = 150
		local BPM2 = 150
		local OneBPM
		if GAMESTATE:GetCurrentSong() ~= nil then
			BPM1 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
			BPM2 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
			if BPM1 == BPM2 then
				OneBPM = BPM2
			end
		end
		if PlayerSpeedType == "X" then
			if OneBPM ~= nil then
				SpeedText = PlayerSpeedMod * OneBPM
				self:settext(round(SpeedText))
			else
				Scroll1 = round(PlayerSpeedMod * BPM1)
				Scroll2 = round(PlayerSpeedMod * BPM2)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif PlayerSpeedType == "M" then
			if OneBPM ~= nil then
				self:settext(PlayerSpeedMod)
			else
				Scroll1 = round(BPM1/BPM2 * PlayerSpeedMod)
				Scroll2 = round(PlayerSpeedMod)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		else
			self:settext(PlayerSpeedMod)
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		if GAMESTATE:GetCurrentSong() ~= nil and PlayerSpeedType == "X" then
			local SpeedText
			local Scroll1, Scroll2
			local BPM1 = 150
			local BPM2 = 150
			local OneBPM
			BPM1 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
			BPM2 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
			if BPM1 == BPM2 then
				OneBPM = BPM2
			end
			if OneBPM ~= nil then
				SpeedText = PlayerSpeedMod * OneBPM
				self:settext(round(SpeedText))
			else
				Scroll1 = round(PlayerSpeedMod * BPM1)
				Scroll2 = round(PlayerSpeedMod * BPM2)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif GAMESTATE:GetCurrentSong() ~= nil and PlayerSpeedType == "M" then
			local SpeedText
			local Scroll1, Scroll2
			local BPM1 = 150
			local BPM2 = 150
			local OneBPM
			BPM1 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[1]
			BPM2 = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
			if BPM1 == BPM2 then
				OneBPM = BPM2
			end
			if OneBPM ~= nil then
				self:settext(PlayerSpeedMod)
			else
				Scroll1 = round(BPM1/BPM2 * PlayerSpeedMod)
				Scroll2 = round(PlayerSpeedMod)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		
		elseif GAMESTATE:GetCurrentSong() == nil then
			self:settext("")
		else
			self:settext(PlayerSpeedMod)
		end
	end,
}

-----------------------------------------------------------------------------------------------------
--- Mini Box
af[#af+1] = Def.Quad{
	Name=pn.."MiniBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."QuickMods3")
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
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

local PlayerMini = mods.Mini:gsub("%%","")
local MaxMini = 150
local MinMini = -100

--- Mini Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."MiniText",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods3")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."MiniBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."MiniBox1"):GetX()
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
			:settext(PlayerMini.."%")
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
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
		
		if CurrentTab == 1 and CurrentRow == 3 then
			if params[1] == "left" then
				if PlayerMini == MinMini then
					PlayerMini = MaxMini
				else
					PlayerMini = PlayerMini - 1
				end
				mods.Mini = PlayerMini.."%"
				self:settext(PlayerMini.."%")
					:queuecommand("SetMod")
			elseif params[1] == "right" then
				if PlayerMini == MaxMini then
					PlayerMini = MinMini
				else
					PlayerMini = PlayerMini + 1
				end
				mods.Mini = PlayerMini.."%"
				self:settext(PlayerMini.."%")
					:queuecommand("SetMod")
			end
		end
	end,
	SetModCommand=function(self)
		SetEngineMod(player, "Mini", PlayerMini/100)
	end,
}

-----------------------------------------------------------------------------------------------------
local Turns ={
THEME:GetString("OptionNames","Mirror"),
THEME:GetString("OptionNames","Left"),
THEME:GetString("OptionNames","Right"),
THEME:GetString("OptionNames","Shuffle"),
THEME:GetString("OptionNames","Blender"),
}

--- Turn Mods
for i=1,#Turns do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."TurnMods"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."QuickMods4")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PreviousWidth
			local PastX
			local CurrentX
			if i > 1 then
				PreviousWidth = self:GetParent():GetChild(pn.."TurnMods"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."TurnMods"..i-1):GetX()
				CurrentX = (PastX + PreviousWidth*zoom) + 18
				self:x(CurrentX)
			else
				self:x(TextXPosition + TextWidth + 5)
			end
			self:horizalign(left):vertalign(bottom):shadowlength(1)
				:draworder(1)
				:y(TextYPosition + TextHeight)
				:maxwidth((width/zoom) - 20)
				:zoom(zoom)
				:settext(Turns[i])
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

--- Turn boxes (this is a joint pairing with the turn mod names above)
for i=1,#Turns do
	af[#af+1] = Def.Quad{
		Name=pn.."TurnBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."QuickMods4")
			local TextZoom = self:GetParent():GetChild(pn.."TurnMods"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."TurnMods"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."TurnMods"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.5)
		end,
		UpdateDisplayedTabCommand=function(self)
			if pn == "P1" then
				if CurrentTabP1 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			end
		end,
	}
end

local IsMirror = PlayerState:GetPlayerOptions(0):Mirror()
local IsLeft = PlayerState:GetPlayerOptions(0):Right()
local IsRight = PlayerState:GetPlayerOptions(0):Left()
local IsShuffle = PlayerState:GetPlayerOptions(0):Shuffle()
local IsBlender = PlayerState:GetPlayerOptions(0):SuperShuffle()

--- Turn Check Boxes 1
for i=1,#Turns do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."TurnCheck"..i,
		InitCommand=function(self)
			local zoom = 0.37
			local Parent = self:GetParent():GetChild(pn.."TurnBox"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if IsMirror then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if IsLeft then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if IsRight then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if IsShuffle then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 5 then
				if IsBlender then
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
				if CurrentTabP1 == 1 then
					self:visible(true)
				else
					self:visible(false)
				end
			elseif pn == "P2" then
				if CurrentTabP2 == 1 then
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
			if CurrentTab == 1 and CurrentRow == 4 then
				if CurrentColumn == 1 and i == 1 then
					if IsMirror then
						IsMirror = false
						SetEngineMod(player, "Mirror", IsMirror)
						self:settext("")
					elseif not IsMirror then
						IsMirror = true
						SetEngineMod(player, "Mirror", IsMirror)
						self:settext("✅")
					end
				elseif CurrentColumn == 2 and i == 2 then
					if IsLeft then
						IsLeft = false
						SetEngineMod(player, "Left", IsLeft)
						self:settext("")
					elseif not IsLeft then
						IsLeft = true
						SetEngineMod(player, "Left", IsLeft)
						self:settext("✅")
					end
				elseif CurrentColumn == 3 and i == 3 then
					if IsRight then
						IsRight = false
						SetEngineMod(player, "Right", IsRight)
						self:settext("")
					elseif not IsRight then
						IsRight = true
						SetEngineMod(player, "Right", IsRight)
						self:settext("✅")
					end
				elseif CurrentColumn == 4 and i == 4 then
					if IsShuffle then
						IsShuffle = false
						SetEngineMod(player, "Shuffle", IsShuffle)
						self:settext("")
					elseif not IsShuffle then
						IsShuffle = true
						SetEngineMod(player, "Shuffle", IsShuffle)
						self:settext("✅")
					end
				elseif CurrentColumn == 5 and i == 5 then
					if IsBlender then
						IsBlender = false
						SetEngineMod(player, "SuperShuffle", IsBlender)
						self:settext("")
					elseif not IsBlender then
						IsBlender = true
						SetEngineMod(player, "SuperShuffle",IsBlender)
						self:settext("✅")
					end
				end
			end
		end,
	}
end


-----------------------------------------------------------------------------------------------------
--- MusicRate Box
af[#af+1] = Def.Quad{
	Name=pn.."MusicRateBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."QuickMods5")
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
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		end
	end,
}

local CurrentRateMod = SL.Global.ActiveModifiers.MusicRate
local MinRate = 1
local MaxRate = 3

--- Rate mod text Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NoteskinName1",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods5")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."MusicRateBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."MusicRateBox1"):GetX()
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
			:settext(CurrentRateMod)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentTabP1 == 1 then
				self:visible(true)
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentTabP2 == 1 then
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
		
		if CurrentTab == 1 and CurrentRow == 5 then
			if params[1] == "left" then
				if CurrentRateMod <= MinRate then
					CurrentRateMod = MaxRate
				else
					CurrentRateMod = CurrentRateMod - 0.01
				end
				self:settext(CurrentRateMod)
					:queuecommand("SetMod")
			elseif params[1] == "right" then
				if CurrentRateMod >= MaxRate then
					CurrentRateMod = MinRate
				else
					CurrentRateMod = CurrentRateMod + 0.01
				end
				self:settext(CurrentRateMod)
					:queuecommand("SetMod")
			end
		end
	end,
	SetModCommand=function(self)
		GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate( CurrentRateMod )
		SL.Global.ActiveModifiers.MusicRate = CurrentRateMod
		MESSAGEMAN:Broadcast("UpdateRateModText")
	end,
}


-------------------------------------------------------------
local Mod1Descriptions = {
THEME:GetString("OptionExplanations","SpeedModType"),
THEME:GetString("OptionExplanations","SpeedMod"),
THEME:GetString("OptionExplanations","Mini"),
THEME:GetString("OptionExplanations","Turn"),
THEME:GetString("OptionExplanations","MusicRate"),
}


-- Bottom Information for mods
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."Mod1Descriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(Mod1Descriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 or CurrentTabP1 ~= 1 then
				self:visible(false)
			else
				self:settext(Mod1Descriptions[CurrentRowP1])
				self:visible(true)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0  or CurrentTabP2 ~= 1 then
				self:visible(false)
				
			else
				self:settext(Mod1Descriptions[CurrentRowP2])
				self:visible(true)
			end
		end
	end,
}