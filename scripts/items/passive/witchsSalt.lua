local mod = SomethingWicked

local function procChance(player) 
    return 1 + (player.Luck / 10)
end

local speedMult = 0.07 local dmgMult = 4
local stacksNeededToDoShit = 4
local function HitEnemy(_, tear, enemy, p)
    if enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        return
    end

    local e_data = enemy:GetData()
    if e_data.sw_blackSaltDamage then
        e_data.sw_blackSaltDamage = math.max(e_data.sw_blackSaltDamage, tear.CollisionDamage)
    else
        e_data.sw_blackSaltDamage = tear.CollisionDamage
    end
    e_data.sw_blackSaltDMGer = p

    if e_data.sw_blackSaltStacks < stacksNeededToDoShit then
        enemy.Friction = enemy.Friction - speedMult
        e_data.sw_blackSaltStacks = (e_data.sw_blackSaltStacks or 0) + 1
        e_data.sw_blackSaltFriction = (e_data.sw_blackSaltFriction or 0) + speedMult
    end
end

mod:AddNewTearFlag(SomethingWicked.CustomTearFlags.FLAG_WITCHS_SALT, {
    ApplyLogic = function (_, player)
        if player:HasCollectible(mod.ITEMS.WITCHS_SALT) then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.WITCHS_SALT)
            if c_rng:RandomFloat() < procChance(player) then
                return true
            end
        end
        return false
    end,
    EnemyHitEffect = function (_, tear, _, enemy, p)
        HitEnemy(_, tear, enemy, p)
    end,
    TearColor = Color(0.2, 0.2, 0.2, 0.8)
})

local deathTimer = 48
local function NPCUpdate(_, enemy)
    local e_data = enemy:GetData()
    e_data.sw_blackSaltStacks = (e_data.sw_blackSaltStacks or 0)
    if e_data.sw_blackSaltStacks > 0 then
        local colorMult = 1 - (e_data.sw_blackSaltStacks / 6)
        enemy:SetColor(Color(colorMult, colorMult, colorMult), 2, 2, false, false)
    end

    if e_data.sw_blackSaltDeathTimer then
        if not e_data.sw_blackSaltEffect then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.BLACK_SALT, 0, enemy.Position, Vector.Zero, enemy):ToEffect()
            effect.Parent = enemy
            effect.SpriteScale = Vector.One * (enemy.Size/10)
            effect.DepthOffset = 200
            effect:FollowParent(enemy)
            effect.SpriteOffset = Vector(0, -16)
            e_data.sw_blackSaltEffect = effect
        end

        e_data.sw_blackSaltDeathTimer = e_data.sw_blackSaltDeathTimer - 1
        if e_data.sw_blackSaltDeathTimer < 0 then
            enemy.Friction = enemy.Friction + e_data.sw_blackSaltFriction
            enemy:TakeDamage(e_data.sw_blackSaltDamage * dmgMult, 0, EntityRef(e_data.sw_blackSaltDMGer), 1)

            e_data.sw_blackSaltStacks = 0
            e_data.sw_blackSaltDamage = 0
            e_data.sw_blackSaltDeathTimer = nil
            e_data.sw_blackSaltEffect = nil
        end
        return
    end
    if e_data.sw_blackSaltStacks >= stacksNeededToDoShit then
        e_data.sw_blackSaltDeathTimer = deathTimer
    end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_NPC_EFFECT_TICK, NPCUpdate)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, salt)
    local parent = salt.Parent
    if parent ~= nil and parent:Exists() then
        local p_data = parent:GetData()
        if p_data.sw_blackSaltDeathTimer then
            return
        end
    end

    local sprite = salt:GetSprite()
    sprite:Play("Poof")
    if sprite:IsFinished("Poof") then
        salt:Remove()
    end
end, mod.EFFECTS.BLACK_SALT)