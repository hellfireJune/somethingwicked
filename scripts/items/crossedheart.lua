local this = {}

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
    player.Damage = SomethingWicked.StatUps:DamageUp(player, (0.7 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_CROSSED_HEART)))
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupHeart, PickupVariant.PICKUP_HEART)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.DMGup, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CROSSED_HEART] = {
        desc = "↑ +0.7 damage up#↑ Picking up a red heart has a 50% chance to heal for a bonus half red heart",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Damage up by 0.7", "Picking up a red heart has a 50% chance to heal for a bonus half red heart"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME
        }
    }
}
return this