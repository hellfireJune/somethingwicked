local mod = SomethingWicked

local applyingElectroStunLightning = nil
local setOnceMore = false
function mod:ElectroStunStatusUpdate(npc)
    local e_data = npc:GetData()
    if not e_data.sw_electroStun
    or not e_data.sw_electroStunParent then
        return
    end

    e_data.sw_electroStunDuration= e_data.sw_electroStunDuration- 1
    if e_data.sw_electroStunDuration< 0 then
        if e_data.sw_removeConfusedWhenDone then
            npc:ClearEntityFlags(EntityFlag.FLAG_CONFUSION)
        end
        e_data.sw_electroStunDuration= nil
        e_data.sw_electroStunParent = nil

        return
    end

    if npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
        npc:SetColor(mod.ElectroStunStatusColor, 2, 3, false, false)

        if e_data.sw_electroStunDuration% 6 == 0 then
            local parent = e_data.sw_electroStunParent
            local lightning = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_LIGHTNING, 0, npc.Position, Vector.Zero, nil)
            lightning.CollisionDamage = parent.Damage / 5
            --lightning.Color = mod.ElectroStunStatusColor
            --lightning.Parent = parent

            --lightning:GetSprite().Color = mod.ElectroStunStatusColor
            --[[local l_data = lightning:GetData()
            l_data.sw_electroStunLightning = true]]
            
            applyingElectroStunLightning = npc
            setOnceMore = true

            --lightning:Update()
            --[[mod:UtilScheduleForUpdate(function ()
                
            
            for in
            alue in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
                print(value.FrameCount)
                if value.FrameCount <= 1 then
                    local l_data = laser:GetData()
                    if applyingElectroStunLightning then
                        l_data.sw_electroStunHost = applyingElectroStunLightning
                        applyingElectroStunLightning = nil
                    end
                end
            end
            end, 0)]]
        end
    else
        npc:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
        e_data.sw_removeConfusedWhenDone = true
    end
end

mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function (_, laser)
    local l_data = laser:GetData()
    if applyingElectroStunLightning then
        l_data.sw_electroStunHost = applyingElectroStunLightning
        applyingElectroStunLightning = nil
    end
end)

local function PreventLightningDMG(_, entity, amount, flags, source, cooldown)
    entity = entity:ToNPC()
    if not entity then
        return
    end
    local sourceEnt = source.Entity
    if not sourceEnt then
        return
    end
    local l_data = sourceEnt:GetData()
    local e = l_data.sw_electroStunHost
    if not e then
        return
    end

    if e.Index == entity.Index then
        --l_data.sw_electroStunHost = entity
        if setOnceMore then
            applyingElectroStunLightning = e
            setOnceMore = false
        end

        return false
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, PreventLightningDMG)