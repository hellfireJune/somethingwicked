
local mod = SomethingWicked
local takingDreadDMG = false
local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    e_data.sw_dreadStacks = e_data.sw_dreadStacks or 0
    e_data.sw_dreadDelay = e_data.sw_dreadDelay or 0
    if e_data.sw_dreadDelay > 0
    and e_data.sw_dreadStacks <= 1 then
        return
    end
    if e_data.sw_dreadStacks > 0
    and not takingDreadDMG then
        takingDreadDMG = true
        ent:TakeDamage(amount * 3, flags, source, dmgCooldown)
        takingDreadDMG = false

        e_data.sw_dreadStacks = e_data.sw_dreadStacks - 1
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_DREAD_POOF, 0, ent.Position + Vector(0, 10), Vector.Zero, ent)
        effect.SpriteOffset = Vector(0, -ent.Size)
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnEnemyTakeDMG)

function mod:DreadStatusUpdate(ent)
    local e_data = ent:GetData()
    e_data.sw_dreadDelay = e_data.sw_dreadDelay or 0
    if e_data.sw_dreadDelay > 0 then 
        e_data.sw_dreadDelay = e_data.sw_dreadDelay - 1
    end

    e_data.sw_dreadStacks = e_data.sw_dreadStacks or 0
    if e_data.sw_dreadStacks > 0 then
        ent:SetColor(mod.DreadStatusColor, 2, 1, false, false)
    end
end