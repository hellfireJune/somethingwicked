local this = {}
CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE = Isaac.GetItemIdByName("Disciple's Eye")

function  this:PlayerUpdate(player)
    local lvel = SomethingWicked.game:GetLevel()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE) then
        for i = 1, 169 do
            local redRoom = lvel:GetRoomByIdx(i)
                
            if redRoom.Data 
            and redRoom.Data.Type == RoomType.ROOM_ULTRASECRET 
            and redRoom.DisplayFlags & 1 << 2 == 0 then
                redRoom.DisplayFlags = (redRoom.DisplayFlags or 0) | 1 << 2
                lvel:UpdateVisibility()
                break
            end
        end
    end
end

function this:OnPickup(player, room)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
end

function this:OnTakeDamage(player, _, flags, ref)
    local room = SomethingWicked.game:GetRoom()
    if player:ToPlayer():HasCollectible(CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE)
    and flags & DamageFlag.DAMAGE_SPIKES ~= 0
    and room:GetType() == RoomType.ROOM_SACRIFICE
    and player:GetDropRNG():RandomInt(3) == 1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnTakeDamage, EntityType.ENTITY_PLAYER)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, this.PlayerUpdate)
--SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, this.OnPickup, CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE)


if MinimapAPI then
    function this.MinimapAPICompatibility(_, room, dflags)
        if room.Descriptor and room.Descriptor.Data.Type == RoomType.ROOM_ULTRASECRET then
            if SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE) then
                return dflags |  1 << 2
            end
        end
        return dflags
    end

    MinimapAPI:AddDisplayFlagsCallback(SomethingWicked, this.MinimapAPICompatibility)
end

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE] = {
        desc = "Reveals the ultra secret room#33% chance to spawn a cracked key upon using sacrifice rooms#Spawns a cracked key on pickup",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Reveals the ultra secret room","33% chance to spawn a cracked key upon using sacrifice rooms","Spawns a cracked key on pickup"})
    }
}
return this
