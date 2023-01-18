local this = {}
CollectibleType.SOMETHINGWICKED_STRANGE_APPLE = Isaac.GetItemIdByName("Strange Apple")
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE = Isaac.GetEntityVariantByName("Retro Snake")
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY = Isaac.GetEntityVariantByName("Retro Snake (body)")
this.Flags = 1 | 8 | 16

local frameCountShit = 6
local snakeLength = 3
function this:HeadUpdate(familiar)
    local f_data = familiar:GetData()
    f_data.somethingWicked_rsDirection = f_data.somethingWicked_rsDirection or Vector(1, 0)
    local lastTarget = familiar.Target
    familiar:PickEnemyTarget(80000, 0, this.Flags, familiar.Velocity, 135)
    if familiar.Target == nil then
        familiar.Target = lastTarget
    end

    if familiar.FrameCount % frameCountShit == 1 then
        local target = familiar.Target
        local targetPos = target and target:Exists() and target.Position or familiar.Player.Position

        local newPos, isStuck = SomethingWicked.FamiliarHelpers:SnakePathFind(familiar, targetPos, f_data.somethingWicked_rsDirection)
        local direction = (newPos - familiar.Position):Normalized()

        this:MoveAnyBodyPiecesRecursive(familiar, familiar.Child)
        familiar.Position = newPos

        if direction:Length() ~= 0 then
            f_data.somethingWicked_rsDirection = direction
        end
        if isStuck then
            f_data.somethingWicked_rsDirection = f_data.somethingWicked_rsDirection:Rotated(-90)
        end
        --local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, newPos, Vector.Zero, nil)
    else
        familiar.Velocity = Vector.Zero
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.HeadUpdate, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.FrameCount % frameCountShit == 1 then
        if not familiar.Parent or not familiar.Parent:Exists() then
            familiar:Die()
        end
    end
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

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.HeadInit, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)

function this:EvaluateCache(player, flags)
    local stacks, rng, source = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_STRANGE_APPLE)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_RETROSNAKE, stacks, rng, source)
end
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_STRANGE_APPLE] = {
        desc = "why did i change this 3 different timmes"
    }
}
return this