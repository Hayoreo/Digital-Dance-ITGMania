local Player = ...
local pn = ToEnumShortString(Player)
local CanEnterName = SL[pn].HighScores.EnteringName
local textBlink = false
local CurrentPlayer

if GAMESTATE:GetNumSidesJoined() == 2 then
	if SL["P1"].HighScores.EnteringName then
		CurrentPlayer = "P1"
	elseif SL["P2"].HighScores.EnteringName then
		CurrentPlayer = "P2"
	end
elseif GAMESTATE:IsSideJoined(0) and SL["P1"].HighScores.EnteringName then
	CurrentPlayer = "P1"
elseif GAMESTATE:IsSideJoined(1) and SL["P2"].HighScores.EnteringName  then
	CurrentPlayer = "P2"
end

if CanEnterName then
	SL[pn].HighScores.Name = ""
end

if PROFILEMAN:IsPersistentProfile(Player) then
	SL[pn].HighScores.Name = PROFILEMAN:GetProfile(Player):GetLastUsedHighScoreName()
end

local t = Def.ActorFrame{
	Name="PlayerNameAndDecorations_"..pn,
	InitCommand=function(self)
		if Player == PLAYER_1 then
			self:x(_screen.cx-285)
		elseif Player == PLAYER_2 then
			self:x(_screen.cx+285)
		end
		self:y(_screen.cy-40)
		self:queuecommand('Blink')
	end,
	
	BlinkCommand=function(self)
		self:stoptweening()
		textBlink = not textBlink
		self:GetChild("PlayerName"):queuecommand("SetText")
		self:sleep(0.5):queuecommand('Blink')
	end,

	-- the quads behind the playerName
	Def.Quad{
		Name="NameFrame",
		InitCommand=cmd(diffuse,PlayerColor(Player); zoomto, 280, _screen.h/7.5),
	},
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.75"); zoomto, 275, _screen.h/8),
	},

	-- the quad behind the highscore list
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.25"); zoomto, 275, _screen.h/2.2),
		OnCommand=cmd(y,155)
	},
}


t[#t+1] = LoadFont("Miso/_miso")..{
	Name="PlayerName",
	InitCommand=cmd(zoom,1.5; halign,0; xy,-132,0;),
	OnCommand=function(self)
		self:visible( CanEnterName )
		self:horizalign(left)
		self:settext( SL[pn].HighScores.Name or "" )
	end,
	SetNamePlayerMessageCommand=function(self, params)
		CurrentPlayer = params[1]
		self:queuecommand('SetText')
	end,
	SetTextCommand=function(self)
		if CurrentPlayer == "P1" and SL["P1"].HighScores.EnteringName then
			if textBlink and pn == CurrentPlayer and SL["P1"].HighScores.EnteringName then
				self:settext( SL[pn].HighScores.Name .. "_" or "" )
			else
				self:settext( SL[pn].HighScores.Name or "" )
			end
		elseif CurrentPlayer == "P2" and SL["P2"].HighScores.EnteringName then
			if textBlink and pn == CurrentPlayer and SL["P2"].HighScores.EnteringName then
				self:settext( SL[pn].HighScores.Name .. "_" or "" )
			else
				self:settext( SL[pn].HighScores.Name or "" )
			end
		else
			-- don't show the text cursor if they don't have input focus.
			if not CurrentPlayer == "P1" and GAMESTATE:IsPlayerEnabled(0) then
				self:settext( SL[pn].HighScores.Name or "" )
			elseif CurrentPlayer == "P2" and GAMESTATE:IsPlayerEnabled(1) then
				self:settext( SL[pn].HighScores.Name or "" )
			end
		end
	end,
}

t[#t+1] = LoadFont("Wendy/_wendy small")..{
	Text=ScreenString("OutOfRanking"),
	OnCommand=cmd(zoom,0.8; diffuse,PlayerColor(Player); y, 0; visible, not CanEnterName)
}

return t
