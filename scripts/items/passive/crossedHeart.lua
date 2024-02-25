local mod = SomethingWicked
local validSubtypes = {HeartSubType.HEART_FULL, HeartSubType.HEART_HALF, HeartSubType.HEART_SCARED, HeartSubType.HEART_DOUBLEPACK, HeartSubType.HEART_BLENDED}
local ProcChance = 0.5
local function PickupHeart(pickup, player)
    player = player:ToPlayer()
    if player == nil or not player:HasCollectible(mod.ITEMS.CROSSED_HEART)  then
        return
    end

    local rng = pickup:GetDropRNG()
    if SomethingWicked:UtilTableHasValue(validSubtypes, pickup.SubType)
    and rng:RandomFloat() < ProcChance
    and mod:WillHeartBePickedUp(pickup, player) then
        player:AddHearts(1)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PickupHeart, PickupVariant.PICKUP_HEART)