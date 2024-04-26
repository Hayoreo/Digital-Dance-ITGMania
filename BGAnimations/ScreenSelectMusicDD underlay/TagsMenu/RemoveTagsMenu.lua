local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local Input = args[3]
local t = args[4]
local quadwidth = args[5]
local quadheight = args[6]
local quadborder = args[7]
local TagXPosition = SCREEN_CENTER_X - quadwidth/2 + 45
local TagYPosition = SCREEN_CENTER_Y - quadheight/2 + 34
local Player_Tags

--- I still do not understand why i have to throw in a random actor frame before everything else will work????
t[#t+1] = Def.Quad{}

-- player tags
for i=1, 24 do
		t[#t+1] = Def.BitmapText{
			Font="Miso/_miso",
			Name="RemovePlayerTags"..i,
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
				if RemoveTagSubMenu then
					local PlayerNumber = params[1]
					local Object = params[2]
					Player_Tags = GetCurrentObjectTags(Object, PlayerNumber)
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
					
					if i > 3 and i < 7 then
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
					elseif i == 22 or i == 23 or i ==24 then
						self:y(TagYPosition + 140)
					end
				end
			end,
			UpdateRemoveTagsTextMessageCommand=function(self, params)
				if not params then return end
				local PlayerNumber = params[1]
				local AvailableTags = params[2]
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
				
				if i + Difference > #AvailableTags then
					self:settext("")
				else
					self:settext(AvailableTags[i + Difference])	
				end
				if i == 2 or i == 5 or i == 8 or i == 11 or i == 14 or i == 17 or i == 20 or i == 23 then
					self:x(TagXPosition + 100)
				elseif i == 3 or i == 6 or i == 9 or i == 12 or i == 15 or i == 18 or i == 21 or i == 24 then
					self:x(TagXPosition + 200)
				end
				
				if i > 3 and i < 7 then
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
				elseif i == 22 or i == 23 or i ==24 then
					self:y(TagYPosition + 140)
				end
				
			end,
			ToggleAddTagsMenuMessageCommand=function(self)
				self:visible(false)
			end,
			ToggleRemoveTagsMenuMessageCommand=function(self)
				if RemoveTagSubMenu then
					self:visible(true)
				else
					self:visible(false)
				end
			end,
			ToggleManageTagsMenuMessageCommand=function(self)
				self:visible(false)
			end,
			ToggleCurrentTagMenuMessageCommand=function(self)
				self:visible(false)
			end,
			UpdateRemovedTagsMessageCommand=function(self, params)
				if RemoveTagSubMenu then
					local PlayerNumber = params[1]
					local Object = params[2]
					if Object:find("/%*") then
						Object = NameOfGroup
					else
						Object = GAMESTATE:GetCurrentSong()
					end
					Player_Tags = GetCurrentObjectTags(Object, PlayerNumber)
					if #Player_Tags == 0 then
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						MESSAGEMAN:Broadcast("InitializeTagsMenu")
						MESSAGEMAN:Broadcast("ToggleRemoveTagsMenu")
					end
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
				end
			end,
		}
end


return t