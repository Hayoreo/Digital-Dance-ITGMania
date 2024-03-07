local args = ...

local player = args.player
local TabWidth = args.TabWidth
local XPos = args.XPos
local YPos = args.YPos
local af = args.af
local pn = ToEnumShortString(player)

if not GAMESTATE:IsHumanPlayer(pn) then return end

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
af[#af+1] = Def.Quad{}

local NameTable =
{
	-- Tab 1
	{
		"SpeedTypes",
		"SpeedModBox",
		"MiniBox",
		"NoteskinBox",
		"JudgmentBox",
		"ComboBox",
		"HoldJBox",
		"TurnBox",
		"TurnBox2",
		"MusicRateBox",
	},
	
	-- Tab 2
	{
		"Perspective",
		"ScrollBox",
		"ScreenFilter",
		"HideBox",
		"HideBox2_",
		"NotefieldXBox",
		"NotefieldYBox",
		"VisualDelayBox",
	},
	
	-- Tab 3
	{
	"LifeBarType",
	"DataVisualization",
	"TargetScoreBox",
	"TargetAction",
	"_1ExtraBox",
	"_2ExtraBox",
	"ErrorBar",
	"ErrorBarOptionsBox",
	"MeasureCounter",
	"MCBox",
	"RescoreBox",
	"FAPlusBox",
	"ColumnCuesBox",
	"CCBox",
	"CCBox2_",
	
	},
	
	-- Tab 4
	{
	"InsertBox",
	"InsertBox2_",
	"RemoveBox",
	"RemoveBox2_",
	"Notes2HoldsBox",
	"Notes2HoldsBox2_",
	"AccelModBox",
	"AccelModBox2_",
	"EffectModBox",
	"EffectModBox2_",
	"AppearanceModBox",
	"AttackMod",
	"HasteMod",
	},
	
	-- Tab 5
	{
	"MainSortBox",
	"SubSort1Box",
	"SubSort2Box",
	"MeterFilter1Box",
	"MeterFilter2Box",
	"DifficultyModBox",
	"Difficulty2ModBox",
	"BPMFilter1Box",
	"BPMFilter2Box",
	"LengthFilter1Box",
	"LengthFilter2Box",
	"Groovestats",
	"Autogen",
	"ResetButtonOutline",
	},
	
	-- We don't need Tab 6 here because it's all 1 column
}


local PositionToName = function(CurrentTab, CurrentRow, CurrentColumn)
	local Name
	--- if just switching tabs
	if CurrentRow == 0 then
		return pn.."MenuTabs"..CurrentTab
	-- if on tab 6
	elseif CurrentTab == 6 then
		return pn.."System"..CurrentRow
	else
		Name = NameTable[CurrentTab][CurrentRow]
		return pn..Name..CurrentColumn
	end
end

af[#af+1] = Def.Quad{
	Name="MenuCursor"..pn,
	InitCommand=function(self)
		local color = PlayerColor(player)
		self:diffuse(color)
			:draworder(1)
			:zoomto(1, 1)
			:diffusealpha(0.8)
			:vertalign('middle'):horizalign('center')
			:x(0)
			:y(0)
			:queuecommand("FadeOut")
			:queuecommand("UpdateMenuCursorPosition"..pn)
	end,
	FadeOutCommand=function(self)
		self:linear(0.75)
			:diffusealpha(0.6)
			:queuecommand("FadeIn")
	end,
	FadeInCommand=function(self)
		self:linear(0.75)
			:diffusealpha(0.8)
			:queuecommand("FadeOut")
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self)
		local Name 
		if pn == "P1" then
			Name = PositionToName(CurrentTabP1, CurrentRowP1, CurrentColumnP1)
		elseif pn == "P2" then
			Name = PositionToName(CurrentTabP2, CurrentRowP2, CurrentColumnP2)
		end
		local Parent = self:GetParent():GetChild(Name)
		local CursorX = Parent:GetX()
		local CursorY = Parent:GetY()
		local HAlign = Parent:GetHAlign()
		local VAlign = Parent:GetVAlign()
		local CursorZoom = Parent:GetZoom() or 1
		local CursorH 
		local CursorW

		-- grab different height and width values for text vs quads
		if Parent:GetWidth() == 1 then
			CursorH = Parent:GetZoomY()
			CursorW = Parent:GetZoomX()
		else
			CursorH = Parent:GetHeight()
			CursorW = Parent:GetWidth() * CursorZoom
		end

		-- Change position to account for alignment.
		-- Using vertalign/horizalign doesn't tween properly.
		CursorX = CursorX + (0.5-HAlign)*CursorW
		CursorY = CursorY + (0.5-VAlign)*CursorH

		self:stoptweening()
			:linear(0.1)
			:zoomto(CursorW, CursorH)
			:vertalign('middle'):horizalign('center')
			:x(CursorX)
			:y(CursorY)
			:queuecommand("FadeOut")
	end,
}
