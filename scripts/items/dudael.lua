local mod = SomethingWicked
local game = Game()

local frameCooldown = 15
local maxGhosts = 7
function this:OnEnemyDMGGeneric(tear, collider, player, proc)
    if not player:HasCollectible(mod.ITEMS.DUDAEL) then
        return
    end

    local e_data = collider:GetData()
    e_data.somethingWicked_dudaelFrames = e_data.somethingWicked_dudaelFrames or 0

    local p_frames = player.FrameCount
    if p_frames - e_data.somethingWicked_dudaelFrames >= frameCooldown then
        e_data.somethingWicked_dudaelFrames = p_frames
    else
        return
    end

    local p_data = player:GetData()
    p_data.somethingWicked_dudaelGhosts = p_data.somethingWicked_dudaelGhosts or {}
    if p_data.somethingWicked_dudaelGhosts[maxGhosts] then
        p_data.somethingWicked_dudaelGhosts[maxGhosts]:Remove()
        p_data.somethingWicked_dudaelGhosts[maxGhosts] = nil
    end

    local newMagicGhost = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_DUDAEL_GHOST, 0, collider.Position, RandomVector() * 30, player):ToFamiliar()
    newMagicGhost.Player = player
    newMagicGhost.Target = collider
    newMagicGhost:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    table.insert(p_data.somethingWicked_dudaelGhosts, 1, newMagicGhost)
    
    for index, value in ipairs(p_data.somethingWicked_dudaelGhosts) do
        value.Hearts = index
    end
end
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.OnEnemyDMGGeneric)

function this:UseItem(_, _, player)
    local p_data = player:GetData()
    p_data.somethingWicked_dudaelGhosts = p_data.somethingWicked_dudaelGhosts or {}
    for _, familiar in ipairs(p_data.somethingWicked_dudaelGhosts) do
        familiar.State = 2
    end
    p_data.somethingWicked_dudaelGhosts = {}
    return true
end
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, mod.ITEMS.DUDAEL)

local moveSpeed = 40
local distanceTillIdle = 80
function this:FamiliarUpdate(familiar)
    if game:GetRoom():GetFrameCount() == 0 then
        familiar:Remove()
        return
    end

    if familiar.Target == nil or not familiar.Target:Exists() then
        --make dissipate
        familiar:Remove()
        return
    end

    local targetPos = familiar.Target.Position
    local fPos = familiar.Position
    if familiar.State ~= 1 then
        local direction = (fPos - targetPos)
        if familiar.State == 2 then
            direction = direction*-1
        end
        direction:Normalized()
        if fPos:Distance(targetPos) < distanceTillIdle or familiar.State == 2 then
            familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(familiar.Velocity, direction * moveSpeed, 0.1)
            return
        else
            familiar.State = 1
        end
    end
    familiar.Velocity = SomethingWicked.EnemyHelpers:Lerp(familiar.Velocity, Vector.Zero, 0.2)
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_DUDAEL_GHOST)

function this:FamiliarCollision(familiar, collider)
    collider = collider:ToNPC()
    if not collider then
        return false
    end

    if familiar.State == 2 then

        if GetPtrHash(familiar.Target) == GetPtrHash(collider) then
            --make this user explode
            local player = familiar.Player
            game:BombExplosionEffects(familiar.Position, player.Damage * 3, TearFlags.TEAR_NORMAL, Color(1, 0, 0, 1, 0.5), familiar, 0.5)
            familiar:BloodExplode()
            familiar:Remove()
            return
        end
    else
        return true
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, this.FamiliarCollision, FamiliarVariant.SOMETHINGWICKED_DUDAEL_GHOST)