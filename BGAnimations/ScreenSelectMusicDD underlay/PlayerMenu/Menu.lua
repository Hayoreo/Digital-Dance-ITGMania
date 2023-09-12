local player = ...
local pn = ToEnumShortString(player)

local padding = 40
local border = 4
local width = SCREEN_WIDTH/3 - padding
local height = SCREEN_HEIGHT - padding*4
local XPos
local YPos = SCREEN_CENTER_Y
local TabWidth = (width-border*1.5)/6 - border/2

if pn == "P1" then
	XPos = 0
elseif pn == "P2" then
	XPos = (SCREEN_WIDTH) - (SCREEN_WIDTH/3)
end


local af = Def.ActorFrame{
	InitCommand=function(self) self:visible(false) end,
	["ShowPlayerMenu"..pn.."MessageCommand"]=function(self)
		self:visible(true)
	end,
	["HidePlayerMenu"..pn.."MessageCommand"]=function(self)
		self:visible(false)
	end,
	["UpdateMenuCursorPosition"..pn.."MessageCommand"]=function(self, params)
		self:stoptweening()
		self:queuecommand("UpdateMenuTabColor")
		self:queuecommand("UpdateDisplayedTab")
	end,
}

-- Tab Contents
-----------------------------------------------------------------------------
local PlayerTabNames = {
THEME:GetString("DDPlayerMenu","QuickMods"),
THEME:GetString("DDPlayerMenu","VisualMods"),
THEME:GetString("DDPlayerMenu","AdvancedMods"),
THEME:GetString("DDPlayerMenu","UncommonMods"),
THEME:GetString("DDPlayerMenu","SortsFilters"),
THEME:GetString("DDPlayerMenu","System"),
}

local TabDescriptions={
THEME:GetString("DDPlayerMenu","QuickModsDescription"),
THEME:GetString("DDPlayerMenu","VisualModsDescription"),
THEME:GetString("DDPlayerMenu","AdvancedModsDescription"),
THEME:GetString("DDPlayerMenu","UncommonModsDescription"),
THEME:GetString("DDPlayerMenu","SortsFiltersDescription"),
THEME:GetString("DDPlayerMenu","SystemDescription"),
}
-----------------------------------------------------------------------------
-- menu structure

-- Darken this 3rd of the screen to create less distractions from the menu.
af[#af+1] = Def.Quad{
	Name="DarkenScreen"..pn,
	InitCommand=function(self)
		self:diffuse(color("#000000"))
			:zoomto(SCREEN_WIDTH/3, SCREEN_HEIGHT)
			:vertalign(middle):horizalign(left)
			:diffusealpha(0.9)
			:x(XPos)
			:y(YPos)
	end,
}

-- Menu Outline
af[#af+1] = Def.Quad{
	Name="MenuOutline"..pn,
	InitCommand=function(self)
		local color = PlayerColor(player)
		color[4] = 1
		color[1] = 0.8 * color[1] + 0.2
		color[2] = 0.8 * color[2] + 0.2
		color[3] = 0.8 * color[3] + 0.2
		self:diffuse(color)
			:zoomto(width, height)
			:vertalign(middle):horizalign(left)
			:x(XPos + padding/2)
			:y(YPos)
	end,
}

-- Menu Body
af[#af+1] = Def.Quad{
	Name="MenuBody"..pn,
	InitCommand=function(self)
		self:diffuse(color("#171717"))
			:zoomto(width-border, height-border)
			:vertalign(middle):horizalign(left)
			:x(XPos + padding/2 + border/2)
			:y(YPos)
	end,
}

-- Tab divider outline
af[#af+1] = Def.Quad{
	Name="MenuOutline"..pn,
	InitCommand=function(self)
		self:diffuse(color("#808080"))
			:zoomto(width-border, 20 + border)
			:vertalign(top):horizalign(left)
			:x(XPos + padding/2 + border/2)
			:y(YPos - height/2 + border/2)
	end,
}

-- Tabs
for i=1,6 do
	af[#af+1] = Def.Quad{
		Name=pn.."MenuTabs"..i,
		InitCommand=function(self)
			self:diffuse(color("#171717"))
				:zoomto(TabWidth, 20)
				:vertalign(top):horizalign(left)
				:x(XPos + padding/2 + ((TabWidth + border/2) * i) - TabWidth + border/2 )
				:y(YPos - height/2 + border)
				if pn == "P1" then
					if i == CurrentTabP1 then
						local color = PlayerColor(player)
						color[4] = 1
						color[1] = 0.3 * color[1] + 0.2
						color[2] = 0.3 * color[2] + 0.2
						color[3] = 0.3 * color[3] + 0.2
						self:diffuse(color)
					end
				elseif pn == "P2" then
					if i == CurrentTabP2 then
						local color = PlayerColor(player)
						color[4] = 1
						color[1] = 0.3 * color[1] + 0.2
						color[2] = 0.3 * color[2] + 0.2
						color[3] = 0.3 * color[3] + 0.2
						self:diffuse(color)
					end
				end
		end,
		UpdateMenuTabColorMessageCommand=function(self, params)
			self:stoptweening()
			if pn == "P1" then
				if i == CurrentTabP1 then
					local color = PlayerColor(player)
					color[4] = 1
					color[1] = 0.3 * color[1] + 0.2
					color[2] = 0.3 * color[2] + 0.2
					color[3] = 0.3 * color[3] + 0.2
					self:GetParent():GetChild(pn.."MenuTabs"..CurrentTabP1):linear(0.1):diffuse(color)
				else
					self:GetParent():GetChild(pn.."MenuTabs"..i):linear(0.1):diffuse(color("#171717"))
				end
			elseif pn == "P2" then
				if i == CurrentTabP2 then
					local color = PlayerColor(player)
					color[4] = 1
					color[1] = 0.3 * color[1] + 0.2
					color[2] = 0.3 * color[2] + 0.2
					color[3] = 0.3 * color[3] + 0.2
					self:GetParent():GetChild(pn.."MenuTabs"..CurrentTabP2):linear(0.1):diffuse(color)
				else
					self:GetParent():GetChild(pn.."MenuTabs"..i):linear(0.1):diffuse(color("#171717"))
				end
			end
		end,
	}
end

-- Tab Names
for i=1,6 do
	af[#af+1] = Def.BitmapText{
		Font="Miso/_miso",
		Name=pn.."TabName"..i,
		InitCommand=function(self)
			local zoom = 0.6
			self:horizalign(center):vertalign(middle):shadowlength(1)
				:x(XPos + padding/2 + ((TabWidth + border/2) * i) - TabWidth/2 + border/2)
				:y(YPos - height/2 + border + 10)
				:maxwidth(TabWidth/zoom - 2)
				:vertspacing(-8)
				:zoom(zoom)
				:draworder(2)
				:settext(PlayerTabNames[i])
		end,
	}
end

-- Bottom Seperator
af[#af+1] = Def.Quad{
	Name="DescriptionOutline"..pn,
	InitCommand=function(self)
		local color = PlayerColor(player)
		color[4] = 1
		color[1] = 0.8 * color[1] + 0.2
		color[2] = 0.8 * color[2] + 0.2
		color[3] = 0.8 * color[3] + 0.2
		self:diffuse(color)
			:zoomto(width-border, border/2)
			:vertalign(bottom):horizalign(left)
			:x(XPos + padding/2 + border/2)
			:y(YPos + height/2 - border - 20)
	end,
}

-----------------------------------------------------------------------------
-- Bottom Information for tabs
af[#af+1] = Def.BitmapText{
	Font="Miso/_miso",
	Name=pn.."TabDescriptions",
	InitCommand=function(self)
		local zoom = 0.5
		self:horizalign(left):vertalign(top):shadowlength(1)
			:x(XPos + padding/2 + border*2)
			:y(YPos + height/2 - 22)
			:maxwidth((width/zoom) - 25)
			:zoom(zoom)
			:settext(TabDescriptions[1])
			:vertspacing(-5)
			:queuecommand("UpdateDisplayedTab")
	end,
	UpdateDisplayedTabCommand=function(self)
		if pn == "P1" then
			if CurrentRowP1 == 0 then
				self:visible(true)
				self:settext(TabDescriptions[CurrentTabP1])
			else
				self:visible(false)
			end
		elseif pn == "P2" then
			if CurrentRowP2 == 0 then
				self:visible(true)
				self:settext(TabDescriptions[CurrentTabP2])
			else
				self:visible(false)
			end
		end
	end,
}

-- Move the individual tab contents out of here, otherwise this file will be thicc
af[#af+1] = LoadActor("Tabs/default.lua", {player = player, padding = padding, border = border, width = width, height = height, XPos = XPos, YPos = YPos, TabWidth = TabWidth, af = af})
-- the cursor for this jawndice
af[#af+1] = LoadActor("./Cursor.lua", {player = player, TabWidth = TabWidth, XPos = XPos, YPos = YPos, af = af})

return af