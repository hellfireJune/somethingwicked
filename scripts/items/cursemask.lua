local this = {}
CollectibleType.SOMETHINGWICKED_CURSE_MASK = Isaac.GetItemIdByName("Curse Mask")

function this:OnDamage(player, amount, flag)
    player = player:ToPlayer()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CURSE_MASK)
    and flag & DamageFlag.DAMAGE_CURSED_DOOR ~= 0 then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.CurseRoomsHealedOff = p_data.SomethingWickedPData.CurseRoomsHealedOff or {} 

        local room = SomethingWicked.game:GetRoom()
        local door = room:GetGridEntityFromPos(player.Position)

        if door and door:ToDoor() then
            door = door:ToDoor()
            local idx = door.TargetRoomType == RoomType.ROOM_CURSE and door.TargetRoomIndex or SomethingWicked.game:GetLevel():GetCurrentRoomIndex()
            if not SomethingWicked:UtilTableHasValue(p_data.SomethingWickedPData.CurseRoomsHealedOff, idx) then
                table.insert(p_data.SomethingWickedPData.CurseRoomsHealedOff, idx)
                player:AddHearts(2)
                SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
            end
        end
        return false
    end
end


SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        player:GetData().SomethingWickedPData.CurseRoomsHealedOff = {} 
    end
end)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnDamage, EntityType.ENTITY_PLAYER)

this.EIDEntries = {}
return this