local this = {}
TrinketType.SOMETHINGWICKED_GACHAPON = Isaac.GetTrinketIdByName("Gachapon")
CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER = Isaac.GetItemIdByName("Trinket Smasher")
this.MinimumDrops = 2
this.MaximumDrops = 4
this.pickupTable = {PickupVariant.PICKUP_HEART, PickupVariant.PICKUP_COIN,
                    PickupVariant.PICKUP_BOMB, PickupVariant.PICKUP_KEY, PickupVariant.PICKUP_GRAB_BAG, 
                    PickupVariant.PICKUP_PILL, PickupVariant.PICKUP_LIL_BATTERY, PickupVariant.PICKUP_TAROTCARD}

this.thingsToCheck = {}

function this:OnUpdate(pickup)
    local frameCount = SomethingWicked.game:GetRoom():GetFrameCount()
    local pickingUp = false
    local allPlayers = SomethingWicked:UtilGetAllPlayers()
    for index, player in ipairs(allPlayers) do
        if player.QueuedItem.Item ~= nil
        and player.QueuedItem.Item:IsTrinket()
        and player.QueuedItem.Item.ID == TrinketType.SOMETHINGWICKED_GACHAPON then
            pickingUp = true
            break
        end
    end

    if not pickingUp then
        --print("a")
        for index, trinket in ipairs(this.thingsToCheck) do
            local pickup = trinket.pickup
            if trinket.frame <= frameCount
            and ((pickup:Exists() == false)
            or (pickup.Type ~= EntityType.ENTITY_PICKUP or pickup.Variant ~= PickupVariant.PICKUP_TRINKET 
            or (pickup.SubType ~= TrinketType.SOMETHINGWICKED_GACHAPON and pickup.SubType ~= TrinketType.SOMETHINGWICKED_GACHAPON + TrinketType.TRINKET_GOLDEN_FLAG))) then
                this:OnDestroy(pickup)
            end
        end
    end
    this.thingsToCheck = {}

    local allTrinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.SOMETHINGWICKED_GACHAPON)
    local allGoldenTrinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.SOMETHINGWICKED_GACHAPON + TrinketType.TRINKET_GOLDEN_FLAG)
    for index, value in ipairs(allGoldenTrinkets) do
        table.insert(allTrinkets, value)
    end
    for index, value in ipairs(allTrinkets) do
        table.insert(this.thingsToCheck, { frame = frameCount + 1, pickup = value})
    end
end

function this:OnDestroy(trinket, player)
    local rng = player ~= nil and player:GetDropRNG() or trinket:GetDropRNG()
    local frequency = rng:RandomInt(this.MaximumDrops - this.MinimumDrops) + this.MinimumDrops
    local mult = 1
    if trinket.SubType & TrinketType.TRINKET_GOLDEN_FLAG ~= 0 then
        mult = mult + 1
    end
    mult = mult + SomethingWicked.ItemHelpers:GlobalGetCollectibleNum(CollectibleType.COLLECTIBLE_MOMS_BOX)
    frequency = frequency * mult

    this:SpawnALOTAPickups(frequency, trinket.Position, trinket, rng)
    
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, trinket.Position, Vector.Zero, trinket)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, trinket.Position, Vector.Zero, trinket)
end

function this:UseCrusher(_, rngobj, player, flags)
    local currTrinket = player:GetTrinket(0)
    if currTrinket ~= 0 then
        local freq = 1
        if currTrinket & TrinketType.TRINKET_GOLDEN_FLAG ~= 0 then
            freq = freq + 1
        end
        if currTrinket == TrinketType.SOMETHINGWICKED_GACHAPON or currTrinket == TrinketType.SOMETHINGWICKED_GACHAPON + TrinketType.TRINKET_GOLDEN_FLAG then
            freq = freq + 1
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
            for i = 1, (freq - 1) * 2, 1 do
                player:AddWisp(CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER, player.Position)
            end
        end

        this:SpawnALOTAPickups(freq * rngobj:RandomInt(this.MaximumDrops - this.MinimumDrops) + this.MinimumDrops, player.Position--[[+ Vector(0, 20)]], player, rngobj)
        player:TryRemoveTrinket(currTrinket)

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, player.Position, Vector.Zero, player)

        SomethingWicked.sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)
        return true
    end
    return {ShowAnim = true, Discharge = false}
end

function this:SpawnALOTAPickups(frequency, position, spanwer, rng)
    for i = 1, frequency, 1 do
        local pickupToCreate = SomethingWicked:GetRandomElement(this.pickupTable, rng)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, pickupToCreate, 0, position, SomethingWicked.SlotHelpers:GetPayoutVector(rng), spanwer)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseCrusher, CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.OnUpdate)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_GACHAPON] = {
        isTrinket = true,
        desc = "Upon destroying or rerolling this trinket, spawns "..this.MinimumDrops.."-"..this.MaximumDrops.." random pickups",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, nil, { this.MinimumDrops, this.MaximumDrops } )
        end,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon destroying or rerolling this trinket, spawns "..this.MinimumDrops.."-"..this.MaximumDrops.." random pickups"})
    },
    [CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER] = {
        desc = "Destroys any held trinkets on use#Spawns 2-4 random pickups on trinket destroy",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Destroys any held trinkets on use","Spawns 2-4 random pickups on trinket destroy"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP
        }
    }
}
return this