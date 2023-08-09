
local mod = SomethingWicked
local takingDreadDMG = false
local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    e_data.somethingWicked_dreadStacks = e_data.somethingWicked_dreadStacks or 0
    e_data.somethingWicked_dreadDelay = e_data.somethingWicked_dreadDelay or 0
    if e_data.somethingWicked_dreadDelay > 0
    and e_data.somethingWicked_dreadStacks <= 1 then
        return
    end
    if e_data.somethingWicked_dreadStacks > 0
    and not takingDreadDMG then
        takingDreadDMG = true
        ent:TakeDamage(amount * 3, flags, source, dmgCooldown)
        takingDreadDMG = false

        e_data.somethingWicked_dreadStacks = e_data.somethingWicked_dreadStacks - 1
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_DREAD_POOF, 0, ent.Position + Vector(0, 10), Vector.Zero, ent)
        effect.SpriteOffset = Vector(0, -ent.Size)
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnEnemyTakeDMG)

local function NPCUpdate(_, ent)
    local e_data = ent:GetData()
    e_data.somethingWicked_dreadDelay = e_data.somethingWicked_dreadDelay or 0
    if e_data.somethingWicked_dreadDelay > 0 then 
        e_data.somethingWicked_dreadDelay = e_data.somethingWicked_dreadDelay - 1
    end

    e_data.somethingWicked_dreadStacks = e_data.somethingWicked_dreadStacks or 0
    if e_data.somethingWicked_dreadStacks > 0 then
        ent:SetColor(mod.DreadStatusColor, 2, 1, false, false)
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, NPCUpdate)