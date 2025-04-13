local mod = SomethingWicked

local procChance = 0.2
local color = mod.HolySpiritColor
local invTime = 30
function mod:holySpiritCollisionLogic(proj, player)
    player = player:ToPlayer()
    if not player then
        return
    end
    
    local pr_data = proj:GetData()
    if pr_data.trt_isHolySpiritProj then
        --player:SetMinDamageCooldown(40)
        player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, invTime-(player:GetData().sw_holySpiritTick or 0))
        player:GetData().sw_holySpiritTick = invTime
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        proj:Remove()
        return true
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.EARLY, mod.holySpiritCollisionLogic)

function mod:holySpiritUpdateLogic(proj)
    local p_data = proj:GetData()
    if proj.FrameCount == 1 then
        local player = PlayerManager.FirstCollectibleOwner(mod.ITEMS.HOLY_SPIRIT)
        if player then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.HOLY_SPIRIT)
            if c_rng:RandomFloat() < procChance then
                p_data.trt_isHolySpiritProj = true
                --p_data.sw_homeOntoMe = player
                proj:AddProjectileFlags(ProjectileFlags.SMART)
                proj:ClearProjectileFlags(ProjectileFlags.EXPLODE | ProjectileFlags.GODHEAD)
                proj.CurvingStrength = 0.3
            end
        end
    end
    if p_data.trt_isHolySpiritProj then
        proj:SetColor(color, 2, 5, false, false)

        --[[local p = p_data.sw_homeOntoMe
        if p.Position:Distance(proj.Position) < 80 then
            if not p_data.resetMeVel then
                proj.Velocity = proj.Velocity * 2
                p_data.resetMeVel = true
            end
            mod:AngularMovementFunction(proj, p.Position + p.Velocity, proj.Velocity:Length(), variance, lerp)
        elseif p_data.resetMeVel then
            p_data.resetMeVel = false
            proj.Velocity = proj.Velocity / 2
        end]]
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, mod.holySpiritUpdateLogic)

local function pEffect(_, player)
    local p_data = player:GetData()
    if p_data.sw_holySpiritTick then
        p_data.sw_holySpiritTick = math.max(p_data.sw_holySpiritTick-1, 0)
        if p_data.sw_holySpiritTick == 0 then
            p_data.sw_holySpiritTick = nil
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, pEffect)