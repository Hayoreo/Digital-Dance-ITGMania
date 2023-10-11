-- don't load in course mode... for now?
if GAMESTATE:IsCourseMode() then return end

local t = Def.ActorFrame{}

for player in ivalues( PlayerNumber ) do
	-- Just the button for toggling the menu on/off with the mouse.
	t[#t+1] = LoadActor("./Button.lua", player)
	-- Literally everything, i'm sorry.
	t[#t+1] = LoadActor("./Menu.lua", player)
end

-- Input to control the menu, oh no.
t[#t+1] = LoadActor("./MenuInput.lua", player)
-- Some functions used in the player menu
t[#t+1] = LoadActor("./Menu-Functions.lua")


return t