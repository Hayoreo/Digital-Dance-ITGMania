local max_length_group = '1:00:00+'
local max_difficulty_group = '100+'
local max_bpm_group = '500+'
local NoSongs = false
local AllSongs = SONGMAN:GetAllSongs()
IsUntiedWR = false
HaveTagsChanged = false
local HasDifficultyFilters =  IsUsingDifficultyFilters()
local DifficultyNames = {
	'Difficulty_Beginner',
	'Difficulty_Easy',
	'Difficulty_Medium',
	'Difficulty_Hard',
	'Difficulty_Challenge'
}

local song_lengths = {}
for i=0,90-1,30 do
	song_lengths[#song_lengths+1] = i
end
for i=90,5*60-10,5 do
	song_lengths[#song_lengths+1] = i
end
for i=5*60,10*60-60,30 do
	song_lengths[#song_lengths+1] = i
end
for i=10*60,30*60-60,60*5 do
	song_lengths[#song_lengths+1] = i
end
for i=30*60,60*60-10*60,10*60 do
	song_lengths[#song_lengths+1] = i
end
song_lengths[#song_lengths+1] = 60*60


local function GetMaxIndexBelowOrEqual(values, exact_value)
	local min_index = 1
	local max_index = #values

	while min_index < max_index do
		local mid_index = math.floor((min_index + max_index+1)/2)
		local song_length = values[mid_index]
		if song_length <= exact_value then
			min_index = mid_index
		else
			max_index = mid_index-1
		end
	end

	return min_index
end

local GetSongLengthGroup = function(song)
	local exact_length = song:MusicLengthSeconds()
	local index = GetMaxIndexBelowOrEqual(song_lengths, exact_length)

	if index == #song_lengths then
		return max_length_group
	else
		return SecondsToMMSS(song_lengths[index])
			.. ' - '
			.. SecondsToMMSS(song_lengths[index+1] - 1)
	end
end

local song_bpms = {}
for i=0,500,10 do
	song_bpms[#song_bpms+1] = i
end


local function GetSongBpmGroup(song)
	local exact_bpm = math.round(song:GetDisplayBpms()[2])
	local index = GetMaxIndexBelowOrEqual(song_bpms, exact_bpm)

	if index == #song_bpms then
		return max_bpm_group
	else
		return song_bpms[index] .. ' - ' .. (song_bpms[index+1] - 1)
	end
end

function GetPeakNPS(steps)
	local mpn = GAMESTATE:GetMasterPlayerNumber()
	local nps = steps:GetPeakNps(mpn)

	return nps
end

function GetStepsNpsGroup(steps)
	local bpm_equivalent = math.round(GetPeakNPS(steps)*15)
	local index = GetMaxIndexBelowOrEqual(song_bpms, bpm_equivalent)

	if index == #song_bpms then
		return max_bpm_group
	else
		return song_bpms[index] .. ' - ' .. (song_bpms[index+1] - 1)
	end
end

-- Initialize GrooveStats filter
local path = THEME:GetCurrentThemeDirectory() .. "Other/GrooveStats-Groups.txt"
local groovestats_groups = GetFileContents(path)
local groovestats_groups_set = {}
if groovestats_groups ~= nil then
	for group in ivalues(groovestats_groups) do
		groovestats_groups_set[group] = true
	end
end

-- You know that spot under the rug where you sweep away all the dirty
-- details and then hope no one finds them?  This file is that spot.
-- The idea is basically to just throw setup-related stuff
-- in here that we don't want cluttering up default.lua
---------------------------------------------------------------------------
-- because no one wants "Invalid PlayMode 7"
GAMESTATE:SetCurrentPlayMode(0)
local SongsInSet = SL.Global.Stages.PlayedThisGame

---------------------------------------------------------------------------
-- local junk
local margin = {
	w = WideScale(54,72),
	h = 30
}

-- FIXME: making numCols and numRows configurable variables made sense when the song select
--  was more grid-like, but groups are now a single row, and songs just go up and down.
local numCols = 3
local numRows = 5

---------------------------------------------------------------------------
-- variables that are to be passed between files

local col = {
	how_many = numCols,
	w = (_screen.w/numCols) - margin.w,
}
local row = {
	how_many = numRows,
	h = ((_screen.h - (margin.h*(numRows-2))) / (numRows-2)),
}

---------------------------------------------------------------------------
-- a steps_type like "StepsType_Dance_Single" is needed so we can filter out steps that aren't suitable

local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()


local function LetterToGroup(letter)
	if 'A' <= letter and letter <= 'Z' then
		return letter
	elseif '0' <= letter and letter <= '9' then
		return '#'
	else
		return 'Other'
	end
end

local function GetSongFirstLetter(song)
	local letter = song:GetDisplayMainTitle():sub(1,1):upper()
	return LetterToGroup(letter)
end

local function GetSongArtistFirstLetter(song)
	local letter = song:GetDisplayArtist():sub(1,1):upper()
	return LetterToGroup(letter)
end

function GetStepsDifficultyGroup(steps)
	local meter = steps:GetMeter()
	if meter >= 100 then return max_difficulty_group end
	return meter
end

local GroupSongsBy = function(func)
	grouped_songs = {}

	for song in ivalues(AllSongs) do
		local song_group = func(song)

		if grouped_songs[song_group] == nil then
			grouped_songs[song_group] = {song}
		else
			local songs = grouped_songs[song_group]
			songs[#songs+1] = song
		end
	end

	return grouped_songs
end


local function GetHighestDifficulty(group, song)
	local difficulty = 0
	for steps in ivalues(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
		difficulty = math.max(difficulty, steps:GetMeter())
	end
	return difficulty
end

local function GetStepCount(group, song)
	local count = 0
	local mpn = GAMESTATE:GetMasterPlayerNumber()

	for steps in ivalues(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
		local steps_count = steps:GetRadarValues(mpn):GetValue('RadarCategory_TapsAndHolds')
		if GetMainSortPreference() ~= 7 or GetStepsDifficultyGroup(steps) == group then
			return steps_count
		end
		count = math.max(count, steps_count)
	end
	
	return count
end

local function GetStepNPS(group, song)
	local nps = 0
	for steps in ivalues(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
		if GetMainSortPreference() == 6 then
			if GetStepsNpsGroup(steps) == group then
				return GetPeakNPS(steps)
			end
		else
			nps = math.max(nps, GetPeakNPS(steps))
		end
	end
	return nps
end

local subsort_funcs = {
	function(g, s) return s:GetGroupName() end,
	function(g, s) return s:GetDisplayMainTitle():lower() end,
	function(g, s) return s:GetDisplayArtist():lower() end,
	function(g, s) return s:MusicLengthSeconds() end,
	function(g, s) return s:GetDisplayBpms()[2] end,
	GetStepNPS,
	GetStepCount,
	GetHighestDifficulty,
}

local main_sort_funcs = {
	-- Group (only subsort)
	function(g, s) return '' end,
	-- Title
	function(g, s) return s:GetDisplayMainTitle():lower() end,
	-- Artist
	function(g, s) return s:GetDisplayArtist():lower() end,
	-- Song Length
	function(g, s) return math.floor(s:MusicLengthSeconds()) end,
	-- Song BPM
	function(g, s) return round(s:GetDisplayBpms()[2], 0) end,
	-- Peak NPS
	function(g, s) return '' end,
	-- Difficulty (only subsort)
	function(g, s) return '' end,
	-- Tags
	function(g, s) return '' end,
}

---------------------------------------------------------------------------
-- provided a group title as a string, prune out songs that don't have valid steps
-- returns an indexed table of song objects
pruned_songs_by_group = {}
local UpdatePrunedSongs = function()
	pruned_songs_by_group = {}

	--[[
	"GROUP",
	"TITLE",
	"ARTIST",
	"LENGTH",
	"BPM",
	"DIFFICULTY",
	]]--

	local sort_pref = GetMainSortPreference()
	local songs_by_group
	if SongSearchSSMDD then
		songs_by_group = {}
		songs_by_group['Search Results'] = AllSongs
	elseif sort_pref == 1 then
		songs_by_group = GroupSongsBy(function(song) return song:GetGroupName() end)
	elseif sort_pref == 2 then
		songs_by_group = GroupSongsBy(GetSongFirstLetter)
	elseif sort_pref == 3 then
		songs_by_group = GroupSongsBy(GetSongArtistFirstLetter)
	elseif sort_pref == 4 then
		songs_by_group = GroupSongsBy(GetSongLengthGroup)
	elseif sort_pref == 5 then
		songs_by_group = GroupSongsBy(GetSongBpmGroup)
	elseif sort_pref == 6 then
		songs_by_group = {}
		local mpn = GAMESTATE:GetMasterPlayerNumber()
		for song in ivalues(AllSongs) do
			local npsBeginner, npsEasy, npsMedium, npsHard, npsExpert
			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
					-- Let's avoid adding the same song multiple times if multiple charts have the same value...
					-- TODO: Make this more efficient(?)
					if steps:GetDifficulty() == DifficultyNames[1] then
						npsBeginner = steps:GetPeakNps(mpn)
						if npsBeginner == npsEasy or npsBeginner == npsMedium or npsBeginner == npsHard or npsBeginner == npsExpert then
							npsBeginner = nil
						end
					elseif steps:GetDifficulty() == DifficultyNames[2] then
						npsEasy = steps:GetPeakNps(mpn)
						if npsEasy == npsBeginner or npsEasy == npsMedium or npsEasy == npsHard or npsEasy == npsExpert then
							npsEasy = nil
						end
					elseif steps:GetDifficulty() == DifficultyNames[3] then
						npsMedium = steps:GetPeakNps(mpn)
						if npsMedium == npsBeginner or npsMedium == npsEasy or npsMedium == npsHard or npsMedium == npsExpert then
							npsMedium = nil
						end
					elseif steps:GetDifficulty() == DifficultyNames[4] then
						npsHard = steps:GetPeakNps(mpn)
						if npsHard == npsBeginner or npsHard == npsEasy or npsHard == npsMedium or npsHard == npsExpert then
							npsHard = nil
						end
					elseif steps:GetDifficulty() == DifficultyNames[5] then
						npsExpert = steps:GetPeakNps(mpn)
						if npsExpert == npsBeginner or npsExpert == npsEasy or npsExpert == npsMedium or npsExpert == npsHard then
							npsExpert = nil
						end
					end
				-- Ignore edits
				if steps:GetDifficulty() ~= 'Difficulty_Edit' then
					if (steps:GetDifficulty() == DifficultyNames[1] and npsBeginner ~= nil) or
						(steps:GetDifficulty() == DifficultyNames[2] and npsEasy ~= nil) or
						(steps:GetDifficulty() == DifficultyNames[3] and npsMedium ~= nil) or
						(steps:GetDifficulty() == DifficultyNames[4] and npsHard ~= nil) or
						(steps:GetDifficulty() == DifficultyNames[5] and npsExpert ~= nil)
					then
						local group = GetStepsNpsGroup(steps)
						if songs_by_group[group] == nil then
							songs_by_group[group] = {song}
						else
							local songs = songs_by_group[group]
							songs[#songs+1] = song
						end
					end
				end
			end
		end
	
	elseif sort_pref == 7 then
		songs_by_group = {}
		for song in ivalues(AllSongs) do
			local meters_set = {}
			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
				local MeetsRequirements = false
				if GetShowDifficulty("Beginner") == 1 and steps:GetDifficulty() == "Difficulty_Beginner" then
					MeetsRequirements = true
				elseif GetShowDifficulty("Easy") == 1 and steps:GetDifficulty() == "Difficulty_Easy" then
					MeetsRequirements = true
				elseif GetShowDifficulty("Medium") == 1 and steps:GetDifficulty() == "Difficulty_Medium" then
					MeetsRequirements = true
				elseif GetShowDifficulty("Hard") == 1 and steps:GetDifficulty() == "Difficulty_Hard" then
					MeetsRequirements = true
				elseif GetShowDifficulty("Challenge") == 1 and steps:GetDifficulty() == "Difficulty_Challenge" then
					MeetsRequirements = true
				elseif GetShowDifficulty("Edit") == 1 and steps:GetDifficulty() == "Difficulty_Edit" then
					MeetsRequirements = true
				end
				if MeetsRequirements then
					local meter = GetStepsDifficultyGroup(steps)
					meters_set[meter] = true
				end
			end
			for meter, _ in pairs(meters_set) do
				if songs_by_group[meter] == nil then
					songs_by_group[meter] = {song}
				else
					local songs = songs_by_group[meter]
					songs[#songs+1] = song
				end
			end
		end

	elseif sort_pref == 8 then
		songs_by_group = {}
		local PlayerNumber
		local NumPlayers = GAMESTATE:GetNumPlayersEnabled()
		local P2TagPath
		local P2TagLines
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			pn = 0
			PlayerNumber = PLAYER_1
		else
			pn = 1
			PlayerNumber = PLAYER_2
		end
		local tag_path
		local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
		if DDStats.GetStat(PlayerNumber, 'LastStyle') == "Single" then
			tag_path = PROFILEMAN:GetProfileDir(pn) .. "Tags-single.txt"
		elseif style == "OnePlayerTwoSides" then
			tag_path = PROFILEMAN:GetProfileDir(pn) .. "Tags-double.txt"
		-- just in case they have a new profile with nothing setup yet
		else
			tag_path = PROFILEMAN:GetProfileDir(pn) .. "Tags-single.txt"
		end
		local tag_lines = GetFileContents(tag_path)
		local tag_group	
		
		if NumPlayers == 2 then
			P2TagPath = PROFILEMAN:GetProfileDir(1) .. "Tags-single.txt"
			P2TagLines =  GetFileContents(P2TagPath)
			--- combine P1 and P2 taglines
			for line in ivalues(P2TagLines) do
				tag_lines[#tag_lines+1] = line
			end
		end
		
		for line in ivalues(tag_lines) do
			if line:sub(1,1) == "#" then
				tag_group = line:sub(2)
			elseif line:sub(1,1) ~= "#" and tag_group ~= nil then
				if line:find("/%*") then
					local song_group = line:sub(2):gsub("/.*", "")
					for song in ivalues(AllSongs) do
						if song:GetGroupName():lower() == song_group:lower() then
							if songs_by_group[tag_group] == nil then
								songs_by_group[tag_group] = {song}
							else
								local songs = songs_by_group[tag_group]
								songs[#songs+1] = song
							end
						end
					end
				elseif SONGMAN:FindSong(line) then
					if songs_by_group[tag_group] == nil then
						songs_by_group[tag_group] = {SONGMAN:FindSong(line)}
					else
						local songs = songs_by_group[tag_group]
						songs[#songs+1] = SONGMAN:FindSong(line)
					end
				end
			end
		end
	end

	for group, group_songs in pairs(songs_by_group) do
		local songs = {}
		
		-- prune out songs that don't have valid steps or fit the filters
		for i,song in ipairs(group_songs) do
			-- this should be guaranteed by this point, but better safe than segfault
			
			if song:HasStepsType(steps_type) then
				local passesFilters = true
				--- Filter for Length
				if GetLowerLengthFilter() ~= 0 then
					if GetLowerLengthFilter() > song:MusicLengthSeconds() then
						passesFilters = false
					end
				end

				if GetUpperLengthFilter() ~= 0 then
					if GetUpperLengthFilter() < song:MusicLengthSeconds() then
						passesFilters = false
					end
				end
				
				--- Filter for BPM
				if GetLowerBPMFilter() ~= 49 then
					if song:GetDisplayBpms()[2] < GetLowerBPMFilter() then
						passesFilters = false
					end
				end
				if GetUpperBPMFilter() ~= 49 then
					if song:GetDisplayBpms()[2] > GetUpperBPMFilter() then
						passesFilters = false
					end
				end

				-- Filter for NPS
				if GetLowerNPSFilter() ~= 0 or GetUpperNPSFilter() ~= 0 then
					local hasPassingNPS = false
					for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
						-- Need to round otherwise floating points will ruin your day.
						local passesLower = GetLowerNPSFilter() == 0 or round(GetPeakNPS(steps) * 15) >= round(GetLowerNPSFilter())
						local passesUpper = GetUpperNPSFilter() == 0 or round(GetPeakNPS(steps) * 15) <= round(GetUpperNPSFilter())
						if passesLower and passesUpper then
							hasPassingNPS = true
							break
						end
					end
					if not hasPassingNPS then
						passesFilters = false
					end
				end
				
				---- Filter for GrooveStats
				if GetGrooveStatsFilter() == 2 then
					if not groovestats_groups_set[song:GetGroupName()] then
						passesFilters = false
					end
				elseif GetGrooveStatsFilter() == 3 then
					if groovestats_groups_set[song:GetGroupName()] then
						passesFilters = false
					end
				end

				-- Filter for Autogen
				if GetAutogenFilter() == 2 or GetAutogenFilter() == 3 then
					local has_non_autogen = false
					for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
						local is_auto = steps:GetDescription():match('^AUTO') or steps:GetAuthorCredit():match('^AUTO')
						if not is_auto then
							has_non_autogen = true
							break
						end
					end
					
					-- hide all autogen
					if not has_non_autogen and GetAutogenFilter() == 3 then
						passesFilters = false
					-- only show autogen
					elseif has_non_autogen and GetAutogenFilter() == 2 then
						passesFilters = false
					end
				end

				---- Filter for Meter
				if GetLowerMeterFilter() ~= 0 or GetUpperMeterFilter() ~= 0 then
					local hasPassingMeter = false
					for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
						local passesLower = GetLowerMeterFilter() == 0 or steps:GetMeter() >= GetLowerMeterFilter()
						local passesUpper = GetUpperMeterFilter() == 0 or steps:GetMeter() <= GetUpperMeterFilter()
						if passesLower and passesUpper then
							hasPassingMeter = true
						end
					end
					if not hasPassingMeter then
						passesFilters = false
					end
				end
				
				--Filter for difficulty
				if HasDifficultyFilters then
					local MeetsRequirements = false
					for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
						if GetShowDifficulty("Beginner") == 1 and steps:GetDifficulty() == "Difficulty_Beginner" then
							MeetsRequirements = true
							break
						elseif GetShowDifficulty("Easy") == 1 and steps:GetDifficulty() == "Difficulty_Easy" then
							MeetsRequirements = true
							break
						elseif GetShowDifficulty("Medium") == 1 and steps:GetDifficulty() == "Difficulty_Medium" then
							MeetsRequirements = true
							break
						elseif GetShowDifficulty("Hard") == 1 and steps:GetDifficulty() == "Difficulty_Hard" then
							MeetsRequirements = true
							break
						elseif GetShowDifficulty("Challenge") == 1 and steps:GetDifficulty() == "Difficulty_Challenge" then
							MeetsRequirements = true
							break
						elseif GetShowDifficulty("Edit") == 1 and steps:GetDifficulty() == "Difficulty_Edit" then
							MeetsRequirements = true
							break
						end
					end
					if MeetsRequirements == false then
						passesFilters = false
					end
				end
				
				----- Filter For song search
				if SongSearchSSMDD == true then
					local match = true
					-- Check for both normal and translated text for song name/artist
					local title = song:GetDisplayFullTitle():lower() .. song:GetTranslitFullTitle():lower()
					local artist = song:GetDisplayArtist():lower() .. song:GetTranslitArtist():lower()
					-- the query "xl grind" will match a song called "Axle Grinder" no matter
					-- what the chart info says
					if title == "Random-Portal" or title == "RANDOM-PORTAL" then
						match = false
					end
					
					if SongSearchAnswer ~= "" and match then
						if not title:find(SongSearchAnswer:lower(), 1, true) then
							match = false
						end
					end
					
					if ArtistSearchAnswer ~= "" and match then
						if not artist:find(ArtistSearchAnswer:lower(), 1, true) then
							match = false
						end
					end
					
					if ChartSearchAnswer ~= "" and match then
						local chartMatch = false
						for i, steps in ipairs(song:GetStepsByStepsType(steps_type)) do
							local chartStr = steps:GetAuthorCredit():lower().." "..steps:GetDescription():lower()
							if chartStr:find(ChartSearchAnswer:lower(), 1, true) then
								chartMatch = true
							end
						end
						if not chartMatch then
							match = false
						end
					end
					
					if not match then
						passesFilters = false
					end
				end
				
				if passesFilters then
					songs[#songs+1] = song
				end
				
			end
		end
		
		--[[
		"GROUP",
		"TITLE",
		"ARTIST",
		"LENGTH",
		"BPM",
		"# OF STEPS",
		"DIFFICULTY",
		]]--

		local main_sort_func = main_sort_funcs[GetMainSortPreference()]
		local sub_sort_func = subsort_funcs[GetSubSortPreference()]
		local sub_sort2_func = subsort_funcs[GetSubSort2Preference()]

		table.sort(songs, function(a, b)
			local main_a = main_sort_func(group, a)
			local main_b = main_sort_func(group, b)
			-- do main sort if no overlap
			if main_a ~= main_b then
				return main_a < main_b
			end
			
			-- do sub sort if main sort overlaps, but sub sort doesn't
			if sub_sort_func(group, a) ~= sub_sort_func(group, b) then
				return sub_sort_func(group, a) < sub_sort_func(group, b)
			end
			
			-- otherwise do the 2nd subsort
			return sub_sort2_func(group, a) < sub_sort2_func(group, b)
		end)

		pruned_songs_by_group[group] = songs
	end
end

local PruneSongsFromGroup = function(group)
	local songs = pruned_songs_by_group[group]
	if songs == nil then songs = {} end

	-- Copy songs so that the calling function can mutate the returned table.
	local songs_copy = {}
	for song in ivalues(songs) do
		songs_copy[#songs_copy+1] = song
	end
	songs = songs_copy
	
	local current_song = GAMESTATE:GetCurrentSong()
	-- we need to retain the index of the current song so we can set the SongWheel to start on it
	local index = 1
	for i, song in ipairs(songs) do
		if current_song == song then
			index = i
			break
		end
	end

	return songs, index
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local function GetGroupsBy(func)
	local groups_set = {}
	for song in ivalues(AllSongs) do
		local group = func(song)
		groups_set[group] = true
	end
	local groups = {}
	for group, _ in pairs(groups_set) do
		groups[#groups+1] = group
	end
	return groups
end

local function SortByLetter(a, b)
	if a == 'Other' then return false end
	if b == 'Other' then return true end
	if a == '#' then return false end
	if b == '#' then return true end
	return a:lower() < b:lower()
end

local GetGroups = function()
	if SongSearchSSMDD == true then
		return {'Search Results'}
	end	
	
	local sort_pref = GetMainSortPreference()
	if sort_pref == 1 then
		local groups = SONGMAN:GetSongGroupNames()
		table.sort(groups, SortByLetter)
		return groups
	elseif sort_pref == 2 then
		local groups = GetGroupsBy(GetSongFirstLetter)
		table.sort(groups, SortByLetter)
		return groups
	elseif sort_pref == 3 then
		local groups = GetGroupsBy(GetSongArtistFirstLetter)
		table.sort(groups, SortByLetter)
		return groups
	elseif sort_pref == 4 then
		local groups = GetGroupsBy(GetSongLengthGroup)
		table.sort(groups, function(a,b)
			if a == max_length_group then return false end
			if b == max_length_group then return true end
			return a < b
		end)
		return groups
	elseif sort_pref == 5 then
		local groups = GetGroupsBy(GetSongBpmGroup)
		table.sort(groups, function(a,b)
			local a_bpm = tonumber(a:match('^[0-9]*'))
			local b_bpm = tonumber(b:match('^[0-9]*'))
			return a_bpm < b_bpm
		end)
		return groups
	elseif sort_pref == 6 then
		local groups_set = {}
		for song in ivalues(AllSongs) do
			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
				groups_set[GetStepsNpsGroup(steps)] = true
			end
		end
		local groups = {}
		for group, _ in pairs(groups_set) do
			groups[#groups+1] = group
		end
		table.sort(groups, function(a,b)
			local a_bpm = tonumber(a:match('^[0-9]*'))
			local b_bpm = tonumber(b:match('^[0-9]*'))
			return a_bpm < b_bpm
		end)
		return groups
	elseif sort_pref == 7 then
		local groups_set = {}
		for song in ivalues(AllSongs) do
			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
				groups_set[GetStepsDifficultyGroup(steps)] = true
			end
		end
		local groups = {}
		for group, _ in pairs(groups_set) do
			groups[#groups+1] = group
		end
		table.sort(groups, function(a,b)
			if a == max_difficulty_group then return false end
			if b == max_difficulty_group then return true end
			return a < b
		end)
		return groups
	elseif sort_pref == 8 then
		local groups = {}
		local PlayerNumber
		local NumPlayers = GAMESTATE:GetNumPlayersEnabled()
		local P2TagPath
		local P2TagLines
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			pn = 0
			PlayerNumber = PLAYER_1
		else
			pn = 1
			PlayerNumber = PLAYER_2
		end
		local tag_path
		local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
		
		if DDStats.GetStat(PlayerNumber, 'LastStyle') == "Single" then
			tag_path = PROFILEMAN:GetProfileDir(pn) .. "Tags-single.txt"
		elseif style == "OnePlayerTwoSides" then
			tag_path = PROFILEMAN:GetProfileDir(pn) .. "Tags-double.txt"
		-- just in case they have a new profile with nothing setup yet
		else
			tag_path = PROFILEMAN:GetProfileDir(pn) .. "Tags-single.txt"
		end
		local tag_lines = GetFileContents(tag_path)
		
		if NumPlayers == 2 then
			P2TagPath = PROFILEMAN:GetProfileDir(1) .. "Tags-single.txt"
			P2TagLines =  GetFileContents(P2TagPath)
			--- combine P1 and P2 taglines
			for line in ivalues(P2TagLines) do
				tag_lines[#tag_lines+1] = line
			end
		end
		
		for line in ivalues(tag_lines) do
			if line:sub(1,1) == "#" then
				groups[#groups+1] = line:sub(2)
			end
		end
		
		table.sort(groups, SortByLetter)
		return groups
	end
end


---------------------------------------------------------------------------

-- First looks to the last "seen" song for the default song and if it doesn't exist it will look at DDStats
-- since the DD GameMode can't rely on the engine to properly save LastPlayedSong. If neither exist then it defaults 
-- to the 1st song in the 1st folder.

local GetDefaultSong = function(groups)
	if SongSearchSSMDD then
		return PruneSongsFromGroup( groups[2] )[1]
	end
	local songs = {}
	local playerNum
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		playerNum = PLAYER_1
	else
		playerNum = PLAYER_2
	end

	local lastSong = DDStats.GetStat(playerNum, 'LastSong')
	
	if LastSeenSong ~= nil then
		for group in ivalues(groups) do
			for song in ivalues(PruneSongsFromGroup(group)) do
				if song:GetSongDir() == LastSeenSong then
					return song
				end
			end
		end
	elseif lastSong ~= nil then
		for group in ivalues(groups) do
			for song in ivalues(PruneSongsFromGroup(group)) do
				if song:GetSongDir() == lastSong then
					return song
				end
			end
		end
	end
	-- "RANDOM" gets counted as the first group so bump it down to start at #2
	return PruneSongsFromGroup( groups[2] )[1]
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- prune out groups that have no valid steps
-- passed an indexed table of strings representing potential group names
-- returns an indexed table of group names as strings



local PruneGroups = function(_groups)
	local groups = {}
	groups[#groups+1] = "RANDOM-PORTAL"

	for group in ivalues( _groups ) do
		local group_has_been_added = false
		local songs = PruneSongsFromGroup(group)
		for song in ivalues(songs) do
			if song:HasStepsType(steps_type) then

				for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
						groups[#groups+1] = group
						group_has_been_added = true
						break
				end
			end
			if group_has_been_added then break end
		end
	end
	return groups
end

--------------------------------------------------------------------------
local GetGroupInfo = function(groups)
	local info = {}
	for group in ivalues(groups) do
		local songs = PruneSongsFromGroup(group)
		local artists, genres, charts = {}, {}, {}

		info[group] = {}
		info[group].num_songs = #songs
		info[group].artists = ""
		info[group].genres = ""
		info[group].charts = ""

		for song in ivalues(songs) do
			if #artists < 5 then
				if song:GetDisplayArtist() ~= "" then
					artists[#artists+1] = song:GetDisplayArtist()
				end
			end

			if #genres < 5 then
				if song:GetGenre() ~= "" then
					genres[#genres+1] = song:GetGenre()
				end
			end

			for i,difficulty in ipairs(Difficulty) do
				-- don't care about edits
				if i>5 then break end
				if charts[difficulty] == nil then charts[difficulty] = 0 end

				if song:HasStepsTypeAndDifficulty(steps_type, difficulty) then
					charts[difficulty] = charts[difficulty] + 1
				end
			end
		end

		for i, a in ipairs(artists) do
			info[group].artists = info[group].artists .. "• " .. a .. (i ~= #artists and "\n" or "")
		end
		for i, g in ipairs(genres) do
			info[group].genres = info[group].genres .. "• " .. g .. (i ~= #genres and "\n" or "")
		end
		for i,difficulty in ipairs(Difficulty) do
			if i>5 then break end
			if charts[difficulty] == nil then charts[difficulty] = 0 end
			info[group].charts = info[group].charts .. charts[difficulty] .. " " .. THEME:GetString( "CustomDifficulty", ToEnumShortString(difficulty) ) .. "\n"
		end

	end
	return info
end

---------------------------------------------------------------------------


local current_song
local group_index

local groups = GetGroups()
UpdatePrunedSongs()
-- prune the list of potential groups down to valid groups
groups = PruneGroups(groups)

-- there will be a current_song if we're on stage 2 or later
current_song = GetDefaultSong(groups)
GAMESTATE:SetCurrentSong(current_song)

-- Find the group of the current song.
local found_group = false
if NameOfGroup ~= nil then
	for song in ivalues(PruneSongsFromGroup(NameOfGroup)) do
		if song == current_song then
			found_group = true
		end
	end
end
if not found_group then
	for group in ivalues(groups) do
		for song in ivalues(PruneSongsFromGroup(group)) do
			if song == current_song then
				NameOfGroup = group
				found_group = true
				break
			end
			if found_group then break end
		end
	end
end

-- Update group if we're sorted by difficulty.
if GetMainSortPreference() == 7 and not SongSearchSSMDD then
	local steps = GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber())
	if steps ~= nil then
		NameOfGroup = GetStepsDifficultyGroup(steps)
	end
end

-- Create list of all available songs to use for song search.
if SongSearchSSMDD == false then
	SongsAvailable = {}
	for groupName, group in pairs (pruned_songs_by_group) do
		for song in ivalues (group) do
			SongsAvailable[#SongsAvailable+1] = song
		end
	end
	if #SongsAvailable == 0 then
		NoSongs = true
	end
end

-- If there are STILL no valid groups or songs, we aren't going to find any.
-- return nil, which default.lua will interpret to mean the
-- player needs to be informed that this machine has no suitable content...  D:
if #groups == 0 or NoSongs == true then
	return nil
end

group_index = FindInTable(NameOfGroup, groups) or 1

return {
	steps_type=steps_type,
	Groups=groups,
	group_index=group_index,
	row=row,
	col=col,
	InitOptionRowsForSingleSong=InitOptionRowsForSingleSong,
	group_info=GetGroupInfo(groups),
	PruneSongsFromGroup=PruneSongsFromGroup
}