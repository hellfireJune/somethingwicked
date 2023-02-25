local this = {}
CollectibleType.SOMETHINGWICKED_LEGION_ITEM = Isaac.GetItemIdByName("Legion")
FamiliarVariant.SOMETHINGWICKED_LEGION = Isaac.GetEntityVariantByName("Legion Familiar")
FamiliarVariant.SOMETHINGWICKED_LEGION_B = Isaac.GetEntityVariantByName("Legion Familiar B")

CollectibleType.SOMETHINGWICKED_DOUBLING_CHERRY = Isaac.GetItemIdByName("Doubling Cherry")
FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC = Isaac.GetEntityVariantByName("Cherry Isaac Familiar")

local frameDiff = 20
local function GetIDX(player)
    local truIdx = 0
    for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
        value = value:ToFamiliar()
        if (value.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION
        or value.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION_B)
        and (GetPtrHash(player) == GetPtrHash(value.Player)) then
            truIdx = truIdx + 1
        end
    end
    return truIdx
end

function this:FamiliarInit(familiar)
    if familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION
    and familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION_B then
        return
    end

    familiar:AddToOrbit(125)
    familiar.OrbitDistance = Vector(40, 40)
	familiar.OrbitSpeed = 0.03

    familiar.Hearts = GetIDX(familiar.Player)
    familiar.FireCooldown = frameDiff * familiar.Hearts
end

this.legionDamageMult = 0.2
this.CherryDMGMult = 0.75
function this:FamiliarUpdate(familiar)
    if familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION
    and familiar.Variant ~= FamiliarVariant.SOMETHINGWICKED_LEGION_B then
        return
    end
    local player = familiar.Player

    familiar.OrbitDistance = Vector(40, 40)
	familiar.OrbitSpeed = 0.03

    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position
    if player:GetFireDirection() ~= Direction.NO_DIRECTION then
        familiar.FireCooldown = math.max(0, familiar.FireCooldown - 1)
    else
        familiar.FireCooldown = math.min(familiar.FireCooldown + 1, frameDiff * familiar.Hearts)
    end

    --firing
    --[[if familiar.FireCooldown <= 0 then
        if player:GetFireDirection() ~= Direction.NO_DIRECTION then
            local angle = SomethingWicked.HoldItemHelpers:GetUseDirection(player)
            player:FireTear(familiar.Position, angle, false, false, false, familiar, this.damageMult)

            familiar.FireCooldown = math.ceil(player.MaxFireDelay)
        end
    else
        familiar.FireCooldown = familiar.FireCooldown - 1
    end]]
end

function this:ProcessFire(player, vector, familiar, dmgMult)
    if GetPtrHash(player)
    ~= GetPtrHash(familiar.Player) then
        return
    end
    if familiar.FireCooldown > 0 then
        return
    end
    
    local fireArgs = {
        Direction = SomethingWicked:UtilGetFireVector(vector, player),
        Position = familiar.Position,
        Source = familiar,
        DMGMult = dmgMult,
        CanEvilEye = true
    }
    local rng = familiar:GetDropRNG()
    SomethingWicked.ItemHelpers:AdaptiveFireFunction(player, false, fireArgs, rng)
end

--This is the section of the code for the doubling cherry

local function UseItem()
    return true
end
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, CollectibleType.SOMETHINGWICKED_DOUBLING_CHERRY)

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    local effects = player:GetEffects()
    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_DOUBLING_CHERRY)
    local c_sourceItem = Isaac.GetItemConfig():GetCollectible(CollectibleType.SOMETHINGWICKED_DOUBLING_CHERRY)

    local boxStacks = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local itemStacks = effects:GetCollectibleEffectNum(CollectibleType.SOMETHINGWICKED_DOUBLING_CHERRY)
    local realstacks = 0
    if itemStacks > 0 then
        realstacks = (itemStacks) + boxStacks
    end
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC, realstacks, c_rng, c_sourceItem)
    
    local l_stacks, l_rng, l_sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_LEGION_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_LEGION, l_stacks, l_rng, l_sourceItem)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_LEGION_B, player:HasCollectible(CollectibleType.SOMETHINGWICKED_LEGION_ITEM) and 3 or 0 , l_rng, l_sourceItem)
end, CacheFlag.CACHE_FAMILIARS)

local function FamiliarUpdate(_, familiar)
    local player = familiar.Player
    familiar.Velocity = player.Velocity
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC)
function this:InitFamiliar(familiar)
    local player = familiar.Player
    if not player.CanFly then
		familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    else
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.InitFamiliar, FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC)
--This is the section of the code for the doubling cherry


local function processFireAll(player, vector, variant, dmgmmult)
    local t = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, variant)
    for index, value in ipairs(t) do
        this:ProcessFire(player, vector, value:ToFamiliar(), dmgmmult)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_FIRE_PURE, function (_, shooter, vector, _, player)
    if shooter.Type == EntityType.ENTITY_PLAYER then
        processFireAll(player, vector, FamiliarVariant.SOMETHINGWICKED_LEGION, this.legionDamageMult)
        processFireAll(player, vector, FamiliarVariant.SOMETHINGWICKED_LEGION_B, this.legionDamageMult)
        processFireAll(player, vector, FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC, this.CherryDMGMult)
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_LEGION_ITEM] = {
        desc = "hey guys"
    },
    [CollectibleType.SOMETHINGWICKED_DOUBLING_CHERRY] = {
        desc = "Doubles you"
    }
}
return this