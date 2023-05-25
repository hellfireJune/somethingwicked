local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_SPOOL_OF_YARN = Isaac.GetItemIdByName("Spool of Yarn")

mod.TFCore:AddNewFlagData(mod.CustomTearFlags.FLAG_UNRAVEL, {
    ApplyLogic = function (_, player)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_SPOOL_OF_YARN) then
            return true
        end
    end
})

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, function (_, ent, amount, flags, source, dmgCooldown)
    if not mod.TFCore:HasFlags(ent, mod.CustomTearFlags.FLAG_UNRAVEL) then
        return
    end

    local e_data = ent:GetData()
    e_data.sw_unravelDMG = (e_data.sw_unravelDMG or 0)
    local unravelAddAmount = (amount - e_data.sw_unravelDMG)/2
    if unravelAddAmount > 0 then
        e_data.sw_unravelDMG = e_data.sw_unravelDMG + unravelAddAmount
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SPOOL_OF_YARN] = {
        desc = "weezer",
        Hide = true,
    }
}
return this