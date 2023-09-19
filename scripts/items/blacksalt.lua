local mod = SomethingWicked

local function procChance(player) 
    return 1 + (player.Luck / 10)
end

local speedMult = 0.06 local dmgMult = 5
local stacksNeededToDoShit = 5 local stacksNeededToSlow = 2
local gracePeriod = 18
local function HitEnemy(_, _, tear, enemy)
    if enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        return
    end

    local e_data = enemy:GetData()
    e_data.sw_blackSaltStacks = (e_data.sw_blackSaltStacks or 0) + 1
    
    if e_data.sw_blackSaltDamage then
        e_data.sw_blackSaltDamage = math.max(e_data.sw_blackSaltDamage, tear.CollisionDamage)
    else
        e_data.sw_blackSaltDamage = tear.CollisionDamage
    end

    if e_data.sw_blackSaltStacks <= stacksNeededToDoShit
    and e_data.sw_blackSaltStacks > stacksNeededToSlow then
        enemy.Friction = enemy.Friction - speedMult
        e_data.sw_blackSaltFriction = (e_data.sw_blackSaltFriction or 0) + speedMult
    end
end

mod:AddNewTearFlag(SomethingWicked.CustomTearFlags.FLAG_BLACK_SALT, {
    ApplyLogic = function (_, player)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_BLACK_SALT) then
            local c_rng = player:GetCollectible(CollectibleType.SOMETHINGWICKED_BLACK_SALT)
            if c_rng:RandomFloat() < procChance(player) then
                return true
            end
        end
        return false
    end,
    EnemyHitEffect = function (_, _, _, enemy)
        HitEnemy(_, _, enemy)
    end,
    TearColor = Color(0.2, 0.2, 0.2, 0.8)
})

local function NPCUpdate(_, enemy)
    local e_data = enemy:GetData()
    e_data.sw_blackSaltStacks = (e_data.sw_blackSaltStacks or 0)
    if e_data.sw_blackSaltStacks > 0 then
        --[[local colorMult = 1 - (e_data.sw_blackSaltStacks / 10)
        enemy:SetColor(Color(colorMult, colorMult, colorMult), 2, 2, false, false)]]
    end

    if e_data.sw_blackSaltDeathTimer then
        e_data.sw_blackSaltDeathTimer = e_data.sw_blackSaltDeathTimer - 1
        if e_data.sw_blackSaltDeathTimer <= 0 then
            enemy.Friction = enemy.Friction + e_data.sw_blackSaltFriction
            enemy:TakeDamage(e_data.sw_blackSaltDamage * dmgMult, 0, EntityRef(enemy), 1)

            e_data.sw_blackSaltStacks = 0
            e_data.sw_blackSaltDamage = 0
        end
        return
    end
    if e_data.sw_blackSaltStacks >= stacksNeededToDoShit then
        e_data.sw_blackSaltDeathTimer = 42
    end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_NPC_EFFECT_TICK, NPCUpdate)

local EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BLACK_SALT] = {
        desc = "",
    }
}