local mod = SomethingWicked
local curseDuration = 5.5

local function PlayerUpdate(_, player)
    if mod:HoldItemUpdateHelper(player, mod.ITEMS.CURSED_CANDLE) then
        local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, mod.WickedFireSubtype, player.Position, mod:GetFireVector(player):Resized(18), player)
        fire = fire:ToEffect()
        fire.Timeout = 20
        fire.CollisionDamage = 5
    end
end

local function OnEnemyTakeDMG(_, ent, amount, flags, source, dmgCooldown)
    local e_data = ent:GetData()
    local fire = source.Entity

    if fire ~= nil
    and fire.Type == EntityType.ENTITY_EFFECT
    and fire.Variant == EffectVariant.BLUE_FLAME
    and fire.SubType == mod.WickedFireSubtype then
        if e_data.sw_curseDuration and e_data.sw_curseDuration > 0
        then
            return false
        end
        --[[local fireSprite = fire:GetSprite()
        fireSprite:Play("Disappear")
        fire.CollisionDamage = 0]]--

        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            SomethingWicked:UtilAddCurse(ent, curseDuration)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, OnEnemyTakeDMG)


local function OnWispDie(_, entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == mod.ITEMS.CURSED_CANDLE then
        local smolFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, mod.WickedFireSubtype, entity.Position, Vector.Zero, entity):ToEffect()
        smolFire.Timeout = 15
        smolFire.SpriteScale = Vector(0.75, 0.75)
    end
end

local function RemoveWisps()
    local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.CURSED_CANDLE)
    if wisps ~= nil and #wisps > 0 then
        for _, wisp in ipairs(wisps) do
            wisp:Remove()
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RemoveWisps)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, OnWispDie, EntityType.ENTITY_FAMILIAR)