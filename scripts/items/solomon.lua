local this = {}
CollectibleType.SOMETHINGWICKED_SOLOMON_ITEM = Isaac.GetItemIdByName("Solomon")
FamiliarVariant.SOMETHINGWICKED_SOLOMON = Isaac.GetEntityVariantByName("Solomon")

this.RoomCount = 8
this.BFFRoomCount = 6

function this:InitFamiliar(familiar)
    familiar:AddToFollowers()
end

function this:UpdateFamiliar(familiar)
    local player = familiar.Player
    local sprite = familiar:GetSprite()

    local playerhasBFF = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    if familiar.RoomClearCount >= (playerhasBFF and this.BFFRoomCount or this.RoomCount) then
        familiar.RoomClearCount = 0

        local pool = SomethingWicked.game:GetItemPool()
        local room = SomethingWicked.game:GetRoom()
        local itemConfig = Isaac.GetItemConfig()

        local poolType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
        if poolType == -1 then poolType = ItemPoolType.POOL_TREASURE end

        local collectible = -1
        while collectible == -1 do
            local newCollectible = pool:GetCollectible(poolType)
            local conf = itemConfig:GetCollectible(newCollectible)
            if conf:HasTags(ItemConfig.TAG_SUMMONABLE) then
                collectible = newCollectible
                

                SomethingWicked.game:GetHUD():ShowItemText(player, conf)
            end
        end
        player:AddItemWisp(collectible, familiar.Position, true)
    end
    if familiar.Velocity.X > 0 then
        sprite.FlipX = true
    elseif familiar.Velocity.X < 0 then
        sprite.FlipX = false
    end

    familiar:FollowParent()
end

function this:cacheEval(player)
    player = player:ToPlayer()
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SOLOMON_ITEM)
    local sourceItem = Isaac.GetItemConfig():GetCollectible(CollectibleType.SOMETHINGWICKED_SOLOMON_ITEM)
    local boxEffect = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local boxStacks = 0
    if boxEffect ~= nil then
        boxStacks = boxEffect.Count
    end

    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_SOLOMON, player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_SOLOMON_ITEM) * (1 + boxStacks), rng, sourceItem)
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_SOLOMON)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.InitFamiliar, FamiliarVariant.SOMETHINGWICKED_SOLOMON)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.cacheEval, CacheFlag.CACHE_FAMILIAR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SOLOMON_ITEM] = {
        desc = "{{Collectible712}} Spawns 1 Lemegeton wisp every 8 rooms",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_BABY_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 1 Lemegeton wisp every 8 rooms"})
    }
}
return this