local mod = SomethingWicked

local velThreshold = 3
local dmgTick = 14 local pow = 0.8
local shadowTick = 17
local slowMult = 0.5
function mod:unfathomableDepthsTick(ent, args)
    if args.unfathomableDepths then
        local vel = ent.Velocity
        local mag = vel:Length()
        local moving = 1-(mag/velThreshold)

        local e_data = ent:GetData()
        local dmgVis = e_data.sw_depthsDmgVisibility or 0
        moving = math.max((dmgVis/dmgTick), moving)^pow

        e_data.sw_depthsLastAlpha = e_data.sw_depthsLastAlpha or 1
        ent:SetColor(ent.Color*Color(1,1,1,moving), 2, 276, false, true)
        e_data.sw_depthsLastAlpha = moving

        if e_data.sw_depthsDmgVisibility then
            e_data.sw_depthsDmgVisibility = math.max(0, e_data.sw_depthsDmgVisibility-1)
            if e_data.sw_depthsDmgVisibility == 0 then
                e_data.sw_depthsDmgVisibility = nil
            end
        end

        e_data.sw_shadowTick = (e_data.sw_shadowTick or 0) + (ent.Size/10)
        if e_data.sw_shadowTick >= shadowTick then
            local rFactor = (RandomVector()+Vector(0,-1))*ent.Size
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+Vector(0,-15)+rFactor, Vector(0, -6), ent)
            trail.Color = Color(0,0,0,(1-moving)*0.8)
            trail.SpriteScale = Vector.One*(ent.Size/20)
            e_data.sw_shadowTick = 0
        end
    end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_NPC_EFFECT_TICK, mod.unfathomableDepthsTick)

function mod:UnfathomableDepthsPostDMG(ent)
    local e_data = ent:GetData()
    if mod.GlobalEffectArgs.unfathomableDepths then
        if e_data.sw_depthsDmgVisibility == nil then
            ent:SetSpeedMultiplier(ent:GetSpeedMultiplier()*slowMult)
        end
        e_data.sw_depthsDmgVisibility = dmgTick
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function (_, ent)
    local e_data = ent:GetData()
    if e_data.sw_depthsDmgVisibility then
        ent:SetSpeedMultiplier(ent:GetSpeedMultiplier()*slowMult)
    end
end)