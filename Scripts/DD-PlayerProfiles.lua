-- It's possible for players to edit their Digital Dance UserPrefs.ini file
-- in various ways that might break the theme.  Also, sometimes theme-specific mods
-- are deprecated or change their internal name, leaving old values behind in player profiles
-- that might break the theme as well. Use this table to validate settings read in
-- from and written out to player profiles.
--
-- For now, this table is local to this file, but might be moved into the SL table (or something)
-- in the future to facilitate type checking in ./Scripts/SL-PlayerOptions.lua and elsewhere.

local permitted_profile_settings = {
	SpeedModType		= "string",
	SpeedMod			= "number",
	Mini				= "string",
	NoteSkin			= "string",
	JudgmentGraphic		= "string",
	JudgmentSize		= "number",
	ComboFont			= "string",
	HeldGraphic			= "string",
	HoldJudgment		= "string",
	BackgroundFilter	= "string",
	GhostWindow			= "number",
	NoteFieldOffsetX	= "number",
	NoteFieldOffsetY	= "number",
	VisualDelay			= "string",
	ShowFaPlusWindow	= "boolean",
	ShowEXScore			= "boolean",
	
	HideEarlyDecentWayOffJudgments	= "boolean",
	HideEarlyDecentWayOffFlash		= "boolean",

	HideTargets				= "boolean",
	HideSongBG				= "boolean",
	HideCombo				= "boolean",
	HideLifebar				= "boolean",
	HideScore				= "boolean",
	HideDanger				= "boolean",
	HideComboExplosions		= "boolean",

	LifeMeterType			= "string",
	DataVisualizations		= "string",
	TargetScore				= "number",
	ActionOnMissedTarget	= "string",

	MeasureCounter			= "string",
	MeasureCounterLeft		= "boolean",
	MeasureCounterUp		= "boolean",
	HideLookahead			= "boolean",
	MeasureLines			= "string",
	ColumnCues				= "string",
	CueMines				= "boolean",
	IgnoreHoldsRolls		= "boolean",
	IgnoreNotes				= "boolean",
	CountdownBreaks			= "boolean",
	
	TimingWindowOptions		= "string",
	ColumnFlashOnMiss		= "boolean",
	SubtractiveScoring		= "boolean",
	Pacemaker				= "boolean",
	NPSGraphAtTop			= "boolean",
	JudgmentTilt			= "number",
	ErrorBar				= "string",
	ErrorBarUp				= "boolean",
	ErrorBarMultiTick		= "boolean",
	ErrorBarTrim			= "boolean",

	PlayerOptionsString	= "string",
}

-- -----------------------------------------------------------------------

local theme_name = THEME:GetThemeDisplayName()
local filename =  theme_name .. " UserPrefs.ini"

-- function assigned to "CustomLoadFunction" under [Profile] in metrics.ini
LoadProfileCustom = function(profile, dir)
	local path =  dir .. filename
	local player, pn, filecontents

	-- we've been passed a profile object as the variable "profile"
	-- see if it matches against anything returned by PROFILEMAN:GetProfile(player)
	for p in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(p) then
			player = p
			pn = ToEnumShortString(p)
			break
		end
	end

	if pn then
		-- Remember and persist stats about songs played across profile switches
		local stages = SL[pn].Stages

		SL[pn]:initialize()
		ParseGrooveStatsIni(player)
		ReadItlFile(player)

		SL[pn].Stages = stages
	end

	if pn and FILEMAN:DoesFileExist(path) then
		filecontents = IniFile.ReadFile(path)[theme_name]

		-- for each key/value pair read in from the player's profile
		for k,v in pairs(filecontents) do
			-- ensure that the key has a corresponding key in permitted_profile_settings
			if permitted_profile_settings[k]
			--  ensure that the datatype of the value matches the datatype specified in permitted_profile_settings
			and type(v)==permitted_profile_settings[k] then
				-- if the datatype is string and this key corresponds with an OptionRow in ScreenPlayerOptions
				-- ensure that the string read in from the player's profile
				-- is a valid value (or choice) for the corresponding OptionRow
				if type(v) == "string" and CustomOptionRow(k) and FindInTable(v, CustomOptionRow(k).Values or CustomOptionRow(k).Choices)
				or type(v) ~= "string" then
					SL[pn].ActiveModifiers[k] = v
				end

				-- special-case PlayerOptionsString for now
				-- it is saved to and read from profile as a string, but doesn't have a corresponding
				-- OptionRow in ScreenPlayerOptions, so it will fail validation above
				-- we want engine-defined mods (e.g. dizzy) to be applied as well, not just SL-defined mods
				if k=="PlayerOptionsString" and type(v)=="string" then
					-- v here is the comma-delimited set of modifiers the engine's PlayerOptions interface understands

					-- update the SL table so that this PlayerOptionsString value is easily accessible throughout the theme
					SL[pn].PlayerOptionsString = v

					-- use the engine's SetPlayerOptions() method to set a whole bunch of mods in the engine all at once
					GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", v)

					-- However! It's quite likely that a FailType mod could be in that^ string, meaning a player could
					-- have their own setting for FailType saved to their profile.  I think it makes more sense to let
					-- machine operators specify a default FailType at a global/machine level, so use this opportunity to
					-- use the PlayerOptions interface to set FailSetting() using the default FailType setting from
					-- the operator menu's Advanced Options
					GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting( GetDefaultFailType() )
				end
			end
		end
	end

	return true
end

-- function assigned to "CustomSaveFunction" under [Profile] in metrics.ini
SaveProfileCustom = function(profile, dir)
	local path =  dir .. filename

	for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(player) then
			local pn = ToEnumShortString(player)
			local output = {}
			for k,v in pairs(SL[pn].ActiveModifiers) do
				if permitted_profile_settings[k] and type(v)==permitted_profile_settings[k] then
					output[k] = v
				end
			end

			-- these values are saved outside the SL[pn].ActiveModifiers tables
			-- and thus won't be handled in the loop above
			output.PlayerOptionsString = SL[pn].PlayerOptionsString

			IniFile.WriteFile( path, {[theme_name]=output} )
			WriteGrooveStatsIni(player)
			
			-- Write to the ITL file if we need to.
			-- The ITLData table will only contain data for memory cards.
			if #SL[pn].ITLData ~= 0 then
				WriteItlFile(dir, table.concat(SL[pn].ITLData, ""))
			end

			break
		end
	end

	return true
end

-- -----------------------------------------------------------------------
-- returns a path to a profile avatar, or nil if none is found

GetAvatarPath = function(profileDirectory, displayName)

	if type(profileDirectory) ~= "string" then return end

	-- check the profile directory for "avatar.png" first (or "avatar.jpg", etc.)
	local path = ActorUtil.ResolvePath(profileDirectory .. "avatar", 1, true)
	          -- support avatars from Hayoreo's Digital Dance, which uses "Profile Picture.png" in profile dir
	          or ActorUtil.ResolvePath(profileDirectory .. "profile picture", 1, true)
	          -- support SM5.3's avatar location to ease the eventual transition
	          or (displayName and displayName ~= "" and ActorUtil.ResolvePath("/Appearance/Avatars/" .. displayName, 1, true) or nil)

	if path and ActorUtil.GetFileType(path) == "FileType_Bitmap" then
		return path
	end
end

-- -----------------------------------------------------------------------
-- returns a path to a player's profile avatar, or nil if none is found

GetPlayerAvatarPath = function(player)
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}

	if not profile_slot[player] then return end

	local dir  = PROFILEMAN:GetProfileDir(profile_slot[player])
	local name = PROFILEMAN:GetProfile(player):GetDisplayName()

	return GetAvatarPath(dir, name)
end