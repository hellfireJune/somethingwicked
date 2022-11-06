local this = {}
CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE = Isaac.GetItemIdByName("Plasma Globe")
this.Color = Color(1, 1, 1, 1, 0.5, 0.82, 1)

this.baseProcChance = 0.2
local function ProcChance(player)
    return (player.Luck >= 0 and (this.baseProcChance * ((player.Luck + 0.5) / 2)) or (this.baseProcChance / math.abs(player.Luck)))
end
function this:FireTear(tear)
    local p = SomethingWicked:UtilGetPlayerFromTear(tear)

    if p and p:HasCollectible(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) then
        local rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) 
        if rng:RandomFloat() > ProcChance(p) then
            return
        end
        tear.Color = tear.Color * this.Color

        local t_data = tear:GetData()
        t_data.somethingWicked_applyingElectroStun = true
    end
end

function this:ApplyEffect(tear, enemy, player)
    enemy = enemy:ToNPC()
    if not enemy then
        return
    end

    if enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        return
    end

    local t_data = tear:GetData()

    if t_data.somethingWicked_applyingElectroStun then
        enemy:AddConfusion(EntityRef(player), 60, false)

        local e_data = enemy:GetData()
        e_data.somethingWicked_electroStun = true
        e_data.somethingWicked_electroStunParent = player
    end
end

function this:NPCUpdate(npc)
    local e_data = npc:GetData()
    if not e_data.somethingWicked_electroStun
    or not e_data.somethingWicked_electroStunParent then
        if e_data.somethingWicked_electroStun then
            print("a")
        elseif e_data.somethingWicked_electroStunParent then
            print("b")
        end
        return
    end

    if npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
        npc:SetColor(this.Color, 2, 3, false, false)

        if npc.FrameCount % 6 == 1 then
            local parent = e_data.somethingWicked_electroStunParent
            local lightning = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_LIGHTNING, 0, npc.Position, Vector.Zero, parent)
            lightning.CollisionDamage = parent.CollisionDamage / 5
            lightning.Color = this.Color
            lightning.Parent = parent

            lightning:GetSprite().Color = this.Color
            local l_data = lightning:GetData()
            l_data.somethingWicked_electroStunLightning = true
            
            local p_data = parent:GetData()
            p_data.somethingWicked_applyingElectroStunLightning = true
        end
    else
        e_data.somethingWicked_electroStun = false
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (ent)
    if ent.Variant == EffectVariant.CHAIN_LIGHTNING then
        local l_data = ent:GetData()
        if l_data.somethingWicked_electroStunLightning then
            
            local p_data = ent.Parent:GetData()
            p_data.somethingWicked_applyingElectroStunLightning = false
        end
        
    end
end, EntityType.ENTITY_EFFECT)

function this:PreventLightningDMG(entity, amount, flags, source, cooldown)
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

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.PreventLightningDMG)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.ApplyEffect)

this.EIDEntries = {}
return this