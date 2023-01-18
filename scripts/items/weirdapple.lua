local this = {}
CollectibleType.SOMETHINGWICKED_STRANGE_APPLE = Isaac.GetItemIdByName("Strange Apple")
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE = Isaac.GetEntityVariantByName("Retro Snake")
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY = Isaac.GetEntityVariantByName("Retro Snake (body)")
this.Flags = 1 | 8 | 16
this.AnimationEnum = {
    [Vector(0, 1)] = "IdleDown",
    [Vector(-1, 0)] = "IdleLeft",
    [Vector(0, -1)] = "IdleUp",
    [Vector(1, 0)] = "IdleRight",
}

local frameCountShit = 6
local snakeLength = 3
function this:HeadUpdate(familiar)
    local player = familiar.Player
    local f_data = familiar:GetData()
    f_data.somethingWicked_rsDirection = f_data.somethingWicked_rsDirection or Vector(1, 0)
    local lastTarget = familiar.Target
    familiar:PickEnemyTarget(80000, 0, this.Flags, familiar.Velocity, 135)
    if familiar.Target == nil then
        familiar.Target = lastTarget
    end

    if familiar.FrameCount % frameCountShit == 1 then
        local target = familiar.Target
        local targetPos = target and target:Exists() and target.Position or player.Position

        local newPos, isStuck = SomethingWicked.FamiliarHelpers:SnakePathFind(familiar, targetPos, f_data.somethingWicked_rsDirection)
        local direction = (newPos - familiar.Position):Normalized()

        this:MoveAnyBodyPiecesRecursive(familiar, familiar.Child)
        familiar.Position = SomethingWicked.FamiliarHelpers:GridAlignPosition(newPos)

        if direction:Length() ~= 0 then
            f_data.somethingWicked_rsDirection = direction
        end
        if isStuck then
            f_data.somethingWicked_rsDirection = f_data.somethingWicked_rsDirection:Rotated(-90)
        end
        --local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, newPos, Vector.Zero, nil)
    else
        familiar.Position = SomethingWicked.FamiliarHelpers:GridAlignPosition(familiar.Position)
        familiar.Velocity = Vector.Zero
    end
    this:Visuals(familiar, player)

    local direction = f_data.somethingWicked_rsDirection
    if direction and direction:Length() ~= 0 then
        
        local anim = "IdleDown" local diff = 999
        for key, value in pairs(this.AnimationEnum) do
            local currentDiff = math.abs(SomethingWicked.EnemyHelpers:GetAngleDifference(key, direction))
            if currentDiff < diff then
                diff = currentDiff
                anim = value
            end
        end
        familiar:GetSprite():Play(anim, false)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.HeadUpdate, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)

function this:Visuals(familiar, player)
    local hasBFFs = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local color = hasBFFs and Color(1, 0.2, 0.2) or Color(0, 1, 0)
    local sizeMult = familiar.Child ~= nil and 1 or 0.95
    familiar.Color = color
    familiar.SpriteScale = (hasBFFs and Vector(0.8, 0.8) or Vector(1, 1)) * sizeMult
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.FrameCount % frameCountShit == 1 then
        if not familiar.Parent or not familiar.Parent:Exists() then
            familiar:Die()
        end
    end
    this:Visuals(familiar, familiar.Player)
end, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY)

function this:MoveAnyBodyPiecesRecursive(parent, familiar)
    if familiar == nil or parent == nil then
        return
    end

    if familiar.Child then
        this:MoveAnyBodyPiecesRecursive(familiar, familiar.Child)
    end

    familiar.Position = parent.Position
end

function this:HeadInit(familiar)
    local lastParent = familiar
    local player = familiar.Player

    familiar.Position = SomethingWicked.FamiliarHelpers:GridAlignPosition(familiar.Position)
    for i = 1, snakeLength - 1, 1 do
        local newBod = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY, 0, lastParent.Position, Vector.Zero, lastParent):ToFamiliar()
        newBod.Parent = lastParent
        lastParent.Child = newBod

        newBod.Player = player

        lastParent = newBod
    end
end

function this:BodyInit(familiar)
    this:Visuals(familiar, familiar.Player)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.HeadInit, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.BodyInit, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY)

function this:EvaluateCache(player, flags)
    local stacks, rng, source = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_STRANGE_APPLE)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_RETROSNAKE, stacks, rng, source)
end
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_STRANGE_APPLE] = {
        desc = "Spawns a snake familiar which moves along the grid every "..frameCountShit.." frames#Will only move forward, left or right",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns a snake familiar which moves along the grid every "..frameCountShit.." frames","Will only move forward, left or right"}),
        pools = { SomethingWicked.encyclopediaLootPools.POOL_TREASURE, SomethingWicked.encyclopediaLootPools.POOL_SECRET, SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET,
        SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE, SomethingWicked.encyclopediaLootPools.POOL_GREED_SECRET},
    }
}
return this