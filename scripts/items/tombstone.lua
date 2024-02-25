local this = {}

local function procChance(player)
    return 1
end
function this:OnKillzEnemy(enemy)
    enemy = enemy:ToNPC()
    if not enemy or not enemy:IsEnemy() then
        return
    end

    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(mod.ITEMS.TOMBSTONE)
    if flag and player then
        local c_rng = player:GetCollectibleRNG(mod.ITEMS.TOMBSTONE)
        if c_rng:RandomFloat() < procChance(player) then
            local tombStone = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_TOMBSTONE, 0, enemy.Position, Vector.Zero, player):ToEffect()
            tombStone.Parent = player

            tombStone:SetTimeout(300) -- 10 seconds
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnKillzEnemy)


local maxFogAlpha = 0.7 local minFogAlpha = 0.2
local radius = 120
local maxSpawnTimer = 15 local minSpawnTimer = 2
local maxFogLifeSpan = 120 local minFogLifeSpan = 35
local function getRandomFogSpawn(e_rng)
    local fogRadius = radius / 1.25
    return SomethingWicked.EnemyHelpers:Lerp(-fogRadius, fogRadius, e_rng:RandomFloat())
end

local windBlow = Vector(0.2, 0)
local dmg = 1
local coolDown = 15
function this:UpdateTombstone(effect)
    local e_data = effect:GetData()
    local e_rng = effect:GetDropRNG()

    e_data.somethingWicked_fogTimer = (e_data.somethingWicked_fogTimer or 
        math.ceil(SomethingWicked.EnemyHelpers:Lerp(minSpawnTimer, maxSpawnTimer, e_rng:RandomFloat()))) - 1

    if e_data.somethingWicked_fogTimer <= 0 then
        e_data.somethingWicked_fogTimer = nil
        local x = getRandomFogSpawn(e_rng) local y = getRandomFogSpawn(e_rng)

        local fog = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_THE_FOG_IS_COMING, 0, effect.Position + Vector(x, y), windBlow, effect):ToEffect()

        local f_data = fog:GetData()
        f_data.somethingWicked_fogAlpha = SomethingWicked.EnemyHelpers:Lerp(minFogAlpha, maxFogAlpha, e_rng:RandomFloat())
        fog:SetTimeout(math.floor(SomethingWicked.EnemyHelpers:Lerp(minFogLifeSpan, maxFogLifeSpan, e_rng:RandomFloat())))
        fog.Color = Color(1, 1, 1, 0)
    end
    
    e_data.sw_TombAttackCooldown = e_data.sw_TombAttackCooldown or 0
    if e_data.sw_TombAttackCooldown <= 0 then
        local enemies = Isaac.FindInRadius(effect.Position, radius, EntityPartition.ENEMY)
        for _, ent in ipairs(enemies) do
            if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                ent:AddSlowing(coolDown*1.25, EntityRef(effect), 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
            end

            ent:TakeDamage(dmg, 0, EntityRef(effect), 1)
            e_data.sw_TombAttackCooldown = coolDown
        end
    else
        e_data.sw_TombAttackCooldown = e_data.sw_TombAttackCooldown - 1
    end
end


function this:UpdateFog(effect)
    local e_data = effect:GetData()
    local spawner = effect.SpawnerEntity

    local shouldWeDissapear = effect.SpawnerEntity == nil
    if effect.SpawnerEntity then
        local distance = effect.Position:Distance(spawner.Position)
        shouldWeDissapear = distance > radius
    end

    local room = SomethingWicked.game:GetRoom()
    shouldWeDissapear = shouldWeDissapear or room:IsClear()
    shouldWeDissapear = shouldWeDissapear or effect.Timeout <= 0

    e_data.somethingWicked_additionalFogAlpha = e_data.somethingWicked_additionalFogAlpha or -1
    if shouldWeDissapear then
        e_data.somethingWicked_additionalFogAlpha = e_data.somethingWicked_additionalFogAlpha - 0.1
        if e_data.somethingWicked_additionalFogAlpha <= -1 then
            effect:Remove()
            return
        end
    elseif e_data.somethingWicked_additionalFogAlpha < 0 then
        e_data.somethingWicked_additionalFogAlpha = e_data.somethingWicked_additionalFogAlpha + 0.1
    end

    local newAlpha = e_data.somethingWicked_fogAlpha + e_data.somethingWicked_additionalFogAlpha
    effect.Color = Color(1, 1, 1, newAlpha)

    effect.Velocity = windBlow
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.UpdateTombstone, EffectVariant.SOMETHINGWICKED_TOMBSTONE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.UpdateFog, EffectVariant.SOMETHINGWICKED_THE_FOG_IS_COMING)

this.EIDEntries = {
    [mod.ITEMS.TOMBSTONE] = {
        desc = "oogly boogly",
        Hide = true,
    }
}
return this