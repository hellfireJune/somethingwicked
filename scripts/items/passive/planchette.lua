local mod = SomethingWicked

function mod:IsPlanchetteFamiliar(familiar)
    return mod:UtilTableHasValue(mod.PlanchetteFamiliars, familiar.Variant)
end

local function heal(familiar)
    familiar.MaxHitPoints = familiar.MaxHitPoints * 2
    familiar:AddHealth(familiar.MaxHitPoints/2)
end
local function BuffFamiliarHP(_, familiar)
    if not mod:IsPlanchetteFamiliar(familiar) then
        return
    end

    local player = familiar.Player
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_PLANCHETTE) then
        if familiar.FrameCount == 5 and familiar.MaxHitPoints > 0 then
            heal(familiar)
        end
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
            familiar.SpriteScale = Vector(1.2, 1.2)
        end
    end
end

local function WispFire(_, tear)
    local spawner = tear.SpawnerEntity
    if spawner then
        spawner = spawner:ToFamiliar()
        if not spawner or not mod:IsPlanchetteFamiliar(spawner) then
            return
        end
        local p = spawner.Player
        if p and p:HasCollectible(CollectibleType.SOMETHINGWICKED_PLANCHETTE) then
            tear.Scale = tear.Scale * 1.2
            tear.CollisionDamage = tear.CollisionDamage * 2
        end
    end
end

local function PlanchetteOnPickup(_, player)
    local p_hash = GetPtrHash(player)

    local currentFamiliars = Isaac.FindByType(EntityType.ENTITY_FAMILIAR)
    for _, familiar in ipairs(currentFamiliars) do
        if mod:IsPlanchetteFamiliar(familiar) then
            local p = familiar.Player
            if p and p_hash == GetPtrHash(p) then
                heal(familiar)
            end
        end
    end

    for i = 1, 4, 1 do
        player:AddWisp(CollectibleType.SOMETHINGWICKED_PLANCHETTE, player.Position)
    end
end

local preDmgFlag = false
local function PreEntityTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    if not ent or preDmgFlag then
        return
    end
    local e = ent:ToNPC()
    if not e then
        return
    end

    local s = source.Entity
    if not s then
        return
    end
    s = s:ToFamiliar()
    if not s or not mod:IsPlanchetteFamiliar(s) then
        return
    end

    preDmgFlag = true
    ent:TakeDamage(amount*2, flags, EntityRef(s), dmgCooldown)
    preDmgFlag = false
    return false
end

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, PreEntityTakeDMG)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, WispFire)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BuffFamiliarHP)
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, PlanchetteOnPickup, CollectibleType.SOMETHINGWICKED_PLANCHETTE)