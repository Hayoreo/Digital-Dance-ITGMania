local player = ...
local pn = ToEnumShortString(player)
local CurrentTab
local CurrentTabNumber
local CurrentHash

if pn == "P1" and GAMESTATE:IsHumanPlayer(pn) then
	if DDStats.GetStat(PLAYER_1, 'LastTab') ~= nil then
		CurrentTab = DDStats.GetStat(pn, 'LastTab')
	else
		CurrentTab = "Steps"
	end
elseif pn == "P2" and GAMESTATE:IsHumanPlayer(pn) then
	if DDStats.GetStat(PLAYER_2, 'LastTab') ~= nil then
		CurrentTab = DDStats.GetStat(pn, 'LastTab')
	else
		CurrentTab = "Steps"
	end
end

local TabText = {}
TabText[#TabText+1] = "Steps"
-- Only show the online tabs if they're available
if IsServiceAllowed(SL.GrooveStats.GetScores) then
	TabText[#TabText+1] = "GS"
	TabText[#TabText+1] = "EX"
	TabText[#TabText+1] = "RPG"
	TabText[#TabText+1] = "ITL"
end
TabText[#TabText+1] = "Local"

local GetRealTab = function(TabClicked)
	local RealTabClick
	
	if IsServiceAllowed(SL.GrooveStats.GetScores) then
		RealTabClick = TabClicked
	else
		-- we only show the steps information and local scores if not online
		if TabClicked == 2 then
			RealTabClick = 6
		else
			RealTabClick = TabClicked
		end
	end
	return tonumber(RealTabClick)
end

local function TabToStyle(Tab)
	local value
	for i=1, #TabText do
		if TabText[i] == Tab then
			value = i
		end
	end
	if value == nil then value = 1 end
	value = GetRealTab(value)
	return value
end
CurrentTabNumber = TabToStyle(CurrentTab)

-- don't run if a player is not enabled
if not GAMESTATE:IsHumanPlayer(pn) then return end

local n = player==PLAYER_1 and "1" or "2"


local MachineProfile = PROFILEMAN:GetMachineProfile()
local PlayerProfile = PROFILEMAN:GetProfile(pn)

local border = 5
local width = SCREEN_WIDTH/3 - 5
local height = 120 - 5

local cur_style
if CurrentTabNumber == 1 then
	cur_style = 0
else
	cur_style = CurrentTabNumber - 2
end

local num_styles = 5
local num_scores = 6

local GrooveStatsBlue = color("#007b85")
local ExBlue =  SL.JudgmentColors["FA+"][1]
local RpgYellow = color("1,0.972,0.792,1")
local ItlPink = color("1,0.2,0.406,1")
local MachinePurple = color("#4d0057")

local isRanked = false
local IsVisible = false

if CurrentTabNumber ~= 1 then
	IsVisible = true
end

local style_color = {
	[0] = GrooveStatsBlue,
	[1] = ExBlue,
	[2] = RpgYellow,
	[3] = ItlPink,
	[4] = MachinePurple,
}

local self_color = color("#a1ff94")
local rival_color = color("#c29cff")

local transition_seconds = 1

local all_data = {}
local MachineScores = {}
local HasLocalScores = false

local ResetAllData = function()
	for i=1,num_styles do
		local data = {
			["has_data"]=false,
			["scores"]={}
		}
		local scores = data["scores"]
		for i=1,num_scores do
			scores[#scores+1] = {
				["rank"]="",
				["name"]="",
				["score"]="",
				["date"]="",
				["isSelf"]=false,
				["isRival"]=false,
				["isFail"]=false,
				["isEx"]=false,
			}
		end
		all_data[#all_data + 1] = data
	end
end

-- Initialize the all_data object.
ResetAllData()

-- Checks to see if any data is available.
local HasData = function(idx)
	return all_data[idx+1] and all_data[idx+1].has_data
end

local SetScoreData = function(data_idx, score_idx, rank, name, score, date, isSelf, isRival, isFail, isEx)
	all_data[data_idx].has_data = true

	local score_data = all_data[data_idx]["scores"][score_idx]
	score_data.rank = rank..((#rank > 0) and "." or "")
	score_data.name = name
	score_data.score = score
	score_data.date = date
	score_data.isSelf = isSelf
	score_data.isRival = isRival
	score_data.isFail = isFail
	score_data.isEx = isEx
end

local LeaderboardRequestProcessor = function(res, master)
	if master == nil then return end
	
	if res.error or res.statusCode ~= 200 then
		local error = res.error and ToEnumShortString(res.error) or nil
		local text = ""
		if error == "Timeout" then
			text = "Timed Out"
		elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
			text = "Failed to Load 😞"
		end
		for i=1, num_scores do
			SetScoreData(1, i, "", "", "", false, false, false, false)
			SetScoreData(2, i, "", "", "", false, false, false, false)
			SetScoreData(3, i, "", "", "", false, false, false, false)
		end
		SetScoreData(1, 1, "", text, "", false, false, false, false)
		SetScoreData(2, 1, "", text, "", false, false, false, false)
		SetScoreData(3, 1, "", text, "", false, false, false, false)
		master:queuecommand("LoopScorebox")
		return
	end

	local playerStr = "player"..n
	local data = JsonDecode(res.body)

	-- First check to see if the leaderboard even exists.
	if data and data[playerStr] then
		-- These will get overwritten if we have any entries in the leaderboard below.
		if data[playerStr]["isRanked"] then
			isRanked = true
			all_data[1].has_data = false
			for i=1,num_scores do
				SetScoreData(1, i, "", "", "", "", false, false, false, false)
			end
			SetScoreData(1, 1, "", "No Scores", "", "", false, false, false, false)
		else
			isRanked = true
			all_data[1].has_data = false
			if (not (data[playerStr]["rpg"] and data[playerStr]["rpg"]["rpgLeaderboard"]) and
			not (data[playerStr]["itl"] and data[playerStr]["itl"]["itlLeaderboard"])) then
				all_data[2].has_data = false
				all_data[3].has_data = false
				for i=1,num_scores do
					SetScoreData(1, i, "", "", "", "", false, false, false, false)
					SetScoreData(2, i, "", "", "", "", false, false, false, false)
					SetScoreData(3, i, "", "", "", "", false, false, false, false)
				end
				SetScoreData(1, 1, "", "No Scores", "", "", false, false, false, false)
				SetScoreData(2, 1, "", "Chart Not Ranked", "", "", false, false, false, false)
				SetScoreData(3, 1, "", "Chart Not Ranked", "", "", false, false, false, false)
				isRanked = false
			end
		end

		if data[playerStr]["gsLeaderboard"] then
			local entryCount = 0
			for entry in ivalues(data[playerStr]["gsLeaderboard"]) do
				entryCount = entryCount + 1
				SetScoreData(1, entryCount,
								tostring(entry["rank"]),
								entry["name"],
								string.format("%.2f", entry["score"]/100),
								ParseGroovestatsDate(entry["date"]),
								entry["isSelf"],
								entry["isRival"],
								entry["isFail"],
								false)
			end
			entryCount = entryCount + 1
			if entryCount > 1 then
				for i=entryCount,num_scores,1 do
					SetScoreData(1, i,
									"",
									"",
									"",
									"",
									false,
									false,
									false,
									false)
				end
			end
		else
			for i=1,num_scores do
				SetScoreData(1, i, "", "", "", "", false, false, false, false)
			end
			SetScoreData(1, 1, "", "No Scores", "", "", false, false, false, false)
		end
		
		if data[playerStr]["exLeaderboard"] then
			local entryCount = 0
			for entry in ivalues(data[playerStr]["exLeaderboard"]) do
				entryCount = entryCount + 1
				SetScoreData(2, entryCount,
								tostring(entry["rank"]),
								entry["name"],
								string.format("%.2f", entry["score"]/100),
								ParseGroovestatsDate(entry["date"]),
								entry["isSelf"],
								entry["isRival"],
								entry["isFail"],
								true)
			end
			entryCount = entryCount + 1
			if entryCount > 1 then
				for i=entryCount,num_scores,1 do
					SetScoreData(2, i,
									"",
									"",
									"",
									"",
									false,
									false,
									false,
									false)
				end
			else
				for i=1,num_scores do
					SetScoreData(2, i, "", "", "", "", false, false, false, false)
				end
				SetScoreData(2, 1, "", "No Scores", "", "", false, false, false, false)
			end
		end

		if data[playerStr]["rpg"] then
			local entryCount = 0
			all_data[3].has_data = false
			for i=1,num_scores do
				SetScoreData(3, i, "", "", "", "", false, false, false, false)
			end
			SetScoreData(3, 1, "", "No Scores", "", "", false, false, false, false)

			if data[playerStr]["rpg"]["rpgLeaderboard"] then
				for entry in ivalues(data[playerStr]["rpg"]["rpgLeaderboard"]) do
					entryCount = entryCount + 1
					SetScoreData(3, entryCount,
									tostring(entry["rank"]),
									entry["name"],
									string.format("%.2f", entry["score"]/100),
									ParseGroovestatsDate(entry["date"]),
									entry["isSelf"],
									entry["isRival"],
									entry["isFail"],
									false
								)
				end
				entryCount = entryCount + 1
				for i=entryCount,num_scores,1 do
					SetScoreData(3, i,
									"",
									"",
									"",
									"",
									false,
									false,
									false,
									false)
				end
			end
		else
			for i=1,num_scores do
				SetScoreData(3, i, "", "", "", "", false, false, false, false)
			end
			SetScoreData(3, 1, "", "Chart Not Ranked", "", "", false, false, false, false)
		end

		if data[playerStr]["itl"] then
			local entryCount = 0
			all_data[4].has_data = false
			for i=1,num_scores do
				SetScoreData(4, i, "", "", "", "", false, false, false, false)
			end
			SetScoreData(4, 1, "", "No Scores", "", "", false, false, false, false)

			if data[playerStr]["itl"]["itlLeaderboard"] then
				for entry in ivalues(data[playerStr]["itl"]["itlLeaderboard"]) do
					if entry["isSelf"] and CurrentHash ~= nil then
						UpdateItlExScore(player, CurrentHash, entry["score"])
					end					
					entryCount = entryCount + 1
					SetScoreData(4, entryCount,
									tostring(entry["rank"]),
									entry["name"],
									string.format("%.2f", entry["score"]/100),
									ParseGroovestatsDate(entry["date"]),
									entry["isSelf"],
									entry["isRival"],
									entry["isFail"],
									true
								)
				end
				entryCount = entryCount + 1
				for i=entryCount,num_scores,1 do
					SetScoreData(4, i,
									"",
									"",
									"",
									"",
									false,
									false,
									false,
									false)
				end
			end
		else
			for i=1,num_scores do
				SetScoreData(4, i, "", "", "", "", false, false, false, false)
			end
			SetScoreData(4, 1, "", "Chart Not Ranked", "", "", false, false, false, false)
		end
		
 	end
	master:queuecommand("LoopScorebox")
end

local af = Def.ActorFrame{
	Name="ScoreBox"..pn,
	InitCommand=function(self)	
		self:xy((player==PLAYER_1 and (SCREEN_WIDTH/3)/2 or _screen.w - (SCREEN_WIDTH/3)/2), _screen.h - 32 - 60)
		if CurrentTabNumber == 1 then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
	OffCommand=function(self) self:stoptweening() end,
	CurrentSongChangedMessageCommand=function(self)
		self:stoptweening()
		CurrentHash = nil
		if GAMESTATE:GetCurrentSong() == nil then
			for i=1, num_scores do
				self:stoptweening()
				SetScoreData(1, i, "", "", "", "", false, false, false)
				SetScoreData(2, i, "", "", "", "", false, false, false)
				SetScoreData(3, i, "", "", "", "", false, false, false)
				SetScoreData(4, i, "", "", "", "", false, false, false)
				if i ~= 1 then
					self:GetChild("MachineRank"..i):settext(""):visible(false)
				end
				self:GetChild("MachineName"..i):settext(""):visible(false)
				self:GetChild("MachineScore"..i):settext(""):visible(false)
			end
			self:queuecommand('LoopScorebox')
		end
	end,
	["TabClicked"..player.."MessageCommand"]=function(self, TabClicked)
		local RealTabClick = GetRealTab(TabClicked[1])
		
		if RealTabClick == CurrentTab then
		elseif RealTabClick == 1 then
			CurrentTab = RealTabClick
			self:visible(false)
			IsVisible = false
		else
			-- don't update the score pane if we're viewing the pane that's already pre-loaded
			if RealTabClick - 2 == cur_style then
				CurrentTab = RealTabClick
				self:visible(true)
				IsVisible = true
				cur_style = RealTabClick - 2
			else
				CurrentTab = RealTabClick
				self:visible(true)
				IsVisible = true
				cur_style = RealTabClick - 2
				self:queuecommand("LoopScorebox")
			end
		end
	end,
	
	LoopScoreboxCommand=function(self)
		self:stoptweening()
		local song = GAMESTATE:GetCurrentSong() ~= nil and true or false
		for i=1, num_scores do
			self:GetChild("Rank"..i):visible(song)
			self:GetChild("Name"..i):visible(song)
			self:GetChild("Score"..i):visible(song)
			self:GetChild("Date"..i):visible(song)
			self:GetChild("MachineRank"..i):visible(song)
			self:GetChild("MachineName"..i):visible(song)
			self:GetChild("MachineScore"..i):visible(song)
			self:GetChild("MachineDate"..i):visible(song)
		end
		if IsServiceAllowed(SL.GrooveStats.GetScores) then
			self:GetChild("GrooveStatsLogo"):stopeffect()
		end
		self:GetChild("EXScoreLogo"):visible(IsServiceAllowed(SL.GrooveStats.GetScores) and song)
		self:GetChild("EXText"):visible(IsServiceAllowed(SL.GrooveStats.GetScores) and song)
		self:GetChild("SRPGLogo"):visible(song)
		self:GetChild("ITLLogo"):visible(song)
		self:GetChild("MachineLogo"):visible(song)
		if song then
			self:queuecommand("UpdateScorebox")
			:queuecommand("UpdateMachineScores")
		end
	end,
	
	GetMachineScoresCommand=function(self)
		self:stoptweening()
		MachineScores = {}
		HasLocalScores = false
		local EntryCount = 0
		local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
		local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
		if not (SongOrCourse and StepsOrTrail) then return end
		
		local HighScoreList = MachineProfile:GetHighScoreList(SongOrCourse,StepsOrTrail)
		local HighScores = HighScoreList:GetHighScores()
		if not HighScores then return end
		
		for i=1,num_scores do
			local y = -height/2 + 16 * i + 8
			local zoom = 0.87
			local rank,name,score, date
			
			if HighScores[i] then
				EntryCount = EntryCount + 1
				HasLocalScores = true
				rank = i
				score = FormatPercentScore(HighScores[i]:GetPercentDP())
				date = ParseGroovestatsDate(HighScores[i]:GetDate())
				name = HighScores[i]:GetName()
				
				MachineScores[#MachineScores+1] = {
					["rank"]=rank,
					["name"]=name,
					["score"]=score,
					["date"]=date,
				}
			end
			if i == num_scores and not IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:queuecommand("LoopScorebox")
			end
		end
		for i=EntryCount+1, num_scores do
			MachineScores[#MachineScores+1] = {
					["rank"]="",
					["name"]="",
					["score"]="",
					["date"]="",
			}
		end
		
	end,
	
	RequestResponseActor(0, 0)..{
		OnCommand=function(self)
			-- Create variables for both players, even if they're not currently active.
			self.IsParsing = {false, false}
			self.RequestNumber = 0
		end,
		-- Broadcasted from ./PerPlayer/DensityGraph.lua
		P1ChartParsingMessageCommand=function(self)	self.IsParsing[1] = true end,
		P2ChartParsingMessageCommand=function(self)	self.IsParsing[2] = true end,
		P1ChartParsedMessageCommand=function(self)
			self.IsParsing[1] = false
			if pn == "P1" and self.IsParsing[2] == false then
				self:stoptweening():queuecommand("ChartParsed")
			end
		end,
		P2ChartParsedMessageCommand=function(self)
			self.IsParsing[2] = false
			if pn == "P2" and self.IsParsing[1] == false then
				self:stoptweening():queuecommand("ChartParsed")
			end
		end,
		ChartParsedCommand=function(self)
			if not self.IsParsing[1] and not self.IsParsing[2] then
				if IsServiceAllowed(SL.GrooveStats.GetScores) then
					self:queuecommand("MakeRequest")
				end
				self:GetParent():queuecommand("GetMachineScores")
			end
		end,
		ResetCommand=function(self)
			ResetAllData()
		end,
		MakeRequestCommand=function(self)
			local sendRequest = false
			local headers = {}
			local query = {
				maxLeaderboardResults=num_scores,
			}
			if SL[pn].ApiKey ~= "" then
				query["chartHashP"..n] = SL[pn].Streams.Hash
				CurrentHash = SL[pn].Streams.Hash
				headers["x-api-key-player-"..n] = SL[pn].ApiKey
				sendRequest = true
			end

			-- We technically will send two requests in ultrawide versus mode since
			-- both players will have their own individual scoreboxes.
			-- Should be fine though.
			if sendRequest then
				if self.IsParsing[1] or self.IsParsing[2] then return end
				RemoveStaleCachedRequests()
				
				self:GetParent():visible(IsVisible)
				for i=1, num_scores do
					self:GetParent():GetChild("Name"..i):settext(""):visible(false)
					self:GetParent():GetChild("Score"..i):settext(""):visible(false)
					self:GetParent():GetChild("Rank"..i):diffusealpha(0):visible(false)
					self:GetParent():GetChild("Date"..i):diffusealpha(0):visible(false)
					self:GetParent():GetChild("MachineName"..i):settext(""):visible(false)
					self:GetParent():GetChild("MachineScore"..i):settext(""):visible(false)
					self:GetParent():GetChild("MachineRank"..i):diffusealpha(0):visible(false)
					self:GetParent():GetChild("MachineDate"..i):diffusealpha(0):visible(false)
				end
				if IsServiceAllowed(SL.GrooveStats.GetScores) then
					self:GetParent():GetChild("GrooveStatsLogo"):diffusealpha(0.5):glowshift({color("#C8FFFF"), color("#6BF0FF")})
				end	
				self:GetParent():GetChild("EXScoreLogo"):diffusealpha(0):visible(false)
				self:GetParent():GetChild("EXText"):diffusealpha(0):visible(false)
				self:GetParent():GetChild("SRPGLogo"):diffusealpha(0):visible(false)
				self:GetParent():GetChild("ITLLogo"):diffusealpha(0):visible(false)
				self:GetParent():GetChild("MachineLogo"):diffusealpha(0):visible(false)
				
				self.RequestNumber = self.RequestNumber + 1
				local thisRequestNumber = self.RequestNumber
				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="player-leaderboards.php?"..NETWORK:EncodeQueryParameters(query),
					method="GET",
					headers=headers,
					timeout=10,
					callback=LeaderboardRequestProcessor,
					args=self:GetParent(),
				})
			end
		end
	},

	-- Outline
	Def.Quad{
		Name="Outline",
		InitCommand=function(self)
			self:diffuse(GrooveStatsBlue):setsize(width + border, height + border)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffuse(style_color[cur_style])
		end,
		OffCommand=function(self) self:stoptweening() end
	},
	-- Main body
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(color("#000000")):setsize(width, height)
		end,
	},
	-- GrooveStats Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "GrooveStats.png"),
		Name="GrooveStatsLogo",
		InitCommand=function(self)
			self:zoom(0.6):diffusealpha(0.5):x(80)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening()
			if cur_style == 0 then
				self:linear(transition_seconds/2):diffusealpha(0.5)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end,
		OffCommand=function(self) self:stoptweening():stopeffect() end
	},
	
	--EX Score Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "EXScore.png"),
		Name="EXScoreLogo",
		InitCommand=function(self)
			self:zoom(0.6):diffusealpha(0):x(80)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening()
			if cur_style == 1 then
				self:linear(transition_seconds/2):diffusealpha(0.5)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end,
	},
	
	-- EX Text
	Def.BitmapText{
		Font="Common Normal",
		Name="EXText",
		Text="EX",
		InitCommand=function(self)
			self:x(80):y(-4):diffusealpha(0):diffuse(color("#ff3367")):visible(false)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening()
			if cur_style == 1 then
				self:linear(transition_seconds/2):diffusealpha(0.4)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end
	},
	-- SRPG Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "SRPG/logo_main (doubleres).png"),
		Name="SRPGLogo",
		InitCommand=function(self)
			self:diffusealpha(0.4):zoom(0.06):diffusealpha(0):x(80)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening()
			if cur_style == 2 then
				self:linear(transition_seconds/2):diffusealpha(0.5)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	},
	-- ITL Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "ITL.png"),
		Name="ITLLogo",
		InitCommand=function(self)
			self:diffusealpha(0.2):zoom(0.3):diffusealpha(0):x(80)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening()
			if cur_style == 3 then
				self:linear(transition_seconds/2):diffusealpha(0.2)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	},
	-- Machine Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "Machine.png"),
		Name="MachineLogo",
		InitCommand=function(self)
			self:diffusealpha(0.2):zoom(0.18):diffusealpha(0):x(80)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening()
			if cur_style == 4 then
				self:linear(transition_seconds/2):diffusealpha(0.3)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	},
}

for i=1,num_scores do
	local y = -height/2 + 16 * i + 8
	local zoom = 0.87

	-- Rank 1 gets a crown.
	if i == 1 then
		af[#af+1] = Def.Sprite{
			Name="Rank"..i,
			Texture=THEME:GetPathG("", "crown.png"),
			InitCommand=function(self)
				self:zoom(0.09):xy(-width/2 + 14, y):diffusealpha(0)
			end,
			UpdateScoreboxCommand=function(self)
				self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
			end,
			SetScoreboxCommand=function(self)
				local score = all_data[cur_style+1]["scores"][i]
				if score.rank ~= "" then
					self:linear(transition_seconds/2):diffusealpha(1)
				end
			end,
			OffCommand=function(self) self:stoptweening() end
		}
	else
		af[#af+1] = LoadFont("Common Normal")..{
			Name="Rank"..i,
			Text="",
			InitCommand=function(self)
				self:diffuse(Color.White):xy(-width/2 + 27, y):maxwidth(30):horizalign(right):zoom(zoom)
				end,
			UpdateScoreboxCommand=function(self)
				self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
			end,
			SetScoreboxCommand=function(self)
				local score = all_data[cur_style+1]["scores"][i]
				local clr = Color.White
				if score.isSelf then
					clr = self_color
				elseif score.isRival then
					clr = rival_color
				end
				if score.rank ~= "" then
					self:settext(score.rank)
				else
					self:settext("")
				end
				self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
			end,
			OffCommand=function(self) self:stoptweening() end
		}
	end

	af[#af+1] = LoadFont("Common Normal")..{
		Name="Name"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 30, y):maxwidth(NoteFieldIsCentered and 60 or 100):horizalign(left):zoom(zoom)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
		end,
		SetScoreboxCommand=function(self)
			local score = all_data[cur_style+1]["scores"][i]
			local clr = Color.White
			if score.isSelf then
				clr = self_color
			elseif score.isRival then
				clr = rival_color
			end
			self:settext(score.name)
			self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
		end,
		OffCommand=function(self) self:stoptweening() end
	}

	af[#af+1] = LoadFont("Common Normal")..{
		Name="Score"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(NoteFieldIsCentered and -width/2 + 130 or -width/2 + 160, y):horizalign(right):zoom(zoom)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
		end,
		SetScoreboxCommand=function(self)
			local score = all_data[cur_style+1]["scores"][i]
			local clr = Color.White
			if score.isFail then
				clr = Color.Red
			elseif score.isEx then
				clr = SL.JudgmentColors["FA+"][1]
			elseif score.isSelf then
				clr = self_color
			elseif score.isRival then
				clr = rival_color
			end
			self:settext(score.score)
			self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
		end,
		OffCommand=function(self) self:stoptweening() end
	}
	
	af[#af+1] = LoadFont("Common Normal")..{
		Name="Date"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 260, y):horizalign(right):zoom(zoom)
		end,
		UpdateScoreboxCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
		end,
		SetScoreboxCommand=function(self)
			local score = all_data[cur_style+1]["scores"][i]
			local clr = Color.White
			if score.isFail then
				clr = Color.Red
			elseif score.isSelf then
				clr = self_color
			elseif score.isRival then
				clr = rival_color
			end
			self:settext(score.date)
			self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
		end,
		OffCommand=function(self) self:stoptweening() end
	}
	
	--- Machine scores
	if i == 1 then
		af[#af+1] = Def.Sprite{
			Name="MachineRank"..i,
			Texture=THEME:GetPathG("", "crown.png"),
			InitCommand=function(self)
				self:zoom(0.09):xy(-width/2 + 14, y):diffusealpha(0)
			end,
			UpdateMachineScoresCommand=function(self)
				self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetMachineScores")
			end,
			SetMachineScoresCommand=function(self)
				if cur_style == 4 and HasLocalScores and GAMESTATE:GetCurrentSong() then
					self:linear(transition_seconds/2):diffusealpha(1)
				end
			end,
		}
	else
		af[#af+1] = LoadFont("Common Normal")..{
			Name="MachineRank"..i,
			Text="",
			InitCommand=function(self)
				self:diffuse(Color.White):xy(-width/2 + 27, y):horizalign(right):zoom(zoom)
			end,
			UpdateMachineScoresCommand=function(self)
				self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetMachineScores")
			end,
			SetMachineScoresCommand=function(self)
				if cur_style == 4 and HasLocalScores and GAMESTATE:GetCurrentSong() then
					self:settext(MachineScores[i]["rank"])
					self:linear(transition_seconds/2):diffusealpha(1)
				end
			end,
			OffCommand=function(self) self:stoptweening() end
		}
	end
	
	af[#af+1] = LoadFont("Common Normal")..{
		Name="MachineName"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 30, y):horizalign(left):zoom(zoom):maxwidth(90)
		end,
		UpdateMachineScoresCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetMachineScores")
		end,
		SetMachineScoresCommand=function(self)
			if cur_style == 4 and HasLocalScores and GAMESTATE:GetCurrentSong() then
				self:settext(MachineScores[i]["name"])
				self:linear(transition_seconds/2):diffusealpha(1)
			elseif cur_style == 4 and not HasLocalScores and i == 1 and GAMESTATE:GetCurrentSong() then
				self:linear(transition_seconds/2):diffusealpha(1):settext("No Scores")
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
	
	af[#af+1] = LoadFont("Common Normal")..{
		Name="MachineScore"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 160, y):horizalign(right):zoom(zoom)
		end,
		UpdateMachineScoresCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetMachineScores")
		end,
		SetMachineScoresCommand=function(self)
			if cur_style == 4 and HasLocalScores and GAMESTATE:GetCurrentSong() then
				self:settext(MachineScores[i]["score"])
				self:linear(transition_seconds/2):diffusealpha(1)
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
	
	af[#af+1] = LoadFont("Common Normal")..{
		Name="MachineDate"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 260, y):horizalign(right):zoom(zoom)
		end,
		UpdateMachineScoresCommand=function(self)
			self:stoptweening():linear(transition_seconds/2):diffusealpha(0):queuecommand("SetMachineScores")
		end,
		SetMachineScoresCommand=function(self)
			if cur_style == 4 and HasLocalScores and GAMESTATE:GetCurrentSong() then
				self:settext(MachineScores[i]["date"])
				self:linear(transition_seconds/2):diffusealpha(1)
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
end
return af