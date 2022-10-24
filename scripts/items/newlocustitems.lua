local this = {}
CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT = Isaac.GetItemIdByName("Star of the Bottomless Pit")
CollectibleType.SOMETHINGWICKED_PLAGUE_OF_WORMWOOD = Isaac.GetItemIdByName("Plague of Wormwood")
CollectibleType.SOMETHINGWICKED_S_AND_FLIES = Isaac.GetItemIdByName("S AND FLIES")

LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD = 21
LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST = 22

this.WWColor = Color(0.5, 0.5, 0.5, 1, 0.4, 0.25, 0)
this.SOTBPAnimations = {
    [1] = "LocustWrath",
    [2] = "LocustPestilence",
    [3] = "LocustFamine",
    [4] = "LocustDeath",
    [5] = "LocustConquest"
}

function this:FlyInit(familiar)
    if familiar.SubType == LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD then
        this:InitWormwoodLocust(familiar)
    elseif familiar.SubType == LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST then
    elseif familiar.SubType == 0 then
        local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_PLAGUE_OF_WORMWOOD)
        if flag and player then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PLAGUE_OF_WORMWOOD)
            local r_float = c_rng:RandomFloat()
            local procChance = 0.5 + player.Luck * 0.3

            if procChance > r_float then
                familiar.SubType = LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD
                this:InitWormwoodLocust(familiar)
                return
            end
        end
        flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT)
        if flag and player then
            local myRNG = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT)

            local subtype = myRNG:RandomInt(5) + 1
            if subtype == LocustSubtypes.LOCUST_OF_CONQUEST then
                for i = 1, myRNG:RandomInt(3), 1 do
                    Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_CONQUEST, familiar.Position, familiar.Velocity, familiar.SpawnerEntity)
                end
            end
            familiar.SubType = subtype

            familiar:GetSprite():Play(this.SOTBPAnimations[subtype], true)
        end
    end
end

function this:enemyDeath(enemy)

    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT)
    if flag and player then
        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT)

        local luck = player.Luck + (player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 0)
        local chance = rng:RandomFloat() 
        if chance <= (0.07 + ((1 - 1 / (1 + 0.17 * luck)) * 0.37)) then 
            player:AddBlueFlies(1, enemy.Position, player)
        end
    end

    local e_data = enemy:GetData()
    flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_PLAGUE_OF_WORMWOOD)
    if flag and e_data.somethingWicked_bitterParent then
        local wf = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD, enemy.Position, Vector.Zero, e_data.somethingWicked_bitterParent)
        wf.Parent = e_data.somethingWicked_bitterParent
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FlyInit, FamiliarVariant.BLUE_FLY)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.enemyDeath)

--wormwood time
function this:InitWormwoodLocust(familiar)
    familiar:GetSprite().Color = this.WWColor
end

local isDoingBitterDamage
local bitterProcess = false
local isDoingWWDamage
function this:OnLocustDoesDMG(entity, amount, flags, source, cooldown)
    if isDoingBitterDamage and not bitterProcess then
        bitterProcess = true
        local newDamageAmount = math.min(amount, entity.HitPoints - 1)
        entity:TakeDamage(newDamageAmount, flags, source, cooldown)
        bitterProcess = false
        return false
    end

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
            isDoingBitterDamage = true

            entity:TakeDamage(amount * 1.5, flags, source, cooldown)
            SomethingWicked:UtilAddBitter(entity, 3, p)
            isDoingBitterDamage = false
            isDoingWWDamage = false
            return false
        elseif sourceEnt.SubType == LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST then

        end
    end
end

function SomethingWicked:UtilAddBitter(ent, duration, player)
    duration = duration * 30

    local e_data = ent:GetData()
    e_data.somethingWicked_bitterDuration = (e_data.somethingWicked_bitterDuration or 0) + duration
    e_data.somethingWicked_bitterParent = player
    ent:SetColor(this.WWColor, duration, 2, false)
end

function this:NPCUpdate(npc)
    local e_data = npc:GetData()
    if e_data.somethingWicked_bitterDuration ~= nil then
        e_data.somethingWicked_bitterDuration = e_data.somethingWicked_bitterDuration - 1
        if e_data.somethingWicked_bitterDuration <= 0 then
            e_data.somethingWicked_bitterDuration = nil
            e_data.somethingWicked_bitterParent = nil
        elseif e_data.somethingWicked_bitterDuration % 20 == 1 then
            isDoingBitterDamage = true
            npc:TakeDamage(e_data.somethingWicked_bitterParent.Damage * 2, 0, EntityRef(e_data.somethingWicked_bitterParent), 1)
            isDoingBitterDamage = false
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnLocustDoesDMG)
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.NPCUpdate)

--shop items of the mega bomb variety
--(sand flies)
this.PlaceHolderLocustColor = Color(1, 1, 1, 1, 3, 3, 3)
function this:InitGlitchLocust(familiar)
    familiar:GetSprite().Color = this.PlaceHolderLocustColor
end

--idk why i decided to do it like this
local numberBug = include("scripts/items/floatingnumberbug")
this.PossibleCorruptions = numberBug.PossibleCorruptions
function SomethingWicked:UtilDoCorruption(pos, strength)
    strength = strength or 0
end

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT] = {
        desc =  "↑ Converts all blue flies into locusts#↑ Chance to spawn a blue fly upon killing enemies",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Holding this item will convert all familiar blue flies into locusts", "Chance to spawn a random locust upon killing an enemy"}, 
        "The fifth angel sounded his trumpet, and I saw a star that had fallen from the sky to the earth. The star was given the key to the shaft of the Abyss.")
    },
    [TrinketType.SOMETHINGWICKED_FLOATING_POINT_BUG] = numberBug.EIDEntries[TrinketType.SOMETHINGWICKED_FLOATING_POINT_BUG]
}
return this