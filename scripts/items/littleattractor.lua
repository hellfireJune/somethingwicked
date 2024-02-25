local this = {}

function this:FamiliarUpdate(familiar)
    familiar:MoveDiagonally(1)

    SomethingWicked.game:UpdateStrangeAttractor(familiar.Position)
end

function this:EvalCache(player)
    local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, mod.ITEMS.LITTLE_ATTRACTOR_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_LITTLE_ATTRACTOR, stacks, rng, sourceItem)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_LITTLE_ATTRACTOR)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvalCache, CacheFlag.CACHE_FAMILIARS)

this.EIDEntries = {
    [mod.ITEMS.LITTLE_ATTRACTOR_ITEM] = {
        Hide = true,
    }
}
return this