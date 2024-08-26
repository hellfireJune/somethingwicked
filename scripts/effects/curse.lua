local mod = SomethingWicked
local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    local fire = source.Entity

    if (fire == nil
    or fire.Type ~= EntityType.ENTITY_EFFECT
    or fire.Variant ~= EffectVariant.BLUE_FLAME
    or fire.SubType ~= 23)
    and e_data.sw_curseDuration and e_data.sw_curseDuration > 0 and e_data.sw_isDoingCurseDamage ~= true then
        e_data.sw_isDoingCurseDamage = true
        ent:TakeDamage(amount * 1.5, flags, source, dmgCooldown)
        e_data.sw_isDoingCurseDamage = nil
        return false
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnEnemyTakeDMG)

local slow = 0.9
function mod:CurseStatusUpdate(ent)
    local e_data = ent:GetData()
    if e_data.sw_curseDuration then
        if e_data.sw_curseDuration < 0 then
            e_data.sw_curseDuration = nil
            if e_data.sw_cursefrictionApplied then
                ent.Friction = ent.Friction / slow
                e_data.sw_cursefrictionApplied = nil
            end
            return
        end
        e_data.sw_curseDuration = e_data.sw_curseDuration - 1

        if not e_data.sw_cursefrictionApplied then
            ent.Friction = ent.Friction * slow
            e_data.sw_cursefrictionApplied = true
        end
    end
end
