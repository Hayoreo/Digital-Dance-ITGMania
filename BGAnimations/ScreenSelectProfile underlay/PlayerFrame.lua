local args = ...
local player = args.Player
local profile_data = args.ProfileData
local avatars = args.Avatars
local scroller = args.Scroller
local scroller_item_mt = LoadActor("./ScrollerItemMT.lua")

local LightenColor = function(c)
	return { c[1]*1.25, c[2]*1.25, c[3]*1.25, c[4] }
end

-- -----------------------------------------------------------------------
-- TODO: start over from scratch so that these numbers make sense in SL
--       as-is, they are half-leftover from editing _fallback's code

local frame = {
	w = 200,
	h = 214,
	border = 2
}

local row_height = 35
scroller.x = -47
scroller.y = row_height * -5

local info = {
	y = frame.h * -0.5,
	w = frame.w *  0.475,
	padding = 4
}

local avatar_dim = info.w - (info.padding * 2.25)

-- account for the possibility that there are no local profiles and
-- we want "[ Guest ]" to start in the middle, with focus
if PROFILEMAN:GetNumLocalProfiles() <= 0 then
	scroller.y = row_height * -4
end
-- -----------------------------------------------------------------------

local FrameBackground = function(c, player, w)
	w = w or frame.w
	scroller.w = w - info.w

	return Def.ActorFrame {
		OnCommand=function(self)
			self:runcommandsonleaves(function(leaf) leaf:smooth(0.3):cropbottom(0) end)
		end,
		OffCommand=function(self)
			if not GAMESTATE:IsSideJoined(player) then
				self:runcommandsonleaves(function(leaf) leaf:accelerate(0.25):cropbottom(1) end)
			end
		end,

		-- border
		Def.Quad{
			InitCommand=function(self)
				self:cropbottom(1):zoomto(w+frame.border, frame.h+frame.border)
			end,
		},
		-- colored bg
		Def.Quad{
			InitCommand=function(self)
				self:cropbottom(1):zoomto(w, frame.h):diffuse(c):diffusetopedge(LightenColor(c))
			end,
			P1ProfileReadyMessageCommand=function(self)
				if player == "PlayerNumber_P1" then
					self:diffuse(color("#000000"))
				end
			end,
			P1ProfileUnReadyMessageCommand=function(self)
				if player == "PlayerNumber_P1" then
					self:diffuse(c):diffusetopedge(LightenColor(c))
				end
			end,
			P2ProfileReadyMessageCommand=function(self)
				if player == "PlayerNumber_P2" then
					self:diffuse(color("#000000"))
				end
			end,
			P2ProfileUnReadyMessageCommand=function(self)
				if player == "PlayerNumber_P2" then
					self:diffuse(c):diffusetopedge(LightenColor(c))
				end
			end,
		},
	}
end

-- -----------------------------------------------------------------------

return Def.ActorFrame{
	Name=ToEnumShortString(player) .. "Frame",
	InitCommand=function(self) self:xy(_screen.cx+(150*(player==PLAYER_1 and -1 or 1)), _screen.cy) end,

	OffCommand=function(self)
		if GAMESTATE:IsSideJoined(player) then
			self:bouncebegin(0.35):zoom(0)
		end
	end,
	InvalidChoiceMessageCommand=function(self, params)
		if params.PlayerNumber == player then
			self:finishtweening():bounceend(0.1):addx(5):bounceend(0.1):addx(-10):bounceend(0.1):addx(5)
		end
	end,
	PlayerJoinedMessageCommand=function(self,param)
		if param.Player == player then
			self:zoom(1.15):bounceend(0.175):zoom(1)
		end
	end,


	-- dark frame prompting players to "Press START to join!"
	-- (or "Enter credits to join!" depending on CoinMode and available credits)
	Def.ActorFrame {
		Name='JoinFrame',
		FrameBackground(Color.Black, player, frame.w*0.9),

		LoadFont("Common Normal")..{
			InitCommand=function(self)
				if IsArcade() and not GAMESTATE:EnoughCreditsToJoin() then
					self:settext( THEME:GetString("ScreenSelectProfile", "EnterCreditsToJoin") )
				else
					self:settext( THEME:GetString("ScreenSelectProfile", "PressStartToJoin") )
				end

				self:diffuseshift():effectcolor1(1,1,1,1):effectcolor2(0.5,0.5,0.5,1)
				self:diffusealpha(0):maxwidth(180)
			end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
			OffCommand=function(self) self:linear(0.1):diffusealpha(0) end,
			CoinsChangedMessageCommand=function(self)
				if IsArcade() and GAMESTATE:EnoughCreditsToJoin() then
					self:settext(THEME:GetString("ScreenSelectProfile", "PressStartToJoin"))
				end
			end
		},
	},

	-- colored frame that contains the profile scroller and DataFrame
	Def.ActorFrame {
		Name='ScrollerFrame',
		InitCommand=function(self)
			-- Create the info needed for the "[Guest]" scroller item.
			-- It won't map to any real local profile (as desired!), so we'll hardcode
			-- an index of 0, and handle it later, on ScreenSelectProfile's OffCommand
			-- in default.lua if either/both players want to chose it.
			local guest_profile = { index=0, displayname=THEME:GetString("ScreenSelectProfile", "GuestProfile") }

			-- here, we are padding the scroller_data table with dummy scroller items to accommodate
			-- the peculiar scroller behavior of starting low, starting on item#2, not wrapping, etc.
			-- see also: https://youtu.be/bXZhTb0eUqA?t=116
			local scroller_data = {{}, {}, {}, guest_profile}

			-- add actual profile data into the scroller_data table
			for profile in ivalues(profile_data) do
				table.insert(scroller_data, profile)
			end

			scroller.focus_pos = 5
			scroller:set_info_set(scroller_data, 0)
		end,

		FrameBackground(PlayerColor(player), player, frame.w * 1.1),

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(scroller.w,row_height):x(scroller.x) end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
		},

		-- sick_wheel scroller containing local profiles as choices
		scroller:create_actors( "Scroller", 9, scroller_item_mt, scroller.x, scroller.y ) .. {
			P1ProfileReadyMessageCommand=function(self)
				if player == "PlayerNumber_P1" then
					self:visible(false)
				end
			end,
			P1ProfileUnReadyMessageCommand=function(self)
				if player == "PlayerNumber_P1" then
					self:visible(true)
				end
			end,
			P2ProfileReadyMessageCommand=function(self)
				if player == "PlayerNumber_P2" then
					self:visible(false)
				end
			end,
			P2ProfileUnReadyMessageCommand=function(self)
				if player == "PlayerNumber_P2" then
					self:visible(true)
				end
			end,
		},

		-- player profile data
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self)
				-- FIXME
				self:x(15.5)
			end,
			OnCommand=function(self) self:playcommand("Set", profile_data[1]) end,
			
			-- semi-transparent Quad to the right of this colored frame to present profile stats and mods
			Def.Quad {
				InitCommand=function(self)
					self:align(0,0):diffuse(0,0,0,0):zoomto(info.w,frame.h)
					self:y(info.y)
				end,
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(1) end,

				-- --------------------------------------------------------------------------------
				-- Avatar ActorFrame
				Def.ActorFrame{
					InitCommand=function(self) self:xy(info.padding*1.125,-103.5) end,
					
					P1ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:linear(0.2)
							self:addx(-62)
						end
					end,
					P1ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:linear(0.2)
							self:addx(62)
						end
					end,
					P2ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:linear(0.2)
							self:addx(-62)
						end
					end,
					P2ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:linear(0.2)
							self:addx(62)
						end
					end,

					---------------------------------------
					-- fallback avatar
					Def.ActorFrame{
						InitCommand=function(self) self:visible(false) end,
						SetCommand=function(self, params)
							if params and params.displayname and avatars[params.displayname] then
								self:visible(false)
							else
								self:visible(true)
							end
						end,
						
						Def.Quad{
							InitCommand=function(self)
								self:align(0,0):zoomto(avatar_dim,avatar_dim):diffuse(color("#283239aa"))
							end
						},
						LoadActor(THEME:GetPathG("","/Default Avatar.png"))..{
							InitCommand=function(self)
								self:align(0.15,0.09):zoom(0.895):diffusealpha(0.9):xy(13, 8)
							end
						},
						LoadFont("Common Normal")..{
							Text=THEME:GetString("ProfileAvatar","NoAvatar"),
							InitCommand=function(self)
								self:valign(0):zoom(0.815):diffusealpha(0.9):xy(self:GetWidth()*0.5 + 13, 72)
							end,
							SetCommand=function(self, params)
								if params == nil then
									self:settext(THEME:GetString("ScreenSelectProfile", "GuestProfile"))
								else
									self:settext(THEME:GetString("ProfileAvatar", "NoAvatar"))
								end
							end
						}
					},
					---------------------------------------

					Def.Sprite{
						Name="PlayerAvatar",
						InitCommand=function(self)
							self:align(0,0):scaletoclipped(avatar_dim,avatar_dim)
						end,
						SetCommand=function(self, params)
							if params and params.displayname and avatars[params.displayname] then
								self:SetTexture(avatars[params.displayname]):visible(true)
							else
								self:visible(false)
							end
						end
					},
				},
				-- --------------------------------------------------------------------------------

				-- how many songs this player has completed in gameplay
				-- failing a song will increment this count, but backing out will not

				LoadFont("Common Normal")..{
					Name="TotalSongs",
					InitCommand=function(self)
						self:align(0,0):xy(info.padding*1.25,0):zoom(0.65):vertspacing(-2)
						self:maxwidth((info.w-info.padding*2.5)/self:GetZoom())
					end,
					SetCommand=function(self, params)
						if params then
							self:visible(true):settext(params.totalsongs or "")
						else
							self:visible(false):settext("")
						end
					end,
					P1ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(false)
						end
					end,
					P1ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(true)
						end
					end,
					P2ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(false)
						end
					end,
					P2ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(true)
						end
					end,
				},

				-- NoteSkin preview
				Def.ActorProxy{
					Name="NoteSkinPreview",
					InitCommand=function(self) self:halign(0):zoom(0.25):xy(info.padding*3, 32) end,
					SetCommand=function(self, params)
						local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
						if params and params.noteskin then
							local noteskin = underlay:GetChild("NoteSkin_"..params.noteskin)
							if noteskin then
								self:visible(true):SetTarget(noteskin)
							else
								self:visible(false)
							end
						else
							self:visible(false)
						end
					end,
					P1ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(false)
						end
					end,
					P1ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(true)
						end
					end,
					P2ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(false)
						end
					end,
					P2ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(true)
						end
					end,
				},

				-- JudgmentGraphic preview
				Def.ActorProxy{
					Name="JudgmentGraphicPreview",
					InitCommand=function(self) self:halign(0):zoom(0.315):xy(info.padding*2.5 + info.w*0.5, 48) end,
					SetCommand=function(self, params)
						local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
						if params and params.judgment then
							local judgment = underlay:GetChild("JudgmentGraphic_"..StripSpriteHints(params.judgment))
							if judgment then
								self:SetTarget(judgment)
							else
								self:SetTarget(underlay:GetChild("JudgmentGraphic_None"))
							end
						else
							self:SetTarget(underlay:GetChild("JudgmentGraphic_None"))
						end
					end,
					P1ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(false)
						end
					end,
					P1ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(true)
						end
					end,
					P2ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(false)
						end
					end,
					P2ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(true)
						end
					end,
				},

				-- (some of) the modifiers saved to this player's UserPrefs.ini file
				-- if the list is long, it will line break and eventually be masked
				-- to prevent it from visually spilling out of the FrameBackground
				LoadFont("Common Normal")..{
					Name="RecentMods",
					InitCommand=function(self)
						self:align(0,0):xy(info.padding*1.25,47):zoom(0.625)
						self:_wrapwidthpixels((info.w-info.padding*2.5)/self:GetZoom())
						self:ztest(true)     -- ensure mask hides this text if it is too long
						self:vertspacing(-2) -- less vertical spacing
					end,
					SetCommand=function(self, params)
						if params then
							self:visible(true):settext(params.mods or "")
						else
							self:visible(false):settext("")
						end
					end,
					P1ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(false)
						end
					end,
					P1ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P1" then
							self:visible(true)
						end
					end,
					P2ProfileReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(false)
						end
					end,
					P2ProfileUnReadyMessageCommand=function(self)
						if player == "PlayerNumber_P2" then
							self:visible(true)
						end
					end,
				},
			},

			-- thin white line separating stats from mods
			Def.Quad {
				InitCommand=function(self)
					self:zoomto(info.w-info.padding*2.5,1):align(0,0):xy(info.padding*1.25,18):diffusealpha(0)
				end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(0.5) end,
				P1ProfileReadyMessageCommand=function(self)
					if player == "PlayerNumber_P1" then
						self:visible(false)
					end
				end,
				P1ProfileUnReadyMessageCommand=function(self)
					if player == "PlayerNumber_P1" then
						self:visible(true)
					end
				end,
				P2ProfileReadyMessageCommand=function(self)
					if player == "PlayerNumber_P2" then
						self:visible(false)
					end
				end,
				P2ProfileUnReadyMessageCommand=function(self)
					if player == "PlayerNumber_P2" then
						self:visible(true)
					end
				end,
			},
		}
	},


	LoadActor(THEME:GetPathG("", "usbicon.png"))..{
		Name="USBIcon",
		InitCommand=function(self)
			self:rotationz(90):zoom(0.8175):visible(false):diffuseshift()
				:effectperiod(1.5):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.5)
		end
	},
	-- profile name text at bottom
	LoadFont("Common Normal")..{
		Name='SelectedProfileText',
		InitCommand=function(self)
			self:settext(profile_data[1] and profile_data[1].displayname or "")
			self:y(160):zoom(1.35):shadowlength(0):cropright(1)
		end,
		OnCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end
	},
	-- ready text
	LoadFont("Common Normal")..{
		Name='ReadyText',
		InitCommand=function(self)
			self:settext(profile_data[1] and profile_data[1].displayname.."\nREADY" or "READY")
			self:y(45):zoom(1.35):shadowlength(0):cropright(1):maxwidth(195)
			self:visible(false)
		end,
		OnCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end,
		P1ProfileReadyMessageCommand=function(self)
			if player == "PlayerNumber_P1" then
				self:visible(true)
			end
		end,
		P1ProfileUnReadyMessageCommand=function(self)
			if player == "PlayerNumber_P1" then
				self:visible(false)
			end
		end,
		P2ProfileReadyMessageCommand=function(self)
			if player == "PlayerNumber_P2" then
				self:visible(true)
			end
		end,
		P2ProfileUnReadyMessageCommand=function(self)
			if player == "PlayerNumber_P2" then
				self:visible(false)
			end
		end,
	},
}