local player, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

if mods.ErrorBar == "None" then
    return
end

local a = LoadActor(mods.ErrorBar .. ".lua", player, layout)

return a
