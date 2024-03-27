local player, header_height, width = unpack(...)
local stylename = GAMESTATE:GetCurrentStyle():GetName()
local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(0, 0, 0, 0.95):setsize(width, _screen.h):y(-header_height)
	end
}

if stylename == "double" then
	af[#af+1] = Def.Quad{
		InitCommand=function(self)
			self:diffuse(0, 0, 0, 0.95):setsize(width, _screen.h):y(-header_height)
			self:x(_screen.w - width)
		end
	}
end



return af