DDSortMenuCursorPosition = 1
IsSortMenuInputToggled = false

local t = Def.ActorFrame{
	Name="MenuCursor",
	InitCommand=function(self)
		self:draworder(106)
	end,

	Def.Quad{
		Name="Cursor",
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
			self:diffuse(color("#FFFFFF"))
			self:zoomx(190)
			self:zoomy(20)
			self:diffusealpha(0.5)
			self:horizalign(right)
			self:visible(true)
			self:queuecommand("FadeOut")
		end,
		
		InitializeDDSortMenuMessageCommand=function(self)
			self:stoptweening()
			self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
			self:diffuse(color("#FFFFFF"))
			self:zoomx(190)
			self:zoomy(20)
			self:diffusealpha(0.5)
			self:horizalign(right)
			self:visible(true)
			self:queuecommand("FadeOut")
			DDSortMenuCursorPosition = 1
		end,
		
		FadeInCommand=function(self)
			self:stoptweening()
			self:linear(0.7):diffusealpha(0.5)
			self:queuecommand("FadeOut")
		end,
		
		FadeOutCommand=function(self)
			self:stoptweening()
			self:linear(0.7):diffusealpha(0.2)
			self:queuecommand("FadeIn")
		end,
		
		UpdateCursorColorMessageCommand=function(self)
			if IsSortMenuInputToggled == true then
				self:stoptweening()
				self:diffusealpha(0.5)
				self:diffuse(color("#FFFFFF")):diffusealpha(0.2)
				self:queuecommand("FadeOut")
			else
				self:diffuse(color("#59ff85")):diffusealpha(0.2)
				self:queuecommand("FadeOut")
			end
		end,
		
		------------ I'm so sorry, this is garbage mama ------------
		
		ToggleSortMenuMovementMessageCommand=function(self)
			if IsSortMenuInputToggled == false then
				IsSortMenuInputToggled = true
			else
				IsSortMenuInputToggled = false
			end
		end,
		
		
		-- Wraps the cursor if it gets to the top or bottom and stops it
		-- if selected an option that needs to navigate left/right to select.
			MoveCursorLeftMessageCommand=function(self)
				if IsSortMenuInputToggled == false then
					if DDSortMenuCursorPosition == 1 then
						DDSortMenuCursorPosition = GetMaxCursorPosition()
						self:playcommand("UpdateCursor")
					else
						DDSortMenuCursorPosition = DDSortMenuCursorPosition - 1
						self:playcommand("UpdateCursor")
					end
				else end
			end,
				
			MoveCursorRightMessageCommand=function(self)
				if IsSortMenuInputToggled == false then
					if DDSortMenuCursorPosition == GetMaxCursorPosition() then
						DDSortMenuCursorPosition = 1
						self:playcommand("UpdateCursor")
					else
						DDSortMenuCursorPosition = DDSortMenuCursorPosition + 1
						self:playcommand("UpdateCursor")
					end
				else end
			end,
			MoveCursorMouseClickMessageCommand=function(self, param)
				DDSortMenuCursorPosition = param.TargetPosition
				self:playcommand("UpdateCursor")
			end,
			
		---- This is telling the cursor where to go for each movement.
		UpdateCursorCommand=function(self)
			self:stoptweening()
			self:decelerate(0.2)
			-- Main sort
			if DDSortMenuCursorPosition == 1 then
				self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
				self:zoomx(190)
			-- Sub Sort
			elseif DDSortMenuCursorPosition == 2 then
				self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 110)
				self:zoomx(190)
			-- Lower Difficulty filter
			elseif DDSortMenuCursorPosition == 3 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X + 55,SCREEN_CENTER_Y - 85)
			-- Upper Difficulty filter
			elseif DDSortMenuCursorPosition == 4 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X + 135,SCREEN_CENTER_Y - 85)
			-- Lower Bpm Filter
			elseif DDSortMenuCursorPosition == 5 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y - 60)
			-- Upper Bpm Filter
			elseif DDSortMenuCursorPosition == 6 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X + 80,SCREEN_CENTER_Y - 60)
			-- Lower Length Filter
			elseif DDSortMenuCursorPosition == 7 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 48.5,SCREEN_CENTER_Y - 35)
			-- Upper Length Filter
			elseif DDSortMenuCursorPosition == 8 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 147.5,SCREEN_CENTER_Y - 35)
				
			--- Favorites toggle/filter (add this back later)
			--[[elseif DDSortMenuCursorPosition == 9 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 122,SCREEN_CENTER_Y - 10)--]]
			
			-- Groovestats filter/toggle
			elseif DDSortMenuCursorPosition == 9 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 122,SCREEN_CENTER_Y - 10)
			-- Autogen filter/toggle
			elseif DDSortMenuCursorPosition == 10 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 122,SCREEN_CENTER_Y + 15)
				
			-------------- Bottom half of the sort menu --------------
			-- Reset sorts
			elseif DDSortMenuCursorPosition == 11 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 55)
				
			-- Switch between Song/Course select
			elseif DDSortMenuCursorPosition == 12 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 80)
				
			-- Mark/Unmark as favorite (add this back later)
			--[[elseif DDSortMenuCursorPosition == 12 then
				self:zoomx(160)
				self:xy(SCREEN_CENTER_X + 80,SCREEN_CENTER_Y + 80)--]]
				
			-- Song Search or Switch from single/double
			elseif DDSortMenuCursorPosition == 13 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 105)
			-- Switch from single/double or GS Leaderboards or test input
			elseif DDSortMenuCursorPosition == 14 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 130)
			-- test input
			elseif DDSortMenuCursorPosition == 15 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 155)
			elseif DDSortMenuCursorPosition == 16 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 180)
			end
			self:queuecommand("FadeOut")
			
		end,
	},
	
}

return t