local w = SL_WideScale(310, 417)
local h = 22

-- Song Completion Meter
return Def.ActorFrame{
	Name="SongMeter",
	InitCommand=function(self) self:xy(_screen.cx, 20) end,

	-- border
	Def.Quad{ InitCommand=function(self) self:zoomto(w, h) end },
	Def.Quad{ InitCommand=function(self) self:zoomto(w-4, h-4):diffuse(0,0,0,1) end },

	Def.SongMeterDisplay{
		StreamWidth=(w-4),
		Stream=Def.Quad({ InitCommand=function(self) self:zoomy(18):diffuse(GetCurrentColor(true)) end })
	},

	-- Song Title
	LoadFont("Common Normal")..{
		Name="SongTitle",
		InitCommand=function(self) self:zoom(0.8):shadowlength(0.6):maxwidth(_screen.w/2.5 - 10) end,
		CurrentSongChangedMessageCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			local course = GAMESTATE:GetCurrentCourse()
			local text = ""
			if song then
				text = song:GetDisplayFullTitle()
			end
			if course then
				text = course:GetDisplayFullTitle() .. " - " .. text
			end
			self:settext( song and text or "" )
		end
	}
}