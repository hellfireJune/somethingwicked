local this = {}
CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT = Isaac.GetItemIdByName("Star of the Bottomless Pit")
this.Animations = {
    [1] = "LocustWrath",
    [2] = "LocustPestilence",
    [3] = "LocustFamine",
    [4] = "LocustDeath",
    [5] = "LocustConquest"
}

function this:FlyUpdate(entity)
    local player = SomethingWicked:UtilGetPlayerFromTear(entity)
    if entity.SubType == 0 
    and player
    and player:HasCollectible(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT) then
        local myRNG = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT)
        local subtype = myRNG:RandomInt(5) + 1
        if subtype == LocustSubtypes.LOCUST_OF_CONQUEST then
            for i = 1, myRNG:RandomInt(3), 1 do
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_CONQUEST, entity.Position, entity.Velocity, entity.SpawnerEntity)
            end
        end
        entity.SubType = subtype

        entity:GetSprite():Play(this.Animations[subtype], true)
       --[[ for i = 1, timesToDoShit, 1 do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype, entity.Position, entity.Velocity, entity.SpawnerEntity)
        end
        entity:Remove()]]
    end
end

function this:enemyDeath(enemy)

    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT)
    if flag and player then
            local myRNG = RNG()
            myRNG:SetSeed(Random() + 1, 1)
            local luck = player.Luck + (player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 0)
            local chance = myRNG:RandomFloat() 
            if chance <= (0.07 + ((1 - 1 / (1 + 0.17 * luck)) * 0.37)) then 
                player:AddBlueFlies(1, player.Position + player.Velocity, player)
            end
        end  
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FlyUpdate, FamiliarVariant.BLUE_FLY)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.enemyDeath)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_STAR_OF_THE_BOTTOMLESS_PIT] = {
        desc =  "↑ Converts all blue flies into locusts#↑ Chance to spawn a blue fly upon killing enemies",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Holding this item will convert all familiar blue flies into locusts", "Chance to spawn a random locust upon killing an enemy"}, 
        "The fifth angel sounded his trumpet, and I saw a star that had fallen from the sky to the earth. The star was given the key to the shaft of the Abyss.")
    }
}
return this