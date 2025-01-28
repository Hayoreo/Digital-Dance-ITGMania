local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

if not mods.SubtractiveScoring then return end
local FAPlusCount = 0
local HeldCount = 0
local ex_actual
local ex_possible
local ex_score
local HasFailed = false
local possible_dp
local current_possible_dp
local actual_dp
local score
-- -----------------------------------------------------------------------

local undesirable_judgment = "W2"

-- flag to determine whether to bother to continue counting excellents
-- or whether to just display percent away from 100%
local received_judgment_lower_than_desired = false

-- this starts at 0 for each song/course
-- (but does not reset to 0 between each song in a course)
local undesirable_judgment_count = 0

-- variables for tapnotescore and holdnotescore that need file scope
local tns, hns

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

-- which font should we use for the BitmapText actor?
local font = mods.ComboFont

-- most ComboFonts have their own dedicated sprite sheets in ./Digital Dance/Fonts/_Combo Fonts/
-- "Wendy" and "Wendy (Cursed)" are exceptions for the time being; reroute both to use "./Fonts/Wendy/_wendy small"
if font == "Wendy" or font == "Wendy (Cursed)" then
	font = "Wendy/_wendy small"
else
	font = "_Combo Fonts/" .. font .. "/"
end

-- -----------------------------------------------------------------------
local GetPossibleExScore = function(counts)
	local best_counts = {}

	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then
			-- Initialize the keys	
			if best_counts[key] == nil then
				best_counts[key] = 0
			end

			-- Upgrade dropped holds/rolls to held.
			if key == "LetGo" or key == "Held" then
				best_counts["Held"] = best_counts["Held"] + value
			-- We never hit any mines.
			elseif key == "HitMine" then
				best_counts[key] = 0
			-- Upgrade to FA+ window.
			else
				best_counts["W0"] = best_counts["W0"] + value
			end
		end
	end

	return CalculateExScore(player, best_counts)
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
	-- stop updating subtractive score and show the total lost score if the player failed.
	if GAMESTATE:GetPlayerState(player):GetHealthState() == "HealthState_Dead" and HasFailed == false then
		if mods.ShowEXScore then
			local percent
			HasFailed = true
			percent = 100 - ex_actual
			self:settext( ("-%.2f%%"):format(percent) )
		else
			HasFailed = true
			local dance_points = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints() * 100
			local percent = 100-dance_points
			self:settext( ("-%.2f%%"):format(percent) )
		end
	end
	if player == params.Player and not mods.ShowEXScore and not HasFailed then
		tns = ToEnumShortString(params.TapNoteScore)
		hns = params.HoldNoteScore and ToEnumShortString(params.HoldNoteScore)
		self:queuecommand("SetScore")
	end
end

bmt.ExCountsChangedMessageCommand=function(self, params)
	if player == params.Player and mods.ShowEXScore then
		local update = true
		-- don't update the score if we have the best judgement because constantly rounding is distracting/annoying.
		if params.ExCounts["W0"] == FAPlusCount + 1 then
			FAPlusCount = FAPlusCount + 1
			update = false
		elseif params.ExCounts["Held"] == HeldCount + 1 then
			HeldCount = HeldCount + 1
			update = false
		end
		
		ex_actual = params.ExScore
		ex_possible = GetPossibleExScore(params.ExCounts)
		ex_score = ex_possible - ex_actual

		-- handle floating point equality.
		if ex_score >= 0.0001 and update then
			self:settext( ("-%.2f%%"):format(ex_score) )
		end
	end
end

-- This is a bit convoluted!
-- If this is a W2/undesirable_judgment, then we want to count up to 10 with them,
-- unless we get some other judgment worse than W2/undesirable_judgment.
-- The complication is in how hold notes are counted.
--
-- Hold note judgments contain a copy of the tap
-- note judgment that started it (because it affects your life regen?), so
-- we have to be careful not to double count it against you.  But we also
-- want a dropped hold to trigger the percentage scoring.  So the
-- choice is having a more straightforward if else structure, but at the
-- expense of repeating the percent displaying code vs a more complicated
-- if else structure. DRY, so second.

bmt.SetScoreCommand=function(self, params)
	-- used to determine if a player has failed yet
	local topscreen = SCREENMAN:GetTopScreen()

	-- if the player adjusts the sync of the stepchart during gameplay, they will eventually
	-- reach ScreenPrompt, where they'll be prompted to accept or reject the sync changes.
	-- Although the screen changes, this Lua sticks around, and the TopScreen will no longer
	-- have a GetLifeMeter() method.
	if topscreen.GetLifeMeter == nil then return end

	-- if this is an undesirable judgment AND we can still count up AND it's not a dropped hold
	if tns == undesirable_judgment
	and not received_judgment_lower_than_desired
	and undesirable_judgment_count < 10
	and (hns ~= "LetGo") then
		-- if this is the tail of a hold note, don't double count it
		if not hns then
			-- increment for the first ten
			undesirable_judgment_count = undesirable_judgment_count + 1
			-- and specify literal W2 count
			self:settext("-" .. undesirable_judgment_count)
		end

	-- else if this wouldn't subtract from percentage (W1 or mine miss)
	elseif tns ~= "W1" and tns ~= "AvoidMine"
	-- unless it actually would subtract from percentage (W1 + let go)
	or (hns == "LetGo")
	-- or we're already dead (and so can't gain any percentage.)
	or (topscreen:GetLifeMeter(player):IsFailing()) then

		received_judgment_lower_than_desired = true

		-- FIXME: I really need to figure out what the calculations are doing and describe that here.  -quietly

		-- PossibleDancePoints and CurrentPossibleDancePoints change as the song progresses and judgments
		-- are earned by the player; these values need to be continually fetched from the engine
		possible_dp = pss:GetPossibleDancePoints()
		current_possible_dp = pss:GetCurrentPossibleDancePoints()

		-- max to prevent subtractive scoring reading more than -100%
		actual_dp = math.max(pss:GetActualDancePoints(), 0)

		score = current_possible_dp - actual_dp
		score = math.floor(((possible_dp - score) / possible_dp) * 10000) / 100

		-- specify percent away from 100%
		if 100-score >= 0.01 then
			self:settext( ("-%.2f%%"):format(100-score) )
		else
			self:settext("")
		end
	end
end

return bmt
