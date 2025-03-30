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

local ExpectedTab = 1

-----------------------------------------------------------------------------------------------------
-- the left side mod types
local QuickModsNames = {
THEME:GetString("OptionTitles","SpeedModType"),
THEME:GetString("OptionTitles","SpeedMod"),
THEME:GetString("OptionTitles","Mini"),
THEME:GetString("OptionTitles","NoteSkin"),
THEME:GetString("OptionTitles","JudgmentGraphic"),
THEME:GetString("OptionTitles","ComboFont"),
THEME:GetString("OptionTitles","HoldJudgment"),
THEME:GetString("OptionTitles","HeldGraphic"),
THEME:GetString("OptionTitles","Turn"),
THEME:GetString("OptionTitles","Turn"),
THEME:GetString("OptionTitles","MusicRate"),
}

local function GetNoteskins()
	local all = NOTESKIN:GetNoteSkinNames()

	if ThemePrefs.Get("HideStockNoteSkins") then
		local game = GAMESTATE:GetCurrentGame():GetName()

		-- Apologies, midiman. :(
		local stock = {
			dance = {
				"default", "delta", "easyv2", "exactv2", "lambda", "midi-note",
				"midi-note-3d", "midi-rainbow", "midi-routine-p1", "midi-routine-p2",
				"midi-solo", "midi-vivid", "midi-vivid-3d", "retro", "retrobar",
				"retrobar-splithand_whiteblue"
			},
			pump = {
				"cmd", "cmd-routine-p1", "cmd-routine-p2", "complex", "default",
				"delta", "delta-note", "delta-routine-p1", "delta-routine-p2",
				"frame5p", "newextra", "pad", "rhythm", "simple"
			},
		}
		if stock[game] then
			for stock_noteskin in ivalues(stock[game]) do
				for i=1,#all do
					if stock_noteskin == all[i] then
						table.remove(all, i)
						break
					end
				end
			end
		end
	end

	-- It's possible a user might want to hide stock noteskins
	-- but only have stock noteskins.  If so, just return all noteskins.
	if #all == 0 then all = NOTESKIN:GetNoteSkinNames() end

	return all

end

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
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
	}

end


-----------------------------------------------------------------------------------------------------
local SpeedTypes ={
"C",
"M",
"X",
"D",
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
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 1 then
			if CurrentColumn == 1 then
				if PlayerSpeedType ~= "C" then
					PlayerSpeedType = "C"
					mods.SpeedModType = "C"
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
				end
			elseif CurrentColumn == 2 then
				if PlayerSpeedType ~= "M" then
					PlayerSpeedType = "M"
					mods.SpeedModType = "M"
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
				end
			elseif CurrentColumn == 3 then
				if PlayerSpeedType ~= "X" then
					PlayerSpeedType = "X"
					mods.SpeedModType = "X"
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
				end
			elseif CurrentColumn == 4 then
				if PlayerSpeedType ~= "D" then
					PlayerSpeedType = "D"
					mods.SpeedModType = "D"
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
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
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		for i=1, #SpeedTypes do
			local Parent = self:GetParent():GetChild(pn.."SpeedTypes"..i)
			local ObjectZoom = Parent:GetZoom()
			local ObjectWidth = Parent:GetWidth() * ObjectZoom
			local ObjectHeight = Parent:GetHeight()
			local ObjectX = Parent:GetX()
			local ObjectY = Parent:GetY()
			local HAlign = Parent:GetHAlign()
			local VAlign = Parent:GetVAlign()
			ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
			ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
			
			if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
				if i == 1 then
					if CurrentRow ~= 1 and PlayerSpeedType == "C" then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					end
					CurrentRow = 1
					CurrentColumn = 1
					if PlayerSpeedType ~= "C" then
						PlayerSpeedType = "C"
						mods.SpeedModType = "C"
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
					end
				elseif i == 2 then
					if CurrentRow ~= 1 and PlayerSpeedType == "M" then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					end
					CurrentRow = 1
					CurrentColumn = 2
					if PlayerSpeedType ~= "M" then
						PlayerSpeedType = "M"
						mods.SpeedModType = "M"
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
					end
				elseif i == 3 then
					if CurrentRow ~= 1 and PlayerSpeedType == "X" then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					end
					CurrentRow = 1
					CurrentColumn = 3
					if PlayerSpeedType ~= "X" then
						PlayerSpeedType = "X"
						mods.SpeedModType = "X"
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
					end
				elseif i == 4 then
					if CurrentRow ~= 1 and PlayerSpeedType == "D" then
						if CurrentRow < 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
						elseif CurrentRow > 1 then
							SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
						end
					end
					CurrentRow = 1
					CurrentColumn = 4
					if PlayerSpeedType ~= "D" then
						PlayerSpeedType = "D"
						mods.SpeedModType = "D"
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						MESSAGEMAN:Broadcast("SpeedTypeHasChanged"..pn, {PastSpeedType, PlayerSpeedType})
					end
				end
				local Parent2 = self:GetParent():GetChild(pn.."SpeedTypes"..i)
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
				MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn)
			end
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."SpeedModBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
			if CurrentRow ~= 2 then
				if CurrentRow < 2 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 2 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 2 then
			if params[1] == "left" then
				if PlayerSpeedType == "X" then
					if PlayerSpeedMod <= MinXMod then
						if not params[2] == true then
							SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
							PlayerSpeedMod = MaxXMod
						end
					else
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerSpeedMod = round(PlayerSpeedMod - 0.05, 2)
					end
				else
					if PlayerSpeedMod <= MinCMod then
						if not params[2] == true then
							SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
							PlayerSpeedMod = MaxCMod
						end
					else
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerSpeedMod = round(PlayerSpeedMod - 5)
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
						if not params[2] == true then
							SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
							PlayerSpeedMod = MinXMod
						end
					else
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerSpeedMod = round(PlayerSpeedMod + 0.05, 2)
					end
				else
					if PlayerSpeedMod >= MaxCMod then
						if not params[2] == true then
							SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
							PlayerSpeedMod = MinCMod
						end
					else
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerSpeedMod = round(PlayerSpeedMod + 5)
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
	["SpeedTypeHasChanged"..pn.."MessageCommand"]=function(self, params)
		PastSpeedType = PlayerSpeedType
		local CurBPM = 150
		if GAMESTATE:GetCurrentSong() ~= nil then
			CurBPM = GAMESTATE:GetCurrentSong():GetDisplayBpms()[2]
		end

		if params[1] == "X" and params[2] ~= "X" then
			PlayerSpeedMod = PlayerSpeedMod * CurBPM
			PlayerSpeedMod = round(PlayerSpeedMod/5)*5
			mods.SpeedMod = PlayerSpeedMod
			self:settext(PlayerSpeedMod)
		elseif params[1] ~= "X" and params[2] == "X" then
			PlayerSpeedMod = PlayerSpeedMod/CurBPM
			PlayerSpeedMod = round(PlayerSpeedMod/0.05)*0.05
			mods.SpeedMod = PlayerSpeedMod
			self:settext(PlayerSpeedMod.."x")
		end
		self:queuecommand("SetMod")
		MESSAGEMAN:Broadcast("UpdateScrollSpeedText")
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		self:queuecommand("SetMod")
	end,
	SetModCommand=function(self)
		local type = GetEffectiveSpeedModType(player, PlayerSpeedType)

		if type == "X" then
			SetEngineMod(player, "XMod", PlayerSpeedMod)
		elseif type == "M" then
			SetEngineMod(player, "MMod", PlayerSpeedMod)
		elseif type == "C" then
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
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
		 
		local speedType = GetEffectiveSpeedModType(player, PlayerSpeedType)

		if speedType == "X" then
			if OneBPM ~= nil then
				SpeedText = PlayerSpeedMod * OneBPM
				self:settext(round(SpeedText))
			else
				Scroll1 = round(PlayerSpeedMod * BPM1)
				Scroll2 = round(PlayerSpeedMod * BPM2)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif speedType == "M" then
			if OneBPM ~= nil then
				self:settext(PlayerSpeedMod)
			else
				Scroll1 = round(BPM1/BPM2 * PlayerSpeedMod)
				Scroll2 = round(PlayerSpeedMod)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif speedType == "C" then
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

		local speedType = GetEffectiveSpeedModType(player, PlayerSpeedType)

		if speedType == "X" then
			if OneBPM ~= nil then
				SpeedText = PlayerSpeedMod * OneBPM
				self:settext(round(SpeedText))
			else
				Scroll1 = round(PlayerSpeedMod * BPM1)
				Scroll2 = round(PlayerSpeedMod * BPM2)
				SpeedText = Scroll1.." - "..Scroll2
				self:settext(SpeedText)
			end
		elseif speedType == "M" then
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."MiniBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 3 then
			if params[1] == "left" then
				if PlayerMini == MinMini then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerMini = MaxMini
					end
				elseif PlayerMini == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerMini = PlayerMini - 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					PlayerMini = PlayerMini - 1
				end
				mods.Mini = PlayerMini.."%"
				self:settext(PlayerMini.."%")
					:queuecommand("SetMod")
			elseif params[1] == "right" then
				if PlayerMini == MaxMini then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerMini = MinMini
					end
				elseif PlayerMini == 0 then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						PlayerMini = PlayerMini + 1
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
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

-- Noteskins
--------------------------------------------------------------------
local Noteskins = GetNoteskins()

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
		local Parent = self:GetParent():GetChild(pn.."QuickMods4")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."NoteskinBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
			if CurrentRow ~= 4 then
				if CurrentRow < 4 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 4 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
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

--- Noteskin Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NoteskinName1",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods4")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 4 then
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
		mods.NoteSkin = Noteskins[CurrentNoteskinIndex]
		SetEngineMod(player, "NoteSkin", mods.NoteSkin)
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
				local Parent = self:GetParent():GetChild(pn.."QuickMods4")
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
					:queuecommand('UpdateNoteskin')
			end,
			UpdateDisplayedTabCommand=function(self)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab ~= 1 then
					self:visible(false)
					return
				elseif Noteskins[CurrentNoteskinIndex] == noteskin:lower() then
					self:visible(true)
				end
			end,
			["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab == 1 and CurrentRow == 4 then
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
local Judgments = GetJudgmentGraphics() or "Digital 2x7 (doubleres).png"
local CurrentJudgmentIndex

--- Judgment Box
af[#af+1] = Def.Quad{
	Name=pn.."JudgmentBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."QuickMods5")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."JudgmentBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
			if CurrentRow ~= 5 then
				if CurrentRow < 5 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 5 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
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

--- Judgment Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."JudgmentName1",
	InitCommand=function(self)	
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods5")
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
		local PlayerJudge = mods.JudgmentGraphic or "Digital 2x7 (doubleres).png"
		for i=1, #Judgments do
			if Judgments[i] == PlayerJudge then
				CurrentJudgmentIndex = i
				self:queuecommand("UpdateJudgmentText")
				break
			end
		end
	end,
	UpdateDisplayedTabCommand=function(self)
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	UpdateJudgmentTextCommand=function(self)
		self:settext( StripSpriteHints(Judgments[CurrentJudgmentIndex]) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 5 then
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
				local Parent = self:GetParent():GetChild(pn.."QuickMods5")
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
					:queuecommand('UpdateJudgment')
			end,
			UpdateDisplayedTabCommand=function(self)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab ~= 1 then
					self:visible(false)
					return
				elseif Judgments[CurrentJudgmentIndex] == JudgmentName then
					self:visible(true)
				end
			end,
			["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab == 1 and CurrentRow == 5 then
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
		local Parent = self:GetParent():GetChild(pn.."QuickMods6")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."ComboBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
			if CurrentRow ~= 6 then
				if CurrentRow < 6 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 6 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
			CurrentRow = 6
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
		local Parent = self:GetParent():GetChild(pn.."QuickMods6")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 6 then
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
				local Parent = self:GetParent():GetChild(pn.."QuickMods6")
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
					:queuecommand('UpdateComboFont')
			end,
			UpdateDisplayedTabCommand=function(self)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab ~= 1 then
					self:visible(false)
					return
				elseif ComboFonts[CurrentComboIndex] == combo_font then
					self:visible(true)
				end
			end,
			["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab == 1 and CurrentRow == 6 then
					self:queuecommand("Loop")
					if params[1] == "left" or params[1] == "right" then
						self:visible(false):queuecommand("UpdateComboFont")
					end
				end
			end,
			LoopCommand=function(self)
				local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
				
				if CurrentTab == 1 and CurrentRow == 6 then
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
		local Parent = self:GetParent():GetChild(pn.."QuickMods7")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."HoldJBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
			if CurrentRow ~= 7 then
				if CurrentRow < 7 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 7 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
			CurrentRow = 7
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
		local Parent = self:GetParent():GetChild(pn.."QuickMods7")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 7 then
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
			local Parent = self:GetParent():GetChild(pn.."QuickMods7")
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
				:queuecommand('UpdateHoldJ')
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
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab ~= 1 then
				self:visible(false)
				return
			elseif HoldJudgments[CurrentHoldJIndex] == hj_filename then
				self:visible(true)
			end
		end,
		["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab == 1 and CurrentRow == 7 then
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
-- Held Misses

--- Held Misses Box
af[#af+1] = Def.Quad{
	Name=pn.."HeldMissesBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."QuickMods8")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."HeldMissesBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
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


local PlayerHeldMiss = mods.HeldGraphic or "None"
local HeldMissGfx = GetHeldMissGraphics()
local CurrentHeldMissIndex


for i=1, #HeldMissGfx do
	if HeldMissGfx[i] == PlayerHeldMiss then
		CurrentHeldMissIndex = i
		break
	end
end

--- Held Misses Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."HeldMissesName1",
	InitCommand=function(self)	
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods8")
		local TextZoom = Parent:GetZoom()
		local QuadWidth = self:GetParent():GetChild(pn.."HeldMissesBox1"):GetZoomX()
		local TextHeight = Parent:GetHeight() * TextZoom
		local QuadXPosition = self:GetParent():GetChild(pn.."HeldMissesBox1"):GetX()
		local TextYPosition = Parent:GetY()
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:draworder(2)
			:settext(StripSpriteHints(HeldMissGfx[CurrentHeldMissIndex]))
			:y(TextYPosition + TextHeight/2)
			:x(QuadXPosition + QuadWidth/2) 
			:maxwidth((QuadWidth-2)/zoom)
			:zoom(zoom)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 8 then
			if params[1] == "left" then
				if CurrentHeldMissIndex == 1 then
					CurrentHeldMissIndex = #HeldMissGfx
				else
					CurrentHeldMissIndex = CurrentHeldMissIndex - 1	
				end
				mods.HeldGraphic = HeldMissGfx[CurrentHeldMissIndex]
				self:settext(StripSpriteHints(HeldMissGfx[CurrentHeldMissIndex]))
			elseif params[1] == "right" then
				if CurrentHeldMissIndex == #HeldMissGfx then
					CurrentHeldMissIndex = 1
				else
					CurrentHeldMissIndex = CurrentHeldMissIndex + 1
				end
				mods.HeldGraphic = HeldMissGfx[CurrentHeldMissIndex]
				self:settext(StripSpriteHints(HeldMissGfx[CurrentHeldMissIndex]))
			end
		end
	end,

}


--- Held Miss Graphic Preview
for hm_filename in ivalues( HeldMissGfx ) do
	af[#af+1] = Def.ActorFrame{
		Name="HeldMiss_"..StripSpriteHints(hm_filename),
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."QuickMods8")
			local JudgmentX = self:GetParent():GetChild(pn.."HeldMissesName1"):GetX()
			local JudgmentY = Parent:GetY()
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth() * TextZoom
			local QuadHeight = self:GetParent():GetChild(pn.."HeldMissesName1"):GetZoomY()
			self:horizalign(center):vertalign(middle)
				:animate(false)
				:draworder(1)
				:x(JudgmentX + 90)
				:y(JudgmentY + 5)
				:zoom(0.28)
				:visible(false)
				:queuecommand('UpdateHeldMiss')
		end,
			-- held
		Def.Sprite{
			Texture=THEME:GetPathG("", "_HeldMiss/" .. hm_filename),
			InitCommand=function(self) self:animate(false):setstate(0):addx(-self:GetWidth()*0.4) end
		},
		UpdateDisplayedTabCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab ~= 1 then
				self:visible(false)
				return
			elseif HeldMissGfx[CurrentHeldMissIndex] == hm_filename then
				self:visible(true)
			end
		end,
		["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab == 1 and CurrentRow == 8 then
				if params[1] == "left" or params[1] == "right" then
					self:queuecommand("UpdateHeldMiss")
				end
			end
		end,
		UpdateHeldMissCommand=function(self)
			self:visible(false)
			if HeldMissGfx[CurrentHeldMissIndex] ==  hm_filename then
				self:visible(true)
			else
				self:visible(false)
			end
		end,
		
	}


end

--------------------------------------------------------------------------
local Turns1 ={
	THEME:GetString("OptionNames","Mirror"),
	THEME:GetString("OptionNames","LRMirror"),
	THEME:GetString("OptionNames","UDMirror"),
}

local Turns2 ={
	THEME:GetString("OptionNames","Left"),
	THEME:GetString("OptionNames","Right"),
	THEME:GetString("OptionNames","Shuffle"),
	THEME:GetString("OptionNames","Random"),
}

--- Turn Mods 1
for i=1,#Turns1 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."TurnMods"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."QuickMods9")
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
				:settext(Turns1[i])
		end,
		UpdateDisplayedTabCommand=function(self)
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
	}
end

--- Turn boxes1 (this is a joint pairing with the turn mod names above)
for i=1,#Turns1 do
	af[#af+1] = Def.Quad{
		Name=pn.."TurnBox"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."QuickMods9")
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
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
	}
end

local IsMirror = PlayerState:GetPlayerOptions(0):Mirror()
local IsLRMirror = PlayerState:GetPlayerOptions(0):LRMirror()
local IsUDMirror = PlayerState:GetPlayerOptions(0):UDMirror()

--- Turn Check Boxes 1
for i=1,#Turns1 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."TurnCheck"..i,
		InitCommand=function(self)
			local zoom = 0.38
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
				if IsLRMirror then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if IsUDMirror then
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
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
		["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab == 1 and CurrentRow == 9 then
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
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if IsLRMirror then
						IsLRMirror = false
						SetEngineMod(player, "LRMirror", IsLRMirror)
						self:settext("")
					elseif not IsLRMirror then
						IsLRMirror = true
						SetEngineMod(player, "LRMirror", IsLRMirror)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if IsUDMirror then
						IsUDMirror = false
						SetEngineMod(player, "UDMirror", IsUDMirror)
						self:settext("")
					elseif not IsUDMirror then
						IsUDMirror = true
						SetEngineMod(player, "UDMirror", IsUDMirror)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				end
			end
		end,
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if pn == "P1" and not PlayerMenuP1 then return end
			if pn == "P2" and not PlayerMenuP2 then return end
			if CurrentTab ~= 1 then return end
			-- yooooooo the j!!!!
			for j=1, #Turns1 do
				local Parent = self:GetParent():GetChild(pn.."TurnBox"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
					if j == 1 and j == i then
						CurrentRow = 9
						CurrentColumn = 1
						if IsMirror then
							IsMirror = false
							SetEngineMod(player, "Mirror", IsMirror)
							self:settext("")
						elseif not IsMirror then
							IsMirror = true
							SetEngineMod(player, "Mirror", IsMirror)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 9
						CurrentColumn = 2
						if IsLRMirror then
							IsLRMirror = false
							SetEngineMod(player, "LRMirror", IsLRMirror)
							self:settext("")
						elseif not IsLRMirror then
							IsLRMirror = true
							SetEngineMod(player, "LRMirror", IsLRMirror)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 9
						CurrentColumn = 3
						if IsUDMirror then
							IsUDMirror = false
							SetEngineMod(player, "UDMirror", IsUDMirror)
							self:settext("")
						elseif not IsUDMirror then
							IsUDMirror = true
							SetEngineMod(player, "UDMirror", IsUDMirror)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 4 and j == i then
						CurrentRow = 9
						CurrentColumn = 4
						if IsShuffle then
							IsShuffle = false
							SetEngineMod(player, "Shuffle", IsShuffle)
							self:settext("")
						elseif not IsShuffle then
							IsShuffle = true
							SetEngineMod(player, "Shuffle", IsShuffle)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 5 and j == i then
						CurrentRow = 9
						CurrentColumn = 5
						if IsRandom then
							IsRandom = false
							SetEngineMod(player, "HyperShuffle", IsRandom)
							self:settext("")
						elseif not IsRandom then
							IsRandom = true
							SetEngineMod(player, "HyperShuffle", IsRandom)
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

--- Turn Mods 2
for i=1,#Turns2 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."TurnMods2"..i,
		InitCommand=function(self)
			local zoom = 0.6
			local Parent = self:GetParent():GetChild(pn.."QuickMods10")
			local TextZoom = Parent:GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = Parent:GetHeight() * TextZoom
			local TextXPosition = Parent:GetX()
			local TextYPosition = Parent:GetY()
			local PreviousWidth
			local PastX
			local CurrentX
			if i > 1 then
				PreviousWidth = self:GetParent():GetChild(pn.."TurnMods2"..i-1):GetWidth()
				PastX = self:GetParent():GetChild(pn.."TurnMods2"..i-1):GetX()
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
				:settext(Turns2[i])
		end,
		UpdateDisplayedTabCommand=function(self)
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
	}
end

--- Turn boxes2 (this is a joint pairing with the turn mod names above)
for i=1,#Turns2 do
	af[#af+1] = Def.Quad{
		Name=pn.."TurnBox2"..i,
		InitCommand=function(self)
			local Parent = self:GetParent():GetChild(pn.."QuickMods10")
			local TextZoom = self:GetParent():GetChild(pn.."TurnMods2"..i):GetZoom()
			local TextWidth = Parent:GetWidth()
			local TextHeight = self:GetParent():GetChild(pn.."TurnMods2"..i):GetHeight() * TextZoom
			local TextXPosition = self:GetParent():GetChild(pn.."TurnMods2"..i):GetX()
			local TextYPosition = Parent:GetY()
			self:diffuse(color("#FFFFFF"))
				:draworder(1)
				:zoomto(TextHeight, TextHeight)
				:vertalign(middle):horizalign(right)
				:x(TextXPosition-2)
				:y(TextYPosition + TextHeight/1.5)
		end,
		UpdateDisplayedTabCommand=function(self)
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
	}
end

local IsLeft = PlayerState:GetPlayerOptions(0):Left()
local IsRight = PlayerState:GetPlayerOptions(0):Right()
local IsShuffle = PlayerState:GetPlayerOptions(0):Shuffle()
local IsRandom = PlayerState:GetPlayerOptions(0):HyperShuffle()

--- Turn Check Boxes 2
for i=1,#Turns2 do
	af[#af+1] = Def.BitmapText{
		Font="Common Normal",
		Name=pn.."TurnCheck2"..i,
		InitCommand=function(self)
			local zoom = 0.38
			local Parent = self:GetParent():GetChild(pn.."TurnBox2"..i)
			local QuadWidth = Parent:GetZoomX()
			local QuadHeight = Parent:GetZoomY()
			local QuadXPosition = Parent:GetX()
			local QuadYPosition = Parent:GetY()
			if i == 1 then
				if IsLeft then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 2 then
				if IsRight then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 3 then
				if IsShuffle then
					self:settext("✅")
				else
					self:settext("")
				end
			elseif i == 4 then
				if IsRandom then
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
			self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
		end,
		["PlayerMenuSelection"..pn.."MessageCommand"]=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if CurrentTab == 1 and CurrentRow == 10 then
				if CurrentColumn == 1 and i == 1 then
					if IsLeft then
						IsLeft = false
						SetEngineMod(player, "Left", IsLeft)
						self:settext("")
					elseif not IsLeft then
						IsLeft = true
						SetEngineMod(player, "Left", IsLeft)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 2 and i == 2 then
					if IsRight then
						IsRight = false
						SetEngineMod(player, "Right", IsRight)
						self:settext("")
					elseif not IsRight then
						IsRight = true
						SetEngineMod(player, "Right", IsRight)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 3 and i == 3 then
					if IsShuffle then
						IsShuffle = false
						SetEngineMod(player, "Shuffle", IsShuffle)
						self:settext("")
					elseif not IsShuffle then
						IsShuffle = true
						SetEngineMod(player, "Shuffle", IsShuffle)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				elseif CurrentColumn == 4 and i == 4 then
					if IsRandom then
						IsRandom = false
						SetEngineMod(player, "HyperShuffle", IsRandom)
						self:settext("")
					elseif not IsRandom then
						IsRandom = true
						SetEngineMod(player, "HyperShuffle",IsRandom)
						self:settext("✅")
					end
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
				end
			end
		end,
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
			
			if pn == "P1" and not PlayerMenuP1 then return end
			if pn == "P2" and not PlayerMenuP2 then return end
			if CurrentTab ~= 1 then return end
			-- yooooooo the j!!!!
			for j=1, #Turns2 do
				local Parent = self:GetParent():GetChild(pn.."TurnBox2"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
					if j == 1 and j == i then
						CurrentRow = 10
						CurrentColumn = 1
						if IsLeft then
							IsLeft = false
							SetEngineMod(player, "Left", IsLeft)
							self:settext("")
						elseif not IsLeft then
							IsLeft = true
							SetEngineMod(player, "Left", IsLeft)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 2 and j == i then
						CurrentRow = 10
						CurrentColumn = 2
						if IsRight then
							IsRight = false
							SetEngineMod(player, "Right", IsRight)
							self:settext("")
						elseif not IsRight then
							IsRight = true
							SetEngineMod(player, "Right", IsRight)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 3 and j == i then
						CurrentRow = 10
						CurrentColumn = 3
						if IsShuffle then
							IsShuffle = false
							SetEngineMod(player, "Shuffle", IsShuffle)
							self:settext("")
						elseif not IsShuffle then
							IsShuffle = true
							SetEngineMod(player, "Shuffle", IsShuffle)
							self:settext("✅")
						end
						SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
						break
					elseif j == 4 and j == i then
						CurrentRow = 10
						CurrentColumn = 4
						if IsRandom then
							IsRandom = false
							SetEngineMod(player, "HyperShuffle", IsRandom)
							self:settext("")
						elseif not IsRandom then
							IsRandom = true
							SetEngineMod(player, "HyperShuffle",IsRandom)
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

-----------------------------------------------------------------------------------------------------
--- MusicRate Box
af[#af+1] = Def.Quad{
	Name=pn.."MusicRateBox1",
	InitCommand=function(self)
		local Parent = self:GetParent():GetChild(pn.."QuickMods11")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	LeftMouseClickUpdateMessageCommand=function(self)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if pn == "P1" and not PlayerMenuP1 then return end
		if pn == "P2" and not PlayerMenuP2 then return end
		if CurrentTab ~= 1 then return end
		local Parent = self:GetParent():GetChild(pn.."MusicRateBox1")
		local ObjectWidth = Parent:GetZoomX()
		local ObjectHeight = Parent:GetZoomY()
		local ObjectX = Parent:GetX()
		local ObjectY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) and CurrentTab == 1 then
			if CurrentRow ~= 11 then
				if CurrentRow < 10 then
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				elseif CurrentRow > 10 then
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
				end
			end
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

local CurrentRateMod = SL.Global.ActiveModifiers.MusicRate
local MinRate = 1
local MaxRate = 3

--- Rate mod text Text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."NoteskinName1",
	InitCommand=function(self)
		local zoom = 0.7
		local Parent = self:GetParent():GetChild(pn.."QuickMods11")
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
		self:visible( GetPlayerMenuVisibility(pn, ExpectedTab) )
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		local CurrentTab, CurrentRow, CurrentColumn = SetLocalCursor(pn)
		
		if CurrentTab == 1 and CurrentRow == 11 then
			if params[1] == "left" then
				if CurrentRateMod <= MinRate then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						CurrentRateMod = round(MaxRate, 2)
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					CurrentRateMod = round(CurrentRateMod - 0.01, 2)
				end
				self:settext(CurrentRateMod)
					:queuecommand("SetMod")
			elseif params[1] == "right" then
				if CurrentRateMod >= MaxRate then
					if not params[2] == true then
						SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
						CurrentRateMod = round(MinRate)
					end
				else
					SOUND:PlayOnce( THEME:GetPathS("", "_change value") )
					CurrentRateMod = round(CurrentRateMod + 0.01, 2)
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
THEME:GetString("OptionExplanations","NoteSkin"),
THEME:GetString("OptionExplanations","JudgmentGraphic"),
THEME:GetString("OptionExplanations","ComboFont"),
THEME:GetString("OptionExplanations","HoldJudgment"),
THEME:GetString("OptionExplanations","HeldGraphic"),
THEME:GetString("OptionExplanations","Turn"),
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