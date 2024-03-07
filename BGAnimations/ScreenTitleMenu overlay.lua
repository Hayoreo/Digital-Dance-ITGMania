local af = Def.ActorFrame{
	OnCommand=function()
		-- defined in ./Scripts/DD-SupportHelpers.lua
		if not StepManiaVersionIsSupported() then
			SM( THEME:GetString("ScreenInit", "UnsupportedSMVersion"):format(ProductID(), ProductVersion()) )
			-- ScreenSystemOptions is the first choice in the operator menu
			-- players can set their game, theme, default NoteSkin, etc. from it
			SCREENMAN:SetNewScreen("ScreenSystemOptions")
		end

		-- also defined in ./Scripts/DD-SupportHelpers.lua
		if not CurrentGameIsSupported() then
			-- Display a SystemMessage alerting the player that their current game is not playable in SL.
			-- We can display a SystemMessage here and it will persist into ScreenSelectGame, because SystemMessages
			-- are part of the always-present ScreenSystemLayer overlay.
			SM( THEME:GetString("ScreenInit", "UnsupportedGame"):format(GAMESTATE:GetCurrentGame():GetName()) )
			-- don't politely transition from ScreenInit to ScreenSystemOptions with fades; just get the player there now
			SCREENMAN:SetNewScreen("ScreenSystemOptions")
		end
	end,
-- Mouse moment
LoadActor(THEME:GetPathB("", "_modules/Mouse Cursor/default.lua"))
}

return af