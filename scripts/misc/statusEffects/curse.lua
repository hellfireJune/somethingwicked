local mod = SomethingWicked
local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    local fire = source.Entity

    if (fire == nil
    or fire.Type ~= EntityType.ENTITY_EFFECT
    or fire.Variant ~= EffectVariant.BLUE_FLAME
    or fire.SubType ~= 23)
    and e_data.somethingWicked_curseTick and e_data.somethingWicked_curseTick > 0 and e_data.somethingWicked_isDoingCurseDamage ~= true then
        e_data.somethingWicked_isDoingCurseDamage = true
        ent:TakeDamage(amount * 1.5, flags, source, dmgCooldown)
        e_data.somethingWicked_isDoingCurseDamage = nil
        return false
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnEnemyTakeDMG)

local slow = 0.9
local function NPCUpdate(_, ent)
    local e_data = ent:GetData()
    if e_data.somethingWicked_curseTick and e_data.somethingWicked_curseTick > 0 then 
        ent.Velocity = ent.Velocity * slow
        e_data.somethingWicked_curseTick = e_data.somethingWicked_curseTick - 1
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, NPCUpdate)
