local mod = SomethingWicked
local dmgMult = 1.5

local flag = false
function OnDamag(_, ent, amount, flags, source, dmgCooldown)
    if flag then
        return
    end
    ent = ent:ToNPC()
    if not ent then
        return
    end
    if source == nil or source.Entity == nil then
        return 
    end
    local player = mod:UtilGetPlayerFromTear(source.Entity)
    if not player then
        return
    end
    local hasItem = player:HasCollectible(mod.ITEMS.BRAVERY)
    if not hasItem then
        return
    end
    local boss = ent:IsBoss() or ent:IsChampion()
    if boss  then
        flag = true
        ent:TakeDamage(amount * dmgMult, flags, source, dmgCooldown)
        flag = false
        return false
    end
end

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnDamag)