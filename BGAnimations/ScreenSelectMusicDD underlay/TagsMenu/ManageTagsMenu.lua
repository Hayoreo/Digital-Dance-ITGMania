local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]
local t = args[4]
local quadwidth = args[5]
local quadheight = args[6]
local quadborder = args[7]
local TagXPosition = SCREEN_CENTER_X - quadwidth/2 + 50
local TagYPosition = SCREEN_CENTER_Y - quadheight/2 + 34
local TagSongs
local TagPacks


--- I still do not understand why i have to throw in a random actor frame before everything else will work????
t[#t+1] = Def.Quad{}

-- player tags
for i=1, 24 do
		t[#t+1] = Def.BitmapText{
			Font="Miso/_miso",
			Name="ManagePlayerTags"..i,
			InitCommand=function(self)
				self:visible(false)
				self:diffuse(color("#FFFFFF"))
				self:horizalign(center)
				self:vertalign(top)
				self:x(TagXPosition)
				self:y(TagYPosition)
				self:zoom(0.75)
				self:draworder(150)
				self:settext("")
				self:maxwidth((quadwidth-quadborder)/2.75)
			end,
			UpdatePlayerTagsTextMessageCommand=function(self, params)
				if ManageTagsSubMenu then
					local PlayerNumber = params[1]
					local Player_Tags = GetCurrentPlayerTags(PlayerNumber)
					if i > #Player_Tags then
						self:settext("")
					else
						self:settext(Player_Tags[i])	
					end
					if i == 2 or i == 5 or i == 8 or i == 11 or i == 14 or i == 17 or i == 20 or i == 23 then
						self:x(TagXPosition + 100)
					elseif i == 3 or i == 6 or i == 9 or i == 12 or i == 15 or i == 18 or i == 21 or i == 24 then
						self:x(TagXPosition + 200)
					end
					
					if i == 4 or i == 5 or i == 6 then
						self:y(TagYPosition + 20)
					elseif  i == 7 or i == 8 or i == 9 then
						self:y(TagYPosition + 40)
					elseif  i == 10 or i == 11 or i == 12 then
						self:y(TagYPosition + 60)
					elseif i == 13 or i == 14 or i == 15 then
						self:y(TagYPosition + 80)
					elseif i == 16 or i == 17 or i == 18 then
						self:y(TagYPosition + 100)
					elseif i == 19 or i == 20 or i == 21 then
						self:y(TagYPosition + 120)
					elseif i == 22 or i == 23 or i == 24 then
						self:y(TagYPosition + 140)
					end
				end
			end,
			ToggleAddTagsMenuMessageCommand=function(self)
				self:visible(false)
			end,
			ToggleRemoveTagsMenuMessageCommand=function(self)
				self:visible(false)
			end,
			ToggleManageTagsMenuMessageCommand=function(self)
				if ManageTagsSubMenu then
					self:visible(true)
				else
					self:visible(false)
				end
			end,
			ReshowManageTagsHeaderMessageCommand=function(self)
				self:visible(true)
			end,
			ToggleCurrentTagMenuMessageCommand=function(self)
				if CurrentTagSubMenu then
					self:visible(false)
				end
			end,
			UpdateRenamedTagMessageCommand=function(self, params)
				if not params then return end
				local PlayerNumber = params[2]
				local Player_Tags = GetCurrentPlayerTags(PlayerNumber)
				if i > #Player_Tags then
					self:settext("")
				else
					self:settext(Player_Tags[i])	
				end
				if i == 2 or i == 5 or i == 8 or i == 11 or i == 14 then
					self:x(TagXPosition + 100)
				elseif i == 3 or i == 6 or i == 9 or i == 12 or i == 15 then
					self:x(TagXPosition + 200)
				end
				
				if i == 4 or i == 5 or i == 6 then
					self:y(TagYPosition + 20)
				elseif  i == 7 or i == 8 or i == 9 then
					self:y(TagYPosition + 40)
				elseif  i == 10 or i == 11 or i == 12 then
					self:y(TagYPosition + 60)
				elseif i == 13 or i == 14 or i == 15 then
					self:y(TagYPosition + 80)
				end
			end,
			UpdateRemovedTagMessageCommand=function(self, params)
				if not params then return end
				local PlayerNumber = params[1]
				local Player_Tags = params[2]
				
				if i > #Player_Tags then
					self:settext("")
				else
					self:settext(Player_Tags[i])	
				end
				if i == 2 or i == 5 or i == 8 or i == 11 or i == 14 then
					self:x(TagXPosition + 100)
				elseif i == 3 or i == 6 or i == 9 or i == 12 or i == 15 then
					self:x(TagXPosition + 200)
				end
				
				if i == 4 or i == 5 or i == 6 then
					self:y(TagYPosition + 20)
				elseif  i == 7 or i == 8 or i == 9 then
					self:y(TagYPosition + 40)
				elseif  i == 10 or i == 11 or i == 12 then
					self:y(TagYPosition + 60)
				elseif i == 13 or i == 14 or i == 15 then
					self:y(TagYPosition + 80)
				end
			end,
			UpdateManageTagsTextMessageCommand=function(self, params)
				if not params then return end
				local PlayerNumber = params[1]
				local Player_Tags = params[2]
				local Index = params [3]
				local FakeIndex = params[4]
				local Wrap = params[5]
				local Direction = params[6]
				
				local Difference = 0
				if FakeIndex ~= nil then
					Difference = Index - FakeIndex
				else
					Difference = -24
				end
				
				if Wrap == "Top" then 
					Difference = 0
				end
				
				if Direction == "Down" then
					if Difference < 3 then
						if Difference < 0 then
							Difference = 0
						else
							Difference = 3
						end
					end
				end
				
				if i + Difference > #Player_Tags then
					self:settext("")
				else
					self:settext(Player_Tags[i + Difference])	
				end
				
				
			end,
		}
end

return t