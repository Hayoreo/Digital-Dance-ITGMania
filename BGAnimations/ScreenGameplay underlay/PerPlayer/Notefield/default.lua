local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
local layout = GetGameplayLayout(player, opts:Reverse() ~= 0)

local af = Def.ActorFrame{
  Name="NoteFieldContainer"..pn,
  OnCommand=function(self)
    -- We multiply by 2 here because most child actors use the center of the
    -- playfield as the anchor point, and we want to move the playfield as a whole.
    self:addx(mods.NoteFieldOffsetX * 2)
    self:addy(mods.NoteFieldOffsetY * 2)
    local player = SCREENMAN:GetTopScreen():GetChild("Player"..pn)
    player:addx(mods.NoteFieldOffsetX)
    player:addy(mods.NoteFieldOffsetY)

    local notefield = player:GetChild("NoteField")
    if mods.MeasureLines == "Off" then
      notefield:SetBeatBars(false)
      notefield:SetBeatBarsAlpha(0, 0, 0, 0)
    else
      notefield:SetBeatBars(true)

      if mods.MeasureLines == "Measure" then
        notefield:SetBeatBarsAlpha(0.5, 0, 0, 0)
      elseif mods.MeasureLines == "Quarter" then
        notefield:SetBeatBarsAlpha(0.5, 0.25, 0, 0)
      elseif mods.MeasureLines == "Eighth" then
        notefield:SetBeatBarsAlpha(0.5, 0.25, 0.1, 0)
      end
    end
	
  end,
}

-- The following actors should also move along with the NoteFields.
-- NOTE(teejusb): Combo and Judgment are not included here because they are
-- controlled by Graphics/Player combo.lua and Graphics/Player judgment.lua
-- respectively.
af[#af+1] = LoadActor("ColumnFlashOnMiss.lua", player)
af[#af+1] = LoadActor("ErrorBar/default.lua", player, layout.ErrorBar)
af[#af+1] = LoadActor("MeasureCounter.lua", player, layout.MeasureCounter)
af[#af+1] = LoadActor("SubtractiveScoring.lua", player, layout.SubtractiveScoring)
af[#af+1] = LoadActor("ColumnCues.lua", player)
af[#af+1] = LoadActor("NoteFieldOffset.lua", player)

return af