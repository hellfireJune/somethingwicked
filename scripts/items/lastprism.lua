local this = {}
CollectibleType.SOMETHINGWICKED_LAST_PRISM = Isaac.GetItemIdByName("Last Prism")--[]
FamiliarVariant.SOMETHINGWICKED_PRISM_HELPER = Isaac.GetItemIdByName("Last Prism Helper")

local prismOffset = 20
function this:PostPEffectUpdate(player)
    local p_data = player:GetData()

    local effects = player:GetEffects()
    if not effects:HasCollectibleEffect(CollectibleType.SOMETHINGWICKED_LAST_PRISM) then
        if p_data.somethingWicked_lastPrism then
            --cleanup
            p_data.somethingWicked_usingLastPrism = false
            p_data.somethingWicked_lastPrism = nil
        end
        return
    end
    player.FireDelay = player.MaxFireDelay

    if not p_data.somethingWicked_lastPrism then
        p_data.somethingWicked_usingLastPrism = true
    end
    
    local prism = p_data.somethingWicked_lastPrism
    if not prism or not prism:Exists() then
        prism = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_PRISM_HELPER, 0, player.Positon, Vector.Zero, player)
        prism:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        p_data.somethingWicked_lastPrism = prism
    end

    local direction = player:GetAimDirection()
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PostPEffectUpdate)

this.EIDEntries = {}
return this
