local this = {}
CollectibleType.SOMETHINGWICKED_BOLINE = Isaac.GetItemIdByName("Boline")

function this:ItemUse(_, _, player, flags)
    return SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, CollectibleType.SOMETHINGWICKED_BOLINE)
end
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.ItemUse, CollectibleType.SOMETHINGWICKED_BOLINE)

function this:PlayerUpdate(player)
    if SomethingWicked.HoldItemHelpers:HoldItemUpdateHelper(player, CollectibleType.SOMETHINGWICKED_BOLINE) then
        local direction = SomethingWicked.HoldItemHelpers:GetUseDirection(player) * 4
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MOTV_HELPER, 1, player.Position, direction, player)
        local void = Isaac.Spawn(EntityType.ENTITY_LASER, 1, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, player.Position, Vector.Zero, player):ToLaser()
        effect.Visible = false
        void.Parent = effect
        void.Radius = 80
        void.Timeout = 76
        void:AddTearFlags(TearFlags.TEAR_PULSE)
        void.CollisionDamage = player.Damage * 2
        SomethingWicked.sfx:Play(SoundEffect.SOUND_MAW_OF_VOID, 1, 0)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

function this:EffectUpdate(effect)
    if effect.SubType == 1 then
        effect.Velocity = SomethingWicked.EnemyHelpers:Lerp(effect.Velocity, Vector.Zero, 0.2)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.EffectUpdate)

function this:PlayerTakeDMG(player)
    player = player:ToPlayer()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_BOLINE) then
        SomethingWicked.ItemHelpers:ChargeFirstActiveOfTypeThatNeedsCharge(player, CollectibleType.SOMETHINGWICKED_BOLINE, 2, false)
    end
end
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, this.PlayerTakeDMG, EntityType.ENTITY_PLAYER)

this.EIDEntries = {}
return this