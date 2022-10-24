--tainted treasures mod is full of saints as developers thank GOD
SomethingWicked.RedKeyRoomHelpers = {}
local game = SomethingWicked.game

function SomethingWicked.RedKeyRoomHelpers:IsDeadEnd(roomidx, shape)
	local level = game:GetLevel()
	shape = shape or RoomShape.ROOMSHAPE_1x1
	local deadend = false
	local adjindex = SomethingWicked.RedKeyRoomHelpers.adjindexes[shape]
	local adjrooms = 0
	for i, entry in pairs(adjindex) do
		local oob = false
		for j, idx in pairs(SomethingWicked.RedKeyRoomHelpers.borderrooms[i]) do
			if idx == roomidx then
				oob = true
			end
		end
		if level:GetRoomByIdx(roomidx+entry).GridIndex ~= -1 and not oob then
			adjrooms = adjrooms+1
		end
	end
	if adjrooms == 1 then
		deadend = true
	end
	return deadend
end

function SomethingWicked.RedKeyRoomHelpers:GetDeadEnds(roomdesc, isRed)
	isRed = isRed or false
	local level = game:GetLevel()
	local roomidx = roomdesc.SafeGridIndex
	local shape = roomdesc.Data.Shape
	local adjindex = SomethingWicked.RedKeyRoomHelpers.adjindexes[shape]
	local deadends = {}
	for i, entry in pairs(adjindex) do
		if level:GetRoomByIdx(roomidx).Data then
			local oob = false
			for j, idx in pairs(SomethingWicked.RedKeyRoomHelpers.borderrooms[i]) do
				if idx == roomidx then
					oob = true
				end
			end
			if roomdesc.Data.Doors & (1 << i) > 0 and (isRed or SomethingWicked.RedKeyRoomHelpers:IsDeadEnd(roomidx+adjindex[i])) and level:GetRoomByIdx(roomidx+adjindex[i]).GridIndex == -1 and not oob then
				table.insert(deadends, {Slot = i, GridIndex = roomidx+adjindex[i]})
			end
		end
	end
	
	if deadends[1] then
		return deadends
	else
		return nil
	end
end

function SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(slot)
	return SomethingWicked.RedKeyRoomHelpers.oppslots[slot]
end

function SomethingWicked.RedKeyRoomHelpers:UpdateRoomDisplayFlags(initroomdesc)
	local level = game:GetLevel()
	local roomdesc = level:GetRoomByIdx(initroomdesc.GridIndex) --Only roomdescriptors from level:GetRoomByIdx() are mutable
	local roomdata = roomdesc.Data
	if level:GetRoomByIdx(roomdesc.GridIndex).DisplayFlags then
		if level:GetRoomByIdx(roomdesc.GridIndex) ~= level:GetCurrentRoomDesc().GridIndex then
			if roomdata then 
				if level:GetStateFlag(LevelStateFlag.STATE_FULL_MAP_EFFECT) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_ALL
				elseif roomdata.Type ~= RoomType.ROOM_DEFAULT and roomdata.Type ~= RoomType.ROOM_SECRET and roomdata.Type ~= RoomType.ROOM_SUPERSECRET and roomdata.Type ~= RoomType.ROOM_ULTRASECRET and level:GetStateFlag(LevelStateFlag.STATE_COMPASS_EFFECT) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_ALL
				elseif roomdata and level:GetStateFlag(LevelStateFlag.STATE_BLUE_MAP_EFFECT) and (roomdata.Type == RoomType.ROOM_SECRET or roomdata.Type == RoomType.ROOM_SUPERSECRET) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_ALL
				elseif level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_BOX
				else
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_NONE
				end
			end
		end
	end
end

function SomethingWicked.RedKeyRoomHelpers:UpdateLevelDisplayFlags()
	local level = game:GetLevel()
	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc then
			SomethingWicked.RedKeyRoomHelpers:UpdateRoomDisplayFlags(roomdesc)
		end
	end
end

function SomethingWicked.RedKeyRoomHelpers:GenerateSpecialRoom(roomtype, minvariant, maxvariant, onnewlevel, rng) --Roomtype must be provided as a string for goto use, enter nil to generate an ordinary room
	onnewlevel = onnewlevel or false
	local level = game:GetLevel()
	local hascurseofmaze = false
	local floordeadends = SomethingWicked.RedKeyRoomHelpers:GetAllDeadEnds(onnewlevel)
	local roomvariants = {}
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	
	if onnewlevel then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			player:GetData().ResetPosition = player.Position
		end
	end
	
	if level:GetCurses() & LevelCurse.CURSE_OF_MAZE > 0 then
		level:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
		hascurseofmaze = true
		SomethingWicked.RedKeyRoomHelpers.applyingcurseofmaze = true
	end
	
	if not floordeadends[1] then
		return false
	end
	
	for i = minvariant, maxvariant do
		table.insert(roomvariants, i)
	end
	
	SomethingWicked:UtilShuffleTable(roomvariants, rng)
	SomethingWicked:UtilShuffleTable(floordeadends, rng)
	
	for i, roomvariant in pairs(roomvariants) do
		if roomtype then
			Isaac.ExecuteCommand("goto s."..roomtype.."."..roomvariant)
		else
			Isaac.ExecuteCommand("goto d."..roomvariant)
		end
		local data = level:GetRoomByIdx(-3,0).Data
		
		if data.Shape == RoomShape.ROOMSHAPE_1x1 then
			for i, entry in pairs(floordeadends) do
				local deadendslot = entry.Slot
				local deadendidx = entry.GridIndex
				local roomidx = entry.roomidx
				local roomdesc = level:GetRoomByIdx(roomidx)
				if roomdesc.Data and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 and SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(deadendslot) and data.Doors & (1 << SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(deadendslot)) > 0 then
						if level:MakeRedRoomDoor(roomidx, deadendslot) then
							local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
							newroomdesc.Data = data
							newroomdesc.Flags = 0
							SomethingWicked:UtilScheduleForUpdate(function()
								SomethingWicked.sfx:Stop(SoundEffect.SOUND_UNLOCK00)
								game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
								if level:GetRoomByIdx(currentroomidx).VisitedCount ~= currentroomvisitcount then
									level:GetRoomByIdx(currentroomidx).VisitedCount = currentroomvisitcount-1
								end
								SomethingWicked.RedKeyRoomHelpers:UpdateRoomDisplayFlags(newroomdesc)
								level:UpdateVisibility()
								if onnewlevel then
									for i = 0, game:GetNumPlayers() - 1 do
										local player = Isaac.GetPlayer(i)
										player.Position = player:GetData().ResetPosition
									end
								end
							end, 0, ModCallbacks.MC_POST_RENDER)
							SomethingWicked:UtilScheduleForUpdate(function()
								if hascurseofmaze then
									level:AddCurse(LevelCurse.CURSE_OF_MAZE)
									SomethingWicked.RedKeyRoomHelpers.applyingcurseofmaze = false
								end
								if onnewlevel then
									for i = 0, game:GetNumPlayers() - 1 do --You have to do it twice or it doesn't look right, not sure why
										local player = Isaac.GetPlayer(i)
										player.Position = player:GetData().ResetPosition
									end
								end
								level:UpdateVisibility()
							end, 0, ModCallbacks.MC_POST_UPDATE)
						--table.insert(SomethingWicked.RedKeyRoomHelpers.minimaprooms, newroomdesc.GridIndex)
						return newroomdesc
					end
				end
			end
		end
	end
	
	game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
	SomethingWicked:UtilScheduleForUpdate(function()
		if onnewlevel then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				player.Position = player:GetData().ResetPosition
			end
		end
	end, 0)
	return false
end

function SomethingWicked.RedKeyRoomHelpers:GenerateExtraRoom(rng)
	local level = game:GetLevel()
	local floordeadends = {}
	local currentroomidx = level:GetCurrentRoomIndex()
	for j = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(j-1)
		if roomdesc then
			local deadends = SomethingWicked.RedKeyRoomHelpers:GetDeadEnds(roomdesc)
			if deadends and roomdesc.GridIndex ~= currentroomidx then
				for k, deadend in pairs(deadends) do
					table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
				end
			end
		end
	end
	
	SomethingWicked:UtilShuffleTable(floordeadends, rng)
	
	for i, deadend in pairs(floordeadends) do
		local deadendslot = deadend.Slot
		local deadendidx = deadend.GridIndex
		local roomidx = deadend.roomidx
		local roomdesc = level:GetRoomByIdx(roomidx)
		if roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_DEFAULT and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 then
			if level:MakeRedRoomDoor(roomidx, deadendslot) then
				local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
				newroomdesc.Flags = 0
				SomethingWicked.RedKeyRoomHelpers:UpdateRoomDisplayFlags(newroomdesc)
				level:UpdateVisibility()
				--table.insert(SomethingWicked.RedKeyRoomHelpers.minimaprooms, newroomdesc.GridIndex)
				return true
			end
		end
	end
end

function SomethingWicked.RedKeyRoomHelpers:InitializeRoomData(roomtype, minvariant, maxvariant, dataset)
	local level = game:GetLevel()
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	local hascurseofmaze = false
	
	if level:GetCurses() & LevelCurse.CURSE_OF_MAZE > 0 then
		level:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
		hascurseofmaze = true
		SomethingWicked.RedKeyRoomHelpers.applyingcurseofmaze = true
	end
	
	for i = minvariant, maxvariant, 1 do
		if roomtype then
			Isaac.ExecuteCommand("goto s."..roomtype.."."..i)
			dataset[i] = level:GetRoomByIdx(-3,0).Data
		else
			Isaac.ExecuteCommand("goto d."..i)
			dataset[i] = level:GetRoomByIdx(-3,0).Data
		end
	end
	game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
	
	if level:GetRoomByIdx(currentroomidx).VisitedCount ~= currentroomvisitcount then
		level:GetRoomByIdx(currentroomidx).VisitedCount = currentroomvisitcount - 1
	end
	
	if hascurseofmaze then
		SomethingWicked:UtilScheduleForUpdate(function()
			level:AddCurse(LevelCurse.CURSE_OF_MAZE)
			SomethingWicked.RedKeyRoomHelpers.applyingcurseofmaze = false
		end, 0, ModCallbacks.MC_POST_UPDATE)
	end
end

function SomethingWicked.RedKeyRoomHelpers:GenerateRoomFromDataset(dataset, onnewlevel, rng)
	onnewlevel = onnewlevel or false
	local level = game:GetLevel()
	local setcopy = dataset
	local currentroomidx = level:GetCurrentRoomIndex()
    local floordeadends = SomethingWicked.RedKeyRoomHelpers:GetAllDeadEnds(onnewlevel)
	
	if not floordeadends[1] then
		return false
	end
	
	--for i, data in pairs(dataset) do
		--table.insert(setcopy, data)
	--end
	
	SomethingWicked:UtilShuffleTable(floordeadends, rng)
	SomethingWicked:UtilShuffleTable(setcopy, rng)
	
	for i, data in pairs(setcopy) do
		if data.Shape == RoomShape.ROOMSHAPE_1x1 then
			for i, entry in pairs(floordeadends) do
				local deadendslot = entry.Slot
				local deadendidx = entry.GridIndex
				local roomidx = entry.roomidx
				local visitcount = entry.visitcount
				local roomdesc = level:GetRoomByIdx(roomidx)
				if roomdesc.Data and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 and SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(deadendslot) and data.Doors & (1 << SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(deadendslot)) > 0 then
					if level:MakeRedRoomDoor(roomidx, deadendslot) then
						local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
						newroomdesc.Data = data
						newroomdesc.Flags = 0
						SomethingWicked.RedKeyRoomHelpers:UpdateRoomDisplayFlags(newroomdesc)
						level:UpdateVisibility()
						--table.insert(SomethingWicked.RedKeyRoomHelpers.minimaprooms, newroomdesc.GridIndex)
						return newroomdesc
					end
				end
			end
		end
	end
end

--June Originals
function SomethingWicked.RedKeyRoomHelpers:GenericShouldGenerateRoom(level, game)
    return level:GetStage() < LevelStage.STAGE7 and not level:IsAscent() and not game:IsGreedMode()
end
function SomethingWicked.RedKeyRoomHelpers:GetAllDeadEnds(onnewlevel)
	local level = game:GetLevel()
	local floordeadends = {}
    local currentroomidx = level:GetCurrentRoomIndex()

	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc and roomdesc.Data.Type == RoomType.ROOM_DEFAULT and roomdesc.Data.Subtype ~= 34 and roomdesc.Data.Subtype ~= 10 then --Subtype checks protect against generation off of Mirror or Mineshaft entrance rooms
		local deadends = SomethingWicked.RedKeyRoomHelpers:GetDeadEnds(roomdesc, false)
			if deadends and not (onnewlevel and roomdesc.GridIndex == currentroomidx) then
				for j, deadend in pairs(deadends) do
					table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
				end
			end
		end
	end
	
    return floordeadends
end

function SomethingWicked.RedKeyRoomHelpers:IsValidRedRoomSpot(level, RRidx, func)
	func = func or function()
		return false
	end

    local roomDesc = level:GetRoomByIdx(RRidx)
	if not roomDesc or roomDesc.GridIndex <= 0 then
        for i = 1, 4, 1 do
            local rslot = i - 1
            if rslot < 0 then rslot = 3 end
            if rslot >= 4 then rslot = 0 end
            local oslot = SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(rslot)
            
            local trIDX = RRidx + SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][rslot]
            local realRoom = level:GetRoomByIdx(trIDX)

            if realRoom and realRoom.GridIndex > 0 then
                if realRoom.Data.Doors & 1 << oslot == 0
                or realRoom.Data.Type == RoomType.ROOM_BOSS
                or func(level, realRoom) then
                    return false
                end
            end
        end
    else
        return false
    end

    return true
end

function SomethingWicked.RedKeyRoomHelpers:GetAllDeadEndsRed()
	local level = game:GetLevel()
	local floordeadends = {}

	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc then --Subtype checks protect against generation off of Mirror or Mineshaft entrance rooms
			if roomdesc.Data.Type ~= RoomType.ROOM_DEFAULT or (roomdesc.Data.Subtype ~= 34 and roomdesc.Data.Subtype ~= 10)  then
				
				local deadends = SomethingWicked.RedKeyRoomHelpers:GetDeadEnds(roomdesc, true)
				if deadends then
					for j, deadend in pairs(deadends) do
						table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
					end
				end
			end
		end
	end
	
    return floordeadends
end

function SomethingWicked.RedKeyRoomHelpers:RoomTypeCurrentlyExists(roomtype, level, rng)
	local sacIDX = level:QueryRoomTypeIndex(roomtype, false, rng)
	if level:GetRoomByIdx(sacIDX).Data.Type == roomtype then
		return true
	end
	return false
end

function SomethingWicked.RedKeyRoomHelpers:ReplaceRoomFromDataset(dataset, idx, rng)
	local level = game:GetLevel()
	local setcopy = dataset
	
	--for i, data in pairs(dataset) do
		--table.insert(setcopy, data)
	--end
	
	SomethingWicked:UtilShuffleTable(setcopy, rng)
	
	for i, data in pairs(setcopy) do
		if data.Shape == RoomShape.ROOMSHAPE_1x1 then
			local roomidx = idx
			local roomdesc = level:GetRoomByIdx(roomidx)
			if roomdesc.Data and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1--[[and SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(deadendslot) and data.Doors & (1 << SomethingWicked.RedKeyRoomHelpers:GetOppositeDoorSlot(deadendslot)) > 0]] then
				roomdesc.Data = data
				roomdesc.Flags = 0
				SomethingWicked.RedKeyRoomHelpers:UpdateRoomDisplayFlags(roomdesc)
				level:UpdateVisibility()
				--table.insert(SomethingWicked.RedKeyRoomHelpers.minimaprooms, newroomdesc.GridIndex)
				return roomdesc
			end
		end
	end
end

--Some Even More #EPIC code i stole from tainted treasures, this time constants

SomethingWicked.RedKeyRoomHelpers.adjindexes = {
	[RoomShape.ROOMSHAPE_1x1] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 1, 
		[DoorSlot.DOWN0] = 13
	},
	[RoomShape.ROOMSHAPE_IH] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.RIGHT0] = 1
	},
	[RoomShape.ROOMSHAPE_IV] = {
		[DoorSlot.UP0] = -13, 
		[DoorSlot.DOWN0] = 13
	},
	[RoomShape.ROOMSHAPE_1x2] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 1, 
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12, 
		[DoorSlot.RIGHT1] = 14
	},
	[RoomShape.ROOMSHAPE_IIV] = {
		[DoorSlot.UP0] = -13, 
		[DoorSlot.DOWN0] = 26
	},
	[RoomShape.ROOMSHAPE_2x1] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 13,
		[DoorSlot.UP1] = -12,
		[DoorSlot.DOWN1] = 14
	},
	[RoomShape.ROOMSHAPE_IIH] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.RIGHT0] = 3
	},
	[RoomShape.ROOMSHAPE_2x2] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13,
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12,
		[DoorSlot.UP1] = -12, 
		[DoorSlot.RIGHT1] = 15, 
		[DoorSlot.DOWN1] = 27
	},
	[RoomShape.ROOMSHAPE_LTL] = {
		[DoorSlot.LEFT0] = -1,
		[DoorSlot.UP0] = -1,
		[DoorSlot.RIGHT0] = 1, 
		[DoorSlot.DOWN0] = 25,
		[DoorSlot.LEFT1] = 11, 
		[DoorSlot.UP1] = -13, 
		[DoorSlot.RIGHT1] = 14, 
		[DoorSlot.DOWN1] = 26
	},
	[RoomShape.ROOMSHAPE_LTR] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 1,
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12, 
		[DoorSlot.UP1] = 1,
		[DoorSlot.RIGHT1] = 15, 
		[DoorSlot.DOWN1] = 27
	},
	[RoomShape.ROOMSHAPE_LBL] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13,
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 13,
		[DoorSlot.LEFT1] = 13,
		[DoorSlot.UP1] = -12, 
		[DoorSlot.RIGHT1] = 15, 
		[DoorSlot.DOWN1] = 27
	},
	[RoomShape.ROOMSHAPE_LBR] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13,
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12,
		[DoorSlot.UP1] = -12,
		[DoorSlot.RIGHT1] = 14,
		[DoorSlot.DOWN1] = 14
	}
}

SomethingWicked.RedKeyRoomHelpers.borderrooms = {
	[DoorSlot.LEFT0] = {0, 13, 26, 39, 52, 65, 78, 91, 104, 117, 130, 143, 156},
	[DoorSlot.UP0] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
	[DoorSlot.RIGHT0] = {12, 25, 38, 51, 64, 77, 90, 103, 116, 129, 142, 155, 168},
	[DoorSlot.DOWN0] = {156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168},
	[DoorSlot.LEFT1] = {0, 13, 26, 39, 52, 65, 78, 91, 104, 117, 130, 143, 156},
	[DoorSlot.UP1] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
	[DoorSlot.RIGHT1] = {12, 25, 38, 51, 64, 77, 90, 103, 116, 129, 142, 155, 168},
	[DoorSlot.DOWN1] = {156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168}
}

SomethingWicked.RedKeyRoomHelpers.oppslots = {
	[DoorSlot.LEFT0] = DoorSlot.RIGHT0, 
	[DoorSlot.UP0] = DoorSlot.DOWN0, 
	[DoorSlot.RIGHT0] = DoorSlot.LEFT0, 
	[DoorSlot.LEFT1] = DoorSlot.RIGHT0, 
	[DoorSlot.DOWN0] = DoorSlot.UP0, 
	[DoorSlot.UP1] = DoorSlot.DOWN0, 
	[DoorSlot.RIGHT1] = DoorSlot.LEFT0, 
	[DoorSlot.DOWN1] = DoorSlot.UP0
}