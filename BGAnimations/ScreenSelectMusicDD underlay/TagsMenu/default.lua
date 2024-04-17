-- don't load in course mode... for now?
if GAMESTATE:IsCourseMode() then return end

local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:draworder(150)
		self:visible(false)
	end,
	
	--- Lets the songwheel input know if it's Open/Closed so it can stop input.
	ToggleTagsMenuMessageCommand=function(self)
		if self:GetVisible() then
			self:stoptweening()
			self:sleep(0.1):visible(false):queuecommand("UpdateVisibility")
		else
			self:stoptweening()
			self:sleep(0.1):visible(true):queuecommand("UpdateVisibility")
		end
	end,
	
	UpdateVisibilityCommand=function(self)
		if IsTagsMenuVisible == true then
			IsTagsMenuVisible = false
		elseif IsTagsMenuVisible == false then
			IsTagsMenuVisible = true
		end
	end,
	
	-- The main tag menu + text
	LoadActor("./TagMenu.lua", {GroupWheel,SongWheel,Input}),
	-- Input to control the menu, oh no.
	LoadActor("./MenuInput.lua", player),

}

return t