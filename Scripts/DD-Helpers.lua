-- -----------------------------------------------------------------------
-- NOTE: This is the preferred way to check for RTT support, but we cannot rely on it to
--   accurately tell us whether the current system atually supports RTT!
--   Some players on Linux and [some version of] SM5.1-beta reported that DISPLAY:SupportsRenderToTexture()
--   returned false, when render to texture was definitely working for them.
--   I'm leaving this check here, but commented out, both as "inline instruction" for current SM5 themers
--   and so that it can be easily uncommented and used ~~when we are trees again~~ at a future date.

-- SupportsRenderToTexture = function()
-- 	-- ensure the method exists and, if so, ensure that it returns true
-- 	return DISPLAY.SupportsRenderToTexture and DISPLAY:SupportsRenderToTexture()
-- end


-- -----------------------------------------------------------------------
-- SM5's d3d implementation does not support render to texture. The DISPLAY
-- singleton has a method to check this but it doesn't seem to be implemented
-- in RageDisplay_D3D which is, ironically, where it's most needed.  So, this.

SupportsRenderToTexture = function()
	-- This is not a sensible way to assess this; it is a hack and should be removed at a future date.
	if HOOKS:GetArchName():lower():match("windows")
	and PREFSMAN:GetPreference("VideoRenderers"):sub(1,3):lower() == "d3d" then
		return false
	end

	return true
end


-- -----------------------------------------------------------------------
-- There's surely a better way to do this.  I need to research this more.

local is8bit = function(text)
	return text:len() == text:utf8len()
end


-- Here's what inline comments in BitmapText.cpp currently have to say about wrapwidthpixels
------
-- // Break sText into lines that don't exceed iWrapWidthPixels. (if only
-- // one word fits on the line, it may be larger than iWrapWidthPixels).
--
-- // This does not work in all languages:
-- /* "...I can add Japanese wrapping, at least. We could handle hyphens
-- * and soft hyphens and pretty easily, too." -glenn */
------
--
-- So, wrapwidthpixels does not have great support for East Asian Languages.
-- Without whitespace characters to break on, the text just... never wraps.  Neat.
--
-- Here are glenn's thoughts on the topic as of June 2019:
------
-- For Japanese specifically I'd convert the string to WString (so each character is one character),
-- then make it split "words" (potential word wrap points) based on each character type.  If you
-- were splitting "text あああ", it would split into "text " (including the space), "あ", "あ", "あ",
-- using a mapping to know which language each character is.  Then just follow the same line fitting
-- and recombine without reinserting spaces (since they're included in the array).
--
-- It wouldn't be great, you could end up with things like periods being wrapped onto a line by
-- themselves, ugly single-character lines, etc.  There are more involved language-specific word
-- wrapping algorithms that'll do a better job:
-- ( https://en.wikipedia.org/wiki/Line_breaking_rules_in_East_Asian_languages ),
-- or a line balancing algorithm that tries to generate lines of roughly even width instead of just
-- filling line by line, but those are more involved.
--
-- A simpler thing to do is implement zero-width spaces (&zwsp), which is a character that just
-- explicitly marks a place where word wrap is allowed, and then you can insert them strategically
-- to manually word-wrap text.  Takes more work to insert them, but if there isn't a ton of text
-- being wrapped, it might be simpler.
------
--
-- I have neither the native intelligence nor the brute-force-self-taught-CS-experience to achieve
-- any of the above, so here is some laughably bad code that is just barely good enough to meet the
-- needs of JP text in Simply Love.  Feel free to copy+paste this method to /r/shittyprogramming,
-- private Discord servers, etc., for didactic and comedic purposes alike.

BitmapText._wrapwidthpixels = function(bmt, w)
	local text = bmt:GetText()

	if not is8bit(text) then
		-- a range of bytes I'm considering to indicate JP characters,
		-- mostly derived from empirical observation and guesswork
		-- >= 240 seems to be emojis, the glyphs for which are as wide as Miso in SL, so don't include those
		-- FIXME: If you know more about how this actually works, please submit a pull request.
		local lower = 200
		local upper = 240
		bmt:settext("")

		for i=1, text:utf8len() do
			local c = text:utf8sub(i,i)
			local b = c:byte()

			-- if adding this character causes the displayed string to be wider than allowed
			if bmt:settext( bmt:GetText()..c ):GetWidth() > w then
				-- and if that character just added was in the jp range (...maybe)
				if b < upper and b >= lower then
					-- then insert a newline between the previous character and the current
					-- character that caused us to go over
					bmt:settext( bmt:GetText():utf8sub(1,-2).."\n"..c )
				else
					-- otherwise it's trickier, as romance languages only really allow newlines
					-- to be inserted between words, not in the middle of single words
					-- we'll have to "peel back" a character at a time until we hit whitespace
					-- or something in the jp range
					local _text = bmt:GetText()

					for j=i,1,-1 do
						local _c = _text:utf8sub(j,j)
						local _b = _c:byte()

						if _c:match("%s") or (_b < upper and _b >= lower) then
							bmt:settext( _text:utf8sub(1,j) .. "\n" .. _text:utf8sub(j+1) )
							break
						end
					end
				end
			end
		end
	else
		bmt:wrapwidthpixels(w)
	end

	-- return the BitmapText actor in case the theme is chaining actor commands
	return bmt
end

BitmapText.Truncate = function(bmt, m)
	local text = bmt:GetText()
	local l = text:len()

	-- With SL's Miso and JP fonts, english characters (Miso) tend to render 2-3x less wide
	-- than JP characters. If the text includes JP characters, it is (probably) desired to
	-- truncate the string earlier to achieve the same effect.
	-- Here, we are arbitrarily "weighting" JP characters to count 4x as much as one Miso
	-- character and then scaling the point at which we truncate accordingly.
	-- This is, of course, a VERY broad over-generalization, but It Works For Now™.
	if not is8bit(text) then
		l = 0

		local lower = 200
		local upper = 240

		for i=1, text:utf8len() do
			local b = text:utf8sub(i,i):byte()
			l = l + ((b < upper and b >= lower) and 4 or 1)
		end
		m = math.floor(m * (m/l))
	end

	-- if the length of the string is less than the specified truncate point, don't do anything
	if l <= m then return end
	-- otherwise, replace everything after the truncate point with an ellipsis
	bmt:settext( text:utf8sub(1, m) .. "…" )

	-- return the BitmapText actor in case the theme is chaining actor commands
	return bmt
end

-- -----------------------------------------------------------------------
-- call this to draw a Quad with a border
-- arguments are: width of quad, height of quad, and border width, in pixels

Border = function(width, height, bw)
	width  = width  or 2
	height = height or 2
	bw     = bw     or 1

	return Def.ActorFrame {
		Def.Quad { InitCommand=function(self) self:zoomto(width-2*bw, height-2*bw):MaskSource(true) end },
		Def.Quad { InitCommand=function(self) self:zoomto(width,height):MaskDest() end },
		Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
	}
end

-- -----------------------------------------------------------------------
-- SL_WideScale() is modified version of WideScale() from SM5.1's _fallback theme
--
-- _fallback's WideScale() is useful for scaling a number to accommodate both 4:3 and 16:9 aspect ratios
-- first arg is what will be returned if AspectRatio is 4:3
-- second arg is what will be returned if AspectRatio is 16:9
-- The number returned will be scaled proprotionately between if AspectRatio is, for example, 16:10
-- and likewise scaled futher up if AspectRatio is, for example, 21:9.
--
-- SL's UI was originally designed for 4:3 and later extended for 16:9, so WideScale() works great there.
-- I'm opting to accommodate ultrawide displays by clamping the scale at 16:9.
--
-- You may not want to adopt this strategy in your theme, but for here
-- it's easier than redesigning the UI again.
--
-- It's important to not override _fallback's WideScale() for the sake of scripted simfiles
-- that expect it to behave a particular way.

SL_WideScale = function(AR4_3, AR16_9)
	return clamp(scale( SCREEN_WIDTH, 640, 854, AR4_3, AR16_9 ), AR4_3, AR16_9)
end

-- -----------------------------------------------------------------------
-- get timing window in milliseconds

GetTimingWindow = function(n, mode)
	local prefs = SL.Preferences[mode or SL.Global.GameMode]
	local scale = PREFSMAN:GetPreference("TimingWindowScale")
	return prefs["TimingWindowSecondsW"..n] * scale + prefs.TimingWindowAdd
end

-- -----------------------------------------------------------------------
-- determines which timing_window an offset value (number) belongs to
-- used by the judgment scatter plot and offset histogram in ScreenEvaluation

DetermineTimingWindow = function(offset)
	for i=1,NumJudgmentsAvailable() do
		if math.abs(offset) <= GetTimingWindow(i) then
			return i
		end
	end
	return 5
end

NumJudgmentsAvailable = function()
	return 5
end

-- -----------------------------------------------------------------------
-- get worst timing judgment hit for a song

GetWorstJudgment = function(offsets)
	local worst_judgment = 1
	for i in ivalues(offsets) do
		if i[2] ~= "Miss" then
			local judgment = DetermineTimingWindow(i[2])
			if worst_judgment < judgment then
				worst_judgment = judgment
			end
		end
	end

	return worst_judgment
end


-- -----------------------------------------------------------------------
-- some common information needed by ScreenSystemOverlay's credit display,
-- as well as ScreenTitleJoin overlay and ./Scripts/SL-Branches.lua regarding coin credits

GetCredits = function()
	local coins = GAMESTATE:GetCoins()
	local coinsPerCredit = PREFSMAN:GetPreference('CoinsPerCredit')
	local credits = math.floor(coins/coinsPerCredit)
	local remainder = coins % coinsPerCredit

	return { Credits=credits,Remainder=remainder, CoinsPerCredit=coinsPerCredit }
end

-- -----------------------------------------------------------------------
-- return the x value for the center of a player's notefield
--   this is used to position various elements in ScreenGameplay
--   but it is not used to position the notefields themselves

GetNotefieldX = function( player )
	if not player then return end

	local style = GAMESTATE:GetCurrentStyle()
	if not style then return end

	local p = ToEnumShortString(player)
	local game = GAMESTATE:GetCurrentGame():GetName()

	local IsPlayingDanceSolo = (style:GetStepsType() == "StepsType_Dance_Solo")
	local NumPlayersEnabled  = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined     = GAMESTATE:GetNumSidesJoined()
	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player') or IsPlayingDanceSolo or (NumSidesJoined==1 and (game=="techno" or game=="kb7"))

	-- dance solo is always centered
	if IsUsingSoloSingles and NumPlayersEnabled == 1 and NumSidesJoined == 1 then return _screen.cx end
	-- double is always centered
	if style:GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local NumPlayersAndSides = ToEnumShortString( style:GetStyleType() )
	return THEME:GetMetric("ScreenGameplay","Player".. p .. NumPlayersAndSides .."X")
end

-- -----------------------------------------------------------------------
-- this is verbose, but it lets us manage what seem to be
-- quirks/oversights in the engine on a per-game + per-style basis

local NoteFieldWidth = {
	-- dance uses such nice, clean multiples of 64.  It's almost like this game gets the most attention and fixes.
	dance = {
		single  = 256,
		versus  = 256,
		double  = 512,
		solo    = 384,
		routine = 512,
		-- couple and threepanel not supported in Digital Dance at this time D:
		-- couple = 256,
		-- threepanel = 192
	},
	-- pump's values are very similar to those used in dance, but curiously smaller
	pump = {
		single  = 250,
		versus  = 250,
		double  = 500,
		routine = 500,
	},
	-- These values for techno, para, and kb7 are the result of empirical observation
	-- of the SM5 engine and should not be regarded as any kind of Truth.
	techno = {
		single8 = 448,
		versus8 = 272,
		double8 = 543,
	},
	para = {
		single = 280,
		versus = 280,
	},
	kb7 = {
		single = 480,
		versus = 270,
	},
}

GetNotefieldWidth = function()
	local game = GAMESTATE:GetCurrentGame()

	if game then
		local game_widths = NoteFieldWidth[game:GetName()]
		local style = GAMESTATE:GetCurrentStyle()
		if style then
			return game_widths[style:GetName()]
		end
	end

	return false
end

-- -----------------------------------------------------------------------
-- Define what is necessary to maintain and/or increment your combo, per Gametype.
-- For example, in dance Gametype, TapNoteScore_W3 (window #3) is commonly "Great"
-- so in dance, a "Great" will not only maintain a player's combo, it will also increment it.
--
-- We reference this function in Metrics.ini under the [Gameplay] section.
GetComboThreshold = function( MaintainOrContinue )
	local CurrentGame = GAMESTATE:GetCurrentGame():GetName()

	local ComboThresholdTable = {
		dance	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		pump	=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		techno	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		kb7		=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		-- these values are chosen to match Deluxe's PARASTAR
		para	=	{ Maintain = "TapNoteScore_W5", Continue = "TapNoteScore_W3" },

		-- I don't know what these values are supposed to actually be...
		popn	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		beat	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		kickbox	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },

		-- lights is not a playable game mode, but it is, oddly, a selectable one within the operator menu
		-- include dummy values here to prevent Lua errors in case players accidentally switch to lights
		lights =	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
	}

	return ComboThresholdTable[CurrentGame][MaintainOrContinue]
end

-- -----------------------------------------------------------------------

-- FailType is a PlayerOption that can be set using SM5's PlayerOptions interface.
-- If you wanted, you could set FailTyper per-player, prior to Gameplay like
--
-- GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Preferred"):FailSetting("FailType_ImmediateContinue")
-- GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptions("ModsLevel_Preferred"):FailSetting("FailType_Off")
--
-- and then P1 and P2 would have different Fail settings during gameplay.
--
-- That sounds kind of chaotic, particularly with saving Machine HighScores, so Digital Dance
-- enforces the same FailType for both players and allows machine operators to set a
-- "default FailType" within Advanced Options in the Operator Menu.
--
-- This "default FailType" is sort of handled by the engine, but not in a way that is
-- necessarily clear to me.  Whatever the history there was, it is lost to me now.
--
-- The engine's FailType enum has the following four values:
-- 'FailType_Immediate', 'FailType_ImmediateContinue', 'FailType_EndOfSong', and 'FailType_Off'
--
-- The conf-based OptionRow for "DefaultFailType" presents these^ as the following hardcoded English strings:
-- 'Immediate', 'ImmediateContinue', 'EndOfSong', and 'Off'
--
-- and whichever the machine operator chooses gets saved as a different hardcoded English string in
-- the DefaultModifiers Preference for the current game:
-- '', 'FailImmediateContinue', 'FailAtEnd', or 'FailOff'

-- It is worth pointing out that a default FailType of "FailType_Immediate" is saved to the DefaultModifiers
-- Preference as an empty string!
--
-- so this:
-- DefaultModifiers=FailOff, Overhead, Cel
-- would result in the engine applying FailType_Off to players when they join the game
--
-- while this:
-- DefaultModifiers=Overhead, Cel
-- would result in the engine applying FailType_Immediate to players when they join the game
--
-- Anyway, this is all convoluted enough that I wrote this global helper function to find the default
-- FailType setting in the current game's DefaultModifiers Preference and return it as an enum value
-- the PlayerOptions interface can accept.
--
-- Keeping track of the logical flow of which preference overrides which metrics
-- and attempting to extrapolate how that will play out over time in a community
-- where players expect to be able to modify the code that drives gameplay is so
-- convoluted that it seems unreasonable to expect any player to follow along.
--
-- I can barely follow along.
--
-- I'm pretty sure ZP Theart was wailing about such project bitrot in Lost Souls in Endless Time.

GetDefaultFailType = function()
	local default_mods = PREFSMAN:GetPreference("DefaultModifiers")

	local default_fail = ""
	local fail_strings = {}

	-- -------------------------------------------------------------------
	-- these mappings just recreate the if/else chain in PlayerOptions.cpp
	fail_strings.failarcade            = "FailType_Immediate"
	fail_strings.failimmediate         = "FailType_Immediate"
	fail_strings.failendofsong         = "FailType_ImmediateContinue"
	fail_strings.failimmediatecontinue = "FailType_ImmediateContinue"
	fail_strings.failatend             = "FailType_EndOfSong"
	fail_strings.failoff               = "FailType_Off"

	-- handle the "faildefault" string differently than the SM5 engine
	-- PlayerOptions.cpp will lookup GAMESTATE's DefaultPlayerOptions
	-- which applies, in sequence:
	--    DefaultModifiers from Preferences.ini
	--    DefaultModifers from [Common] in metrics.ini
	--    DefaultNoteSkinName from [Common] in metrics.ini
	--
	-- SM5.1's _fallback theme does not currently specify any FailType
	-- in DefaultModifiers under [Common] in its metrics.ini
	--
	-- This suggests that if a non-standard failstring (like "FailASDF")
	-- is found, the _fallback theme won't enforce anything, but the engine
	-- will enforce FailType_Immediate.  Brief testing seems to align with this
	-- theory, but I haven't dug through enough of the src to *know*.
	--
	-- So, anyway, if Digital Dance finds "faildefault" as a DefaultModifier in
	-- Digital Dance UserPrefs.ini, I'll go with "FailType_ImmediateContinue.
	-- ImmediateContinue will be Simply Love's default.
	fail_strings.faildefault           = "FailType_ImmediateContinue"
	-- -------------------------------------------------------------------

	for mod in string.gmatch(default_mods, "%w+") do
		if mod:lower():find("fail") then
			-- we found something matches "fail", so set our default_fail variable
			-- and keep looking; don't break from the loop immediately.
			-- I don't know if it's possible to have multiple FailType
			-- strings saved in a single DefaultModifiers string...
			default_fail = mod:lower()
		end
	end

	-- return the appropriate Enum string or "FailType_Immediate" if nothing was parsed out of DefaultModifiers
	return fail_strings[default_fail] or "FailType_Immediate"
end

-- -----------------------------------------------------------------------

SetGameModePreferences = function()
	-- apply the preferences associated with this SL GameMode (Casual, ITG, FA+)
	for key,val in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreference(key, val)
	end

	--------------------------------------------
	-- Always keep all judgements on.
	SL.Global.ActiveModifiers.TimingWindows = {true,true,true,true,true}

	--------------------------------------------
	-- loop through human players and apply whatever mods need to be set now
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local player_modslevel = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

		-- using PREFSMAN to set the preference for MinTNSToHideNotes apparently isn't
		-- enough when switching gamemodes because MinTNSToHideNotes is also a PlayerOption.
		-- so, set the PlayerOption version of it now, too, to ensure that arrows disappear
		-- at the appropriate judgments during gameplay for this gamemode.
		player_modslevel:MinTNSToHideNotes(SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes)

		-- FailSetting is also a modifier that can be set per-player per-stage in SM5, but I'm
		-- opting to enforce it in Simply Love using what the machine operator sets
		-- as the default FailType in Advanced Options in the operator menu
		player_modslevel:FailSetting( GetDefaultFailType() )
	end

	--------------------------------------------
	-- finally, load the Stats.xml file appropriate for this SL GameMode

	-- these are the prefixes that are prepended to each custom Stats.xml, resulting in
	-- Stats.xml, ECFA-Stats.xml, Casual-Stats.xml
	local prefix = {}

	-- ITG has no prefix and scores go directly into the main Stats.xml
	-- this was probably a Bad Decision™ on my part in hindsight  -quietly
	prefix["DD"] = ""

	if PROFILEMAN:GetStatsPrefix() ~= prefix[SL.Global.GameMode] then
		PROFILEMAN:SetStatsPrefix(prefix[SL.Global.GameMode])
	end
end
-- -----------------------------------------------------------------------
-- Call ResetPreferencesToStockSM5() to reset all the Preferences that SL silently
-- manages for you back to their stock SM5 values.
--
-- These "managed" Preferences are listed in ./Scripts/SL_Init.lua
-- per-gamemode (DD, ITG), and actively applied (and reapplied)
-- for each new game using SetGameModePreferences()
--
-- SL normally calls ResetPreferencesToStockSM5() from
-- ./BGAnimations/ScreenPromptToResetPreferencesToStock overlay.lua
-- but people have requested that the functionality for resetting Preferences be
-- generally accessible (for example, switching themes via a pad code).
-- Thus, this global function.

ResetPreferencesToStockSM5 = function()
	-- loop through all the Preferences that SL forcibly manages and reset them
	for key, value in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreferenceToDefault(key)
	end
	-- now that those Preferences are reset to default values, write Preferences.ini to disk now
	PREFSMAN:SavePreferences()
end

-- -----------------------------------------------------------------------
-- given a player, return a table of stepartist text for the current song or trail
-- so that various screens (SSM, Eval) can cycle through these values and players
-- can see each for brief duration

GetStepsCredit = function(player)
	local t = {}

	if GAMESTATE:IsCourseMode() then
		local trail = GAMESTATE:GetCurrentTrail(player)
		local entries = trail:GetTrailEntries()
		local song

		for i, entry in ipairs(entries) do
			steps = entry:GetSteps()
			if steps then
				-- prefer steps Description; this is where stepartists seem to put chart info
				if steps:GetDescription() ~= "" then
					t[i] = steps:GetDescription()

				-- if no description was available, use AuthorCredit instead
				elseif steps:GetAuthorCredit() ~= "" then
					t[i] = steps:GetAuthorCredit()
				end
			end
		end
	else
		local steps = GAMESTATE:GetCurrentSteps(player)
		-- credit
		if steps:GetAuthorCredit() ~= "" then t[#t+1] = steps:GetAuthorCredit() end
		-- description
		if steps:GetDescription() ~= "" then t[#t+1] = steps:GetDescription() end
		-- chart name
		if steps:GetChartName() ~= "" then t[#t+1] = steps:GetChartName() end
	end

	return t
end

-- -----------------------------------------------------------------------
-- Check a string for emojis.  If any are found, force specifically
-- those characters to be diffused to an rgba of 1,1,1,1
-- that is, no color - native emoji colors will be maintained.
--
-- This allows us to have a string like "hello world 🌊 i am here" displayed
-- in a single BitmapText actor, with diffuse() only applied to the text.
--
-- If you have string that might have emojis in it, do your normal diffuse() first,
-- then use DiffuseEmojis() to remove that diffuse property from emoji characters.

DiffuseEmojis = function(bmt, text)
	text = text or bmt:GetText()

	-- loop through each char in the string, checking for emojis; if any are found
	-- don't diffuse that char to be any specific color by selectively diffusing it to be {1,1,1,1}
	for i=1, text:utf8len() do
		-- FIXME: Similar to _wrapwidthpixels(), if you can implement a proper utf8-friendly fix,
		--        please submit a pull request because I certainly don't know what I'm doing.
		if text:utf8sub(i,i):byte() >= 240 then
			bmt:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
		end
	end
end

-- -----------------------------------------------------------------------
-- read the theme version from ThemeInfo.ini to display on ScreenTitleMenu underlay
-- this allows players to more easily identify what version of the theme they are currently using

GetThemeVersion = function()
	local file = IniFile.ReadFile( THEME:GetCurrentThemeDirectory() .. "ThemeInfo.ini" )
	if file then
		if file.ThemeInfo and file.ThemeInfo.Version then
			return file.ThemeInfo.Version
		end
	end
	return false
end

-- -----------------------------------------------------------------------
-- functions handle custom judgment graphic detection/loading

local function FilenameIsMultiFrameSprite(filename)
	-- look for the "[frames wide] x [frames tall]"
	-- and some sort of all-letters file extension
	-- Lua doesn't support an end-of-string regex marker...
	return string.match(filename, " %d+x%d+") and string.match(filename, "%.[A-Za-z]+")
end

function StripSpriteHints(filename)
	-- handle common cases here, gory details in /src/RageBitmapTexture.cpp
	return filename:gsub(" %d+x%d+", ""):gsub(" %(doubleres%)", ""):gsub(".png", "")
end

GetJudgmentGraphics = function()
	local path = THEME:GetPathG('', '_judgments')
	local files = FILEMAN:GetDirListing(path .. '/')
	local judgment_graphics = {}

	for i,filename in ipairs(files) do

		-- Filter out files that aren't judgment graphics
		-- e.g. hidden system files like .DS_Store
		if FilenameIsMultiFrameSprite(filename) then

			-- remove the file extension from the string, leaving only the name of the graphic
			local name = StripSpriteHints(filename)

			judgment_graphics[#judgment_graphics+1] = filename
		end
	end

	-- "None" results in Player judgment.lua returning an empty Def.Actor
	judgment_graphics[#judgment_graphics+1] = "None"

	return judgment_graphics
end

GetHoldJudgments = function()
	local path = THEME:GetCurrentThemeDirectory().."Graphics/_HoldJudgments/"
	local files = FILEMAN:GetDirListing(path)
	local hold_graphics = {}

	for i,filename in ipairs(files) do

		-- Filter out files that aren't HoldJudgment labels
		-- e.g. hidden system files like .DS_Store
		if FilenameIsMultiFrameSprite(filename) then
			table.insert(hold_graphics, filename)
		end
	end

	return hold_graphics
end


-- -----------------------------------------------------------------------
-- GetComboFonts returns a table of strings that match valid ComboFonts for use in Gameplay
--
-- a valid ComboFont must:
--   • have its assets in a unique directory at ./Fonts/_Combo Fonts/
--   • include the usual files needed for a StepMania BitmapText actor (a png and an ini)
--   • have its png and ini file both be named to match the directory they are in
--
-- a valid ComboFont should:
--   • include glyphs for 1234567890()/.-%
--   • be open source or "100% free" on dafont.com

GetComboFonts = function()
	local path = THEME:GetCurrentThemeDirectory().."Fonts/_Combo Fonts/"
	local dirs = FILEMAN:GetDirListing(path, true, false)
	local fonts = {}
	local has_wendy_cursed = false

	for directory_name in ivalues(dirs) do
		local files = FILEMAN:GetDirListing(path..directory_name.."/")
		local has_png, has_ini = false, false

		for filename in ivalues(files) do
			if FilenameIsMultiFrameSprite(filename) and StripSpriteHints(filename)==directory_name then has_png = true end
			if filename:match(".ini") and filename:gsub(".ini","")==directory_name then has_ini = true end
		end

		if has_png and has_ini then
			-- special-case Wendy to always appear first in the list
			if directory_name == "Wendy" then
				table.insert(fonts, 1, directory_name)

			-- special-case Wendy (Cursed) to always appear last in the last
			elseif directory_name == "Wendy (Cursed)" then
				has_wendy_cursed = true
			else
				table.insert(fonts, directory_name)
			end
		end
	end

	if has_wendy_cursed then table.insert(fonts, "Wendy (Cursed)") end

	return fonts
end

-------------------------------------------------------------------------

GetHeldMissGraphics = function()
	local path = THEME:GetCurrentThemeDirectory().."Graphics/_HeldMiss/"
	local files = FILEMAN:GetDirListing(path)
	local held_miss = {}

	for i,filename in ipairs(files) do
		-- we want "none" to show up at the end/beginning of the list.
		if filename ~= "None 1x2.png" then
			table.insert(held_miss, filename)
		end
	end
	held_miss[#held_miss+1] = "None"
	
	return held_miss
end

-------------------------------------------------------------------------
IsHumanPlayer = function(player)
	return GAMESTATE:GetPlayerState(player):GetPlayerController() == "PlayerController_Human"
end

-------------------------------------------------------------------------
IsAutoplay = function(player)
	return GAMESTATE:GetPlayerState(player):GetPlayerController() == "PlayerController_Autoplay"
end

-- -----------------------------------------------------------------------
-- Helper function to determine if a TNS falls within the W0 window.
-- Params are the params received from the JudgmentMessageCommand.
-- Returns true/false
IsW0Judgment = function(params, player)
	if params.Player ~= player then return false end
	if params.HoldNoteScore then return false end

	-- Only check/update FA+ count if we received a TNS in the top window.
	if params.TapNoteScore == "TapNoteScore_W1" then
		local prefs = SL.Preferences["FA+"]
		local scale = PREFSMAN:GetPreference("TimingWindowScale")
		local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]

		local offset = math.abs(params.TapNoteOffset)
		if offset <= W0 then
			return true
		end
	end
	return false
end

-- Gets the fully populated judgment counts for a player.
-- This includes the FA+ window (W0). Decents/WayOffs (W4/W5) will only exist in the
-- resultant table if the windows were active.
--
-- Should NOT be used in casual mode.
--
-- Returns a table with the following keys:
-- {
--             "W0" -> the fantasticPlus count
--             "W1" -> the fantastic count
--             "W2" -> the excellent count
--             "W3" -> the great count
--             "W4" -> the decent count (may not exist if window is disabled)
--             "W5" -> the way off count (may not exist if window is disabled)
--           "Miss" -> the miss count
--     "totalSteps" -> the total number of steps in the chart (including hold heads)
--          "Holds" -> total number of holds held
--     "totalHolds" -> total number of holds in the chart
--          "Mines" -> total number of mines hit
--     "totalMines" -> total number of mines in the chart
--          "Rolls" -> total number of rolls held
--     "totalRolls" -> total number of rolls in the chart
-- }
GetExJudgmentCounts = function(player)
	local pn = ToEnumShortString(player)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	
	local counts = {}
	
	local TNS = { "W1", "W2", "W3", "W4", "W5", "Miss" }

	for window in ivalues(TNS) do
		-- Get the count.
		local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
		-- We need to extract the W0 count in ITG mode.
		if window == "W1" then
			local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W0_total
			-- Subtract FA+ count from the overall fantastic window count.
			number = number - faPlus
			-- Populate the two numbers.
			counts["W0"] = faPlus
			counts["W1"] = number
		else
			counts[window] = number
		end
	end
	counts["totalSteps"] = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )

	local RadarCategory = { "Holds", "Mines", "Rolls" }
	
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
	
	for RCType in ivalues(RadarCategory) do
		local number = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_"..RCType )

		if RCType == "Mines" then
			-- NoMines still report the total number of mines that exist in a chart, even if they weren't played in the chart.
			-- If NoMines was set, report 0 for the number of mines as the chart actually didn't have any.
			-- TODO(teejusb): Track AvoidMine in the future. This is fine for now as ITL compares serverside.
			if po:NoMines() then
				counts[RCType] = 0
				counts["total"..RCType] = 0
			else
				-- We want to keep track of mines hit.
				counts[RCType] = possible - number
				counts["total"..RCType] = possible
			end
		else
			counts[RCType] = number
			counts["total"..RCType] = possible
		end
	end
	return counts
end
-- -----------------------------------------------------------------------
-- Calculate the EX score given for a given player.
--
-- The ex_counts default to those computed in BGAnimations/ScreenGameplay underlay/TrackExScoreJudgments.lua
-- They are computed from the HoldNoteScore and TapNotScore from the JudgmentMessageCommands.
-- We look for the following keys: 
-- {
--             "W0" -> the fantasticPlus count
--             "W1" -> the fantastic count
--             "W2" -> the excellent count
--             "W3" -> the great count
--             "W4" -> the decent count
--             "W5" -> the way off count
--           "Miss" -> the miss count
--           "Held" -> the number of holds/rolds held
--          "LetGo" -> the number of holds/rolds dropped
--        "HitMine" -> total number of mines hit
-- }
CalculateExScore = function(player, ex_counts, use_actual_w0_weight)
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	
	local totalSteps = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )
	local totalHolds = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Holds" )
	local totalRolls = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Rolls" )
	
	local W0Weight = use_actual_w0_weight and 3.5 or SL.ExWeights["W0"]
	local total_possible = totalSteps * W0Weight + (totalHolds + totalRolls) * SL.ExWeights["Held"]

	local total_points = 0
	
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

	-- If mines are disabled, they should still be accounted for in EX Scoring based on the weight assigned to it.
	-- Stamina community does often play with no-mines on, but because EX scoring is more timing centric where mines
	-- generally have a negative weight, it's a better experience to make sure the EX score reflects that.
	if po:NoMines() then
		local totalMines = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Mines" )
		total_points = total_points + totalMines * SL.ExWeights["HitMine"];
	end
	
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }
	local counts = ex_counts or SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts
	-- Just for validation, but shouldn't happen in normal gameplay.
	if counts == nil then return 0 end
	
	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then		
			total_points = total_points + value * SL.ExWeights[key]
		end
	end
	
	return math.max(0, math.floor(total_points/total_possible * 10000) / 100), total_points, total_possible
end

-- -----------------------------------------------------------------------
-- Returns a stringified form of a player's selected options.
GetPlayerOptionsString = function(player)
	-- grab the song options from this PlayerState
	local PlayerOptions = GAMESTATE:GetPlayerState(player):GetPlayerOptionsArray("ModsLevel_Preferred")
	local pn = ToEnumShortString(player)

	-- start with an empty string...
	local optionslist = ""

	-- if the player used an XMod of 1x, it won't be in PlayerOptions list
	-- so check here, and add it in manually if necessary
	if SL[pn].ActiveModifiers.SpeedModType == "X" and SL[pn].ActiveModifiers.SpeedMod == 1 then
		optionslist = "1x, "
	end

	--  ...and append options to that string as needed
	for i,option in ipairs(PlayerOptions) do

		-- these don't need to show up in the mods list
		if option ~= "FailAtEnd" and option ~= "FailImmediateContinue" and option ~= "FailImmediate" and not string.find(option, "Lights") then
			-- 100% Mini will be in the PlayerOptions as just "Mini" so use the value from the SL table instead
			if option:match("Mini") then
				option = SL[pn].ActiveModifiers.Mini .. " Mini"
			end

			if option:match("Cover") then
				option = THEME:GetString("OptionNames", "Cover")
			end

			if i < #PlayerOptions then
				optionslist = optionslist..option..", "
			else
				optionslist = optionslist..option
			end
		end
	end
	
	if GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):Haste() ~= 0 then
		optionslist = optionslist .. ", " .. "Haste"
	end

	-- Display TimingWindowScale as a modifier if it's set to anything other than 1
	local TimingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
	if TimingWindowScale ~= 1 then
		optionslist = optionslist .. ", " .. (ScreenString("TimingWindowScale")):format(TimingWindowScale*100)
	end

	local substitutions = {
		["SuperShuffle"] = "Blender",
		["HyperShuffle"] = "Random",
		["LRMirror"] = "LR-Mirror",
		["UDMirror"] = "UD-Mirror",
	}

	for k,v in pairs(substitutions) do
		optionslist = optionslist:gsub(k, v)
	end

	return optionslist
end

GetBlackList=function(self)
	local List = {
		--- Leave this commented out until hopefully sometime in the future when the API for leaderboards changes so that this can work as intended.
		--[["adry",
		"dragwassup4",
		"DF.Happy Feet!",
		"RhythmIO",
		"StarrySergal",--]]
	}
	return List
end

-- -----------------------------------------------------------------------
-- helper function for returning the player AF
-- Works as expected in ScreenGameplay
--     arguments:  pn is short string PlayerNumber like "P1" or "P2"
--     returns:    the "PlayerP1" or "PlayerP2" ActorFrame in ScreenGameplay
--                 or, the unnamed equivalent in ScrenEdit
GetPlayerAF = function(pn)
	local topscreen = SCREENMAN:GetTopScreen()
	
	if not topscreen then
		lua.ReportScriptError("GetPlayerAF() failed to find the player ActorFrame because there is no Screen yet.")
		return nil
	end
	
	local playerAF = nil
	
	-- Get the player ActorFrame on ScreenGameplay
	-- It's a direct child of the screen and named "PlayerP1" for P1
	-- and "PlayerP2" for P2.
	-- This naming convention is hardcoded in the SM5 engine.
	--
	-- ScreenEdit does not name its player ActorFrame, but we can still find it.
	-- find the player ActorFrame in edit mode
	local notefields = {}
	
	if (THEME:GetMetric(topscreen:GetName(), "Class") == "ScreenEdit") then
		-- loop through all nameless children of topscreen
		-- and find the one that contains the NoteField
		-- which is thankfully still named "NoteField"1
		for _,nameless_child in ipairs(topscreen:GetChild("")) do
			if nameless_child:GetChild("NoteField") then
				notefields[#notefields+1] = nameless_child
			end
		end
		-- If there is only one side joined always return the first one.
		if #notefields == 1 then
			return notefields[1]
		-- If there are two sides joined, return the one that matches the player number.
		else
			return notefields[pn == "P1" and 1 or 2]
		end
	-- find the player ActorFrame in gameplay
	else
		local player_af = topscreen:GetChild("Player"..pn)
		if player_af then
			playerAF = player_af
		end
	end
	
	return playerAF
end