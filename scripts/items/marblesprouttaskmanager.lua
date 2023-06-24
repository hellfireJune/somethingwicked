local this = {}

function this:UseSprout(_, rngObj, player)
    return this:SpawnLocusts(player, rngObj, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD)
end

function this:UseTM(_, rngObj, player)
    return this:SpawnLocusts(player, rngObj, LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST)
end

function this:SpawnLocusts(player, rng, subtype)
    for i = 1, 1 + rng:RandomInt(3), 1 do
    local wf = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype,
        player.Position, Vector.Zero, player)
        wf.Parent = player
    end

    return true
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseSprout, CollectibleType.SOMETHINGWICKED_MARBLE_SPROUT)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseTM, CollectibleType.SOMETHINGWICKED_TASK_MANAGER)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_MARBLE_SPROUT] = {
        Hide = true,
    },
    [CollectibleType.SOMETHINGWICKED_TASK_MANAGER] = {
        Hide = true,
    }
}
return this