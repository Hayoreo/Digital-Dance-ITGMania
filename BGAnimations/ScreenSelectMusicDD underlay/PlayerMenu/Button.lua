local player = ...
local pn = ToEnumShortString(player)

local border = 5
local width = 60
local height = 16
local XSpot
local YSpot = 148

if pn == "P1" then
	XSpot = SCREEN_WIDTH/3 - 20 - width
elseif pn == "P2" then
	XSpot = (SCREEN_WIDTH) - (SCREEN_WIDTH/3 - 20)
end
local af = Def.ActorFrame{
	InitCommand=function(self) self:visible(GAMESTATE:IsPlayerEnabled(pn)) end,
}

-- Outline
af[#af+1] = Def.Quad{
	Name="ButtonOutline"..pn,
	InitCommand=function(self)
		self:diffuse(color("#1e282f")):zoomto(width+border, height + border):vertalign(top):horizalign(left)
			:x(XSpot)
			:y(YSpot)
	end,

}

-- Button
af[#af+1] = Def.Quad{
	Name="Button"..pn,
	InitCommand=function(self)
		self:diffuse(color("#32a852")):zoomto(width, height):vertalign(top):horizalign(left)
			:x(XSpot + border/2)
			:y(YSpot + border/2)
	end,
}


-- Button text
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name="ButtonText"..pn,
	InitCommand=function(self)
		local zoom = 0.8
		self:horizalign(center):vertalign(middle):shadowlength(1)
			:x(XSpot + width/2 + border/2)
			:y(YSpot + height/2 + border/2)
			:maxwidth((width - 10)/zoom)
			:zoom(zoom)
			self:settext("OPTIONS")
	end,
}

return af