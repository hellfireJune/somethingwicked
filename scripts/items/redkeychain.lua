local this = {}

local ccSpawnChance = 0.1
SomethingWicked:AddCallback(ModCallbacks.MC_GET_CARD, function ()
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(mod.TRINKETS.RED_KEYCHAIN)
    if flag and player then
        local t_rng = player:GetTrinketRNG(mod.TRINKETS.RED_KEYCHAIN)
        if t_rng:RandomFloat() < ccSpawnChance then
            return Card.CARD_CRACKED_KEY
        end
    end
end)

local ProcessedRooms
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function ()
    ProcessedRooms = nil
end)

function this:UpdateRoomly()
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(mod.TRINKETS.RED_KEYCHAIN)
    if flag and player then
        if SomethingWicked.game:GetFrameCount() % 4 == 1 then --sort of like a bus stop (doing this coz i fear how performance intensive this might be on later levels)
            local SkipMakingRRooms = false
            if ProcessedRooms == nil then
                ProcessedRooms = {}
                SkipMakingRRooms = true
            end

            local level = SomethingWicked.game:GetLevel()
            for i = level:GetRooms().Size, 0, -1 do
                local roomdesc = level:GetRooms():Get(i-1)
                if roomdesc then
                    
                local grIdx = roomdesc.GridIndex
                if not ProcessedRooms[grIdx] then
                    ProcessedRooms[grIdx] = true
                    if not SkipMakingRRooms
                    and roomdesc.Flags & RoomDescriptor.FLAG_RED_ROOM ~= 0 then
                        local attachedRooms = {}
                        for j = 0, 3, 1 do
                            local idx = grIdx + SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][j]
                            local room = level:GetRoomByIdx(idx)
                            if room and room.GridIndex ~= -1 then
                                attachedRooms[j] = idx
                            end
                        end

                        if #attachedRooms < 4 then
                            local rrSlot = -1
                            local t_rng = player:GetTrinketRNG(mod.TRINKETS.RED_KEYCHAIN)

                            if attachedRooms == {} then
                                rrSlot = t_rng:RandomInt(4)
                            else
                                local cr_Idx = level:GetCurrentRoomIndex()
                                local slotCandidates = {}
                                for slot, idx in pairs(attachedRooms) do
                                    local oslot = SomethingWicked.RedKeyRoomHelpers.oppslots[slot]
                                    local orIdx = grIdx + SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][oslot]

                                    local oppRoom = level:GetRoomByIdx(orIdx)
                                    if (not oppRoom or oppRoom.GridIndex == -1)
                                    and SomethingWicked.RedKeyRoomHelpers:IsValidRedRoomSpot(level, orIdx) then
                                        slotCandidates[orIdx] = oslot
                                    end
                                end
                                    local nslot = {}
                                    for key, value in pairs(slotCandidates) do
                                        table.insert(nslot, value)

                                        local diff = grIdx - key
                                        if grIdx + diff == cr_Idx
                                        and slotCandidates[grIdx - diff] then
                                            rrSlot = slotCandidates[grIdx - diff]
                                            break
                                        end
                                    end
                                    if rrSlot == -1 then
                                        rrSlot = SomethingWicked:GetRandomElement(nslot, t_rng)
                                    end
                                end
                                if rrSlot ~= -1 then
                                    if level:MakeRedRoomDoor(grIdx, rrSlot) then
                                        local idx = grIdx + SomethingWicked.RedKeyRoomHelpers.adjindexes[RoomShape.ROOMSHAPE_1x1][rrSlot]
                                        ProcessedRooms[idx] = 1
                                        local TheSweetReleaseOfHopefullyWritingTheFinalVariableNeededForThis = level:GetRoomByIdx(idx) --unfortunately not the case
                                        TheSweetReleaseOfHopefullyWritingTheFinalVariableNeededForThis.DisplayFlags = roomdesc.DisplayFlags
                                        level:UpdateVisibility()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        ProcessedRooms = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.UpdateRoomly)
this.EIDEntries = {}
return this