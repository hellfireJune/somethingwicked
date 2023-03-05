local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_DEVILSKNIFE_ITEM = Isaac.GetItemIdByName("Devilsknife")
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

this.EIDEntries = {}
return this