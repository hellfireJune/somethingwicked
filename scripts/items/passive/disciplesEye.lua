local mod = SomethingWicked
local game = Game()

local function PlayerUpdate(_, player)
    local lvel = game:GetLevel()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE) then
        for i = 1, 169 do
            local redRoom = lvel:GetRoomByIdx(i)
                
            if redRoom.Data 
            and redRoom.Data.Type == RoomType.ROOM_ULTRASECRET 
            and redRoom.DisplayFlags & 1 << 2 == 0 then
                redRoom.DisplayFlags = (redRoom.DisplayFlags or 0) | 1 << 2
                lvel:UpdateVisibility()
            end
        end
    end
end

local function OnPickup(_, player, room)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
end

local function OnTakeDamage(_, player, _, flags, ref)
    local room = game:GetRoom()
    if player:ToPlayer():HasCollectible(CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE)
    and flags & DamageFlag.DAMAGE_SPIKES ~= 0
    and room:GetType() == RoomType.ROOM_SACRIFICE
    and player:GetDropRNG():RandomInt(3) == 1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end
end

SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, OnTakeDamage, EntityType.ENTITY_PLAYER)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PlayerUpdate)
--SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, OnPickup, CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE)


if MinimapAPI then
    local function MinimapAPICompatibility(_, _, room, dflags)
        if room.Descriptor and room.Descriptor.Data.Type == RoomType.ROOM_ULTRASECRET then
            if mod:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_DISCIPLES_EYE) then
                return dflags |  1 << 2
            end
        end
        return dflags
    end

    MinimapAPI:AddDisplayFlagsCallback(SomethingWicked, MinimapAPICompatibility)
end