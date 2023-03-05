local this = {}
CollectibleType.SOMETHINGWICKED_CURSE_MASK = Isaac.GetItemIdByName("Curse Mask")
CollectibleType.SOMETHINGWICKED_BLACK_MOON_MEDALLION = Isaac.GetItemIdByName("Black Moon Medallion")

function this:OnDamage(player, amount, flag)
    player = player:ToPlayer()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CURSE_MASK) or player:HasCollectible(CollectibleType.SOMETHINGWICKED_BLACK_MOON_MEDALLION)
    and flag & DamageFlag.DAMAGE_CURSED_DOOR ~= 0 then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.CurseRoomsHealedOff = p_data.SomethingWickedPData.CurseRoomsHealedOff or {} 

        local room = SomethingWicked.game:GetRoom()
        local door = room:GetGridEntityFromPos(player.Position)

        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CURSE_MASK) and door then
            door = door:ToDoor()
            if door then
                local idx = door.TargetRoomType == RoomType.ROOM_CURSE and door.TargetRoomIndex or SomethingWicked.game:GetLevel():GetCurrentRoomIndex()
                if not SomethingWicked:UtilTableHasValue(p_data.SomethingWickedPData.CurseRoomsHealedOff, idx) then
                    table.insert(p_data.SomethingWickedPData.CurseRoomsHealedOff, idx)
                    player:AddHearts(2)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position - Vector(0, 60), Vector.Zero, player)
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
                end
            end
        else
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BLACK_MOON_MEDALLION)
            if (SomethingWicked.game:GetLevel():GetCurses() == LevelCurse.CURSE_NONE)
            or c_rng:RandomFloat() < 0.5 then
                return
            end
        end
        
        local color = Color(1, 1, 1, 1, 0.5)
        player:SetColor(color, 8, 3, true, false)
        player:SetMinDamageCooldown(40)
        return false
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        player:GetData().SomethingWickedPData.CurseRoomsHealedOff = {} 
    end
    
    if not SomethingWicked.RedKeyRoomHelpers:GenericShouldGenerateRoom(SomethingWicked.game:GetLevel(), SomethingWicked.game) or
    (SomethingWicked.game:GetLevel():GetCurses() == LevelCurse.CURSE_NONE) then
        return
    end

    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_BLACK_MOON_MEDALLION)
    if flag and player then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BLACK_MOON_MEDALLION)
        for i = 1, c_rng:RandomInt(3) + 1, 1 do
            SomethingWicked.RedKeyRoomHelpers:GenerateSpecialRoom("curse", 1, 6, true, c_rng)
        end
    end
end)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnDamage, EntityType.ENTITY_PLAYER)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CURSE_MASK] = {
        desc = "Blocks all damage from curse rooms#Curse rooms heal upon entering for the first time",
        Hide = true,
    }
}
return this