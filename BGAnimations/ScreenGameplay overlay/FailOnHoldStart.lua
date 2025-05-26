-- Check if the player gave up before the song properly ended.

local usedAutoplay = {
	[PLAYER_1] = false,
	[PLAYER_2] = false
}

local af = Def.ActorFrame{
	JudgmentMessageCommand=function(self, params)
		if params.Player == nil then return end
		
		if IsAutoplay(params.Player) then
			usedAutoplay[params.Player] = true
		end
	end,
	OffCommand=function(self)
		-- In ITGMania the GaveUp() function is available.
		local stage_stats = STATSMAN:GetCurStageStats()
		local fail = false
		if stage_stats.GaveUp then
			fail = stage_stats:GaveUp()
		end

		-- We have to fail both players as we stopped the song early.
		for player in ivalues( GAMESTATE:GetEnabledPlayers() ) do
			if fail or usedAutoplay[player] then
				STATSMAN:GetCurStageStats():GetPlayerStageStats(player):FailPlayer()
			end
		end
	end,
}

return af
