--- Here we want to do all the file editing for tags

local style
if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
	style = "double"
else
	style = "single"
end

local function getPlayerProfileDir(PlayerNumber)
	local dir = PROFILEMAN:GetProfileDir(PlayerNumber)

	return dir..'Tags-'..style..'.txt'
end

local function PleaseSortMe(Taggles)
	table.sort(Taggles, function(a, b)
		if a.Tag ~= b.Tag then
			return a.Tag:lower() < b.Tag:lower()
		elseif a.Tag == b.Tag then
			if a.Hashtag and not b.Hashtag then
				return a.line:lower() < b.line:lower()
			end
			
			if a.Pack and b.Pack then
				return a.line:lower() < b.line:lower()
			end
			
			if a.Pack and b.Song then
				return a.Pack < b.Song
			end
			
			if a.Song and b.Song then
				local song_title_a = SONGMAN:FindSong(a.line)
				local song_title_b = SONGMAN:FindSong(b.line)
				return song_title_a:GetDisplayMainTitle():lower() < song_title_b:GetDisplayMainTitle():lower()
			end
		end
	end)
end

local function WriteToTagFile(dir, Taggles)
	file = RageFileUtil:CreateRageFile()
	file:Open(dir, 2)
	for line in ivalues(Taggles) do
		file:Write(line.line..'\n')
	end
	file:Close()
	file:destroy()
	HaveTagsChanged = true
end

local t = Def.ActorFrame{

-- Create a new tag and add it to the current song or group
CreateNewTagFromTextMessageCommand=function(self, params)
	if not params then return end
	local PlayerNumber = params[1]
	local SongOrGroup = params[2]
	local NewTag = params[3]
	local Object
	
	if SongOrGroup == "Song" then
		Object = GAMESTATE:GetCurrentSong():GetSongDir():sub(7):sub(1, -2)
	else
		Object = "/"..NameOfGroup.."/*"
	end
	
	local dir = getPlayerProfileDir(PlayerNumber)
	if dir == nil then
		SM("No profile found!")
		return 
	end
	
	local TagLines = GetFileContents(dir)
	TagLines[#TagLines+1]="#"..NewTag
	TagLines[#TagLines+1]=Object
	
	local Taggles = {}
	local AnTag
	for line in ivalues(TagLines) do
		if line:sub(1,1) == "#" then
			AnTag = line
			Taggles[#Taggles+1] = {
				Tag = AnTag,
				Hashtag = line,
				line = line,
			}
		elseif line:sub(1,1) ~= "#" then
			if line:find("/%*") then
				-- only include groups that exist
				if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Pack = "a",
						line = line,
					}
				end
			elseif not line:find("/%*") then
				-- only include songs that exist
				if SONGMAN:FindSong(line) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Song = "b",
						line = line,
					}
				end
			end
		end
		
	end
	
	PleaseSortMe(Taggles)
	
	WriteToTagFile(dir, Taggles)
	SOUND:PlayOnce( THEME:GetPathS("", "_save.ogg") )
	SM('Tag "'..NewTag..'" added to current '..SongOrGroup:lower()..' for '..PROFILEMAN:GetPlayerName(PlayerNumber)..' successfully!')
	MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber})
end,

-- Add an existing tag to a song or group
AddCurrentTagMessageCommand=function(self, params)
	if not params then return end
	local PlayerNumber = params[1]
	local CurrentTag = params[2]
	local SongOrGroup = params[3]
	local Object
	if SongOrGroup == "Song" then
		Object = GAMESTATE:GetCurrentSong():GetSongDir():sub(7):sub(1, -2)
	else
		Object = "/"..NameOfGroup.."/*"
	end
	
	local dir = getPlayerProfileDir(PlayerNumber)
	if dir == nil then
		SM("No profile found!")
		return 
	end
	
	local TagLines = GetFileContents(dir)
	local Taggles = {}
	local AnTag
	for line in ivalues(TagLines) do
		if line:sub(1,1) == "#" then
			AnTag = line
			Taggles[#Taggles+1] = {
				Tag = AnTag,
				Hashtag = line,
				line = line,
			}
			if line:sub(2) == CurrentTag then
				if SongOrGroup == "Song" then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Song = "b",
						line = Object,
					}
				elseif SongOrGroup == "Pack" then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Pack = "a",
						line = Object,
					}
				end
			end
		elseif line:sub(1,1) ~= "#" then
			if line:find("/%*") then
				-- only include groups that exist
				if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Pack = "a",
						line = line,
					}
				end
			elseif not line:find("/%*") then
				-- only include songs that exist
				if SONGMAN:FindSong(line) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Song = "b",
						line = line,
					}
				end
			end
		end
	
	end
	
	PleaseSortMe(Taggles)
	
	WriteToTagFile(dir, Taggles)
	SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
	MESSAGEMAN:Broadcast("UpdatePlayerTagsText", {PlayerNumber})
	MESSAGEMAN:Broadcast("UpdateAddedTags", {PlayerNumber})
	--SM('Tag "'..CurrentTag..'" added to current '..SongOrGroup:lower()..' for '..PROFILEMAN:GetPlayerName(PlayerNumber)..' successfully!')
end,

-- Remove an existing song or group from a tag
RemoveCurrentTagMessageCommand=function(self, params)
	if not params then return end
	local PlayerNumber = params[1]
	local CurrentTag = params[2]
	local Object = params[3]
	local SongOrGroup
	if Object ~= NameOfGroup then
		Object = GAMESTATE:GetCurrentSong():GetSongDir():sub(7):sub(1, -2)
		SongOrGroup = "song"
	else
		Object = "/"..Object.."/*"
		SongOrGroup = "group"
	end
	
	local dir = getPlayerProfileDir(PlayerNumber)
	if dir == nil then
		SM("No profile found!")
		return 
	end
	
	local TagLines = GetFileContents(dir)
	local Taggles = {}
	local AnTag
	
	for line in ivalues(TagLines) do
		if line:sub(1,1) == "#" then
			AnTag = line
			Taggles[#Taggles+1] = {
				Tag = AnTag,
				Hashtag = line,
				line = line,
			}
		elseif line:sub(1,1) ~= "#" then
			if line ~= Object then
				if line:find("/%*") then
					-- only include groups that exist
					if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Pack = "a",
							line = line,
						}
					end
				elseif not line:find("/%*") then
					-- only include songs that exist
					if SONGMAN:FindSong(line) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Song = "b",
							line = line,
						}
					end
				end
			elseif AnTag:sub(2) ~= CurrentTag then
				if line:find("/%*") then
					-- only include groups that exist
					if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Pack = "a",
							line = line,
						}
					end
				elseif not line:find("/%*") then
					-- only include songs that exist
					if SONGMAN:FindSong(line) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Song = "b",
							line = line,
						}
					end
				end
			end
		end
	end
	
	PleaseSortMe(Taggles)
	
	WriteToTagFile(dir, Taggles)
	SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
	SM('Tag "'..CurrentTag..'" removed from current '..SongOrGroup..' for '..PROFILEMAN:GetPlayerName(PlayerNumber)..' successfully!')
	MESSAGEMAN:Broadcast("UpdateRemovedTags", {PlayerNumber, Object})
end,

RenameCurrentTagMessageCommand=function(self, params)
	if not params then return end
	local PlayerNumber = params[1]
	local Tag = params[2]
	local Text = params[3]
	
	local dir = getPlayerProfileDir(PlayerNumber)
	if dir == nil then
		SM("No profile found!")
		return 
	end
	
	local TagLines = GetFileContents(dir)
	local Taggles = {}
	local AnTag
	
	for line in ivalues(TagLines) do
		if line:sub(1,1) == "#" then
			if line:sub(2) == Tag then
				AnTag = "#"..Text
				Taggles[#Taggles+1] = {
				Tag = AnTag,
				Hashtag = "#"..Text,
				line = "#"..Text,
			}
			else
				AnTag = line
				Taggles[#Taggles+1] = {
					Tag = AnTag,
					Hashtag = line,
					line = line,
				}
			end
		else
			if line:find("/%*") then
				-- only include groups that exist
				if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Pack = "a",
						line = line,
					}
				end
			elseif not line:find("/%*") then
				-- only include songs that exist
				if SONGMAN:FindSong(line) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Song = "b",
						line = line,
					}
				end
			end
		end
	end
	
	PleaseSortMe(Taggles)
	
	WriteToTagFile(dir, Taggles)
	SOUND:PlayOnce( THEME:GetPathS("", "_save.ogg") )
	MESSAGEMAN:Broadcast("UpdateRenamedTag", {Text, PlayerNumber} )
	SM('Rename of tag "'..Tag..'" to "'..Text..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)..' was successful!')
end,

RemoveCurrentObjectMessageCommand=function(self, params)
	if not params then return end
	local PlayerNumber = params[1]
	local CurrentTag = params[2]
	local CurrentLine = params[3]
	local SongOrGroup = params[4]
	
	local dir = getPlayerProfileDir(PlayerNumber)
	if dir == nil then
		SM("No profile found!")
		return 
	end
	
	local TagLines = GetFileContents(dir)
	local Taggles = {}
	local AnTag
	
	for line in ivalues(TagLines) do
		if line:sub(1,1) == "#" then
			AnTag = line
			Taggles[#Taggles+1] = {
				Tag = AnTag,
				Hashtag = line,
				line = line,
			}
		elseif line:sub(1,1) ~= "#" then
			if line ~= CurrentLine then
				if line:find("/%*") then
					-- only include groups that exist
					if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Pack = "a",
							line = line,
						}
					end
				elseif not line:find("/%*") then
					-- only include songs that exist
					if SONGMAN:FindSong(line) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Song = "b",
							line = line,
						}
					end
				end
			elseif AnTag:sub(2) ~= CurrentTag then
				if line:find("/%*") then
					-- only include groups that exist
					if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Pack = "a",
							line = line,
						}
					end
				elseif not line:find("/%*") then
					-- only include songs that exist
					if SONGMAN:FindSong(line) then
						Taggles[#Taggles+1] = {
							Tag = AnTag,
							Song = "b",
							line = line,
						}
					end
				end
			end
		end
	end
	PleaseSortMe(Taggles)
	WriteToTagFile(dir, Taggles)
	SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
	SM('Removed '..SongOrGroup:lower()..' from tag "'..CurrentTag..'" for '..PROFILEMAN:GetPlayerName(PlayerNumber)..' successfully!')
	MESSAGEMAN:Broadcast("UpdateRemovedObjects", {PlayerNumber, CurrentTag})
end,

DeleteCurrentTagMessageCommand=function(self, params)
	if not params then return end
	local PlayerNumber = params[1]
	local CurrentTag = params[2]
	local dir = getPlayerProfileDir(PlayerNumber)
	if dir == nil then
		SM("No profile found!")
		return 
	end
	local TagLines = GetFileContents(dir)
	local Taggles = {}
	local AnTag
	
	for line in ivalues(TagLines) do
		if line:sub(1,1) == "#" then
			AnTag = line
			if AnTag:sub(2) ~= CurrentTag then
				Taggles[#Taggles+1] = {
					Tag = AnTag,
					Hashtag = line,
					line = line,
				}
			end
		elseif line:sub(1,1) ~= "#" and AnTag:sub(2) ~= CurrentTag then
			if line:find("/%*") then
				-- only include groups that exist
				if SONGMAN:DoesSongGroupExist(line:sub(2):gsub("/.*", "")) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Pack = "a",
						line = line,
					}
				end
			elseif not line:find("/%*") then
				-- only include songs that exist
				if SONGMAN:FindSong(line) then
					Taggles[#Taggles+1] = {
						Tag = AnTag,
						Song = "b",
						line = line,
					}
				end
			end
		end
	
	end
	
	
	PleaseSortMe(Taggles)
	WriteToTagFile(dir, Taggles)
	SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
	local CurrentTags = GetCurrentPlayerTags(PlayerNumber)
	if #CurrentTags > 0 then
		MESSAGEMAN:Broadcast("UpdateRemovedTag", {PlayerNumber, CurrentTags})
		CurrentTagSubMenu = false
		ManageTagsSubMenu = true
		MESSAGEMAN:Broadcast("ToggleCurrentTagMenu")
		MESSAGEMAN:Broadcast("ReshowManageTagsHeader")
	else
		CurrentTagSubMenu = false
		MESSAGEMAN:Broadcast("ToggleCurrentTagMenu")
		MESSAGEMAN:Broadcast("InitializeTagsMenu")
	end
end,


}


return t