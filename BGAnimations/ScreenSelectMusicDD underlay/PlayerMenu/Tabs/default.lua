local NumTabs = 6

local args = ...

--- Pass these into each tab to make spacing consistent/easy
local player = args.player
local padding = args.padding
local border = args.border
local width = args.width
local height = args.height
local XPos = args.XPos
local YPos = args.YPos
local TabWidth = args.TabWidth
local af = args.af

for i=1, NumTabs do
	af[#af+1] = LoadActor("Tab"..i.."/default.lua", {player = player, padding = padding, border = border, width = width, height = height, XPos = XPos, YPos = YPos, TabWidth = TabWidth, af = af})
end