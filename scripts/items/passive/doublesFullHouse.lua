local mod = SomethingWicked

local function postFire(_, shooter, _, _, player)
    local p_data = player:GetData()
    local weapon = player:GetWeapon(1)
    if shooter.Type ~= EntityType.ENTITY_PLAYER then
        local familiar = shooter:ToFamiliar()
        if familiar then
            weapon = familiar:GetWeapon()
        end
    end
    
    if p_data.sw_doublesBonus then
        local mult = (1-(math.log(p_data.sw_doublesBonus, 10)))/0.89
        weapon:SetFireDelay((weapon:GetFireDelay()/mult)*0.456)
    end
    p_data.sw_resetVolley = true
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, postFire)

local function pEffectUpdate(_, player)
    local p_data = player:GetData()
    if p_data.sw_resetVolley == true then
        p_data.sw_resetVolley = nil
        
        if player:HasCollectible(mod.ITEMS.FULL_HOUSE) then
            p_data.sw_fullHouseBonus = (p_data.sw_fullHouseBonus or 1) == 2 and 1 or 2
        else
            p_data.sw_fullHouseBonus = nil
        end
        if p_data.sw_doublesBonus then
            p_data.sw_doublesBonus = nil
        end
        if player:HasCollectible(mod.ITEMS.DOUBLES) then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.DOUBLES)
            p_data.sw_doublesBonus = c_rng:RandomInt(1,6)
        end
        p_data.sw_weaponsToBone = {}
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, pEffectUpdate)
 
local function getVolleySize(_, player)
    local weapon = player:GetWeapon(1)
    if weapon then
        local type = weapon:GetWeaponType()
        local params = player:GetMultiShotParams(type)
        local p_data = player:GetData()
        
        local tears = (p_data.sw_doublesBonus or 1)-1 + (p_data.sw_fullHouseBonus or 0)
        if tears > 0 then
            params:SetNumTears(params:GetNumTears()+tears)
            params:SetNumLanesPerEye(params:GetNumLanesPerEye()+tears)
            if tears >= 2 then
                local a = tears
                if type == WeaponType.WEAPON_BONE then
                    a=a*10
                end
                params:SetSpreadAngle(type, a)
            end
        end
        return params
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, getVolleySize)