local mod = SomethingWicked

--mod.EFFECTS.TEAR_HOLY_AURA

local auraRadius = 70

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_GODSTICKY, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.LIVING_WATER) then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.LIVING_WATER)
            if c_rng:RandomFloat() < 0.12 then
                return true
            end
        end
    end,
    PostApply = function (_, player, tear)
        if tear.Type == EntityType.ENTITY_TEAR then
            tear:AddTearFlags(TearFlags.TEAR_BOOGER)
        end
    end,
    OverrideTearUpdate = function (_, tear)
        local t_data = tear:GetData()
        local glow = tear.StickTarget ~= nil

        local effect = t_data.sw_stickyAura
        if glow and not effect then
            local neffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.TEAR_HOLY_AURA, 0, tear.Position, Vector.Zero, nil):ToEffect()
            neffect.Parent = tear
            neffect:FollowParent(tear)

            effect = neffect
            t_data.sw_stickyAura = effect
            effect:Update()
        end
        if glow and effect~=nil and effect:Exists() then
            tear.CollisionDamage = 0
            effect.PositionOffset = tear.PositionOffset
        end
    end,
    TearColor = Color(1,1,1,1,0.3,0.3,0.3)
})

local function EffectUpdate(_, effect)
    if effect.SubType ~= 0 then
        return
    end
    local p = effect.Parent
    if p then
        p = p:ToTear()
    end
    local e_sprite = effect:GetSprite()
    if p ~= nil and p.StickTarget ~= nil then   
        effect.SpriteScale = p.Scale*Vector.One

        local e_data = effect:GetData()
        e_data.sw_disNeeded = auraRadius*p.Scale 
        
        if e_sprite:IsFinished("Appear") then
            e_sprite:Play("Idle")
        end
    else
        e_sprite:Play("Disappear")
        if e_sprite:IsFinished("Disappear") then
            effect:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EffectUpdate, mod.EFFECTS.TEAR_HOLY_AURA)

local function PlayerUpdate(_, player)
    local auras = Isaac.FindByType(EntityType.ENTITY_EFFECT, mod.EFFECTS.TEAR_HOLY_AURA, 0)
    local num = 0
    for index, value in ipairs(auras) do
        local e_data = value:GetData()
        local dis = e_data.sw_disNeeded or auraRadius

        if player.Position:Distance(value.Position) < dis then
            num=num+1
        end
    end

    local p_data = player:GetData()
    local shouldEvaluate = p_data.sw_currentWaterAuras == num
    p_data.sw_currentWaterAuras = num
    if shouldEvaluate then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)