local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local TransitionTime = args[3]
local steps_type = args[4]
local row = args[5]
local col = args[6]
local Input = args[7]
local PruneSongsFromGroup = args[8]
local starting_group = args[9]
local group_info = args[10]
local WheelWidth = SCREEN_WIDTH/3

local max_chars = 64

local switch_to_songs = function(group_name,event)
	local songs, index = PruneSongsFromGroup(group_name)
	songs[#songs+1] = "Random-Portal"
	songs[#songs+1] = "CloseThisFolder"
	SongWheel:set_info_set(songs, index)
	
end

local switch_to_songs_from_group = function(group_name,event)
	local songs, index = PruneSongsFromGroup(group_name)
	songs[#songs+1] = "Random-Portal"
	songs[#songs+1] = "CloseThisFolder"
	index = 0
	SongWheel:set_info_set(songs,index)	
end

local item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index

			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself

					subself:xy(_screen.cx, _screen.cy)

					if GAMESTATE:GetCurrentSong() then

						if self.index ~= GroupWheel:get_actor_item_at_focus_pos().index then
							subself:playcommand("LoseFocus"):diffusealpha(0)
						else
							-- position this folder in the header
							subself:zoom(0)

							switch_to_songs(starting_group)
							MESSAGEMAN:Broadcast("SwitchFocusToSongs")
							MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=starting_group})
						end
					end
				end,
				
				CloseCurrentFolderMessageCommand=function(subself)
					switch_to_songs_from_group(self.groupName)
				end,
				
				ReloadDDMusicWheelMessageCommand=function(subself)
					subself:queuecommand("set")
				end,
				
				OnCommand=function(subself) subself:finishtweening() end,

				StartCommand=function(subself)
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						-- slide the chosen Actor into place
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					else
						-- hide everything else
						subself:linear(0.2):diffusealpha(0)
					end
				end,
				
				UnhideCommand=function(subself)
					-- we're going back to group selection
					-- slide the chosen group Actor back into grid position
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToGroups")
						self.container:addy(45)
					else
						subself:sleep(0.25):linear(0.2):diffusealpha(1)
					end
				end,
				GainFocusCommand=function(subself) subself:decelerate(0):zoom(1) end,
				LoseFocusCommand=function(subself) subself:decelerate(0):zoom(1) end,
				SlideToTopCommand=function(subself)
					subself:linear(0.12):zoom(0)
					       :linear(0.2 ):queuecommand("Switch")
				end,
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.2 ):x( _screen.cx )
					       :linear( 0.12 ):zoom(1):y( _screen.cy )
				end,
				---CloseCurrentFolderMessageCommand=function(subself) subself:sleep(0.5) switch_to_songs_from_group(self.groupName) end,--]]
				SwitchCommand=function(subself) switch_to_songs_from_group(self.groupName) end,
				
				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},

				-- Wheel Item quad for the group folder.
				Def.Quad{
					Name="GroupWheelQuad",
					InitCommand=function(subself)
						self.QuadColor = subself
						subself:y(_screen.cy - 240)
						subself:x(0)
						subself:zoomx(WheelWidth)
						subself:zoomy(24)
					end,
				},
				-- unique songs
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.Numberbmt = subself
						subself:zoom(0.75):diffuse(Color.White):xy(IsUsingWideScreen() and 135 or 310,IsUsingWideScreen() and 0 or -113):maxwidth(300):horizalign(right)
					end,
				},
				-- group title bmt
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.bmt = subself
						subself:maxwidth(290):vertspacing(-4):shadowlength(1.1):zoom(0.75)
					end,
					OnCommand=function(subself)
						if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
							subself:horizalign(left):playcommand("Untruncate")
						end
					end,
					UntruncateCommand=function(subself) subself:settext(self.groupName) end,
					TruncateCommand=function(subself) subself:settext(self.groupName):Truncate(max_chars) end,

					GainFocusCommand=function(subself) BannerOfGroup = self.groupName  subself:horizalign(center):linear(0.15) MESSAGEMAN:Broadcast("GroupsHaveChanged") end,
					LoseFocusCommand=function(subself) subself:horizalign(center):linear(0.15) end,
					
					
					SlideToTopCommand=function(subself) subself:queuecommand("SlideToTop2") end,
					SlideToTop2Command=function(subself) subself:horizalign(left):linear(0.2):playcommand("Untruncate") end,
					SlideBackIntoGridCommand=function(subself) subself:horizalign(center):linear(0.2):playcommand("Truncate") end,
				},
				
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			local offset = item_index - math.floor(num_items/2)
			local ry = offset > 0 and 25 or (offset < 0 and -25 or 0)
			self.container:finishtweening()


			-- if we are initializing the screen, the focus starts (should start) on the SongWheel
			-- so we want to position all the folders "behind the scenes", and then call Init
			-- on the group folder with focus so that it is positioned correctly at the top
			if Input.WheelWithFocus ~= GroupWheel then
				self.container:y( IsUsingWideScreen() and WideScale( ((offset * col.w)/6.8 + _screen.cy) + 45 , ((offset * col.w)/8.4 + _screen.cy) + 45 )  or ((offset * col.w)/6.4 + _screen.cy) + 45 )
				if has_focus then 
				self.container:playcommand("Init") end

			-- otherwise, we are performing a normal transform
			else
				if has_focus and self.groupName == "RANDOM-PORTAL" then
					local SongsAvailable = {}
					for groupName, group in pairs (pruned_songs_by_group) do
						for song in ivalues (group) do
							SongsAvailable[#SongsAvailable+1] = song
						end
					end
					local RandomSong = SongsAvailable[math.random(#SongsAvailable)]
					GAMESTATE:SetCurrentSong(RandomSong)
					if GAMESTATE:GetCurrentSong() ~= nil then
						LastSeenSong = GAMESTATE:GetCurrentSong():GetSongDir()
					end
					self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
					self.container:playcommand("GainFocus")
					MESSAGEMAN:Broadcast("CurrentSongChanged")
					MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=self.groupName})
					NameOfGroup = self.groupName
				elseif has_focus and self.groupName ~= "RANDOM-PORTAL" then
					GAMESTATE:SetCurrentSong(nil)
					SOUND:StopMusic()
					self.container:playcommand("GainFocus")
					MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=self.groupName})
					NameOfGroup = self.groupName
					MESSAGEMAN:Broadcast("GroupsHaveFocus")
				else
					self.container:playcommand("LoseFocus")
				end
				
				if item_index ~= 1 and item_index ~= num_items then
					self.container:decelerate(0.1)
				end
				self.container:y( IsUsingWideScreen() and WideScale( ((offset * col.w)/6.8 + _screen.cy) + 45 , ((offset * col.w)/8.4 + _screen.cy) + 45 )  or ((offset * col.w)/6.4 + _screen.cy) + 45 )
			end
		end,

		set = function(self, groupName)
		
			if groupName == "RANDOM-PORTAL" then
				self.groupName = groupName
				self.bmt:settext("RANDOM"):diffuse(color("#f70000"))
				self.QuadColor:diffuse(color("#000000"))
				self.Numberbmt:settext("")
			else
				self.groupName = groupName
				self.QuadColor:diffuse(color("#363d42"))
				self.bmt:diffuse(color("#4ffff3"))
				-- handle text
				self.bmt:settext(self.groupName):Truncate(max_chars)
				self.Numberbmt:settext(group_info[groupName].num_songs)
			end
		end
	}
}

return item_mt