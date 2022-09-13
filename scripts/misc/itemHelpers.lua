local this = {}
SomethingWicked.ItemHelpers = {}

function SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(type, ignoreModifs)
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasCollectible(type, ignoreModifs) then
            return true, value
        end
    end
    return false
end 

function SomethingWicked.ItemHelpers:GlobalGetCollectibleNum(type, ignoreModifs)
    local num = 0
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            num = num + value:GetCollectibleNum(type)
    end
    return num
end

function SomethingWicked.ItemHelpers:AllPlayersWithCollectible(type, ignoreModifs)
    local t = {}
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasCollectible(type, ignoreModifs) then
            table.insert(t, value)
        end
    end
    return t
end

function SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(type, ignoreModifs)
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasTrinket(type, ignoreModifs) then
            return true, value
        end
    end
    return false
end 

function SomethingWicked.ItemHelpers:GlobalGetTrinketNum(type, ignoreModifs)
    local num = 0
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            num = num + value:GetTrinketMultiplier(type)
    end
    return num
end

function SomethingWicked.ItemHelpers:AllPlayersWithTrinket(type, ignoreModifs)
    local t = {}
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasTrinket(type, ignoreModifs) then
            table.insert(t, value)
        end
    end
    return t
end
--returns with the charge of the item and the slot of the item
function SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, item)
    for i = 0, 3, 1 do
        local currentItem = player:GetActiveItem(i)
        if item == currentItem then
            local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)
            return charge, i
        end
    end
    return 0, -1
end

--From REP+. Removes the player queued item
function SomethingWicked.ItemHelpers:RemoveQueuedItem(player)
    --"oh boy how great is that to work with queued items. so much fun!" -Anonymous ~~damned soul~~ Repentance Plus Coder (Presumably Mr. SeemsGood)
    local id = player.QueuedItem.Item.ID
    local b = player.QueuedItem.Item.AddBombs
    local b_p = player:GetNumBombs()
    local c = player.QueuedItem.Item.AddCoins
    local c_p = player:GetNumCoins()
    local k = player.QueuedItem.Item.AddKeys
    local k_p = player:GetNumKeys()
    local mh = player.QueuedItem.Item.AddMaxHearts
    local mh_p = player:GetMaxHearts()
    local h = player.QueuedItem.Item.AddHearts
    local h_p = player:GetHearts()
    local sh = player.QueuedItem.Item.AddSoulHearts
    local sh_p = player:GetSoulHearts()
    local bh = player.QueuedItem.Item.AddBlackHearts
    local bh_p = SomethingWicked.ItemHelpers:bitmaskIntoNumber(player)
    --
    player:FlushQueueItem()
    player:RemoveCollectible(id)
    --
    player:AddBombs(-math.min(b, 99 - b_p))
    player:AddCoins(-math.min(c, 99 - c_p))
    player:AddKeys(-math.min(k, 99 - k_p))
    player:AddMaxHearts(-math.min(mh, 24 - mh_p))
    player:AddHearts(-math.min(h, player:GetEffectiveMaxHearts() - h_p))
    player:AddSoulHearts(-math.min(sh, 24 - sh_p))
    player:AddBlackHearts(-math.min(bh, 24 - bh_p))
    
		
	for _, pickup in pairs(Isaac.FindByType(5)) do
		if pickup.FrameCount == 0 and pickup.Position:Distance(player.Position) < 250 then
			pickup:Remove()
		end
	end
end
--This is also from REP+.
function SomethingWicked.ItemHelpers:bitmaskIntoNumber(player, getFirstHeart, heartType)
	getFirstHeart = getFirstHeart or false
	if not getFirstHeart then heartType = "" end
	
	local s = player:GetSoulHearts()	-- number of soul + black hearts
	local b = player:GetBlackHearts()	-- bitmask of black hearts read right-to-left
	
	local y = {}
	while b > 0 do
		table.insert(y, b % 2)
		b = b // 2
	end
	
	if not getFirstHeart then
		-- if we just need the amount of black hearts, return right now
		local numB = 0
		for _, el in pairs(y) do
			if el == 1 then numB = numB + 1 end
		end
		
		return numB
	else
		--[[ getting the first heart of a kind will be a bit more complicated
		just having y table does not account for soul hearts at the back of the health bar
		so we need to add as many 0's to that as there are soul hearts left --]]
		local addBits = math.floor(s / 2 + 0.5) - #y	
		for j = 1, addBits do
			table.insert(y, 0)
		end
		
		-- reverse the table
		local y_r = {}
		for i = #y, 1, -1 do
			table.insert(y_r, y[i])
			--print(y[i])
		end
		y = y_r
	
		-- now that y table has ALL of our soul health, we can get the needed one
		for index, heart in pairs(y) do
			if (heart == 0 and heartType == "soul") or (heart == 1 and heartType == "black") then
				return {index, s % 2 == 1}	-- {first entry of the heart, whether your soul health has an odd number of units}
			end
		end
	end
end

--too cool to not reuse
function SomethingWicked.ItemHelpers:SpawnPickupShmorgabord(payout, variant, rng, position, spawner, postSpawnFunction)
    local table = this.pickupsSpawnRegularEnMasseTable[variant]
    while payout > 0 do
        local pickupSubtype
        for index, realIDx in ipairs(table.orders) do
            local value = table.values[realIDx]

            local mult = (1 * index / #table.orders)^2-- * (table.orders[#table.orders])
            local flag = rng:RandomFloat() > mult --multProcessed
            if realIDx <= payout
            and not flag then
                pickupSubtype = value
                payout = payout - realIDx 
                break
            end
        end

        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, pickupSubtype, position, Vector.Zero, spawner) 
        postSpawnFunction(pickup)
    end 
end

--[[
this.Coins = {
    [10] = CoinSubType.COIN_DIME,
    [5] = CoinSubType.COIN_NICKEL,
    [1] = CoinSubType.COIN_PENNY
}
this.CoinOrders = {
    [1] = 10,
    [2] = 5,
    [3] = 1,
} ]]
this.pickupsSpawnRegularEnMasseTable = {
    [PickupVariant.PICKUP_COIN] = {
        values = {
            [10] = CoinSubType.COIN_DIME,
            [5] = CoinSubType.COIN_NICKEL,
            [1] = CoinSubType.COIN_PENNY
        },
        orders = {
            [1] = 10,
            [2] = 5,
            [3] = 1,
        }
    },
    [PickupVariant.PICKUP_BOMB] = {
        values = {
            [1] = BombSubType.BOMB_NORMAL,
            [2] = BombSubType.BOMB_DOUBLEPACK
        },
        orders = {
            [1] = 2,
            [2] = 1
        }
    },
    [PickupVariant.PICKUP_KEY] = {
        values = {
            [1] = KeySubType.KEY_NORMAL,
            [2] = KeySubType.KEY_DOUBLEPACK
        },
        orders = {
            [1] = 2,
            [2] = 1
        }
    },
    [PickupVariant.PICKUP_HEART] = {
        values = {
            [1] = HeartSubType.HEART_HALF,
            [2] = HeartSubType.HEART_FULL,
            [4] = HeartSubType.HEART_DOUBLEPACK,
        },
        orders = {
            [1] = 4,
            [2] = 2,
            [3] = 1 
        }
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = {
        values = {
            [6] = HeartSubType.BATTERY_NORMAL,
            [2] = HeartSubType.BATTERY_MICRO,
            [18] = HeartSubType.BATTERY_MEGA,
        },
        orders = {
            [1] = 18,
            [2] = 6,
            [3] = 2 
        }
    },
}
function this:CanPickupHeartGeneric(heart, player)
    if (not heart:IsShopItem() or heart.Price > player:GetNumCoins()) then
        return true
    end
    return false
end

--use on collision to check if a hearts gettin picked up
function SomethingWicked.ItemHelpers:WillHeartBePickedUp(heart, player)
    if heart.Type ~= EntityType.ENTITY_PICKUP
    and heart.Variant ~= PickupVariant.PICKUP_HEART then
        return false
    end
    if this.heartFuncs[heart.SubType] == nil then
        return false
    else
        return (this.heartFuncs[heart.SubType](player) and this:CanPickupHeartGeneric(heart, player))
    end
end

this.heartFuncs = {
        [HeartSubType.HEART_HALF] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_FULL] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_SCARED] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_DOUBLEPACK] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_SOUL] = function(player) return player:CanPickSoulHearts() end,
        [HeartSubType.HEART_HALF_SOUL] = function(player) return player:CanPickSoulHearts() end,
        [HeartSubType.HEART_BLACK] = function(player) return player:CanPickBlackHearts() end,
        [HeartSubType.HEART_GOLDEN] = function(player) return player:CanPickGoldenHearts() end,
        [HeartSubType.HEART_BLENDED] = function(player) if not player:CanPickRedHearts() then return player:CanPickSoulHearts() end return true end,
        [HeartSubType.HEART_BONE] = function(player) return player:CanPickBoneHearts() end,
        [HeartSubType.HEART_ROTTEN] = function(player) return player:CanPickRottenHearts() end,
}
function this:GetSmokeshopItemPool(item, itempool, decrease, seed)
    SomethingWicked.save.runData.ItemBlacklist = SomethingWicked.save.runData.ItemBlacklist or {}
    if SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.ItemBlacklist, item) and this.StackOverflowerPreventer < 100 then
        this.StackOverflowerPreventer = this.StackOverflowerPreventer + 1
        local gItempool = SomethingWicked.game:GetItemPool()
        --print("Blacklisted item "..item.." spotted in itempool "..itempool)
        local collectible = gItempool:GetCollectible(itempool, decrease)
        return collectible
    end
    this.StackOverflowerPreventer = 0
end
this.StackOverflowerPreventer = 0
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, this.GetSmokeshopItemPool)
--[[
this.validSubtypes = {HeartSubType.HEART_FULL, HeartSubType.HEART_HALF, HeartSubType.HEART_SCARED, HeartSubType.HEART_DOUBLEPACK, HeartSubType.HEART_BLENDED}
this.ProcChance = 0.5
function this:PickupHeart(pickup, player)
    player = player:ToPlayer()
    if player == nil or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_CROSSED_HEART)  then
        return
    end

    local rng = pickup:GetDropRNG()
    if SomethingWicked:UtilTableHasValue(this.validSubtypes, pickup.SubType)
    and rng:RandomFloat() < this.ProcChance
    and player:CanPickRedHearts()
    and (not pickup:IsShopItem() or pickup.Price > player:GetNumCoins()) then
        player:AddHearts(1)
    end
end]]