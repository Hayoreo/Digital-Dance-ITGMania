--- This is the script that will end a song early if it's cut or the chart ends sooner than other charts.

-- Let's not use this in course mode.
if not GAMESTATE:IsCourseMode() then
	local sTable = GAMESTATE:GetCurrentSong():GetStepsByStepsType( "StepsType_Dance_Single" );
	local nsj = GAMESTATE:GetNumSidesJoined()

	for playerIndex=0,1 do
		if GAMESTATE:IsPlayerEnabled(playerIndex) then
			local difficulty = GAMESTATE:GetCurrentSteps(playerIndex):GetDifficulty()
		end
	end

	-- Populate stats
	local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
	local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)
	local TotalMinesP1
	local TotalMinesP2
	
	local IsNoMinesP1 = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions(3):NoMines()
	local IsNoMinesP2 = GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptions(3):NoMines()
	
	if GAMESTATE:IsPlayerEnabled(0) then
		if IsNoMinesP1 then
			TotalMinesP1 = 0
		else
			TotalMinesP1 = PlayerOneChart:GetRadarValues(playerIndex):GetValue('RadarCategory_Mines')
		end
	end
	if GAMESTATE:IsPlayerEnabled(1) then
		if IsNoMinesP2 then
			TotalMinesP2 = 0
		else
			TotalMinesP2 = PlayerTwoChart:GetRadarValues(playerIndex):GetValue('RadarCategory_Mines')
		end
	end
	
	local Player1MinesAvoided = 0
	local Player2MinesAvoided = 0
	
	local function IsSongOver()
		local P1IsNotDone = 0
		local P2IsNotDone = 0
		
		--- this is stupid but #stepmania-moment
		local statsP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats("P1")
		local statsP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats("P2")

		local curMaxPointsP1 = statsP1:GetCurrentPossibleDancePoints()
		local curMaxPointsP2 = statsP2:GetCurrentPossibleDancePoints()

		local totalPointsP1 = statsP1:GetPossibleDancePoints()
		local totalPointsP2 = statsP2:GetPossibleDancePoints()

		local MinesHitP1 = statsP1:GetTapNoteScores('TapNoteScore_HitMine')
		local MinesHitP2 = statsP2:GetTapNoteScores('TapNoteScore_HitMine')

		local MinesPassedByP1 = MinesHitP1 + Player1MinesAvoided
		local MinesPassedByP2 = MinesHitP2 + Player2MinesAvoided
		
		local LastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()
		local CurrentSecond = GAMESTATE:GetCurMusicSeconds()

		if nsj == 2 then
			if curMaxPointsP1 ~= totalPointsP1 then
				P1IsNotDone = P1IsNotDone + 1
			end
			if curMaxPointsP2 ~= totalPointsP2 then
				P2IsNotDone = P2IsNotDone + 1
			end
			if MinesPassedByP1 ~= TotalMinesP1 then
				P1IsNotDone = P1IsNotDone + 1
			end
			if MinesPassedByP2 ~= TotalMinesP2 then
				P2IsNotDone = P2IsNotDone + 1
			end
		else
			if GAMESTATE:IsPlayerEnabled(0) then
				if curMaxPointsP1 ~= totalPointsP1 then
					P1IsNotDone = P1IsNotDone + 1
				end
				if MinesPassedByP1 ~= TotalMinesP1 then
					P1IsNotDone = P1IsNotDone + 1
				end
			elseif GAMESTATE:IsPlayerEnabled(1) then
				if curMaxPointsP2 ~= totalPointsP2 then
					P2IsNotDone = P2IsNotDone + 1
				end
				if MinesPassedByP2 ~= TotalMinesP2 then
					P2IsNotDone = P2IsNotDone + 1
				end
			end
		end

		local isDone
		if nsj == 2 then
			if IsNoMinesP1 or IsNoMinesP2 then
				isDone = CurrentSecond >= LastSecond
			else
				isDone = P1IsNotDone == 0 and P2IsNotDone == 0
			end
		else
			if GAMESTATE:IsPlayerEnabled(0) then
				if IsNoMinesP1 then
					isDone = CurrentSecond >= LastSecond
				else
					isDone = P1IsNotDone == 0
				end
			elseif GAMESTATE:IsPlayerEnabled(1) then
				if IsNoMinesP2 then
					isDone = CurrentSecond >= LastSecond
				else
					isDone = P2IsNotDone == 0
				end
			end
		end

		return isDone
	end
		---- set last difficulty played
	if not GAMESTATE:IsCourseMode() then
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			DDStats.SetStat(PLAYER_1, 'LastDifficulty', PlayerOneChart:GetDifficulty())
			DDStats.Save(PLAYER_1)
		end

		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			DDStats.SetStat(PLAYER_2, 'LastDifficulty', PlayerTwoChart:GetDifficulty())
			DDStats.Save(PLAYER_2)
		end
	else
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			local PlayerOneCourse = GAMESTATE:GetCurrentTrail(0)
			DDStats.SetStat(PLAYER_1, 'LastCourseDifficulty', PlayerOneCourse:GetDifficulty())
			DDStats.Save(PLAYER_1)
		end

		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			local PlayerTwoCourse = GAMESTATE:GetCurrentTrail(1)
			DDStats.SetStat(PLAYER_2, 'LastCourseDifficulty', PlayerTwoCourse:GetDifficulty())
			DDStats.Save(PLAYER_2)
		end
	end
	local t = Def.ActorFrame {
			OnCommand=function(self)
				self:sleep(999999)
			end,
			Def.ActorFrame {
				JudgmentMessageCommand=function(self, params)
					if params.TapNoteScore == "TapNoteScore_AvoidMine" then
						if params.Player == PLAYER_1 then
							Player1MinesAvoided = Player1MinesAvoided + 1
						end
						if params.Player == PLAYER_2 then
							Player2MinesAvoided = Player2MinesAvoided + 1
						end
					end
				end,
			},
			Def.ActorFrame {
				OnCommand=function(self)
					self:sleep(0.1):queuecommand('CheckEnd')
				end,
				CheckEndCommand=function(self)
					if IsSongOver() then
						self:sleep(0.4):queuecommand('Finished')
					else
						self:sleep(0.1):queuecommand('CheckEnd')
					end
				end,
				FinishedCommand=function(self)
					SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_DoNextScreen")
				end,
			}
		}
	return t
end