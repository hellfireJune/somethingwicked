local this = {}
CollectibleType.SOMETHINGWICKED_CROSSED_HEART = Isaac.GetItemIdByName("Crossed Heart")

this.validSubtypes = {HeartSubType.HEART_FULL, HeartSubType.HEART_HALF, HeartSubType.HEART_SCARED, HeartSubType.HEART_DOUBLEPACK, HeartSubType.HEART_BLENDED}
this.ProcChance = 0.5
function this:PickupHeart(pickup, player)
    player = player:ToPlayer()
    if player == nil or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_CROSSED_HEART)  then
        return
    end

    local rng = pickup:GetDropRNG()
    if SomethingWicked:UtilTableHasValue(this.validSubtypes, pickup.SubType)
    and rng:RandomFloat() < this.ProcChance
    and SomethingWicked.ItemHelpers:WillHeartBePickedUp(pickup, player) then
        player:AddHearts(1)
    end
end

function this:DMGup(player, flags)
    player.Damage = player.Damage + SomethingWicked.StatUps:DamageUp(player, 1.3)
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupHeart, PickupVariant.PICKUP_HEART)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.DMGup, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
}
return this