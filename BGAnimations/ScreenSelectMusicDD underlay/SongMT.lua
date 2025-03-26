local args = ...
local SongWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]
local WheelWidth = SCREEN_WIDTH/3
local DarkenAmount = 0.5
local DarkenAmount2 = 0.4
local DarkenGroup = 0.8
local DarkenGroup2 = 0.6

local P1Colors = {
0.298,
0.082,
0.478,
}
local P2Colors = {
0,
0.710,
0.686,
}

local P1GroupColors = {
0.298,
0.082,
0.478,
}
local P2GroupColors = {
0,
0.710,
0.686,
}



local NumPlayers = GAMESTATE:GetNumSidesJoined()
local mpn = GAMESTATE:GetMasterPlayerNumber()
local PlayerNum

if mpn == "PlayerNumber_P1" then
	PlayerNum = 0
elseif mpn == "PlayerNumber_P2" then
	PlayerNum = 1
end

for i=1, 3 do
	P1Colors[i] = P1Colors[i] * DarkenAmount
	P2Colors[i] = P2Colors[i] * DarkenAmount2
	P1GroupColors[i] = P1GroupColors[i] * DarkenGroup
	P2GroupColors[i] = P2GroupColors[i] * DarkenGroup2
end

local P1Color = color( tostring(P1Colors[1])..","..tostring(P1Colors[2])..","..tostring(P1Colors[3])..",1" )
local P2Color = color( tostring(P2Colors[1])..","..tostring(P2Colors[2])..","..tostring(P2Colors[3])..",1" )
local P1GroupColor = color( tostring(P1GroupColors[1])..","..tostring(P1GroupColors[2])..","..tostring(P1GroupColors[3])..",1" )
local P2GroupColor = color( tostring(P2GroupColors[1])..","..tostring(P2GroupColors[2])..","..tostring(P2GroupColors[3])..",1" )

local Subtitle
local CurrentStyle = GAMESTATE:GetCurrentStyle():GetStepsType()


local function update_edit(self)
	if self.song ~= nil and self.song ~= "CloseThisFolder" and self.song ~= "Random-Portal" then
		if self.song:GetOneSteps(CurrentStyle, 'Difficulty_Edit') ~= nil then
			self.edit:visible(true)
		else
			self.edit:visible(false)
		end
	else
		self.edit:visible(false)
	end
end

local function update_grade(self)
	--change the Grade sprite
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		if self.song ~= "CloseThisFolder" and self.song ~= "Random-Portal" then
			local current_difficulty
			local grade
			local steps
			if GAMESTATE:GetCurrentSteps(pn) then
				current_difficulty = GAMESTATE:GetCurrentSteps(pn):GetDifficulty() --are we looking at steps?
			end
			if current_difficulty and self.song:GetOneSteps(GAMESTATE:GetCurrentSteps(pn):GetStepsType(),current_difficulty) then
				steps = self.song:GetOneSteps(GAMESTATE:GetCurrentSteps(pn):GetStepsType(),current_difficulty)
			end
			if steps then
				grade = GetTopGrade(player, self.song, steps)
			end
			--if we have a grade then set the grade sprite
			if grade then
				self[pn..'grade_sprite']:visible(true):setstate(grade)
			else
				self[pn..'grade_sprite']:visible(false)
			end
		else
			self[pn..'grade_sprite']:visible(false)
		end
	end
end

local function update_exscore(self)
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		self[pn..'ex_score']:visible(false):settext("")
		-- Only display EX score if a profile is found for an enabled player.
		if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
			self[pn..'ex_score']:visible(false)
			return
		end
		
		if self.song ~= "CloseThisFolder" and self.song ~= "Random-Portal" and self.song ~= nil then
			local song = self.song
			local song_dir = song:GetSongDir()
			if song_dir ~= nil then
				if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
					local hash = SL[pn].ITLData["pathMap"][song_dir]
					if SL[pn].ITLData["hashMap"][hash] ~= nil then
						local ex = SL[pn].ITLData["hashMap"][hash]["ex"] / 100
						if ex then
							self[pn..'ex_score']:settext(("%.2f"):format(ex)):visible(true)
							self.title_bmt:maxwidth(255)
							self.subtitle_bmt:maxwidth(255)
						else
							self[pn..'ex_score']:visible(false):settext("")
						end
					end
				end
			else
				self[pn..'ex_score']:visible(false):settext("")
			end
		else
			self[pn..'ex_score']:visible(false):settext("")
		end
	end

end

local function update_itl_rank(self)
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		-- Only display EX score if a profile is found for an enabled player.
		if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
			self[pn..'ITLRank']:visible(false)
			return
		end

		if self.song ~= "CloseThisFolder" and self.song ~= "Random-Portal" and self.song ~= nil and GAMESTATE:GetNumSidesJoined() == 1 then
			local song = self.song
			local song_dir = song:GetSongDir()
			if song_dir ~= nil and #song_dir ~= 0 then
				if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
					local hash = SL[pn].ITLData["pathMap"][song_dir]
					if SL[pn].ITLData["hashMap"][hash] ~= nil then
						if SL[pn].ITLData["hashMap"][hash]["rank"] ~= nil then
							if SL[pn].ITLData["hashMap"][hash]["rank"] ~= nil then
								local rank = SL[pn].ITLData["hashMap"][hash]["rank"]
								self[pn..'ITLRank']:settext(tostring(rank))
								local style = GAMESTATE:GetCurrentStyle():GetName()
								if 		rank <=	(style == "single" and 10 or 5) 	then self[pn..'ITLRank']:diffuse(SL.JudgmentColors["FA+"][1])
								elseif	rank <= (style == "single" and 25 or 20)	then self[pn..'ITLRank']:diffuse(SL.JudgmentColors["FA+"][2])
								elseif	rank <= (style == "single" and 50 or 40) 	then self[pn..'ITLRank']:diffuse(SL.JudgmentColors["FA+"][3])
								elseif	rank <= (style == "single" and 75 or 50) 	then self[pn..'ITLRank']:diffuse(SL.JudgmentColors["FA+"][4])
								elseif	rank <= (style == "single" and 85 or 55)	then self[pn..'ITLRank']:diffuse(SL.JudgmentColors["FA+"][5])
								else self[pn..'ITLRank']:diffuse(Color.Red)
								end
							end
						end
						self[pn..'ITLRank']:visible(true)
						return
					end
				end
			end
		end
		self[pn..'ITLRank']:visible(false)
	end

end

local function update_itl_points(self)
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		-- Only display EX score if a profile is found for an enabled player.
		if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
			self[pn..'ITLPoints']:visible(false)
			return
		end
		
		if self.song ~= "CloseThisFolder" and self.song ~= "Random-Portal" and self.song ~= nil and GAMESTATE:GetNumSidesJoined() == 1 then
			local song = self.song
			local song_dir = song:GetSongDir()
			if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
				local hash = SL[pn].ITLData["pathMap"][song_dir]
				if SL[pn].ITLData["hashMap"][hash] ~= nil then
					self[pn..'ITLPoints']:settext(SL[pn].ITLData["hashMap"][hash]["points"])
					self[pn..'ITLPoints']:visible(true)
					return
				end
			end
		end
		self[pn..'ITLPoints']:visible(false)
	end
end

local song_mt = {
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
					subself:diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:finishtweening():sleep(0.25):linear(0.25):diffusealpha(1):queuecommand("PlayMusicPreview")
				end,

				StartCommand=function(subself)
					-- slide the chosen Actor into place
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSingleSong")

					-- hide everything else
					else
						subself:visible(false)
					end
				end,
				HideCommand=function(subself)
					subself:visible(false):diffusealpha(0)
				end,
				UnhideCommand=function(subself)

					-- we're going back to song selection
					-- slide the chosen song ActorFrame back into grid position
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					end
					subself:visible(true):sleep(0.3):linear(0.2):diffusealpha(1)
				end,
				SlideToTopCommand=function(subself) subself:linear(0.2)end,
				SlideBackIntoGridCommand=function(subself) subself:linear(0.2) end,

				CurrentStepsChangedMessageCommand=function(subself, params)
					update_grade(self)
					update_exscore(self)
					if NumPlayers == 1 then
						update_itl_rank(self)
						update_itl_points(self)
					end
				end,
				
				SongIsReloadingMessageCommand=function(subself)
					self:set(self.song)
				end,

				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},
				-- black background quad
					Def.Quad{
						Name="SongWheelBackground",
						InitCommand=function(subself) 
						self.QuadColor = subself
						subself:zoomto(WheelWidth,24):diffuse(color("#0a141b")):cropbottom(1):playcommand("Set")
						end,
						SetCommand=function(subself)
							subself:x(0)
							subself:y(_screen.cy-215)
							subself:finishtweening()
							subself:accelerate(0.2):cropbottom(0)
						end,
					},
				-- title
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.title_bmt = subself
						subself:zoom(0.75):diffuse(Color.White):shadowlength(0.75):y(25)
					end,
				},
				-- subtitle
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.subtitle_bmt = subself
						subself:zoom(0.5):diffuse(Color.White):shadowlength(0.75)
						subself:y(32)
					end,
				},
				-- Load an edit icon if the song has an edit chart(s).
				Def.Sprite{
				Texture=THEME:GetPathG("", "usbicon.png"),
				InitCommand=function(subself) 
					subself:visible(false):zoom(0.1):xy(IsUsingWideScreen() and SCREEN_WIDTH/6.8 or SCREEN_WIDTH/4.8, 25):animate(0) self.edit = subself 
				end,
				},

			}
			
			--Things we need two of
			for pn in ivalues({'P1','P2'}) do
				local side
				if pn == 'PLAYER_1' then side = -1
				else side = 1 end
				local grade_position
				local ExScore_position
				local rank_position
				local point_position = 30
				if pn == 'P1' then
					grade_position = -130
					rank_position = -112
					ExScore_position = 17
				else
					grade_position = -112
					rank_position = -132
					ExScore_position = 28
				end
				-- Player grades
				af[#af+1] = Def.ActorFrame {
					-- The grade shown to the left of the song name
					Def.Sprite{
						Texture=THEME:GetPathG("","_grades/assets/grades 1x19.png"),
						InitCommand=function(subself) 
							subself:visible(false)
							:zoom(WideScale(.25,.18))
							:xy(side*grade_position, 25)
							:animate(0) 
							self[pn..'grade_sprite'] = subself 
						end,
					}
				}
				-- player EX Score for ITL
				af[#af+1] = Def.BitmapText{
					Font="Wendy/_wendy monospace numbers",
					Text="",
					InitCommand=function(subself)
						subself:visible(false)
						:zoom(0.15)
						:horizalign(right)
						:x( _screen.w/6 )
						:diffuse(SL.JudgmentColors["FA+"][1])
						if NumPlayers == 2 then
							subself:y(ExScore_position):zoom(0.14)
						else
							subself:y(18)
						end
						self[pn..'ex_score'] = subself 
					end,
				}
				
				if NumPlayers == 1 then
					--- Player ExScore Rank
					af[#af+1] = Def.BitmapText{
						Font="Common Normal",
						Text="",
						InitCommand=function(subself)
							self[pn..'ITLRank'] = subself
							subself:visible(true)			
								   :zoom(0.75)
								   :xy(rank_position, 25)
						end,	
					}
					--- Player ITL Points
					af[#af+1] = Def.BitmapText{
						Font="Common Normal",
						Text="",
						InitCommand=function(subself)
							self[pn..'ITLPoints'] = subself
							subself:visible(true)			
								   :zoom(0.5)
								   :horizalign(center)
								   :xy( _screen.w/6.75 , point_position)
						end,	
					}
				
				end
				
			end

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			local offset = IsUsingWideScreen() and WideScale( (item_index - math.floor(num_items/10)) - 3.4 , item_index - math.floor(num_items/3) - 0.4 ) or item_index - math.floor(num_items/2) + 3
			local ry = offset > 0 and 25 or (offset < 0 and -25 or 0)
			self.container:finishtweening()
			self.container:finishtweening()

			if item_index ~= 1 and item_index ~= num_items then
				self.container:decelerate(0.1)
			end

			if has_focus then
				if self.song ~= "CloseThisFolder" and self.song ~= "Random-Portal" then
					GAMESTATE:SetCurrentSong(self.song)
					MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song})
					if GAMESTATE:GetCurrentSong() ~= nil then
						LastSeenSong = GAMESTATE:GetCurrentSong():GetSongDir()
					end
					-- wait for the musicgrid to settle for at least 0.2 seconds before attempting to play preview music
					self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
					self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
					self.container:x(_screen.cx)
				elseif self.song == "CloseThisFolder" then
					GAMESTATE:SetCurrentSong(nil)
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				elseif self.song == "Random-Portal" then
					-- Only call a random song from within the same group
					local groupsongs = pruned_songs_by_group[NameOfGroup]
					local RandomGroupSong = groupsongs[math.random(#groupsongs)]
					GAMESTATE:SetCurrentSong(RandomGroupSong)
					MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song})
					self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
					if GAMESTATE:GetCurrentSong() ~= nil then
						LastSeenSong = GAMESTATE:GetCurrentSong():GetSongDir()
					end
					self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
					self.container:x(_screen.cx)
				end
				self.container:playcommand("GainFocus")
				self.container:x(_screen.cx)
				self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
			else
				self.container:playcommand("LoseFocus")
				self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
				self.container:x(_screen.cx)
			end
		end,
		
		set = function(self, song)

			if not song then return end

			self.img_path = ""
			self.img_type = ""
			
			-- this SongMT was passed the string "CloseThisFolder" or "Random-Portal"
			-- so this is a special case for song metatable items
			if type(song) == "string" then
				if song == "CloseThisFolder" then
					self.song = song
					self.title_bmt:settext(NameOfGroup):maxwidth(280):diffuse(color("#4ffff3")):shadowlength(1.1):horizalign(center):valign(0.5):x(0)
					self.QuadColor:diffuse(color("#363d42"))
					self.subtitle_bmt:settext("")
					if NumPlayers == 1 then
						if IsCurrentGroupTagged(NameOfGroup, PlayerNum) then
							if PlayerNum == 0 then
								self.QuadColor:diffuse(P1GroupColor)
							elseif PlayerNum == 1 then
								self.QuadColor:diffuse(P2GroupColor)
							end
						end
					elseif NumPlayers == 2 then
						if IsCurrentGroupTagged(NameOfGroup, 0) then
							self.QuadColor:diffuse(P1GroupColor)
						elseif IsCurrentGroupTagged(NameOfGroup, 1) then
							self.QuadColor:diffuse(P2GroupColor)
						end
					end
				else
					self.song = song
					self.title_bmt:settext("RANDOM"):diffuse(color("#f70000")):shadowlength(1.1):horizalign(center):valign(0.5):x(0)
					self.QuadColor:diffuse(color("#000000"))
					self.subtitle_bmt:settext("")
				end
			else
				-- we are passed in a Song object as info
				self.song = song
				if GAMESTATE:GetCurrentSong() ~= nil then
					LastSeenSong = GAMESTATE:GetCurrentSong():GetSongDir()
				end
				Subtitle = self.song:GetDisplaySubTitle()
				self.title_bmt:settext( self.song:GetDisplayMainTitle() ):maxwidth(280):diffuse(Color.White):horizalign(left):x(-100)
				self.subtitle_bmt:settext( self.song:GetDisplaySubTitle() ):maxwidth(280):horizalign(left):x(-100)
				self.QuadColor:diffuse(color("#0a141b"))
				if Subtitle ~= "" then
					self.title_bmt:valign(row.h/170)
				else
					self.title_bmt:valign(0.5)
				end
				if GetMainSortPreference() ~= 8 then
					if NumPlayers == 1 then
						if IsCurrentSongTagged(song, PlayerNum) or (IsCurrentGroupTagged(song:GetGroupName(), PlayerNum) and GetMainSortPreference() ~= 1) then
							if PlayerNum == 0 then
								self.QuadColor:diffuse(P1Color)
							elseif PlayerNum == 1 then
								self.QuadColor:diffuse(P2Color)
							end
						end
					elseif NumPlayers == 2 then
						if IsCurrentSongTagged(song, 0) or (IsCurrentGroupTagged(song:GetGroupName(), PlayerNum) and GetMainSortPreference() ~= 1) then
							self.QuadColor:diffuse(P1Color)
						elseif IsCurrentSongTagged(song, 1) then
							self.QuadColor:diffuse(P2Color)
						end
					end
				end
			end

			update_grade(self)
			update_exscore(self)
			update_edit(self)
			if NumPlayers == 1 then
				update_itl_rank(self)
				update_itl_points(self)
			end
			
		end,
	}
}

return song_mt