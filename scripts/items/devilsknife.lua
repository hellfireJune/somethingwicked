local this = {}
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

    SomethingWicked.EnemyHelpers:FluctuatingOrbitFunc(familiar, player, 1)
end

function this:EvaluateCache(player)
    local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_DEVILSKNIFE_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE, stacks, rng, sourceItem)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

this.EIDEntries = {}
return this