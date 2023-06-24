local this = {}
FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA = Isaac.GetEntityVariantByName("Ms. Gonorrhea")

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:AddToFollowers()
    familiar.Parent = familiar.Parent or familiar.Player
end, FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA)

function this:FamiliarUpdate(familiar)
    local player = familiar.Player
    local direction = player:GetAimDirection()

    familiar.FireCooldown = math.max(familiar.FireCooldown - 1, 0)

    if direction:Length() == 0 and familiar.FireCooldown <= 0 then
        local f_rng = familiar:GetDropRNG()
        direction = (direction * 10) + familiar.Velocity
        local fireAngle = direction:Rotated(SomethingWicked.EnemyHelpers:Lerp(-30, 30, f_rng:RandomFloat()))

        local tear = familiar:FireProjectile(fireAngle:Resized(1.5))
        tear.CollisionDamage = 0.7
        tear.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
        tear.FallingAcceleration = tear.FallingAcceleration + 2
        tear.FallingSpeed = -10

        local t_data = tear:GetData()
        t_data.somethingWicked_isPusShot = f_rng:RandomFloat() < 0.33

        familiar.FireCooldown = 5 - familiar.Hearts
    end
    familiar:FollowParent()
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA)

function this:TearRemoved(tear)
    local t_data = tear:GetData()
    if t_data.somethingWicked_isPusShot and tear.SpawnerEntity then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, 0, tear.Position, Vector.Zero, tear.SpawnerEntity.Player):Update()
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, this.TearRemoved, EntityType.ENTITY_TEAR)

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_MS_GONORRHEA)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA, stacks, rng, sourceItem)
end, CacheFlag.CACHE_FAMILIARS)

SomethingWicked:AddCallback(ModCallbacks.MC_USE_PILL, function (_, pill)
    for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA)) do
        value = value:ToFamiliar() value.Hearts = value.Hearts + 1 
    end

    --[[local pillConf = Isaac.GetItemConfig():GetPillEffect(pill)
    print(pillConf.Name, pillConf.ID, pillConf.EffectClass, pillConf.EffectSubClass, pillConf.MimicCharge, pillConf:IsAvailable())
    print(pillConf.AnnouncerVoice, pillConf.AnnouncerVoiceSuper, pillConf.AnnouncerDelay)]]
end)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_, _)
    for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA)) do
        value = value:ToFamiliar() value.Hearts = 0
    end
end)

this.EIDEntries = {}
return this