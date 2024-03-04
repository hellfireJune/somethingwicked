local mod = SomethingWicked
local sfx = SFXManager()

local SOTBPAnimations = {
    [1] = "LocustWrath",
    [2] = "LocustPestilence",
    [3] = "LocustFamine",
    [4] = "LocustDeath",
    [5] = "LocustConquest"
}

local function FlyInit(_, familiar)
    if --[[familiar.SubType == LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD then
        this:InitWormwoodLocust(familiar)
    elseif familiar.SubType == LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST then
        this:InitGlitchLocust(familiar)
    elseif]] familiar.SubType == 0 then
        local --[[flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(mod.ITEMS.SAND_FLIES)
        if flag and player then
            familiar.SubType = LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST
            this:InitGlitchLocust(familiar)
            return
        end
        flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(mod.ITEMS.PLAGUE_OF_WORMWOOD)
        if flag and player then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.PLAGUE_OF_WORMWOOD)
            local r_float = c_rng:RandomFloat()
            local procChance = 0.5 + player.Luck * 0.3

            if procChance > r_float then
                familiar.SubType = LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD
                this:InitWormwoodLocust(familiar)
                return
            end
        end]]
        flag, player = mod:GlobalPlayerHasTrinket(mod.TRINKETS.OWL_FEATHER)
        if flag and player then
            local t_rng = player:GetTrinketRNG(mod.TRINKETS.OWL_FEATHER)
            if t_rng:RandomFloat() < 0.2 * player:GetTrinketMultiplier(mod.TRINKETS.OWL_FEATHER) then
                familiar.SubType = LocustSubtypes.LOCUST_OF_WRATH
                familiar:GetSprite():Play(SOTBPAnimations[LocustSubtypes.LOCUST_OF_WRATH], true)
                return
            end
        end
        flag, player = mod:GlobalPlayerHasCollectible(mod.ITEMS.STAR_OF_THE_BOTTOMLESS_PIT)
        print(flag, player)
        if flag and player then
            local myRNG = player:GetCollectibleRNG(mod.ITEMS.STAR_OF_THE_BOTTOMLESS_PIT)

            local subtype = myRNG:RandomInt(5) + 1
            if subtype == LocustSubtypes.LOCUST_OF_CONQUEST then
                for i = 1, myRNG:RandomInt(3), 1 do
                    Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_CONQUEST, familiar.Position, familiar.Velocity, familiar.SpawnerEntity)
                end
            end
            familiar.SubType = subtype

            familiar:GetSprite():Play(SOTBPAnimations[subtype], true)
        end
    end
end

local function enemyDeath(_, enemy)
    local flag, player = mod:GlobalPlayerHasCollectible(mod.ITEMS.STAR_OF_THE_BOTTOMLESS_PIT)
    if flag and player then
        local rng = player:GetCollectibleRNG(mod.ITEMS.STAR_OF_THE_BOTTOMLESS_PIT)

        local luck = player.Luck + (player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 0)
        local chance = rng:RandomFloat() 
        if chance <= (0.12 + ((1 - 1 / (1 + 0.10 * luck)) * 0.37)) then 
            player:AddBlueFlies(1, enemy.Position, player)
        end
    end

    --[[local e_data = enemy:GetData()
    flag, player = mod:GlobalPlayerHasCollectible(mod.ITEMS.PLAGUE_OF_WORMWOOD)
    if flag and e_data.somethingWicked_bitterParent then
        local wf = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD, enemy.Position, Vector.Zero, e_data.somethingWicked_bitterParent)
        wf.Parent = e_data.somethingWicked_bitterParent
    end]]
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FlyInit, FamiliarVariant.BLUE_FLY)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, enemyDeath)

--wormwood time
--[[function InitWormwoodLocust(familiar)
    familiar:GetSprite().Color = mod.BitterStatusColor
end

local isDoingWWDamage
local function OnLocustDoesDMG(entity, amount, flags, source, cooldown)
    if isDoingWWDamage then
        return
    end
    entity = entity:ToNPC()
    if not entity then
        return
    end
    local sourceEnt = source.Entity
    if not sourceEnt
    or not sourceEnt:ToFamiliar() then
        return
    end
    sourceEnt = sourceEnt:ToFamiliar()

    if sourceEnt.Variant == FamiliarVariant.BLUE_FLY then
        if sourceEnt.SubType == LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD then
            local p = SomethingWicked:UtilGetPlayerFromTear(sourceEnt)
            isDoingWWDamage = true

            entity:TakeDamage(amount * 1.5, flags | DamageFlag.DAMAGE_NOKILL, source, cooldown)
            SomethingWicked:UtilAddBitter(entity, 3, p)
            isDoingWWDamage = false
            return false
        elseif sourceEnt.SubType == LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST
        and sourceEnt:GetDropRNG():RandomFloat() < 0.5 then
            SomethingWicked:UtilDoCorruption(sourceEnt.Position, -2)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnLocustDoesDMG)]]

--flies that explode
--[[local PlaceHolderLocustColor = Color(1, 1, 1, 1, 3, 3, 3)
function this:InitGlitchLocust(familiar)
    familiar:GetSprite().Color = this.PlaceHolderLocustColor
end]]

--idk why i decided to do it like this
--[[local numberBug = include("scripts/items/floatingnumberbug")
this.PossibleCorruptions = numberBug.PossibleCorruptions]]

--[[local function NewRoom()
    local room = game:GetRoom()
    if room:IsClear() and not room:IsAmbushActive() then
        return
    end
    SpawnLocusts(mod.TRINKETS.BAG_OF_MUGWORTS, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD)
    SpawnLocusts(mod.TRINKETS.FLOATING_POINT_BUG, LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST)
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoom)
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_NEW_WAVE_SPAWNED, this.NewRoom)]]

--this.EIDEntries = {
    --[mod.TRINKETS.FLOATING_POINT_BUG] = numberBug.EIDEntries[mod.TRINKETS.FLOATING_POINT_BUG],
--}
--return this