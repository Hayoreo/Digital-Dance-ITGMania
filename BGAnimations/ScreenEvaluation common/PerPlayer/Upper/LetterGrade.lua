local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()

-- QUINT
local ex = CalculateExScore(player, GetExJudgmentCounts(player))
if ex == 100 then grade = "Grade_Tier00" end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(70 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-138)
	end,
	OnCommand=function(self) self:zoom(0.38) end
}

return t