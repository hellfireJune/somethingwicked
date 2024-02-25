local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local function PickupInit(_, pickup)
    local players = mod:AllPlayersWithCollectible(mod.ITEMS.BOOK_OF_EXODUS)

    for _, player in ipairs(players) do
        if (pickup:GetSprite():IsPlaying("Appear") or pickup:GetSprite():IsPlaying("AppearFast")) 
        and pickup:GetSprite():GetFrame() == 0 then
            if pickup.SpawnerType ~= EntityType.ENTITY_PLAYER then
                local room = game:GetRoom()

                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, room:FindFreePickupSpawnPosition(pickup.Position+Vector(40,0)), pickup.Velocity, player)
            end
        end
    end
end

--floorly smelt now in main.lua

--[[local function ShittyWorkaroundMarblesCheck(_, player)
    local p_data = player:GetData()
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
end]]

function mod:GetSmeltedTrinkets(player)
    local history = player:GetHistory()
    local historyItems = history:GetcollectiblesHistory()

    local trinks = {}
    for index, value in ipairs(historyItems) do
        if value:IsTrinket() then
            table.insert(trinks, value:GetItemID())
        end
    end
    return trinks
end

local function UseDice(_, _, rngObj, player, flags)
    local trinketsToAdd = 0
    local smeltedTrinketsToAdd = 0
    local gildedTrinketsToAdd = 0

    for i = 0, player:GetMaxTrinkets() - 1 , 1 do
        local trinket = player:GetTrinket(0)
        if trinket ~= 0 then
            player:TryRemoveTrinket(trinket)
            trinketsToAdd = trinketsToAdd + 1

            local gilded = false
            if trinket >= TrinketType.TRINKET_GOLDEN_FLAG then
                gilded = true
                gildedTrinketsToAdd = gildedTrinketsToAdd + 1
            end

            if trinket % TrinketType.TRINKET_GOLDEN_FLAG == mod.TRINKETS.GACHAPON then
                mod:GachaponDestroy(nil, player, gilded)
            end
        end
    end
    
    local smeltedTrinkets = mod:GetSmeltedTrinkets(player)
    for key, trinket in pairs(smeltedTrinkets) do
        if player:HasTrinket(trinket) then
            player:TryRemoveTrinket(trinket)
            smeltedTrinketsToAdd = smeltedTrinketsToAdd + 1
            
            if trinket >= TrinketType.TRINKET_GOLDEN_FLAG then
                gildedTrinketsToAdd = gildedTrinketsToAdd + 1
            end
        end
    end

    local itemPool = game:GetItemPool()
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

local function BookEffect(player, trinket, inInventory)
    inInventory = inInventory or inInventory == nil
    player:TryRemoveTrinket(trinket)
    if inInventory then
        player:AddTrinket(trinket + TrinketType.TRINKET_GOLDEN_FLAG)
    else
        SomethingWicked:UtilAddSmeltedTrinket(trinket + TrinketType.TRINKET_GOLDEN_FLAG, player) 
    end

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)
    poof.Color = mod.ColourGold
    poof.SpriteScale = Vector(1.5, 1.5)
    local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, player.Position, Vector.Zero, player)
    crater.Color = mod.ColourGold
    sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)

    game:SpawnParticles(player.Position, 98, 4, 2)
    return true
end
local function UseBook(_, _, rngObj, player, flags)
    local p_data = player:GetData()
    
    for i = 0, player:GetMaxTrinkets() - 1 , 1 do
        local trinket = player:GetTrinket(i)
        if trinket < TrinketType.TRINKET_GOLDEN_FLAG and trinket ~= 0 then
            return BookEffect(player, trinket)
        end
    end
    
    local smeltedTrinkets = mod:GetSmeltedTrinkets(player)
    for key, value in pairs(smeltedTrinkets) do
        if player:HasTrinket(value)
        and value < TrinketType.TRINKET_GOLDEN_FLAG and value ~= 0  then
            return BookEffect(player, value, false)
        end
    end

    return { Discharge = false, ShowAnim = true }
end
--TrinketType.TRINKET_GOLDEN_FLAG

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PickupInit, PickupVariant.PICKUP_TRINKET)

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseBook, mod.ITEMS.BOOK_OF_EXODUS)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseDice, mod.ITEMS.WOODEN_DICE)

--[[SomethingWicked:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function (_, rngObj, player, flags)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.TrinketInventory = p_data.SomethingWickedPData.TrinketInventory or {}
    if player:GetTrinket(0) ~= 0 then
        table.insert(p_data.SomethingWickedPData.TrinketInventory, player:GetTrinket(0))
    end
end, CollectibleType.COLLECTIBLE_SMELTER)]]
--SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ShittyWorkaroundMarblesCheck) --i loooove marbles
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    player.Luck = player.Luck + player:GetCollectibleNum(mod.ITEMS.WOODEN_DICE) + player:GetCollectibleNum(mod.ITEMS.BOOK_OF_EXODUS)
end, CacheFlag.CACHE_LUCK)