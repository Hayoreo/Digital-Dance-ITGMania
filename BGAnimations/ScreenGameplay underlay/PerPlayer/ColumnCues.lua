-- don't run this in course mode (for now) or outside of 4-panel
if GAMESTATE:IsCourseMode() or GAMESTATE:GetCurrentGame():GetName() ~= "dance" then return end

local player = ...
local BreakTime

--- A list of potential mods the player will have active.
local mods = SL[ToEnumShortString(player)].ActiveModifiers
local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Preferred')

local Left = po:Left()
local Right = po:Right()
local mirror = po:Mirror()
local shuffle = po:Shuffle() or po:SuperShuffle() or po:SoftShuffle()
local flip = po:Flip() > 0
local invert = po:Invert() > 0
local insert = po:Wide() or po:Big() or po:Quick() or po:BMRize() or po:Skippy() or po:Echo() or po:Stomp()
local mini = po:Mini()

-- this isn't even a selectable mod on this theme, but sure.
local backwards = po:Backwards()
local NoMines = po:NoMines()
local notes_removed = (po:Little()  or po:NoHolds() or po:NoStretch() or
                       po:NoHands() or po:NoJumps() or po:NoFakes() or 
                       po:NoLifts() or po:NoQuads() or po:NoRolls())

local CueMines = mods.CueMines and not NoMines
local IgnoreHoldsRolls = mods.IgnoreHoldsRolls
local IgnoreNotes = mods.IgnoreNotes
local CountdownBreaks = mods.CountdownBreaks

-- Don't run this if mines AND notes are not being cued lol
if IgnoreNotes and not CueMines then return end

-- Don't run this if on shuffle, blender, backwards or inserting/removing notes
if shuffle or backwards or insert or notes_removed then return end

-- Don't run this if flip AND invert are on because it breaks the column spacing.
if flip and invert then return end

local noteMapping = {1, 2, 3, 4}

if flip then
	noteMapping = {noteMapping[4], noteMapping[3], noteMapping[2], noteMapping[1]}
end

if invert then
	noteMapping = {noteMapping[2], noteMapping[1], noteMapping[4], noteMapping[3]}
end

if Left then
	noteMapping = {noteMapping[2], noteMapping[4], noteMapping[1], noteMapping[3]}
end
if Right then
	noteMapping = {noteMapping[3], noteMapping[1], noteMapping[4], noteMapping[2]}
end
if mirror then
	noteMapping = {noteMapping[4], noteMapping[3], noteMapping[2], noteMapping[1]}
end

local cue_time = nil
if mods.ColumnCues ~= nil then
	cue_time = tonumber(mods.ColumnCues:sub(1, #mods.ColumnCues-1))
end

if cue_time == nil then
	return Def.ActorFrame {}
end

local pn = ToEnumShortString(player)
local steps = GAMESTATE:GetCurrentSteps(player)

local noteTimes = GetChartNoteTimes(steps, pn)
-- Find gaps of at least cue_time

if noteTimes == nil then
	return Def.ActorFrame {}
end

local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local columnTimes = {}
for i=1,NumColumns do
	columnTimes[i] = {}
end

if NumColumns == 8 then
	for i=1,4 do
		noteMapping[4+i] = noteMapping[i] + 4
	end
	
	-- Flip and mirror cancel each other out so only move the column cues around if it's one or the other.
	if flip and mirror then
	
	elseif flip or mirror then
		for i=1,4 do
			noteMapping[i] = noteMapping[i] + 4
			noteMapping[i+4] = noteMapping[i+4] - 4
		end
	end
	
elseif NumColumns ~= 4 then
	return
end


local cancelCuesPattern
if IgnoreHoldsRolls then
	cancelCuesPattern = '[124]'
else
	cancelCuesPattern = '[1234]'
end

local cuePattern
if IgnoreNotes then
	cuePattern = '[M]'
elseif CueMines then
	cuePattern = '[124M]'
else
	cuePattern = '[124]'
end

local prevTime = 0
local holdCount = 0
for _, noteTime in ipairs(noteTimes) do
	if noteTime.time - prevTime >= cue_time and holdCount == 0 then
		for _, note in ipairs(noteTime.notes) do
			local isMatch = note.type:match(cuePattern)
			if isMatch then
				local col = note.column
				col = noteMapping[col]
				local times = columnTimes[col]
				times[#times+1] = {
					start=prevTime,
					duration=noteTime.time-prevTime,
					noteType=note.type,
				}
			end
		end
	end

	for _, note in ipairs(noteTime.notes) do
		if not IgnoreHoldsRolls then
			if note.type:match('[24]') then
				holdCount = holdCount + 1
			end

			if note.type == '3' then
				holdCount = holdCount - 1
			end
		end

		if note.type:match(cancelCuesPattern) then
			prevTime = noteTime.time
		end
	end
end

local style = GAMESTATE:GetCurrentStyle(player)
local width = style:GetWidth(player)

local y_offset = 80
local fade_time = 0.15

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( GetNotefieldX(player), y_offset)
		-- See ColumnFlashOnMiss for what the fuck this is.
		local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
		self:zoomx( zoom_factor )
	end,
	OnCommand=function(self)
		
	end,
}

local IsReversedColumn = function(player, columnIndex)
	local columns = {}
	for i=1, NumColumns do
		columns[#columns + 1] = false
	end

	if po:Reverse() == 1 then
		for column,val in ipairs(columns) do
			columns[column] = not val
		end
	end

	if po:Alternate() == 1 and po:Centered() == 0 then
		for column,val in ipairs(columns) do
			if column % 2 == 0 then
				columns[column] = not val
			end
		end
	end

	if po:Split() == 1 and po:Centered() == 0 then
		for column,val in ipairs(columns) do
			if column > NumColumns / 2 then
				columns[column] = not val
			end
		end
	end

	if po:Cross() == 1 and po:Centered() == 0 then
		local firstChunk = NumColumns / 4
		local lastChunk = NumColumns - firstChunk
		for column,val in ipairs(columns) do
			if column > firstChunk and column <= lastChunk then
				columns[column] = not val
			end
		end
	end

	return columns[columnIndex]
end

for ColumnIndex=1,NumColumns do
	local timeIndex = 1
	local quad = nil
	af[#af+1] = Def.ActorFrame {
		InitCommand=function(self)
			self:queuecommand('Run')
		end,
		RunCommand=function(self)
			local now = GAMESTATE:GetCurMusicSeconds() / SL.Global.ActiveModifiers.MusicRate
			local flashDuration = nil
			local color = nil
			while true do
				local nextTime = columnTimes[ColumnIndex][timeIndex]
				if nextTime == nil then break end
				local waitTime = nextTime.start - now
				if waitTime >= 0.017 then
					self:sleep(waitTime)
					self:queuecommand('Run')
					break
				end
				timeIndex = timeIndex + 1
				flashDuration = nextTime.duration
				if nextTime.noteType == 'M' then
					color = {1,0.4,0.4,0.12}
				else
					color = {0.3,1,1,0.12}
				end
			end

			if flashDuration ~= nil then
				BreakTime = tonumber(flashDuration)
				quad:stoptweening()
					:decelerate(fade_time)
					:diffuse(color)
					:sleep(flashDuration - 2*fade_time)
					:accelerate(fade_time)
					:diffuse(0,0,0,0)
				if CountdownBreaks then
					if BreakTime >= 5 then
						text:stoptweening()
							:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
							:decelerate(fade_time)
							:diffuse(Color.White)
							:settext(round(BreakTime,1))
							:playcommand("UpdateBreak")
					else
						text:diffuse(0,0,0,0)
					end
				end
			end
		end,
		Def.Quad {
			InitCommand=function(self)
				self:diffuse(0,0,0,0)
					:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
					:vertalign(top)
					:setsize(width/NumColumns, _screen.h - y_offset)
					:fadebottom(0.333)
				quad = self
			end,
		},
		Def.BitmapText{
			Font="_Combo Fonts/Bebas Neue/Bebas Neue",
			Text="",
			InitCommand=function(self)
				self:zoom(0.5)
					:diffuse(0,0,0,0)
					:horizalign(center)
					:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
				if IsReversedColumn(player, noteMapping[ColumnIndex]) then
					self:y(260 + (mini * 15))
				else
					self:y(80 - (mini * 15))
				end
				if po:Centered() > 0 then
					self:addy(po:Reverse() == 0 and (135 - (mini * 4)) or (-135 + (mini * 4)))
				end
				text = self
			end,
			UpdateBreakCommand=function(self)
				if BreakTime > 0.5 then
					BreakTime = BreakTime - 0.1
					if BreakTime > 0.5 then
						self:sleep(0.1)
							:settext(round(BreakTime))
							:queuecommand("UpdateBreak")
					else
						self:diffuse(0,0,0,0)
					end
				else
					self:diffuse(0,0,0,0)
				end
				
			end,
		}
	}
end

return af
