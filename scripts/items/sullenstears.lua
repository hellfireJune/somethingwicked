local this = {}
CollectibleType.SOMETHINGWICKED_SULLENS_TEARS = Isaac.GetItemIdByName("Sullen's Tears")

local function proc(player)
    return 1
end
function this:FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if not player or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_SULLENS_TEARS) then
        return
    end

    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SULLENS_TEARS)
    if c_rng:RandomFloat() < proc(player) then
        local t_data = tear:GetData()
        t_data.somethingWicked_willdoSullensTearCreep = true
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

function this:OnEnemyHit(tear, collider, player, procChance)
    local shouldSpawn = false
    if tear.Type == EntityType.ENTITY_TEAR then
        local t_data = tear:GetData()
        shouldSpawn = t_data.somethingWicked_willdoSullensTearCreep or false
    elseif player:HasCollectible(CollectibleType.SOMETHINGWICKED_SULLENS_TEARS) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SULLENS_TEARS)
        shouldSpawn = c_rng:RandomFloat() < proc(player)
    end

    if shouldSpawn then
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, collider.Position, Vector.Zero, player)

        effect.SpriteScale = Vector(1.5, 1.5)
        effect:Update()

        effect:GetData()["somethingWicked_isCurseCreep"] = true
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.OnEnemyHit)

function this:OnEnemyDMG(ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    local fire = source.Entity

    if fire ~= nil
    and fire.Type == EntityType.ENTITY_EFFECT
    and fire.Variant == EffectVariant.PLAYER_CREEP_GREEN
    and fire:GetData()["somethingWicked_isCurseCreep"]  then
        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            e_data.somethingWicked_dreadStacks = math.max(1, e_data.somethingWicked_dreadStacks or 0)
        end
        
        return false
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnEnemyDMG)
this.EIDEntries = {}
return this