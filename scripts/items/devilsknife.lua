local this = {}
local mod = SomethingWicked
FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE = Isaac.GetEntityVariantByName("Devilsknife")

function this:FamiliarInit(familiar)
    familiar:AddToOrbit(60)
    familiar.OrbitDistance = Vector(60, 60)
	familiar.OrbitSpeed = 0.02
end
function this:UpdateFamiliar(familiar)
    local player = familiar.Player
    familiar.OrbitDistance = Vector(60, 60)
	familiar.OrbitSpeed = 0.02

    mod.EnemyHelpers:FluctuatingOrbitFunc(familiar, player, 1)
end

function this:EvaluateCache(player)
    local stacks, rng, sourceItem = mod.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_DEVILSKNIFE_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE, stacks, rng, sourceItem)
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function (_, knife, proj)
    if proj:ToProjectile() then
        proj:Die()
    end
end, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_DEVILSKNIFE_ITEM] = {
        desc = "Spawns an orbiting knife familiar which will deal heavy contact damage and will oscillate in distance from the player",
        pools = {mod.encyclopediaLootPools.POOL_DEVIL, mod.encyclopediaLootPools.POOL_GREED_DEVIL, mod.encyclopediaLootPools.POOL_CURSE, mod.encyclopediaLootPools.POOL_ULTRA_SECRET, mod.encyclopediaLootPools.POOL_BABY_SHOP},
    }
}
return this