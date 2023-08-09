local mod = SomethingWicked

local function NPCUpdate(_, npc)
    local e_data = npc:GetData()
    if not e_data.somethingWicked_electroStun
    or not e_data.somethingWicked_electroStunParent then
        return
    end

    if npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
        npc:SetColor(mod.ElectroStunStatusColor, 2, 3, false, false)

        if npc.FrameCount % 6 == 1 then
            local parent = e_data.somethingWicked_electroStunParent
            local lightning = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_LIGHTNING, 0, npc.Position, Vector.Zero, parent)
            lightning.CollisionDamage = parent.CollisionDamage / 5
            lightning.Color = mod.ElectroStunStatusColor
            lightning.Parent = parent

            lightning:GetSprite().Color = mod.ElectroStunStatusColor
            local l_data = lightning:GetData()
            l_data.somethingWicked_electroStunLightning = true
            
            local p_data = parent:GetData()
            p_data.somethingWicked_applyingElectroStunLightning = true
        end
    else
        e_data.somethingWicked_electroStun = false
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, NPCUpdate)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, ent)
    if ent.Variant == EffectVariant.CHAIN_LIGHTNING then
        local l_data = ent:GetData()
        if l_data.somethingWicked_electroStunLightning then
            
            local p_data = ent.Parent:GetData()
            p_data.somethingWicked_applyingElectroStunLightning = false
        end
        
    end
end, EntityType.ENTITY_EFFECT)

local function PreventLightningDMG(_, entity, amount, flags, source, cooldown)
    entity = entity:ToNPC()
    if not entity then
        return
    end
    local sourceEnt = source.Entity
    if not sourceEnt then
        return
    end
    sourceEnt = sourceEnt:ToPlayer()
    if not sourceEnt then
        return
    end

    local se_data = sourceEnt:GetData()
    if se_data.somethingWicked_applyingElectroStunLightning
    and amount < 0.11 and amount > 0.1 then
        local e_data = entity:GetData()
        if not e_data.somethingWicked_electroStun then
            entity:TakeDamage(sourceEnt.Damage / 5, flags, source, cooldown)
        end
        return false  
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, PreventLightningDMG)