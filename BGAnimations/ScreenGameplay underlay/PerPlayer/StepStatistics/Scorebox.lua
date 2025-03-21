local player = ...
local pn = ToEnumShortString(player)
local stylename = GAMESTATE:GetCurrentStyle():GetName()
local BlackList = GetBlackList()

if SL[pn].ApiKey == "" then
	return
end

local n = player==PLAYER_1 and "1" or "2"
local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local NumEntries = 5

local border = 5
local width = NoteFieldIsCentered and 140 or 162
local height = NoteFieldIsCentered and 68 or 80

local cur_style = 0
local num_styles = 4

local GrooveStatsBlue = color("#007b85")
local RpgYellow = color("1,0.972,0.792,1")
local ItlPink = color("1,0.2,0.406,1")

local style_color = {
	[0] = GrooveStatsBlue,  -- Either GrooveStats or GrooveStats EX score
	[1] = GrooveStatsBlue,  -- Either GrooveStats or GrooveStats EX score
	[2] = RpgYellow,
	[3] = ItlPink,
}

local self_color = color("#a1ff94")
local rival_color = color("#c29cff")

local loop_seconds = 5
local transition_seconds = 1

local all_data = {}

local ResetAllData = function()
	for i=1,num_styles do
		local data = {
			["has_data"]=false,
			["scores"]={}
		}
		local scores = data["scores"]
		for i=1,NumEntries do
			scores[#scores+1] = {
				["rank"]="",
				["name"]="",
				["score"]="",
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

local SetScoreData = function(data_idx, score_idx, rank, name, score, isSelf, isRival, isFail, isEx)
	all_data[data_idx].has_data = true

	local score_data = all_data[data_idx]["scores"][score_idx]
	score_data.rank = rank..((#rank > 0) and "." or "")
	score_data.name = name
	score_data.score = score
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
			text = THEME:GetString("Groovestats", "TimedOut")
		elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
			text = THEME:GetString("Groovestats", "FailedToLoad")
		end
		SetScoreData(1, 1, "", text, "", false, false, false, false)
		master:queuecommand("CheckScorebox")
		return
	end

	local playerStr = "player"..n
	local data = JsonDecode(res.body)

	-- First check to see if the leaderboard even exists.
	if data and data[playerStr] then
		-- These will get overwritten if we have any entries in the leaderboard below.
		SetScoreData(1, 1, "", "No Scores", "", false, false, false, false)
		-- Don't use ex leaderboard if not using EX scoring.
		if SL["P"..n].ActiveModifiers.ShowEXScore or SL["P"..n].ActiveModifiers.ShowFaPlusWindow then
			SetScoreData(2, 1, "", "No Scores", "", false, false, false, false)
		end

		local numEntries = 0
		if SL["P"..n].ActiveModifiers.ShowEXScore then
			-- If the player is using EX scoring, then we want to display the EX leaderboard first.
			if data[playerStr]["exLeaderboard"] then
				numEntries = 0
				local IsBlackListed
				local NumBlackListed = 0
				for entry in ivalues(data[playerStr]["exLeaderboard"]) do
					IsBlackListed = false
					for i=1, #BlackList do
						if entry["name"] == BlackList[i] then
							IsBlackListed = true
							NumBlackListed = NumBlackListed + 1
						end
					end
					if not IsBlackListed then
						numEntries = numEntries + 1
						SetScoreData(2, numEntries,
										tostring(entry["rank"] - NumBlackListed),
										entry["name"],
										string.format("%.2f", entry["score"]/100),
										entry["isSelf"],
										entry["isRival"],
										entry["isFail"],
										true
									)
					end
				end
			end

			if data[playerStr]["gsLeaderboard"] then
				numEntries = 0
				local IsBlackListed
				local NumBlackListed = 0
				for entry in ivalues(data[playerStr]["gsLeaderboard"]) do
					IsBlackListed = false
					for i=1, #BlackList do
						if entry["name"] == BlackList[i] then
							IsBlackListed = true
							NumBlackListed = NumBlackListed + 1
						end
					end
					if not IsBlackListed then
						numEntries = numEntries + 1
						SetScoreData(1, numEntries,
										tostring(entry["rank"] - NumBlackListed),
										entry["name"],
										string.format("%.2f", entry["score"]/100),
										entry["isSelf"],
										entry["isRival"],
										entry["isFail"],
										false
									)
					end
				end
			end
		else
			-- Display the main GrooveStats leaderboard first and if player is not using EX scoring OR FA+ don't show the EX leaderboard.
			if data[playerStr]["gsLeaderboard"] then
				numEntries = 0
				local IsBlackListed
				local NumBlackListed = 0
				for entry in ivalues(data[playerStr]["gsLeaderboard"]) do
					IsBlackListed = false
					for i=1, #BlackList do
						if entry["name"] == BlackList[i] then
							IsBlackListed = true
							NumBlackListed = NumBlackListed + 1
						end
					end
					if not IsBlackListed then
						numEntries = numEntries + 1
						SetScoreData(1, numEntries,
										tostring(entry["rank"] - NumBlackListed),
										entry["name"],
										string.format("%.2f", entry["score"]/100),
										entry["isSelf"],
										entry["isRival"],
										entry["isFail"],
										false
									)
					end
				end
			end
			
			-- If not using EXScoring, but using FA+ show the EX Score leaderboard 2nd instead of 1st.
			if SL["P"..n].ActiveModifiers.ShowFaPlusWindow then
				if data[playerStr]["exLeaderboard"] then
					numEntries = 0
					local IsBlackListed
					local NumBlackListed = 0
					for entry in ivalues(data[playerStr]["exLeaderboard"]) do
						IsBlackListed = false
						for i=1, #BlackList do
							if entry["name"] == BlackList[i] then
								IsBlackListed = true
								NumBlackListed = NumBlackListed + 1
							end
						end
						if not IsBlackListed then
							numEntries = numEntries + 1
							SetScoreData(2, numEntries,
											tostring(entry["rank"] - NumBlackListed),
											entry["name"],
											string.format("%.2f", entry["score"]/100),
											entry["isSelf"],
											entry["isRival"],
											entry["isFail"],
											true
										)
						end
					end
				end
			end
		end

		if data[playerStr]["rpg"] then
			local entryCount = 0
			local IsBlackListed
			local NumBlackListed = 0
			SetScoreData(3, 1, "", "No Scores", "", false, false, false)

			if data[playerStr]["rpg"]["rpgLeaderboard"] then
				for entry in ivalues(data[playerStr]["rpg"]["rpgLeaderboard"]) do
					IsBlackListed = false
					for i=1, #BlackList do
						if entry["name"] == BlackList[i] then
							IsBlackListed = true
							NumBlackListed = NumBlackListed + 1
						end
					end
					if not IsBlackListed then
						entryCount = entryCount + 1
						SetScoreData(3, entryCount,
										tostring(entry["rank"] - NumBlackListed),
										entry["name"],
										string.format("%.2f", entry["score"]/100),
										entry["isSelf"],
										entry["isRival"],
										entry["isFail"],
										false
									)
					end
				end
			end
		end

		if data[playerStr]["itl"] then
			local numEntries = 0
			local IsBlackListed
			local NumBlackListed = 0
			SetScoreData(4, 1, "", "No Scores", "", false, false, false)

			if data[playerStr]["itl"]["itlLeaderboard"] then
				for entry in ivalues(data[playerStr]["itl"]["itlLeaderboard"]) do
					IsBlackListed = false
					for i=1, #BlackList do
						if entry["name"] == BlackList[i] then
							IsBlackListed = true
							NumBlackListed = NumBlackListed + 1
						end
					end
					if not IsBlackListed then
						numEntries = numEntries + 1
						SetScoreData(4, numEntries,
										tostring(entry["rank"] - NumBlackListed),
										entry["name"],
										string.format("%.2f", entry["score"]/100),
										entry["isSelf"],
										entry["isRival"],
										entry["isFail"],
										true
									)
					end
				end
			end
		end
 	end
	master:queuecommand("CheckScorebox")
end

local af = Def.ActorFrame{
	Name="ScoreBox"..pn,
	InitCommand=function(self)
		self:xy((player==PLAYER_1 and 106 or -110), -15)
		-- offset a bit more when NoteFieldIsCentered
		if NoteFieldIsCentered and IsUsingWideScreen() then
			self:addx( (player==PLAYER_1 and -34 or 38) )
		end
		-- ultrawide and both players joined
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:x(self:GetX() * -1)
		end
		if stylename == "double" then
			self:x(SCREEN_WIDTH - 118.5)
				:y(-70)
				:zoom(0.821)
		end
		self.isFirst = true
	end,
	CheckScoreboxCommand=function(self)
		self:queuecommand("LoopScorebox")
	end,
	LoopScoreboxCommand=function(self)
		if #all_data == 0 then return end
		
		local start = cur_style

		cur_style = (cur_style + 1) % num_styles
		if cur_style ~= start or self.isFirst then
			-- Make sure we have the next set of data.
			while cur_style ~= start do
				if HasData(cur_style) then
					-- If this is the first time we're looping, update the start variable
					-- since it may be different than the default
					if self.isFirst then
						start = cur_style
						self.isFirst = false
						-- Continue looping to figure out the next style.
					else
						break
					end
				end
				cur_style = (cur_style + 1) % num_styles
			end
		end

		-- Loop only if there's something new to loop to.
		if start ~= cur_style then
			self:sleep(loop_seconds):queuecommand("LoopScorebox")
		end
	end,

	RequestResponseActor(0, 0)..{
		OnCommand=function(self)
			self:queuecommand("MakeRequest")
		end,
		CurrentSongChangedMessageCommand=function(self)
			if not self.isFirst then
				ResetAllData()
				self:queuecommand("MakeRequest")
			end
		end,
		MakeRequestCommand=function(self)
			local sendRequest = false
			local headers = {}
			local query = {
				maxLeaderboardResults=NoteFieldIsCentered and NumEntries - 1 or NumEntries,
			}
			if SL[pn].ApiKey ~= "" and SL[pn].Streams.Hash ~= "" then
				query["chartHashP"..n] = SL[pn].Streams.Hash
				headers["x-api-key-player-"..n] = SL[pn].ApiKey
				sendRequest = true
			end

			-- We technically will send two requests in ultrawide versus mode since
			-- both players will have their own individual scoreboxes.
			-- Should be fine though.
			if sendRequest then
				self:GetParent():GetChild("Name1"):settext(THEME:GetString("Groovestats", "Loading"))
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
		LoopScoreboxCommand=function(self)
			if cur_style == 0 then
				self:linear(transition_seconds):diffuse(color("#007b85"))
			elseif cur_style == 1 then
				self:linear(transition_seconds):diffuse(color("#aa886b"))
			elseif cur_style == 2 then
				self:linear(transition_seconds):diffuse(color("1,0.2,0.406,1"))
			end
			self:linear(transition_seconds):diffuse(style_color[cur_style])
		end
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
			self:zoom(0.6):diffusealpha(0.5)
		end,
		LoopScoreboxCommand=function(self)
			if cur_style == 0 or cur_style == 1 then
				self:sleep(transition_seconds/2):linear(transition_seconds/2):diffusealpha(0.5)
			else
				self:linear(transition_seconds/2):diffusealpha(0)
			end
		end
	},
	-- EX Text
	Def.BitmapText{
		Font="Common Normal",
		Text="EX",
		InitCommand=function(self)
			self:diffusealpha(0.3):x(2):y(-5)
		end,
		LoopScoreboxCommand=function(self)
			if cur_style == 1 then
				self:sleep(transition_seconds/2):linear(transition_seconds/2):diffusealpha(0.3)
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
			self:diffusealpha(0.4):zoom(0.06):diffusealpha(0)
		end,
		LoopScoreboxCommand=function(self)
			if cur_style == 2 then
				self:linear(transition_seconds/2):diffusealpha(0.5)
			else
				self:sleep(transition_seconds/2):linear(transition_seconds/2):diffusealpha(0)
			end
		end
	},
	-- ITL Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "ITL.png"),
		Name="ITLLogo",
		InitCommand=function(self)
			self:diffusealpha(0.2):zoom(0.3):diffusealpha(0)
		end,
		LoopScoreboxCommand=function(self)
			if cur_style == 3 then
				self:linear(transition_seconds/2):diffusealpha(0.2)
			else
				self:sleep(transition_seconds/2):linear(transition_seconds/2):diffusealpha(0)
			end
		end
	},
}

for i=1,NumEntries do
	local y = -height/2 + 16 * i - 8
	local zoom = 0.87

	-- Rank 1 gets a crown.
	if i == 1 then
		af[#af+1] = LoadFont("Common Normal")..{
			Name="Rank"..i,
			Text="",
			InitCommand=function(self)
				self:diffuse(Color.White):xy(-width/2 + 27, y):maxwidth(30):horizalign(right):zoom(zoom)
				end,
			LoopScoreboxCommand=function(self)
				self:linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
			end,
			SetScoreboxCommand=function(self)
				local score = all_data[cur_style+1]["scores"][i]
				local clr = Color.White
				if score.rank == 1 .. "." then
					self:settext("🏅"):zoom(0.7)
					self:linear(transition_seconds/2):diffusealpha(1)
				else
					self:settext(score.rank):zoom(zoom)
					if score.isSelf then
						clr = self_color
					elseif score.isRival then
						clr = rival_color
					end
					self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
				end
			end
		}
	else
		af[#af+1] = LoadFont("Common Normal")..{
			Name="Rank"..i,
			Text="",
			InitCommand=function(self)
				self:diffuse(Color.White):xy(-width/2 + 27, y):maxwidth(30):horizalign(right):zoom(zoom)
				end,
			LoopScoreboxCommand=function(self)
				self:linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
			end,
			SetScoreboxCommand=function(self)
				local score = all_data[cur_style+1]["scores"][i]
				local clr = Color.White
				if score.isSelf then
					clr = self_color
				elseif score.isRival then
					clr = rival_color
				end
				self:settext(score.rank)
				self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
			end
		}
	end

	af[#af+1] = LoadFont("Common Normal")..{
		Name="Name"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 30, y):maxwidth(NoteFieldIsCentered and 60 or 100):horizalign(left):zoom(zoom)
		end,
		LoopScoreboxCommand=function(self)
			self:linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
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
			end
	}

	af[#af+1] = LoadFont("Common Normal")..{
		Name="Score"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(NoteFieldIsCentered and -width/2 + 130 or -width/2 + 160, y):horizalign(right):zoom(zoom)
		end,
		LoopScoreboxCommand=function(self)
			self:linear(transition_seconds/2):diffusealpha(0):queuecommand("SetScorebox")
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
		end
	}
end
return af