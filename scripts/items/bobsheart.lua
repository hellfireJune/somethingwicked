local this = {}

function this:PickupInit(entity)
    if entity.SubType ~= HeartSubType.HEART_FULL 
    and entity.SubType ~= HeartSubType.HEART_HALF 
    and entity.SubType ~= HeartSubType.HEART_SCARED then
        return
    end

    if SomethingWicked:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_BOBS_HEART) then
        entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, true)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.PickupInit, PickupVariant.PICKUP_HEART)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_BOBS_HEART] = {
        isTrinket = true,
        desc = "Turns all red hearts into rotten hearts.",
    }
}
return this