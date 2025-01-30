local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

if not mods.SubtractiveScoring then return end
local chart = GAMESTATE:GetCurrentSteps(player)

local NoteCount = chart:GetRadarValues(player):GetValue('RadarCategory_TapsAndHolds')
local HoldCount = chart:GetRadarValues(player):GetValue('RadarCategory_Holds')
local RollCount = chart:GetRadarValues(player):GetValue('RadarCategory_Rolls')
local MineCount = chart:GetRadarValues(player):GetValue('RadarCategory_Mines')
local Score
local PossibleScore
local CurrentPossibleScore
local ActualScore
local HasFailed = false
local IsNumber = true
local FAPlusCount = 0
local HeldCount = 0
local ex_actual
local ex_possible
local ex_score
local MinesHit = 0
local HoldsRollsDropped = 0
-- -----------------------------------------------------------------------

local undesirable_judgment = mods.ShowEXScore and "W1" or "W2"
local undesirable_judgment_count = 0

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

-- which font should we use for the BitmapText actor?
local font = mods.ComboFont or "Wendy"

-- most ComboFonts have their own dedicated sprite sheets in ./Digital Dance/Fonts/_Combo Fonts/
-- "Wendy" and "Wendy (Cursed)" are exceptions for the time being; reroute both to use "./Fonts/Wendy/_wendy small"
if font == "Wendy" or font == "Wendy (Cursed)" then
	font = "Wendy/_wendy small"
else
	font = "_Combo Fonts/" .. font .. "/"
end

-- -----------------------------------------------------------------------
local GetCurrentExScore = function(player, ex_counts, PotentialNotes, PotentialHoldsRolls)
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	
	local W0Weight = SL.ExWeights["W0"]
	local total_possible = NoteCount * W0Weight + (HoldCount + RollCount) * SL.ExWeights["Held"]

	local total_points = 0
	
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

	-- If mines are disabled, they should still be accounted for in EX Scoring based on the weight assigned to it.
	-- Stamina community does often play with no-mines on, but because EX scoring is more timing centric where mines
	-- generally have a negative weight, it's a better experience to make sure the EX score reflects that.
	if po:NoMines() then
		local totalMines = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Mines" ) - MinesHit
		total_points = total_points + totalMines * SL.ExWeights["HitMine"];
	end
	
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }
	local counts = ex_counts
	counts["W0"] = counts["W0"] + PotentialNotes
	counts["Held"] = counts["Held"] + PotentialHoldsRolls
	-- Just for validation, but shouldn't happen in normal gameplay.
	if counts == nil then return 0 end
	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then		
			total_points = total_points + value * SL.ExWeights[key]
		end
	end
	return math.max(0, math.floor(total_points/total_possible * 10000) / 100)
end

-- -----------------------------------------------------------------------
local GetPossibleExScore = function(counts)
	local best_counts = {}
	local TotalStepsHit = 0
	local PotentialNotes = 0
	local PotentialHoldsRolls = 0
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then
			-- Initialize the keys	
			if best_counts[key] == nil then
				best_counts[key] = 0
			end

			-- Upgrade dropped holds/rolls to held.
			best_counts[key] = best_counts[key] + value
			if key == "W0" or key == "W1" or key == "W2" or key == "W3" or key == "W4" or key == "W5" or key == "Miss" then
				TotalStepsHit = TotalStepsHit + value
			elseif key ==  "Held" or key ==  "LetGo" then
				PotentialHoldsRolls = PotentialHoldsRolls + value
			elseif key == "HitMine" then
				MinesHit = MinesHit + 1
			end
		end
	end
	if IsNumber then
		if best_counts["W1"] > 10 then
			IsNumber = false
		else
			undesirable_judgment_count = best_counts["W1"]
		end
	end
	PotentialNotes = NoteCount - TotalStepsHit
	PotentialHoldsRolls = HoldCount - PotentialHoldsRolls
	return GetCurrentExScore(player, best_counts, PotentialNotes, PotentialHoldsRolls)
end

-- -----------------------------------------------------------------------

-- the BitmapText actor
local bmt = LoadFont(font)

bmt.InitCommand=function(self)
	if mods.ShowEXScore then
		self:diffuse(SL.JudgmentColors["FA+"][1])
	else
		self:diffuse(color("#ff55cc"))
	end
	self:zoom(0.35):shadowlength(1):horizalign(center)

	local width = GetNotefieldWidth()
	local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
	-- mirror image of MeasureCounter.lua
	self:xy( GetNotefieldX(player) + (width/NumColumns), _screen.cy )

	-- Fix overlapping issue when MeasureCounter is enabled, not moved up, and displaying lookahead
	-- since the lookaheads will overlap subtractive scoring.
	if mods.MeasureCounter ~= "None" and not mods.MeasureCounterUp and not mods.HideLookahead then
		self:addy(-55)
	end

	-- Fix overlap issues when MeasureCounter is centered
	-- since in this case we don't need symmetry.
	if (mods.MeasureCounterLeft == false) then
		self:horizalign(left)
		-- nudge slightly left (15% of the width of the bitmaptext when set to "100.00%")
		self:settext("100.00%"):addx( -self:GetWidth()*self:GetZoom() * 0.15 )
		self:settext("")
	end
end

bmt.JudgmentMessageCommand=function(self, params)
	if player == params.Player and not mods.ShowEXScore and not HasFailed then
		-- stop updating subtractive score and show the total lost score if the player failed.
		if GAMESTATE:GetPlayerState(player):GetHealthState() == "HealthState_Dead" and HasFailed == false then
			HasFailed = true
			local dance_points = pss:GetPercentDancePoints() * 100
			local percent = 100-dance_points
			self:settext( ("-%.2f%%"):format(percent) )
		end
		-- Check to see if we still want to show the players excellent count
		if IsNumber then
			if 	params.TapNoteScore ~= nil and 
					ToEnumShortString(params.TapNoteScore) ~= "W1" and 
					ToEnumShortString(params.TapNoteScore) ~= "W2" and 
					ToEnumShortString(params.TapNoteScore) ~= "AvoidMine" then
				IsNumber = false
			elseif params.HoldNoteScore ~= nil and ToEnumShortString(params.HoldNoteScore) ~= "Held" then
				IsNumber = false
			end
		end
		self:queuecommand('SetScore')
	end
	if player == params.Player and mods.ShowEXScore and not HasFailed then
		if IsNumber then
			if params.TapNoteScore ~= nil and 
					ToEnumShortString(params.TapNoteScore) ~= "W1" and 
					ToEnumShortString(params.TapNoteScore) ~= "AvoidMine" then
				IsNumber = false
			elseif params.HoldNoteScore ~= nil and ToEnumShortString(params.HoldNoteScore) ~= "Held" then
				IsNumber = false
			end
		end
	end
end

bmt.ExCountsChangedMessageCommand=function(self, params)
	if player == params.Player and mods.ShowEXScore then
		if params.HasFailed then
			HasFailed = true
			local ExScore = params.ExScore
			local percent = 100 - ExScore
			self:settext( ("-%.2f%%"):format(percent) )
		end
		if not HasFailed then
			ex_possible = GetPossibleExScore(params.ExCounts)
			if undesirable_judgment_count > 10 then
				IsNumber = false
			end
			if not IsNumber then
				ex_score = 100 - ex_possible
				-- handle floating point equality.
				if ex_score >= 0.0001 then
					self:settext( ("-%.2f%%"):format(ex_score) )
				end
			elseif undesirable_judgment_count > 0 and undesirable_judgment_count < 11 then
				self:settext("-" .. undesirable_judgment_count)
			else
				self:settext("")
			end
		end
	end
end

bmt.SetScoreCommand=function(self, params)	
	if not mods.ShowEXScore and not HasFailed then
		undesirable_judgment_count = pss:GetTapNoteScores('TapNoteScore_W2')
		if undesirable_judgment_count > 10 then
			IsNumber = false
		end
		if not IsNumber then
			PossibleScore = pss:GetPossibleDancePoints()
			CurrentPossibleScore = pss:GetCurrentPossibleDancePoints()
			
			ActualScore = pss:GetActualDancePoints()
			Score = CurrentPossibleScore - ActualScore
			
			Score = math.floor(((PossibleScore - Score) / PossibleScore) * 10000) / 100
			
			-- specify percent away from 100%
			if 100-Score >= 0.001 then
				self:settext( ("-%.2f%%"):format(100-Score) )
			else
				self:settext("")
			end
		elseif undesirable_judgment_count > 0 then
			self:settext("-" .. undesirable_judgment_count)
		else
			self:settext("")
		end
	end
end

return bmt
