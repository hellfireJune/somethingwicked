
local mod = SomethingWicked

function mod:DreadStatusUpdate(ent)
    local e_data = ent:GetData()
    if e_data.sw_dreadDuration then
        e_data.sw_dreadDuration = e_data.sw_dreadDuration - 1
        if e_data.sw_dreadDuration == 0 then
           e_data.sw_dreadDuration = nil
           e_data.sw_currentDreadTimer = nil
           e_data.sw_dreadCountdown = nil
           e_data.sw_minotaurPrimed = nil
        else
            e_data.sw_timesDreadHit = e_data.sw_timesDreadHit or 0
            if e_data.sw_dreadCountdown == nil then
                e_data.sw_dreadCountdown = 20
            end
            e_data.sw_currentDreadTimer = (e_data.sw_currentDreadTimer or -15)
            e_data.sw_dreadCountdown = e_data.sw_dreadCountdown - 1
            e_data.sw_dreadoffsettimer = math.max((e_data.sw_dreadoffsettimer or 0) - 1, 0)
            if e_data.sw_dreadoffsettimer == 0 then
                if  e_data.sw_dreadBounceBack then
                    e_data.sw_dreadIconOffset = e_data.sw_dreadIconOffset * -0.5
                    e_data.sw_dreadBounceBack = false
                else
                    e_data.sw_dreadIconOffset = 0
                end
            else
                e_data.sw_dreadIconOffset=e_data.sw_dreadIconOffset*4/3
            end
            if e_data.sw_dreadCountdown <= 0 then
                if e_data.sw_dreadPlayer ~= nil then
                    local dmg = e_data.sw_dreadPlayer:GetTearPoisonDamage()
                    ent:TakeDamage(dmg, DamageFlag.DAMAGE_POISON_BURN, EntityRef(e_data.sw_dreadPlayer), 0)
                end
                e_data.sw_dreadIconOffset = ((e_data.sw_lastDreadIconOffset or 0) > 0 and -1 or 1)*math.max(1,e_data.sw_dreadStrength)*0.75
                e_data.sw_lastDreadIconOffset = e_data.sw_dreadIconOffset
                e_data.sw_dreadoffsettimer = 2
                e_data.sw_dreadBounceBack = true
                e_data.sw_dreadCountdown = nil
            else 
                e_data.sw_dreadStrength = math.min(math.max(0,e_data.sw_currentDreadTimer)/30, 20/3)
                e_data.sw_dreadCountdown = e_data.sw_dreadCountdown - e_data.sw_dreadStrength
            end 
            e_data.sw_currentDreadTimer = e_data.sw_currentDreadTimer+ 1
        end
    end
end

function mod:PostDreadNormalDMG(ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    if not e_data.sw_minotaurPrimed then
        return
    end
    if flags & DamageFlag.DAMAGE_POISON_BURN ~= 0 then
        return
    end
    local p = source.Entity
    if not p then
        return
    elseif p:ToPlayer() == nil then
        if p.Parent and p.Parent:ToPlayer() then
            p = p.Parent
        elseif p.SpawnerEntity and p.SpawnerEntity:ToPlayer() then
            p = p.SpawnerEntity
        else
            return
        end
    end
    p = p:ToPlayer()

    local duration = 2
    if e_data.sw_dreadDuration then
        duration = 0.333
    end
    mod:UtilAddDread(ent, duration, p)
end