local CurrentPlayer
local nsj = GAMESTATE:GetNumSidesJoined()
local stylename = GAMESTATE:GetCurrentStyle():GetName()

return Def.Banner{
	CurrentSongChangedMessageCommand=function(self)
		if nsj == 1 then
			CurrentPlayer = GAMESTATE:IsPlayerEnabled(0) and "P1" or "P2"
		end
		self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			:setsize(418,164):zoom(0.4)
			:xy(CurrentPlayer == "P1" and -70 or 70, -200)
		if stylename == "double" then
			self:zoom(0.308)
			self:x( SCREEN_WIDTH - (self:GetWidth()*self:GetZoom()/2.185) )
			self:y(-135)
			
		end
		self:SetDecodeMovie(ThemePrefs.Get("AnimateBanners"))
	end
}