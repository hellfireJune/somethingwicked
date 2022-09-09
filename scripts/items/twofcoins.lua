local this = {}
TrinketType.SOMETHINGWICKED_TWO_OF_COINS = Isaac.GetTrinketIdByName("Two of Coins")

function this:PickupCollision(heart, entity, low)
    local player = entity:ToPlayer()
    if player ~= nil
    and player:HasTrinket(TrinketType.SOMETHINGWICKED_TWO_OF_COINS)
    and player:CanPickRedHearts()
    and (heart.SubType == HeartSubType.HEART_FULL 
    or heart.SubType == HeartSubType.HEART_HALF) then
        local pickupRNG = heart:GetDropRNG()
        for i = 1, 1 + pickupRNG:RandomInt(4), 1 do            
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, entity.Position, Vector.FromAngle(pickupRNG:RandomInt(360)) * 3, player)  
        end 
    end
end
 
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision, PickupVariant.PICKUP_HEART)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_TWO_OF_COINS] = {
        isTrinket = true,
        desc = "Spawns 2-4 coins upon picking up a heart",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 2-4 coins upon picking up a heart"})
    }
}
return this