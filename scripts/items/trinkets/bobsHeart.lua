local mod = SomethingWicked

local function PickupInit(_, entity)
    if entity.SubType ~= HeartSubType.HEART_FULL 
    and entity.SubType ~= HeartSubType.HEART_HALF 
    and entity.SubType ~= HeartSubType.HEART_SCARED then
        return
    end

    if mod:GlobalPlayerHasTrinket(mod.TRINKETS.BOBS_HEART) then
        entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PickupInit, PickupVariant.PICKUP_HEART)