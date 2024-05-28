local FirstPass = true
local RandomSound = nil

local FilesP1
local FilesP2
local SoundsP1 = {}
local SoundsP2 = {}
local PlaySound

if GAMESTATE:IsPlayerEnabled(0) and PROFILEMAN:GetProfileDir(0) ~= nil then
	FilesP1 = FILEMAN:GetDirListing(PROFILEMAN:GetProfileDir(0) .. 'WRSounds/', false, true)
	for file in ivalues(FilesP1) do
		local extension = file:match('[.](.*)$')
		if extension == 'ogg' or extension == 'mp3' then
			SoundsP1[#SoundsP1+1] = file
		end
	end
end

if GAMESTATE:IsPlayerEnabled(1) and PROFILEMAN:GetProfileDir(1) ~= nil then
	FilesP2 = FILEMAN:GetDirListing(PROFILEMAN:GetProfileDir(1) .. 'WRSounds/', false, true)
	for file in ivalues(FilesP2) do
		local extension = file:match('[.](.*)$')
		if extension == 'ogg' or extension == 'mp3' then
			SoundsP2[#SoundsP2+1] = file
		end
	end
end


-- don't try to play a sound if the folder is empty.
if #SoundsP1 ~= 0 then
	RandomSoundP1 = SoundsP1[math.random(#SoundsP1)]
end
if #SoundsP2 ~= 0 then
	RandomSoundP2 = SoundsP2[math.random(#SoundsP2)]
end

local af = Def.ActorFrame {
	InitCommand=function(self)
		-- If the GSL is disabled and we got a quad we still want to play a sound.
		if not IsServiceAllowed(SL.GrooveStats.Leaderboard) then
			for i=1,2 do
				local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(i-1)
				local PercentDP = stats:GetPercentDancePoints()
				local percent = FormatPercentScore(PercentDP)
				if percent == "100.00%" then
					self:playcommand("PlayRandomWRSound", {"P"..i})
				end
			end
		end
	end,
	PlayRandomWRSoundMessageCommand=function(self, params)
		self:sleep(2)
		local Player = params[1]
		
		if FirstPass == true and ((Player == "P1" and RandomSoundP1 ~= nil) or (Player == "P2" and RandomSoundP2 ~= nil)) then
			self:queuecommand("StartSound"..Player)
			FirstPass = false
		end
	end,

	Def.Sound {
		File=RandomSoundP1,
		IsAction=false,

		StartSoundP1Command=function(self, params)
			self:play()
		end,

		StopWRSoundMessageCommand=function(self)
			self:stop()
		end,
	},
	
	Def.Sound {
		File=RandomSoundP2,
		IsAction=false,

		StartSoundP2Command=function(self, params)
			self:play()
		end,

		StopWRSoundMessageCommand=function(self)
			self:stop()
		end,
	},
}

return af