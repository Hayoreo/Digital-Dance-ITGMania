-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--------------------------------DD PROFILE PREFENCES TO LOAD/SAVE--------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

----- MAIN SORT PROFILE PREFERNCE ----- 
function GetMainSortPreference()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'MainSortPreference')
	else
		value = DDStats.GetStat(PLAYER_2, 'MainSortPreference')
	end

	if value == nil then
		value = 1
	end
	
	MainSortIndex = tonumber(value)

	return tonumber(value)
end

function SetMainSortPreference(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'MainSortPreference', value)
		DDStats.Save(playerNum)
	end
end

----- COURSE SORT PROFILE PREFERNCE ----- 
function GetMainCourseSortPreference()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'MainCourseSortPreference')
	else
		value = DDStats.GetStat(PLAYER_2, 'MainCourseSortPreference')
	end

	if value == nil then
		value = 1
	end
	
	MainCourseSortIndex = tonumber(value)

	return tonumber(value)
end

function SetMainCourseSortPreference(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'MainCourseSortPreference', value)
		DDStats.Save(playerNum)
	end
end

----- SUB SORT PROFILE PREFERNCE -----
function GetSubSortPreference()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'SubSortPreference')
	else
		value = DDStats.GetStat(PLAYER_2, 'SubSortPreference')
	end

	if value == nil then
		value = 2
	end
	
	SubSortIndex = tonumber(value)

	return tonumber(value)
end

function SetSubSortPreference(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'SubSortPreference', value)
		DDStats.Save(playerNum)
	end
end

----- SUB SORT2 PROFILE PREFERNCE -----
function GetSubSort2Preference()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'SubSort2Preference')
	else
		value = DDStats.GetStat(PLAYER_2, 'SubSort2Preference')
	end

	if value == nil then
		value = 2
	end
	
	SubSort2Index = tonumber(value)

	return tonumber(value)
end

function SetSubSort2Preference(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'SubSort2Preference', value)
		DDStats.Save(playerNum)
	end
end

----- Lower Meter Filter profile settings ----- 
function GetLowerMeterFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerMeterFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerMeterFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

function SetLowerMeterFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerMeterFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Upper Meter Filter profile settings ----- 
function GetUpperMeterFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperMeterFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperMeterFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

function SetUpperMeterFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperMeterFilter', value)
		DDStats.Save(playerNum)
	end
end


----- Show difficulty profile settings -----
function GetShowDifficulty(difficulty)
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, difficulty)
	else
		value = DDStats.GetStat(PLAYER_2, difficulty)
	end

	if value == nil then
		value = 1
	end

	return tonumber(value)
end

function SetShowDifficulty(difficulty, value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, difficulty, value)
		DDStats.Save(playerNum)
	end
end


----- Lower BPM Filter profile settings ----- 
function GetLowerBPMFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerBPMFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerBPMFilter')
	end

	if value == nil then
		value = 49
	end

	return tonumber(value)
end

function SetLowerBPMFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerBPMFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Upper BPM Filter profile settings ----- 
function GetUpperBPMFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperBPMFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperBPMFilter')
	end

	if value == nil then
		value = 49
	end

	return tonumber(value)
end

function SetUpperBPMFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperBPMFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Lower NPS Filter profile settings ----- 
function GetLowerNPSFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerNPSFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerNPSFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

function SetLowerNPSFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerNPSFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Upper NPS Filter profile settings ----- 
function GetUpperNPSFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperNPSFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperNPSFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

function SetUpperNPSFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperNPSFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Lower Length Filter profile settings ----- 
function GetLowerLengthFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerLengthFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerLengthFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

function SetLowerLengthFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerLengthFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Upper Length Filter profile settings ----- 
function GetUpperLengthFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperLengthFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperLengthFilter')
	end
	
	if value == nil then
		value = 0
	end
	
	return tonumber(value)
end

function SetUpperLengthFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperLengthFilter', value)
		DDStats.Save(playerNum)
	end
end

---- GrooveStats profile preference
function GetGrooveStatsFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'GrooveStatsFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'GrooveStatsFilter')
	end

	if value == nil or value == "No" or value == "Yes" then
		value = 1
	end

	return tonumber(value)
end

function SetGrooveStatsFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'GrooveStatsFilter', value)
		DDStats.Save(playerNum)
	end
end

---- Autogen profile preference
function GetAutogenFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'AutogenFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'AutogenFilter')
	end

	if value == nil or value == "No" or value == "Yes" then
		value = 1
	end

	return tonumber(value)
end

function SetAutogenFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'AutogenFilter', value)
		DDStats.Save(playerNum)
	end
end


function IsUsingFilters()
	if GetLowerMeterFilter() ~= nil and GetLowerMeterFilter() ~= 0 then return true
	elseif GetUpperMeterFilter() ~= nil and GetUpperMeterFilter() ~= 0 then return true
	elseif GetShowDifficulty("Beginner") ~= nil and GetShowDifficulty("Beginner") ~= 1 then return true
	elseif GetShowDifficulty("Easy") ~= nil and GetShowDifficulty("Easy") ~= 1 then return true
	elseif GetShowDifficulty("Medium") ~= nil and GetShowDifficulty("Medium") ~= 1 then return true
	elseif GetShowDifficulty("Hard") ~= nil and GetShowDifficulty("Hard") ~= 1 then return true
	elseif GetShowDifficulty("Challenge") ~= nil and GetShowDifficulty("Challenge") ~= 1 then return true
	elseif GetShowDifficulty("Edit") ~= nil and GetShowDifficulty("Edit") ~= 1 then return true
	elseif GetLowerBPMFilter() ~= nil and GetLowerBPMFilter() ~= 49 then return true
	elseif GetUpperBPMFilter() ~= nil and GetUpperBPMFilter() ~= 49 then return true
	elseif GetLowerNPSFilter() ~= nil and GetLowerNPSFilter() ~= 0 then return true
	elseif GetUpperNPSFilter() ~= nil and GetUpperNPSFilter() ~= 0 then return true
	elseif GetLowerLengthFilter() ~= nil and GetLowerLengthFilter() ~= 0 then return true
	elseif GetUpperLengthFilter() ~= nil and GetUpperLengthFilter() ~= 0 then return true
	elseif GetGrooveStatsFilter() ~= nil and GetGrooveStatsFilter() ~= 1 then return true
	elseif GetAutogenFilter() ~= nil and GetAutogenFilter() ~= 1 then return true
	end
	
	return false
end

function IsUsingSorts()
	if GetMainSortPreference() ~= nil and GetMainSortPreference() ~= 1 then return true
	elseif GetSubSortPreference() ~= nil and GetSubSortPreference() ~= 2 then return true
	elseif GetSubSort2Preference() ~= nil and GetSubSort2Preference() ~= 2 then return true
	end
	
	return false
end

function IsUsingDifficultyFilters()
	if GetShowDifficulty("Beginner") ~= nil and GetShowDifficulty("Beginner") ~= 1 then return true
	elseif GetShowDifficulty("Easy") ~= nil and GetShowDifficulty("Easy") ~= 1 then return true
	elseif GetShowDifficulty("Medium") ~= nil and GetShowDifficulty("Medium") ~= 1 then return true
	elseif GetShowDifficulty("Hard") ~= nil and GetShowDifficulty("Hard") ~= 1 then return true
	elseif GetShowDifficulty("Challenge") ~= nil and GetShowDifficulty("Challenge") ~= 1 then return true
	elseif GetShowDifficulty("Edit") ~= nil and GetShowDifficulty("Edit") ~= 1 then return true
	end
end


function IsUsingCourseFilters()
	if GetLowerMeterFilter() ~= nil and GetLowerMeterFilter() ~= 0 then return true
	elseif GetUpperMeterFilter() ~= nil and GetUpperMeterFilter() ~= 0 then return true
	elseif GetLowerBPMFilter() ~= nil and GetLowerBPMFilter() ~= 49 then return true
	elseif GetUpperBPMFilter() ~= nil and GetUpperBPMFilter() ~= 49 then return true
	elseif GetLowerLengthFilter() ~= nil and GetLowerLengthFilter() ~= 0 then return true
	elseif GetUpperLengthFilter() ~= nil and GetUpperLengthFilter() ~= 0 then return true
	end
	
	return false
end


--- Why the actual fuck do I have to do this shit
function GetPlayerMod(pn, mod)
	local value
	if pn == "P1" then
		value = DDStats.GetStat(PLAYER_1, "DD"..mod)
	elseif pn == "P2" then
		value = DDStats.GetStat(PLAYER_2, "DD"..mod)
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

function SetPlayerMod(pn, mod, value)
	if pn == "P1" then
		DDStats.SetStat(PLAYER_1, "DD"..mod, value)
		DDStats.Save(PLAYER_1)
	elseif pn == "P2" then
		DDStats.SetStat(PLAYER_2, "DD"..mod, value)
		DDStats.Save(PLAYER_2)
	end
end