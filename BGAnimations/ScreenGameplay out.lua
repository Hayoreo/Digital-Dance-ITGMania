return Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:sleep(0.5):linear(1):diffusealpha(1) end,
	OffCommand=function(self)
		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local pn = ToEnumShortString(player)
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			local number = pss:GetTapNoteScores("TapNoteScore_W1")
			local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W0_total
			-- Subtract FA+ count from the overall fantastic window count.
			whites = number - faPlus
			-- This will save the white count to Stats.xml, so we can later recover
			-- it when we deprecate FA+ mode and introduce W0.
			--
			-- The Score field is completely unused in Simply Love, and the ability
			-- to set the field is exposed to lua so we can hijack it for our own\
			-- purposes.
			--
			-- TODO(teejusb): Remove once we have W0 support in ITGmania.
			-- Let's also check to make sure the score has improved before saving the white counts this way.
			local song = GAMESTATE:GetCurrentSong()
			local chart = GAMESTATE:GetCurrentSteps(pn)
			local scores = PROFILEMAN:GetProfile(pn):GetHighScoreList(song,chart):GetHighScores()
			
			-- obviously if we do worse don't update it.
			if pss:GetPercentDancePoints() > scores[1]:GetPercentDP() then
				pss:SetScore(whites)
			--- In most cases this will be a requad
			elseif pss:GetPercentDancePoints() == scores[1]:GetPercentDP() then
				-- Only update white count if it's improved from the previous score.
				if whites < scores[1]:GetScore() then
					pss:SetScore(whites)
				end
			end
		end
	end
}