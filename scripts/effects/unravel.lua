local mod = SomethingWicked

local specialestBool = false
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, function (_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    if specialestBool then return end
    if e_data.sw_unravelDMG == nil then return end
    if flags & DamageFlag.DAMAGE_CLONES > 0 then return end

    specialestBool = true
    ent:TakeDamage(amount + e_data.sw_unravelDMG, flags, source, dmgCooldown)
    specialestBool = false
    return false
end)