local this = {}
CollectibleType.SOMETHINGWICKED_XXXS_FAVOURITE_TOYS = Isaac.GetItemIdByName("Book of Exodus")
CollectibleType.SOMETHINGWICKED_WOODEN_DICE = Isaac.GetItemIdByName("Wooden Dice")

function this:PickupInit(pickup)
    local players = SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_XXXS_FAVOURITE_TOYS)

    for _, player in ipairs(players) do
        if (pickup:GetSprite():IsPlaying("Appear") or pickup:GetSprite():IsPlaying("AppearFast")) 
        and pickup:GetSprite():GetFrame() == 0 then
            if pickup.SpawnerType ~= EntityType.ENTITY_PLAYER then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, SomethingWicked.game:GetRoom():FindFreePickupSpawnPosition(pickup.Position), pickup.Velocity, player)
            end
        end
    end
end

function this:NewLevel()
    local players = SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_WOODEN_HORN)

    for _, player in ipairs(players) do
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
    end
end

function this:SmelterHook(_, rngObj, player, flags)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.TrinketInventory = p_data.SomethingWickedPData.TrinketInventory or {}
    if player:GetTrinket(0) ~= 0 then
        table.insert(p_data.SomethingWickedPData.TrinketInventory, player:GetTrinket(0))
    end
end
function this:ShittyWorkaroundMarblesCheck(player)
    local p_data = player:GetData()
    --print(#p_data.SomethingWickedPData.TrinketInventory)
    p_data.somethingwicked_LastHeldTrinkets = p_data.somethingwicked_LastHeldTrinkets or {}
    for key, value in pairs(p_data.somethingwicked_LastHeldTrinkets) do
        local isGolden = value >= TrinketType.TRINKET_GOLDEN_FLAG
        local momsBoxStacks = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and 1 or 0
        local queduedItem = player.QueuedItem.Item
        local queuedTrinket = (queduedItem and queduedItem:IsTrinket()) and queduedItem.ID or 0

        if (player:GetTrinket(0) ~= value) and (player:GetTrinket(1) ~= value) and queuedTrinket ~= value
        and player:HasTrinket(value)
        and ((isGolden and player:GetTrinketMultiplier(value) > 1 + momsBoxStacks)
        or (not isGolden and player:GetTrinketMultiplier(value) == 1 + momsBoxStacks)) then
            table.insert(p_data.SomethingWickedPData.TrinketInventory, value)
        end
    end
    p_data.somethingwicked_LastHeldTrinkets = { player:GetTrinket(0), player:GetTrinket(1) }
end
function SomethingWicked:UtilRefreshTrinketInventory(player)
    local p_data = player:GetData()
    local newTable = {} 
    for key, value in pairs(p_data.SomethingWickedPData.TrinketInventory) do
        if player:HasTrinket(value)
        and (player:GetTrinket(0) ~= value)
        and (player:GetTrinket(1) ~= value) then
            table.insert(newTable, value)
        end
    end 

    p_data.SomethingWickedPData.TrinketInventory = newTable
end

function this:UseDice(_, rngObj, player, flags)
    local p_data = player:GetData()
    local trinketsToAdd = 0
    local smeltedTrinketsToAdd = 0
    local gildedTrinketsToAdd = 0

    for i = 0, player:GetMaxTrinkets() - 1 , 1 do
        local trinket = player:GetTrinket(0)
        if trinket ~= 0 then
            player:TryRemoveTrinket(trinket)
            trinketsToAdd = trinketsToAdd + 1

            if trinket >= TrinketType.TRINKET_GOLDEN_FLAG then
                gildedTrinketsToAdd = gildedTrinketsToAdd + 1
            end
        end
    end
    p_data.SomethingWickedPData.TrinketInventory = p_data.SomethingWickedPData.TrinketInventory or {}
    SomethingWicked:UtilRefreshTrinketInventory(player)
    for key, trinket in pairs(p_data.SomethingWickedPData.TrinketInventory) do
        if player:HasTrinket(trinket) then
            player:TryRemoveTrinket(trinket)
            smeltedTrinketsToAdd = smeltedTrinketsToAdd + 1
            
            if trinket >= TrinketType.TRINKET_GOLDEN_FLAG then
                gildedTrinketsToAdd = gildedTrinketsToAdd + 1
            end
        end
    end

    local itemPool = SomethingWicked.game:GetItemPool()
    for i = 1, trinketsToAdd + smeltedTrinketsToAdd, 1 do
        local trinketToAdd = itemPool:GetTrinket()
        --print(trinketToAdd)
        if i <= gildedTrinketsToAdd then
            if trinketToAdd < TrinketType.TRINKET_GOLDEN_FLAG then
                trinketToAdd = trinketToAdd + TrinketType.TRINKET_GOLDEN_FLAG
            end
        elseif trinketToAdd >= TrinketType.TRINKET_GOLDEN_FLAG then
            trinketToAdd = trinketToAdd - TrinketType.TRINKET_GOLDEN_FLAG
        end
        --print(trinketToAdd)
        player:AddTrinket(trinketToAdd)
        if i <= smeltedTrinketsToAdd then 
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
    end

    return true
end

--stole this shmancy gold color from gold rune cheers love xoxoxoxoxo
this.goldColor = Color(0.9, 0.8, 0, 1, 0.8, 0.7)
function this:UseBook(_, rngObj, player, flags)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.TrinketInventory = p_data.SomethingWickedPData.TrinketInventory or {}
    for i = 0, player:GetMaxTrinkets() - 1 , 1 do
        local trinket = player:GetTrinket(i)
        if trinket < TrinketType.TRINKET_GOLDEN_FLAG and trinket ~= 0 then
            return this:BookEffect(player, trinket)
        end
    end
    
    SomethingWicked:UtilRefreshTrinketInventory(player)
    for key, value in pairs(p_data.SomethingWickedPData.TrinketInventory) do
        if player:HasTrinket(value)
        and value < TrinketType.TRINKET_GOLDEN_FLAG and value ~= 0  then
            return this:BookEffect(player, value, false)
        end
    end

    return { Discharge = false, ShowAnim = true }
end
function this:BookEffect(player, trinket, inInventory)
    inInventory = inInventory or inInventory == nil
    player:TryRemoveTrinket(trinket)
    if inInventory then
        player:AddTrinket(trinket + TrinketType.TRINKET_GOLDEN_FLAG)
    else
        SomethingWicked:UtilRefreshTrinketInventory(player)
        SomethingWicked:UtilAddSmeltedTrinket(trinket + TrinketType.TRINKET_GOLDEN_FLAG, player) 
    end

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
    poof.Color = this.goldColor
    local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, player.Position, Vector.Zero, player)
    crater.Color = this.goldColor
    SomethingWicked.sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
    return true
end
--TrinketType.TRINKET_GOLDEN_FLAG

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewLevel)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.PickupInit, PickupVariant.PICKUP_TRINKET)

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseBook, CollectibleType.SOMETHINGWICKED_XXXS_FAVOURITE_TOYS)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseDice, CollectibleType.SOMETHINGWICKED_WOODEN_DICE)

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, this.SmelterHook, CollectibleType.COLLECTIBLE_SMELTER)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.ShittyWorkaroundMarblesCheck) --i loooove marbles

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_XXXS_FAVOURITE_TOYS] = {
        desc = "↑ Doubles all trinket spawns#Converts any trinkets to golden trinkets on use",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Doubles all trinket spawns","Converts any trinkets to golden trinkets on use"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_LIBRARY
        }
    },
    [CollectibleType.SOMETHINGWICKED_WOODEN_DICE] = {
        desc = "↑ Gulps one trinket upon entering a new floor#Rerolls any trinkets on you, smelted or not, upon use",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Gulps one trinket upon entering a new floor","Rerolls any trinkets on you, smelted or not, upon use"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
        }
    }
}
return this