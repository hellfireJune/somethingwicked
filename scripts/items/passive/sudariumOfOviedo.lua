local mod = SomethingWicked

local isProjDMG = false
local function preDMG(_, player)
    if not player:HasCollectible(mod.ITEMS.SUDARIUM) then
        return
    end

    local ceffects = player:GetEffects()
    local p_data = player:GetData()

    if player:IsInvincible() or player:HasInvincibility() then
        return
    end
    if player:GetDamageCooldown() > 0 then
        return
    end

    p_data.sw_doSudarium = true
    p_data.sw_isMantleSudarium = ceffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
    p_data.sw_sudariumIsProj = isProjDMG
    isProjDMG = false
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, CallbackPriority.EARLY, preDMG)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.IMPORTANT, function (_, proj, player)
    player = player:ToPlayer()
    if player then
        isProjDMG = true
        preDMG(_, player)
    end
end)

function mod:sudariumPostDMG(player)
    local p_data = player:GetData()
    
    p_data.sw_doSudarium = nil
end

function mod:sudariumPeffectUpdate(player)
    local p_data = player:GetData()

    if p_data.sw_mantleSudariumFrames then
        local queueEval = false
        if p_data.sw_mantleSudariumFrames ~= 0 then
            queueEval = true
        end
        p_data.sw_mantleSudariumFrames = math.max(p_data.sw_mantleSudariumFrames-1, 0)
        if queueEval then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
    if p_data.sw_doSudarium then
        p_data.sw_doSudarium = nil
        
        if not player:IsInvincible() and not player:HasInvincibility() and player:GetDamageCooldown() == 0
        and not isProjDMG then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CONE_HEAD) then
                local cParams = player:GetColorParams()
                for index, value in ipairs(cParams) do
                    if value:GetDuration() == 10 and value:GetLifespan() >= 9 then
                        goto continue
                    end
                end
            end
        end
        ::continue::
        
        if p_data.sw_isMantleSudarium then
            local ceffects = player:GetEffects()
            if ceffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
                return
            end
            p_data.sw_mantleSudariumFrames = (p_data.sw_mantleSudariumFrames or 0) + 60
        else
            p_data.WickedPData.sudariumRooms = math.min(6*3, (p_data.WickedPData.sudariumRooms or 0) + 6)
            player:SetMinDamageCooldown(150)
        end
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
    end
end
mod:AddPeffectCheck(function (p)
    return p:HasCollectible(mod.ITEMS.SUDARIUM) or p:GetData().sw_mantleSudariumFrames ~= nil
end, mod.sudariumPeffectUpdate)

function mod:sudariumNewRoom(player)
    local p_data = player:GetData()
    p_data.sw_mantleSudariumFrames = nil
    if p_data.WickedPData.sudariumRooms then
        p_data.WickedPData.sudariumRooms = p_data.WickedPData.sudariumRooms - 1
        if p_data.WickedPData.sudariumRooms >= 0 then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        else
            p_data.WickedPData.sudariumRooms = nil
        end
    end
end