-- -----------------------------------------------------------------------
-- Helper Functions for PlayerOptions
-- -----------------------------------------------------------------------

local GetModsAndPlayerOptions = function(player)
	local mods = SL[ToEnumShortString(player)].ActiveModifiers
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
	local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)

	return mods, playeroptions
end

-- -----------------------------------------------------------------------
-- For normal gameplay, the engine offers SongUtil.GetPlayableSteps()
-- but there is not currently any analogous helper function for CourseMode.
-- Let's use this for now.

local GetPlayableTrails = function(course)
	if not (course and course.GetAllTrails) then return nil end

	local trails = {}
	for _,trail in ipairs(course:GetAllTrails()) do
		local playable = true
		for _,entry in ipairs(trail:GetTrailEntries()) do
			if not SongUtil.IsStepsTypePlayable(entry:GetSong(), entry:GetSteps():GetStepsType()) then
				playable = false
				break
			end
		end
		if playable then table.insert(trails, trail) end
	end

	return trails
end

-- shorthand function for setting an engine level modifier
SetEngineMod = function(player, name, value)
	local mods = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
    mods[name](mods, value)
end

GetEffectiveSpeedModType = function(player, type)
	type = type or "X"

	if type ~= "D" then return type end

	-- TODO : Course mode does not work.
	--[[
	if GAMESTATE:IsCourseMode() then
		SM("WTF")
		return "M"
	end
	]]--

	local steps = GAMESTATE:GetCurrentSteps(player)
	if steps == nil then return "M" end
	
	local song = GAMESTATE:GetCurrentSong()
	if song == nil then return "M" end
	
	local pack = tostring(song:GetGroupName():lower())
	local subtitle = tostring(song:GetDisplaySubTitle():lower())
	local name = "ITL"
	local mod = "No CMOD"
	
	-- ITL Check first, then normal behavior otherwise.
	if pack:find(name:lower()) then
		if subtitle:find(mod:lower()) then
			return "M"
		else
			return "C"
		end
	end
	
	local timingData = steps:GetTimingData()
	local displayBpms = steps:GetDisplayBpms()
	
	local hasShit = (
		timingData:HasDelays()
		or timingData:HasScrollChanges()
		or timingData:HasSpeedChanges()
		or timingData:HasStops()
		or timingData:HasWarps()
	)

	local hasBpms = #displayBpms == 2 and displayBpms[1] ~= displayBpms[2]

	if hasBpms or hasShit then
		return "M"
	else
		return "C"
	end
end

-- -----------------------------------------------------------------------
-- when to use Choices() vs. Values()
--
-- Each OptionRow needs stringified choices to present to the player.  Sometimes using hardcoded strings
-- is okay. For example, SpeedModType choices (x, C, M) are the same in English as in French.
--
-- Other times, we need to be able to localize the choices presented to the player but also
-- maintain an internal value that code within the theme can rely on regardless of language.
--
-- For each of the subtables in Overrides, you must specify 'Choices' and/or 'Values' depending on your
-- needs. Each can be either a table of strings or a function that returns a table of strings.
-- Using a function can be helpful when the OptionRow needs to present different options depending
-- on certain conditions.
--
-- If you specify only 'Choices', the engine presents the strings exactly as-is and also uses those
-- same strings internally.
--
-- If you specify only 'Values', the engine will use those raw strings internally but localize them
-- using the corresponding display strings in en.ini (or es.ini, fr.ini, etc.) for the user.
--
-- If you specify both, then the strings in 'Choices' are presented as-is,
-- but the strings in 'Values' are what the theme stores into the ActiveModifiers table.

------------------------------------------------------------

-- Define SL's custom OptionRows that appear in ScreenPlayerOptions as subtables within Overrides.
-- As an OptionRow, each subtable is expected to have specific key/value pairs:
--
-- ExportOnChange (boolean)
-- 	false if unspecified; if true, calls SaveSelections() whenever the current choice changes
-- LayoutType (string)
-- 	"ShowAllInRow" if unspecified; you can set it to "ShowOneInRow" if needed
-- OneChoiceForAllPlayers (boolean)
-- 	false if unspecified
-- SelectType (string)
-- 	"SelectOne" if unspecified; you can set it to "SelectMultiple" if needed
-- LoadSelections (function)
-- 	normally (in other themes) called when the PlayerOption screen initializes
-- 	read the notes surrounding ApplyMods() for further discussion of additional work SL does
-- SaveSelections (function)
-- 	this is where you should do whatever work is needed to ensure that the player's choice
-- 	persists beyond the PlayerOptions screen; normally called around the time of ScreenPlayerOption's
-- 	OffCommand; can also be called because ExportOnChange=true


-- It's not necessary to define each possible key for each OptionRow.  Anything you don't specify
-- will use fallback values in OptionRowDefault (defined later, below).

local Overrides = {

	-------------------------------------------------------------------------
	SpeedModType = {
		Values = { "X", "C", "M", "D" },
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			for i=1,#list do
				if list[i] then
					-- Broadcast a message that ./BGAnimations/ScreenPlayerOptions overlay.lua will be listening for
					-- so it can hackishly modify the single BitmapText actor used in the SpeedMod optionrow
					MESSAGEMAN:Broadcast('SpeedModType'..ToEnumShortString(pn)..'Set', {SpeedModType=self.Values[i], Player=pn})
				end
			end
		end
	},
	-------------------------------------------------------------------------
	SpeedMod = {
		Choices = { "       " },
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			local type = GetEffectiveSpeedModType(pn, mods.SpeedModType)

			local speed = mods.SpeedMod or 1.00

			playeroptions[type.."Mod"](playeroptions, speed)
		end
	},
	-------------------------------------------------------------------------
	NoteSkin = {
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		Choices = function()

			local all = NOTESKIN:GetNoteSkinNames()

			if ThemePrefs.Get("HideStockNoteSkins") then
				local game = GAMESTATE:GetCurrentGame():GetName()

				-- Apologies, midiman. :(
				local stock = {
					dance = {
						"default", "delta", "easyv2", "exactv2", "lambda", "midi-note",
						"midi-note-3d", "midi-rainbow", "midi-routine-p1", "midi-routine-p2",
						"midi-solo", "midi-vivid", "midi-vivid-3d", "retro", "retrobar",
						"retrobar-splithand_whiteblue"
					},
					pump = {
						"cmd", "cmd-routine-p1", "cmd-routine-p2", "complex", "default",
						"delta", "delta-note", "delta-routine-p1", "delta-routine-p2",
						"frame5p", "newextra", "pad", "rhythm", "simple"
					},
				}
				if stock[game] then
					for stock_noteskin in ivalues(stock[game]) do
						for i=1,#all do
							if stock_noteskin == all[i] then
								table.remove(all, i)
								break
							end
						end
					end
				end
			end

			-- It's possible a user might want to hide stock noteskins
			-- but only have stock noteskins.  If so, just return all noteskins.
			if #all == 0 then all = NOTESKIN:GetNoteSkinNames() end

			return all
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			for i, val in ipairs(self.Choices) do
				if list[i] then mods.NoteSkin = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the NoteSkin preview
			MESSAGEMAN:Broadcast('NoteSkinChanged', {Player=pn, NoteSkin=mods.NoteSkin})
			playeroptions:NoteSkin( mods.NoteSkin )
		end
	},
	-------------------------------------------------------------------------
	JudgmentGraphic = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function() return map(StripSpriteHints, GetJudgmentGraphics()) end,
		Values = function() return GetJudgmentGraphics() end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			for i, val in ipairs(self.Values) do
				if list[i] then mods.JudgmentGraphic = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the Judgment preview
			MESSAGEMAN:Broadcast("JudgmentGraphicChanged", {Player=pn, JudgmentGraphic=StripSpriteHints(mods.JudgmentGraphic)})
		end
	},
	-------------------------------------------------------------------------
	HeldGraphic = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function() return map(StripSpriteHints, GetHeldMissGraphics()) end,
		Values = function() return GetHeldMissGraphics() end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			for i, val in ipairs(self.Values) do
				if list[i] then mods.HeldGraphic = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the Judgment preview
			MESSAGEMAN:Broadcast("RefreshActorProxy", {Player=pn, Name="HeldGraphic", Value=StripSpriteHints(mods.HeldGraphic)})
		end
	},
	-------------------------------------------------------------------------
	HoldJudgment = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function() return map(StripSpriteHints, GetHoldJudgments()) end,
		Values = function() return GetHoldJudgments() end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			for i, val in ipairs(self.Values) do
				if list[i] then mods.HoldJudgment = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the HoldJudgment preview
			MESSAGEMAN:Broadcast("HoldJudgmentChanged", {Player=pn, HoldJudgment=StripSpriteHints(mods.HoldJudgment)})
		end
	},
	-------------------------------------------------------------------------
	ComboFont = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function() return GetComboFonts() end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			for i, val in ipairs(self.Choices) do
				if list[i] then mods.ComboFont = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the ComboFont preview
			MESSAGEMAN:Broadcast("ComboFontChanged", {Player=pn, ComboFont=mods.ComboFont})
		end
	},
	-------------------------------------------------------------------------
	BackgroundFilter = {
		Values = { 'Off','Dark','Darker','Darkest' },
	},
	-------------------------------------------------------------------------
	Mini = {
		Choices = function()
			local first	= -100
			local last 	= 150
			local step 	= 1

			return stringify( range(first, last, step), "%g%%")
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			for i=1,#self.Choices do
				if list[i] then
					mods.Mini = self.Choices[i]
				end
			end

			-- to make the arrows smaller, pass Mini() a value between 0 and 1
			-- (to make the arrows bigger, pass Mini() a value larger than 1)
			playeroptions:Mini( mods.Mini:gsub("%%","")/100 )
		end
	},
	-------------------------------------------------------------------------
	GhostWindow = {
		Choices = function()
			local first	= 0
			local last 	= 23
			local step 	= 1

			return stringify( range(first, last, step), "%g")
		end,
		LoadSelections = function(self, list, pn)
			local val = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.GhostWindow) or 0
			for i,v in ipairs(self.Choices) do
				if v == val then
					list[i] = true
					break
				end
			end
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Choices) do
				if list[i] then
					SL[ToEnumShortString(pn)].ActiveModifiers.GhostWindow = v
					break
				end
			end
		end,
	},
	-------------------------------------------------------------------------
	JudgmentSize = {
		Choices = function()
			local first	= -200
			local last 	= 200
			local step 	= 1

			return stringify( range(first, last, step), "%g")
		end,
		LoadSelections = function(self, list, pn)
			local val = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.JudgmentSize) or 0
			for i,v in ipairs(self.Choices) do
				if v == val then
					list[i] = true
					break
				end
			end
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Choices) do
				if list[i] then
					SL[ToEnumShortString(pn)].ActiveModifiers.JudgmentSize = v
					break
				end
			end
		end,
	},
	-------------------------------------------------------------------------
	MusicRate = {
		Choices = function()
			local first	= 1
			local last 	= 3
			local step 	= 0.01

			return stringify( range(first, last, step), "%g")
		end,
		ExportOnChange = true,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			local rate = ("%g"):format( SL.Global.ActiveModifiers.MusicRate )
			local i = FindInTable(rate, self.Choices) or 1
			list[i] = true
			return list
		end,
		SaveSelections = function(self, list, pn)

			local mods = SL.Global.ActiveModifiers

			for i=1,#self.Choices do
				if list[i] then
					mods.MusicRate = tonumber( self.Choices[i] )
				end
			end

			local topscreen = SCREENMAN:GetTopScreen():GetName()

			-- Use the older GameCommand interface for applying rate mods in Edit Mode;
			-- it seems to be the only way (probably due to how broken Edit Mode is, in general).
			-- As an unintentional side-effect of setting musicrate mods this way, they STAY set
			-- (between songs, between screens, etc.) until you manually change them.  This is (probably)
			-- not the desired behavior in EditMode, so when users change between different songs in EditMode,
			-- always reset the musicrate mod.  See: ./BGAnimations/ScreenEditMeny underlay.lua
			if topscreen ~= "ScreenEditOptions" then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate( mods.MusicRate )
			end

			MESSAGEMAN:Broadcast("MusicRateChanged")
		end
	},
	
	MusicRateEdit = {
		Choices = function()
			local first	= 0.4
			local last 	= 1
			local step 	= 0.01

			return stringify( range(first, last, step), "%g")
		end,
		ExportOnChange = true,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			local rate = ("%g"):format( SL.Global.ActiveModifiers.MusicRate )
			local i = FindInTable(rate, self.Choices) or 1
			list[i] = true
			return list
		end,
		SaveSelections = function(self, list, pn)

			local mods = SL.Global.ActiveModifiers

			for i=1,#self.Choices do
				if list[i] then
					mods.MusicRateEdit = tonumber( self.Choices[i] )
				end
			end

			local topscreen = SCREENMAN:GetTopScreen():GetName()

			-- Use the older GameCommand interface for applying rate mods in Edit Mode;
			-- it seems to be the only way (probably due to how broken Edit Mode is, in general).
			-- As an unintentional side-effect of setting musicrate mods this way, they STAY set
			-- (between songs, between screens, etc.) until you manually change them.  This is (probably)
			-- not the desired behavior in EditMode, so when users change between different songs in EditMode,
			-- always reset the musicrate mod.  See: ./BGAnimations/ScreenEditMeny underlay.lua
			if topscreen == "ScreenEditOptions" then
				GAMESTATE:ApplyGameCommand("mod," .. mods.MusicRateEdit .."xmusic")
			end

			MESSAGEMAN:Broadcast("MusicRateEditChanged")
		end
	},
	-------------------------------------------------------------------------
	Stepchart = {
		ExportOnChange = true,
		Choices = function()
			local choices = {}

			if not GAMESTATE:IsCourseMode() then
				local song = GAMESTATE:GetCurrentSong()
				if song then
					for steps in ivalues( SongUtil.GetPlayableSteps(song) ) do
						if steps:IsAnEdit() then
							choices[#choices+1] = ("%s %i"):format(steps:GetDescription(), steps:GetMeter())
						else
							choices[#choices+1] = ("%s %i"):format(THEME:GetString("Difficulty", ToEnumShortString(steps:GetDifficulty())), steps:GetMeter())
						end
					end
				end
			else
				local course = GAMESTATE:GetCurrentCourse()
				if course then
					for _,trail in ipairs(GetPlayableTrails(course)) do
						choices[#choices+1] = ("%s %i"):format(THEME:GetString("Difficulty", ToEnumShortString(trail:GetDifficulty())), trail:GetMeter())
					end
				end
			end

			return choices
		end,
		Values = function()
			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			if SongOrCourse then
				if GAMESTATE:IsCourseMode() then
					return GetPlayableTrails(SongOrCourse)
				else
					return SongUtil.GetPlayableSteps(SongOrCourse)
				end
			end
			return {}
		end,
		LoadSelections = function(self, list, pn)
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(pn) or GAMESTATE:GetCurrentSteps(pn)
			local i = FindInTable(StepsOrTrail, self.Values) or 1
			list[i] = true
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Values) do
				if list[i] then
					-- GAMESTATE keeps track of what the "preferred difficulty" is and this is used by
					-- the engine's SelectMusic class.  SL is using the engine's SelectMusic for now.
					-- Set the PreferredDifficulty now so that the player's newly chosen difficulty
					-- doesn't reset when they return to SelectMusic/SelectCourse.
					GAMESTATE:SetPreferredDifficulty(pn, v:GetDifficulty())

					if GAMESTATE:IsCourseMode() then
						GAMESTATE:SetCurrentTrail(pn, v)
						MESSAGEMAN:Broadcast("CurrentTrail"..ToEnumShortString(pn).."Changed")
					else
						GAMESTATE:SetCurrentSteps(pn, v)
						MESSAGEMAN:Broadcast("CurrentSteps"..ToEnumShortString(pn).."Changed")
					end
					break
				end
			end
		end
	},
	FaPlus = {
		SelectType = "SelectMultiple",
		Values = function()
			return { "ShowFaPlusWindow", "ShowEXScore" }
		end,
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers

			list[1] = mods.ShowFaPlusWindow or false
			list[2] = mods.ShowEXScore or false
			return list
		end,
		SaveSelections = function(self, list, pn)
			local sl_pn = SL[ToEnumShortString(pn)]
			local mods = sl_pn.ActiveModifiers
			mods.ShowFaPlusWindow = list[1]
			mods.ShowEXScore   = list[2]
			-- Default to FA+ pane if either options are active.
			sl_pn.EvalPanePrimary = (list[1] or list[2]) and 8 or 1
			-- Default to timing distribution pane if either are active.
			sl_pn.EvalPaneSecondary = (list[1] or list[2]) and 4 or 2
		end
	},
	-------------------------------------------------------------------------
	Hide = {
		SelectType = "SelectMultiple",
		Values = { "Targets", "SongBG", "Combo", "Lifebar", "Score", "Danger", "ComboExplosions" },
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			list[1] = mods.HideTargets or false
			list[2] = mods.HideSongBG  or false
			list[3] = mods.HideCombo   or false
			list[4] = mods.HideLifebar or false
			list[5] = mods.HideScore   or false
			list[6] = mods.HideDanger  or false
			list[7] = mods.HideComboExplosions or false
			return list
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			mods.HideTargets = list[1]
			mods.HideSongBG  = list[2]
			mods.HideCombo   = list[3]
			mods.HideLifebar = list[4]
			mods.HideScore   = list[5]
			mods.HideDanger  = list[6]
			mods.HideComboExplosions = list[7]

			playeroptions:Dark(mods.HideTargets and 1 or 0)
			playeroptions:Cover(mods.HideSongBG and 1 or 0)
		end,
	},
	-------------------------------------------------------------------------
	DataVisualizations = {
		Values = function()
			local choices = { "None", "Target Score Graph", "Step Statistics" }
			
			-- None and Target Score Graph should always be available to players
			-- but Step Statistics needs a lot of space and isn't always possible
			-- remove it as an available option if we aren't in single or if the current
			-- notefield width already uses more than half the screen width
			local style = GAMESTATE:GetCurrentStyle()
			local notefieldwidth = GetNotefieldWidth()
			local IsUltraWide = (GetScreenAspectRatio() > 21/9)
			local mpn = GAMESTATE:GetMasterPlayerNumber()

			-- Never In 4:3 versus/double mode
			if (not IsUsingWideScreen() and style and (style:GetName() == "versus" or style:GetName() == "double") ) then
				table.remove(choices, 3)
			end

			return choices
		end,
	},
	-------------------------------------------------------------------------
	TargetScore = {
		Values = { 'C-', 'C', 'C+', 'B-', 'B', 'B+', 'A-', 'A', 'A+', 'S-', 'S', 'S+', '☆', '☆☆', '☆☆☆', '☆☆☆☆', 'Machine best', 'Personal best' },
		LoadSelections = function(self, list, pn)
			local i = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.TargetScore) or 101
			list[i] = true
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Values) do
				if list[i] then SL[ToEnumShortString(pn)].ActiveModifiers.TargetScore = i; break end
			end
		end
	},
	-------------------------------------------------------------------------
	ActionOnMissedTarget = {
		Values = { "Nothing", "Fail", "Restart" },
	},
	-------------------------------------------------------------------------
	GameplayExtras = {
		SelectType = "SelectMultiple",
		Values = function()
			-- GameplayExtras will be presented as a single OptionRow when WideScreen
			local vals = { "ColumnFlashOnMiss", "SubtractiveScoring", "Pacemaker", "NPSGraphAtTop" }

			-- if not WideScreen (traditional DDR cabinets running at 640x480)
			-- remove the last two choices to be appended an additional OptionRow (GameplayExtrasB below).
			if not IsUsingWideScreen() then
				table.remove(vals, 4)
			end
			return vals
		end,
	},
	ErrorBar = {
		Values = { "None", "Colorful", "Monochrome", "Text" },
	},
	-------------------------------------------------------------------------
	ErrorBarOptions = {
		SelectType = "SelectMultiple",
		Values = { "ErrorBarUp", "ErrorBarMultiTick", "ErrorBarTrim" },
	},
	-------------------------------------------------------------------------
	MeasureCounter = {
		Values = { "None", "8th", "12th", "16th", "24th", "32nd" },
	},
	-------------------------------------------------------------------------
	MeasureCounterOptions = {
		SelectType = "SelectMultiple",
		Values = { "MeasureCounterLeft", "MeasureCounterUp", "HideLookahead" },
	},
	-------------------------------------------------------------------------
	TimingWindowOptions = {
		SelectType = "SelectMultiple",
		Values = { "HideEarlyDecentWayOffJudgments", "HideEarlyDecentWayOffFlash" }
	},
	-------------------------------------------------------------------------
	JudgmentTilt = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function()
			local first	= 0
			local last 	= 100
			local step 	= 1

			return range(first, last, step)
		end,
		LoadSelections = function(self, list, pn)
			local val = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.JudgmentTilt) or 0
			for i,v in ipairs(self.Choices) do
				if v == val then
					list[i] = true
					break
				end
			end
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Choices) do
				if list[i] then
					SL[ToEnumShortString(pn)].ActiveModifiers.JudgmentTilt = v
					break
				end
			end
		end
	},
	-------------------------------------------------------------------------
	NoteFieldOffsetX = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function()
			local first	= -50
			local last 	= 50
			local step 	= 1

			return range(first, last, step)
		end,
		LoadSelections = function(self, list, pn)
			local val = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.NoteFieldOffsetX) or 0
			for i,v in ipairs(self.Choices) do
				if v == val then
					list[i] = true
					break
				end
			end
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Choices) do
				if list[i] then
					SL[ToEnumShortString(pn)].ActiveModifiers.NoteFieldOffsetX = v
					break
				end
			end
		end
	},
	-------------------------------------------------------------------------
	NoteFieldOffsetY = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function()
			local first	= -50
			local last 	= 50
			local step 	= 1

			return range(first, last, step)
		end,
		LoadSelections = function(self, list, pn)
			local val = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.NoteFieldOffsetY) or 0
			for i,v in ipairs(self.Choices) do
				if v == val then
					list[i] = true
					break
				end
			end
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Choices) do
				if list[i] then
					SL[ToEnumShortString(pn)].ActiveModifiers.NoteFieldOffsetY = v
					break
				end
			end
		end
	},
	-------------------------------------------------------------------------
	MeasureLines = {
		Values = { "Off", "Measure", "Quarter", "Eighth" },
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			for i=1,#self.Choices do
				if list[i] then
					mods.MeasureLines = self.Choices[i]
				end
			end
		end
	},
	-------------------------------------------------------------------------
	VisualDelay = {
		Choices = function()
			local first	= -100
			local last 	= 100
			local step 	= 1
			return stringify( range(first, last, step), "%gms")
		end,
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			for i=1,#self.Choices do
				if list[i] then
					mods.VisualDelay = self.Choices[i]
				end
			end
			playeroptions:VisualDelay( mods.VisualDelay:gsub("ms","")/1000 )
		end
	},
	-------------------------------------------------------------------------
	ColumnCueExtras = {
		SelectType = "SelectMultiple",
		Values = function()
			return {"CueMines", "IgnoreHoldsRolls", "IgnoreNotes","CountdownBreaks"}
		end,
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers

			list[1] = mods.CueMines or false
			list[2] = mods.IgnoreHoldsRolls or false
			list[3] = mods.IgnoreNotes or false
			list[4] = mods.CountdownBreaks or false
			return list
		end,
		SaveSelections = function(self, list, pn)
			local sl_pn = SL[ToEnumShortString(pn)]
			local mods = sl_pn.ActiveModifiers
			mods.CueMines = list[1]
			mods.IgnoreHoldsRolls = list[2]
			mods.IgnoreNotes = list[3]
			mods.CountdownBreaks = list[4]
		end
	},
	-------------------------------------------------------------------------
	LifeMeterType = {
		Values = { "Standard", "Surround", "Vertical" },
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions = {
		Values = function()
			local choices = { "Gameplay", "Select Music", "Options2", "Options3"  }
			return choices
		end,
		OneChoiceForAllPlayers = true,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions = SelectMusicOrCourse() end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions2" end
			if list[4] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions3" end
		end
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions2 = {
		Values = function()
			local choices = { "Gameplay", "Select Music", "Options1", "Options3"  }
			return choices
		end,
		OneChoiceForAllPlayers = true,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions2 = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions2 = SelectMusicOrCourse() end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions2 = "ScreenPlayerOptions" end
			if list[4] then SL.Global.ScreenAfter.PlayerOptions2 = "ScreenPlayerOptions3" end
		end
	},
	-------------------------------------------------------------------------
	-- this is so dumb; I need to find time to completely rewrite ScreenPlayerOptions :(
	ScreenAfterPlayerOptions3 = {
		Values = function()
			local choices = { "Gameplay", "Select Music", "Options1", "Options2"  }
			return choices
		end,
		OneChoiceForAllPlayers = true,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions3 = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions3 = SelectMusicOrCourse() end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions3 = "ScreenPlayerOptions" end
			if list[4] then SL.Global.ScreenAfter.PlayerOptions3 = "ScreenPlayerOptions2" end
		end
	}
	-------------------------------------------------------------------------
}


-- -----------------------------------------------------------------------
-- Generic OptionRow Definition
-- -----------------------------------------------------------------------
local OptionRowDefault = {
	-- the __index metatable will serve to define a completely generic OptionRow
	__index = {
		initialize = function(self, name)

			self.Name = name

			-- FIXME: add inline comments explaining the intent/purpose of All This Code
			if Overrides[name].Values then
				if Overrides[name].Choices then
					self.Choices = type(Overrides[name].Choices)=="function" and Overrides[name].Choices() or Overrides[name].Choices
				else
					self.Choices = {}
					for i, v in ipairs( (type(Overrides[name].Values)=="function" and Overrides[name].Values() or Overrides[name].Values) ) do
						self.Choices[i] = THEME:GetString("SLPlayerOptions", v)
					end
				end
				self.Values = type(Overrides[name].Values)=="function" and Overrides[name].Values() or Overrides[name].Values
			else
				self.Choices = type(Overrides[name].Choices)=="function" and Overrides[name].Choices() or Overrides[name].Choices
			end

			-- define fallback values to use here if an override isn't specified
			self.LayoutType = Overrides[name].LayoutType or "ShowAllInRow"
			self.SelectType = Overrides[name].SelectType or "SelectOne"
			self.OneChoiceForAllPlayers = Overrides[name].OneChoiceForAllPlayers or false
			self.ExportOnChange = Overrides[name].ExportOnChange or false


			if self.SelectType == "SelectOne" then

				self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
					local mods, playeroptions = GetModsAndPlayerOptions(pn)
					local choice = mods[name] or (playeroptions[name] ~= nil and playeroptions[name](playeroptions)) or self.Choices[1]
					local i = FindInTable(choice, (self.Values or self.Choices)) or 1
					list[i] = true
					return list
				end
				self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, val in ipairs(vals) do
						if list[i] then mods[name] = val; break end
					end
				end

			else
				-- "SelectMultiple" typically means a collection of theme-defined flags in a single OptionRow
				-- most of these behave the same and can fall back on this generic definition; a notable exception is "Hide"
				self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, mod in ipairs(vals) do
						list[i] = mods[mod] or false
					end
					return list
				end
				self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, mod in ipairs(vals) do
						mods[mod] = list[i]
					end
				end
			end

			return self
		end
	}
}

-- -----------------------------------------------------------------------
-- Passed a string like "Mini", CustomOptionRow() will return table that represents
-- the themeside attributes of the OptionRow for Mini.
--
-- CustomOptionRow() is mostly used in Metrics.ini under [ScreenPlayerOptions] and siblings
-- to pass OptionRow data (Lua) to the engine (C++) via Metrics (ini).
--
-- There are a few other places in the theme where CustomOptionRow() is used to retrieve a list
-- of possible choices for a given OptionRow and then do something based on that list.
-- For example, ./ScreenPlayerOptions overlay/NoteSkinPreviews.lua uses it to get a list of NoteSkins
-- so it can load preview NoteSkin actors into the overlay's ActorFrame ahead of time.

function CustomOptionRow( name )
	if not (type(name)=="string" and Overrides[name]) then return false end

	-- assign the properties of the generic OptionRowDefault to OptRow
	local OptRow = setmetatable( {}, OptionRowDefault )

	-- now that OptRow has the method available, run its initialize() method
	return OptRow:initialize( name )
end


-- -----------------------------------------------------------------------
-- Mods are applied in their respective SaveSelections() functions when
-- ScreenPlayerOptions receives its OffCommand(), but what happens
-- if a player expects mods to have been set via a profile,
-- and thus never visits ScreenPlayerOptions?
--
-- Thus, we have this global function, ApplyMods(), which we can call from
-- ./BGAnimations/ScreenProfileLoad overlay.lua
-- as well as the the PlayerJoinedMessageCommand of
-- /BGAnimations/ScreenSelectMusic overlay/PlayerModifiers.lua
-- the former handles "normally" joined players, and the latter handles latejoin

function ApplyMods(player)
	for name,value in pairs(Overrides) do
		OptRow = CustomOptionRow( name )

		-- LoadSelections() and SaveSelections() expect two arguments in addition to self (the OptionRow)
		-- first, a table of true/false values corresponding to the OptionRow's Choices table
		-- second, the player that this applies to
		--
		-- LoadSelections() receives a table of all false values, one for each entry in this OptionRow's Choices table
		-- LoadSelections() will process that table, and set the appropriate entries to true using the SL[pn].ActiveModifiers table
		-- when done setting one or more entries to true, LoadSelections() will return that table of true/false values
		--
		-- SaveSelections() expects the same sort of arguments, but it expects the true/false table to be already set appropriately
		-- thus, we pass in the list that was returned from LoadSelections()
		local list = {}
		for i=1, #OptRow.Choices do
			list[i] = false
		end
		list = OptRow:LoadSelections( list, player )
		OptRow:SaveSelections( list, player )
	end
end
