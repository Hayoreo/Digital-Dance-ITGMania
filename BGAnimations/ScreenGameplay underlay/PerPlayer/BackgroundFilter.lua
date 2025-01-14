local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local mini = mods.Mini:gsub("%%","")

-- if no BackgroundFilter is necessary, it's safe to bail now
if mods.BackgroundFilter == "Off" then return end

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

return Def.Quad{
	InitCommand=function(self)
		self:xy(GetNotefieldX(player) + (mods.NoteFieldOffsetX * 2), _screen.cy )
			:diffuse(Color.Black)
			:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
		-- We need to scale the filter with mini
		if tonumber(mini) > 0 then
			self:zoomto( GetNotefieldWidth() + ((-1* mini)*1.275), _screen.h )
		elseif tonumber(mini) < 0 then
			self:zoomto( GetNotefieldWidth() + ((-1* mini)*1.33), _screen.h )
		elseif tonumber(mini) == 0 then
			self:zoomto( GetNotefieldWidth(), _screen.h )
		end
	end,
	OffCommand=function(self) self:queuecommand("ComboFlash") end,
	ComboFlashCommand=function(self)
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local FlashColor = nil
		local WorstAcceptableFC = SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes:gsub("TapNoteScore_W", "")

		for i=1, tonumber(WorstAcceptableFC) do
			if pss:FullComboOfScore("TapNoteScore_W"..i) then
				FlashColor = SL.JudgmentColors[SL.Global.GameMode][i]
				break
			end
		end

		if (FlashColor ~= nil) then
			self:accelerate(0.25):diffuse( FlashColor )
				:accelerate(0.5):faderight(1):fadeleft(1)
				:accelerate(0.15):diffusealpha(0)
		end
	end
}