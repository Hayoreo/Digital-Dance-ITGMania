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

-- Menu Outline stuff
local MenuOutlineTheta = 0

local x0 = 0
local x1 = width
local y0 = -height/2
local y1 = height/2
local MenuOutlineSpeed = 5
local MenuOutlineFPS = PREFSMAN:GetPreference("RefreshRate") ~= 0 and PREFSMAN:GetPreference("RefreshRate") or 120
local PlayerWhiteness = pn == "P1" and 0.5 or 0.7


local MenuOutlineVerts = {
	{ { x0, y0, 0 }, { 0, 0, 0, 0 } },
	{ { x1, y0, 0 }, { 1, 0, 0, 1 } },
	{ { x1, y1, 0 }, { 0, 1, 0, 1 } },
	{ { x0, y1, 0 }, { 0, 0, 1, 1 } },
}

local function ColorAtAngle(angle)
	local color = PlayerColor(player)
	local whiteness = PlayerWhiteness*(math.sin(angle)+1)/2
	local playerness = 1 - whiteness

	color[4] = 1
	color[1] = playerness * color[1] + whiteness
	color[2] = playerness * color[2] + whiteness
	color[3] = playerness * color[3] + whiteness
	
	return color
end

local function RotateMenuOutlineColors()
	MenuOutlineTheta = MenuOutlineTheta + MenuOutlineSpeed / MenuOutlineFPS

	MenuOutlineVerts[1][2] = ColorAtAngle(MenuOutlineTheta)
	MenuOutlineVerts[2][2] = ColorAtAngle(MenuOutlineTheta + 1.5*math.pi)
	MenuOutlineVerts[3][2] = ColorAtAngle(MenuOutlineTheta + math.pi)
	MenuOutlineVerts[4][2] = ColorAtAngle(MenuOutlineTheta + 0.5*math.pi)
end

RotateMenuOutlineColors()
-- the actual menu outline
af[#af+1] = Def.ActorMultiVertex {
	Name="MenuOutline"..pn,
	InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_Quads", First=1, Num=-1})
		self:SetVertices(MenuOutlineVerts)

		self:x(XPos + padding/2)
			:y(YPos)
			:queuecommand('RotateColor')
	end,
	RotateColorCommand=function(self)
		self:linear(1/MenuOutlineFPS)
		self:SetDrawState({Mode="DrawMode_Quads", First=1, Num=-1})
		RotateMenuOutlineColors()
		self:visible(true):SetVertices(MenuOutlineVerts)

		self:queuecommand('RotateColor')
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
	RightMouseClickUpdateMessageCommand=function(self)
		local ObjectX = self:GetX() - border/2
		local ObjectY = self:GetY()
		local ObjectWidth = self:GetZoomX() + border
		local ObjectHeight = self:GetZoomY() + border
		local HAlign = self:GetHAlign()
		local VAlign = self:GetVAlign()
		ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
		ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
		if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
			if pn == "P1" and PlayerMenuP1 then
				PlayerMenuP1 = false
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				MESSAGEMAN:Broadcast("HidePlayerMenuP1")
			elseif pn == "P2" and PlayerMenuP2 then
				PlayerMenuP2 = false
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				MESSAGEMAN:Broadcast("HidePlayerMenuP2")
			end
		
		end
		
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
		LeftMouseClickUpdateMessageCommand=function(self)
			local CurrentTab, CurrentRow, CurrentColumn
			if pn == "P1" then
				CurrentTab = CurrentTabP1
				CurrentRow = CurrentRowP1
				CurrentColumn = CurrentColumnP1
			elseif pn == "P2" then
				CurrentTab = CurrentTabP2
				CurrentRow = CurrentRowP2
				CurrentColumn = CurrentColumnP2
			end
			for j=1, 6 do
				local Parent = self:GetParent():GetChild(pn.."MenuTabs"..i)
				local ObjectWidth = Parent:GetZoomX()
				local ObjectHeight = Parent:GetZoomY()
				local ObjectX = Parent:GetX()
				local ObjectY = Parent:GetY()
				local HAlign = Parent:GetHAlign()
				local VAlign = Parent:GetVAlign()
				ObjectX = ObjectX + (0.5-HAlign)*ObjectWidth
				ObjectY = ObjectY + (0.5-VAlign)*ObjectHeight
				
				if IsMouseGucci(ObjectX, ObjectY, ObjectWidth, ObjectHeight) then
					
					if CurrentTab ~= i then
						SOUND:PlayOnce( THEME:GetPathS("", "page_turn.ogg") )
					elseif CurrentRow ~= 0 and CurrentTab == i then
						SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					end
					CurrentTab = i
					CurrentRow = 0
					CurrentColumn = 1
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
				end
			end
			if pn == "P1" then
				CurrentTabP1 = CurrentTab
				CurrentRowP1 = CurrentRow
				CurrentColumnP1 = CurrentColumn
			elseif pn == "P2" then
				CurrentTabP2 = CurrentTab
				CurrentRowP2 = CurrentRow
				CurrentColumnP2 = CurrentColumn
			end
			MESSAGEMAN:Broadcast("UpdateMenuCursorPosition"..pn, {})
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