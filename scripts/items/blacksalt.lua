local this = {}
CollectibleType.SOMETHINGWICKED_BLACK_SALT = Isaac.GetItemIdByName("Black Salt")

local function procChance(player) 
    return 1 + (player.Luck / 10)
end
SomethingWicked.TFCore:AddNewFlagData(SomethingWicked.CustomTearFlags.FLAG_BLACK_SALT, {
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
        this:HitEnemy(_, _, enemy)
    end,
    TearColor = Color(0.2, 0.2, 0.2, 0.8)
})

local speedMult = 0.12
local stacksNeededToDoShit = 4
local dmgMult = 5
function this:HitEnemy(_, tear, enemy)
    if enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        return
    end

    local e_data = enemy:GetData()
    e_data.somethingWicked_blackSaltStacks = (e_data.somethingWicked_blackSaltStacks or 0) + 1
    
    if e_data.somethingWicked_blackSaltDamage then
        e_data.somethingWicked_blackSaltDamage = math.max(e_data.somethingWicked_blackSaltDamage, tear.CollisionDamage)
    else
        e_data.somethingWicked_blackSaltDamage = tear.CollisionDamage
    end

    if e_data.somethingWicked_blackSaltStacks == 1 then
        e_data.somethingWicked_blackSaltSavedFriction = enemy.Friction
    end
    if e_data.somethingWicked_blackSaltStacks <= stacksNeededToDoShit then
        enemy.Friction = enemy.Friction - speedMult
    end
end

function this:NPCUpdate(enemy)
    local e_data = enemy:GetData()
    e_data.somethingWicked_blackSaltStacks = (e_data.somethingWicked_blackSaltStacks or 0)
    if e_data.somethingWicked_blackSaltStacks > 0 then
        local colorMult = 1 - (e_data.somethingWicked_blackSaltStacks / 10)
        enemy:SetColor(Color(colorMult, colorMult, colorMult), 2, 2, false, false)
    end

    if e_data.somethingWicked_blackSaltDeathTimer then
        e_data.somethingWicked_blackSaltDeathTimer = e_data.somethingWicked_blackSaltDeathTimer - 1
        if e_data.somethingWicked_blackSaltDeathTimer <= 0 then
            enemy.Friction = enemy.Friction + (speedMult * e_data.somethingWicked_blackSaltStacks)
            enemy:TakeDamage(e_data.somethingWicked_blackSaltDamage * dmgMult, 0, EntityRef(enemy), 1)

            e_data.somethingWicked_blackSaltStacks = 0
            e_data.somethingWicked_blackSaltDamage = 0
        end
        return
    end
    if e_data.somethingWicked_blackSaltStacks >= stacksNeededToDoShit then
        e_data.somethingWicked_blackSaltDeathTimer = 10
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)

this.EIDEntries = {}
return this