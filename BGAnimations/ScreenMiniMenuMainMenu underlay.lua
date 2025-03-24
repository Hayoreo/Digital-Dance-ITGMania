local t = Def.ActorFrame{
	OffCommand=function(self)
		if SL.Global.ActiveModifiers.MusicRateEdit < 1 then	
			SL.Global.ActiveModifiers.MusicRate = 1
			SL.Global.ActiveModifiers.MusicRateEdit = 1
		end
		
	end,
}

return t