local this = {}
CollectibleType.SOMETHINGWICKED_LEGION_ITEM = Isaac.GetItemIdByName("Legion")
FamiliarVariant.SOMETHINGWICKED_LEGION = Isaac.GetEntityVariantByName("Legion Familiar")
FamiliarVariant.SOMETHINGWICKED_LEGION_B = Isaac.GetEntityVariantByName("Legion Familiar B")

function this:OnCache(player, flags)
    if flags == CacheFlag.CACHE_FAMILIARS then

        local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_LEGION_ITEM)
        player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_LEGION, stacks, rng, sourceItem)
        player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_LEGION_B, stacks * 3 , rng, sourceItem)
        
    end
end

function this:FamiliarInit(familiar)
    if familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION
    and familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION_B then
        return
    end

    familiar:AddToOrbit(125)
    familiar.OrbitDistance = Vector(40, 40)
	familiar.OrbitSpeed = 0.03
end

this.damageMult = 0.175
function this:FamiliarUpdate(familiar)
    if familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION
    and familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION_B then
        return
    end
    local player = familiar.Player

    familiar.OrbitDistance = Vector(40, 40)
	familiar.OrbitSpeed = 0.03

    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position

    --firing
    if familiar.FireCooldown <= 0 then
        if player:GetFireDirection() ~= Direction.NO_DIRECTION then
            local angle = SomethingWicked.HoldItemHelpers:GetUseDirection(player)
            player:FireTear(familiar.Position, angle, false, false, false, familiar, this.damageMult)

            familiar.FireCooldown = math.ceil(player.MaxFireDelay)
        end
    else
        familiar.FireCooldown = familiar.FireCooldown - 1
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate)

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.OnCache)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_LEGION_ITEM] = {
        desc = "hey guys"
    }
}
return this