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

function SomethingWicked.ItemHelpers:GetAllActiveDatasOfType(player, item)
    local table = {}
    for i = 0, 3, 1 do
        local currentItem = player:GetActiveItem(i)
        if item == currentItem then
            local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)
            table[i] = charge
        end
    end
    return table
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
function SomethingWicked.ItemHelpers:CanPickupPickupGeneric(heart, player)
    if (not heart:IsShopItem() or (heart.Price > player:GetNumCoins() and player:IsExtraAnimationFinished()))
    then
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
        return (this.heartFuncs[heart.SubType](player) and SomethingWicked.ItemHelpers:CanPickupPickupGeneric(heart, player))
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
function this:ItemBlacklister(item, itempool, decrease, seed)
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
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, this.ItemBlacklister)
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

--shame this didnt work :/
--[[this.isTrackingPools = false
function SomethingWicked.ItemHelpers:ClearPlayerItemsThenGetNoOfItems(player)
    local noOfItems = 0
    this.trackedPools = {}
    this.trackedCollectibles = {}
    this.isTrackingPools = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D4, UseFlag.USE_NOANIM)
    this.isTrackingPools = false
    
    --because GetCollectible callbacks are wacky and will break if another mod is doing shit (prolly)
    local fakePlayer = SomethingWicked.ItemHelpers:CreateFakePlayer(player, Vector.Zero, PlayerType.PLAYER_ISAAC)
    fakePlayer:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_D4, UseFlag.USE_NOANIM)

    local gItem = SomethingWicked.game:GetItemPool():GetCollectible(ItemPoolType.POOL_TREASURE, false)
    print(gItem)

    for i = 1, math.abs(gItem), 1 do
        if player:HasCollectible(-i) then
            --player:RemoveCollectible(-i)
            noOfItems = noOfItems + 1
        end
    end

    fakePlayer:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
    --fakePlayer:Remove()
    print(noOfItems)
    return noOfItems, this.trackedPools
end

--not good, but better than nothing
function this:CheckForPoolsAndCollectible(item, itempool)
    if this.isTrackingPools then
        if not SomethingWicked:UtilTableHasValue(this.trackedCollectibles, item) then
            table.insert(this.trackedCollectibles, item)
            table.insert(this.trackedPools, item)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, this.CheckForPoolsAndCollectible)

--stolen from fiendfolio, makes a fake player thing idk
function SomethingWicked.ItemHelpers:CreateFakePlayer(parent, pos, playerType)
    parent = parent or Isaac.GetPlayer()
    Isaac.ExecuteCommand("addplayer " .. playerType.. " " .. parent.ControllerIndex)

    local player = Isaac.GetPlayer(SomethingWicked.game:GetNumPlayers() - 1)
    player.Parent = parent

    player.Position = pos

    return player
end]]
SomethingWicked.HoldItemHelpers = {}

function SomethingWicked.HoldItemHelpers:HoldItemUseHelper(player, flags, item)
    
    local d = player:GetData()

    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        return
    end
    d.somethingWicked_isHoldingItem = d.somethingWicked_isHoldingItem or {}
    if not player:IsHoldingItem () then
        player:AnimateCollectible(item, "LiftItem", "PlayerPickupSparkle")
        d.somethingWicked_isHoldingItem[item] = true
    else
        player:AnimateCollectible(item, "HideItem", "PlayerPickupSparkle")
        d.somethingWicked_isHoldingItem[item] = false
    end

    local returnArray = {
        Discharge = false,
        ShowAnim = false,
        Remove = false
    }
    return returnArray
end

function SomethingWicked.HoldItemHelpers:HoldItemUpdateHelper(player, item)
    
    local d = player:GetData()
    d.somethingWicked_isHoldingItem = d.somethingWicked_isHoldingItem or {}
    local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, item)

    if player:IsHoldingItem() 
    and d.somethingWicked_isHoldingItem[item] == true 
    and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
        player:AnimateCollectible(item, "HideItem", "PlayerPickupSparkle")
        d.somethingWicked_isHoldingItem[item] = false
    end

    if player:IsHoldingItem() 
    and player:GetFireDirection() ~= Direction.NO_DIRECTION 
    and d.somethingWicked_isHoldingItem[item] == true then
        player:AnimateCollectible(item, "HideItem", "PlayerPickupSparkle")
        d.somethingWicked_isHoldingItem[item] = false
        player:DischargeActiveItem(slot)
        return true
    end

    return false
end

function SomethingWicked.HoldItemHelpers:GetUseDirection(player)
    return (player:GetAimDirection() * (player.ShotSpeed * 10) + player.Velocity):Resized(player.ShotSpeed * 10) 
end

function SomethingWicked.HoldItemHelpers:AimToVector(direction)
    --stolen from a wofsauge message i found ctrl+f'ing "direction to vector", cheers
    local dirToVec ={
        [Direction.NO_DIRECTION] = Vector(0,0),
        [Direction.LEFT] = Vector(-1,0),
        [Direction.UP] = Vector(0,-1),
        [Direction.RIGHT] = Vector(1,0),
        [Direction.DOWN] = Vector(0,1),
    }
    return dirToVec[direction]
end

--ItemPool stuff

function this:GenerateLootData()
    SomethingWicked.save.runData.LootData = SomethingWicked.NewItemPools
end

function SomethingWicked.ItemHelpers:RandomItemFromCustomPool(poolEnum, myRNG)
    if SomethingWicked.save.runData.LootData == nil then
        this:GenerateLootData()
    end
    local itemPool = SomethingWicked.game:GetItemPool()

    for _ = 1, 2, 1 do
        local pool = SomethingWicked.save.runData.LootData[poolEnum]
        if #pool > 0 then
            local totalWeights = 0
            for _, v in ipairs(pool) do
                totalWeights = totalWeights + v.weight
            end
  
            local unprocessedItemToGet = myRNG:RandomFloat() * totalWeights
            local allValues = {}
            for i, value in ipairs(pool) do
                unprocessedItemToGet = unprocessedItemToGet - value.weight
                table.insert(allValues, value.item)
                if unprocessedItemToGet <= 0 then
                    if itemPool:RemoveCollectible(value.item) then
                        return value.item
                    end
                    SomethingWicked.save.runData.LootData[poolEnum][i].weight = 0
                end
            end
        end
    end
    return -1
end

--taken from the punished, slightly modified, gets num of projectiles to shoot and any mods
local function GetNumProjectiles(player, rng)
    local monstrosLung = CollectibleType.COLLECTIBLE_MONSTROS_LUNG
    local mutantSpider = CollectibleType.COLLECTIBLE_MUTANT_SPIDER
    local innerEye = CollectibleType.COLLECTIBLE_INNER_EYE
    local _2020 = CollectibleType.COLLECTIBLE_20_20

    local hasMonstros = player:HasCollectible(monstrosLung)

    local baseProjectiles
    if hasMonstros then
        baseProjectiles = 14
    else
        if player:HasCollectible(mutantSpider) and player:HasCollectible(innerEye) then
            baseProjectiles = 5
        elseif player:HasCollectible(mutantSpider) then
            baseProjectiles = 4
        elseif player:HasCollectible(innerEye) then
            baseProjectiles = 3
        elseif player:HasCollectible(_2020) then
            baseProjectiles = 2
        else
            baseProjectiles = 1
        end
    end

    local stackingItemProjectiles
    if hasMonstros then
        stackingItemProjectiles = math.floor(2.4 * (
            5 * (math.max(0, player:GetCollectibleNum(monstrosLung) - 1)) +
            2 * player:GetCollectibleNum(mutantSpider) +
            player:GetCollectibleNum(innerEye) +
            player:GetCollectibleNum(_2020)
        ))
    else
        stackingItemProjectiles =
            2 * (math.max(0, player:GetCollectibleNum(mutantSpider) - 1)) +
            math.max(0, (player:GetCollectibleNum(innerEye) - 1)) +
            math.max(0, (player:GetCollectibleNum(_2020) - 1))
    end

    local momsEye = false local lokisHorn = false local eyeSoreShots = 0
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE) then
        local momsChance = math.min(math.max(0, 0.50 + 0.25 * player.Luck), 1)
        if rng:RandomFloat() < momsChance then
           momsEye = true
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
        local lokisChance = math.min(math.max(0, 0.25 + 0.05 * player.Luck), 1)
        if rng:RandomFloat() < lokisChance then
           lokisHorn = true
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then
        if rng:RandomFloat() > 0.66 then
            local eyeSoreSeed = rng:RandomInt(6)
            if eyeSoreSeed < 3 then
                eyeSoreShots = 1
            elseif eyeSoreSeed < 5 then
                eyeSoreShots = 2
            else
                eyeSoreShots = 3
            end
        end
    end

    local numProjectiles = baseProjectiles + stackingItemProjectiles
    return numProjectiles, { EyeSore = eyeSoreShots, MomsEye = momsEye, LokisHorn = lokisHorn, MonstrosLung = hasMonstros }
end

local function InternalFireFunction(player, ignoreLudo, args)
    ignoreLudo = ignoreLudo or false
    if (player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) and not ignoreLudo) then
        return nil
    end

    if player:HasWeaponType(WeaponType.WEAPON_ROCKETS) then
        --FIRE NUKE (might not be possible D:
    end
    if player:HasWeaponType(WeaponType.WEAPON_FETUS) then
        --c section
    end
    if player:HasWeaponType(WeaponType.WEAPON_KNIFE) then
        --return fire knife
    end
    if player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
        player:FireTechXLaser(args.Position, args.Direction, 100, args.Source, args.DMGMult--[[position, direction, radius, source, damageMult]])
        return
    end
    if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
        local brim = player:FireBrimstone(args.Direction, args.Source, args.DMGMult--[[direction, source, dmgMult]])
        brim.Position = args.Position
        return
    end
    if player:HasWeaponType(WeaponType.WEAPON_BOMBS) then
        player:FireBomb(args.Position, args.Direction, args.Source--[[position, direction, source]])
        return
    end
    if player:HasWeaponType(WeaponType.WEAPON_LASER) then
        player:FireTechLaser(args.Position, LaserOffset.LASER_TECH1_OFFSET, args.Direction, false, false, args.Source, args.DMGMult--[[position, laserOffset, direction, leftEye, oneHit(?), source, damageMult]])
        return
    end
    player:FireTear(args.Position, args.Direction, args.CanEvilEye, true, false, args.Source, args.DMGMult)
end

--[[Args:
Position: vector
Direction: vector
Source: entity
DMGMult: float
CanEvilEye: boolean]]
function SomethingWicked.ItemHelpers:AdaptiveFireFunction(player, ignoreLudo, args, rng)
    local shotNum, shotMods = GetNumProjectiles(player, rng)

    local spreadMult = (shotNum - 2) * (15 / shotNum)
    for i = -spreadMult*(math.floor(shotNum/2)), spreadMult*(math.ceil(shotNum/2)), spreadMult do
        local n_args = args
        n_args.Direction = args.Direction:Rotated(i)
        InternalFireFunction(player, ignoreLudo, args)
    end

    for i = 1, shotMods.EyeSore, 1 do
        local n_args = args
        n_args.Direction = args.Direction:Rotated(rng:RandomInt(360))
        InternalFireFunction(player, ignoreLudo, args)
    end

    if shotMods.MomsEye then
        local n_args = args
        n_args.Direction = args.Direction:Rotated(180)
        InternalFireFunction(player, ignoreLudo, args)
    end
    if shotMods.LokisHorn then
        for i = 1, 3, 1 do
            local n_args = args
            n_args.Direction = args.Direction:Rotated(90*i)
            InternalFireFunction(player, ignoreLudo, args)
        end
    end
end

function SomethingWicked:TEARFLAG(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end

function SomethingWicked.ItemHelpers:ShouldConvertBomb(bomb, player, collectible, spritesheet, dataIdentifer, fetusChance)
    local sprite = bomb:GetSprite()
    local bombData = bomb:GetData()
    if player:HasCollectible(collectible) then
        local c_rng = player:GetCollectibleRNG(collectible)
        if bomb.IsFetus and c_rng:RandomFloat() > fetusChance then
            return false
        end
        if (bomb.Variant > 4 or bomb.Variant < 3) then
            sprite:ReplaceSpritesheet(0, spritesheet)
            sprite:LoadGraphics()
        end
        bombData[dataIdentifer] = true
        return true
    end
    return false
end

--made by Xalum send him ur love
function SomethingWicked.ItemHelpers.EntityCollidesWithSwingingKnife(entity, knife)
    local player = knife.SpawnerEntity:ToPlayer()
    local capsuleRadius = knife.Size * 2 * knife.SpriteScale.X
    local knifeVectorDirection = (knife.Position - player.Position):Normalized()
    local capsulePosition = knife.Position + player.Velocity + knifeVectorDirection * capsuleRadius

    return entity.Position:Distance(capsulePosition) < entity.Size + capsuleRadius
end

function SomethingWicked.ItemHelpers:ChargeFirstActiveOfTypeThatNeedsCharge(player, collectible, chargeToAdd, skipBatteryCheck)
    chargeToAdd = chargeToAdd or 1
    if skipBatteryCheck == nil then
        skipBatteryCheck = false
    end
    local items = SomethingWicked.ItemHelpers:GetAllActiveDatasOfType(player, collectible)
    local maxCharge = Isaac.GetItemConfig():GetCollectible(collectible).MaxCharges

    local newMaxCharge = maxCharge * ((player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) or skipBatteryCheck) and 2 or 1)
    for slot, charge in pairs(items) do
        
        if charge < newMaxCharge then
            player:SetActiveCharge(math.min(newMaxCharge, charge + chargeToAdd), slot)

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position - Vector(0, 60), Vector.Zero, player)
            SomethingWicked.game:GetHUD():FlashChargeBar(player, slot)
            SomethingWicked.sfx:Play(SoundEffect.SOUND_BEEP)
            return
        end
    end
end


--Taken from encyclopedia, absolute lifesaver
--only needed for vanilla stuffs
SomethingWicked.ItemHelpers.CardNamesProper = {
	[Card.CARD_FOOL] = "0 - The Fool",
	[Card.CARD_MAGICIAN] = "I - The Magician",
	[Card.CARD_HIGH_PRIESTESS] = "II - The High Priestess",
	[Card.CARD_EMPRESS] = "III - The Empress",
	[Card.CARD_EMPEROR] = "IV - The Emperor",
	[Card.CARD_HIEROPHANT] = "V - The Hierophant",
	[Card.CARD_LOVERS] = "VI - The Lovers",
	[Card.CARD_CHARIOT] = "VII - The Chariot",
	[Card.CARD_JUSTICE] = "VIII - Justice",
	[Card.CARD_HERMIT] = "IX - The Hermit",
	[Card.CARD_WHEEL_OF_FORTUNE] = "X - Wheel of Fortune",
	[Card.CARD_STRENGTH] = "XI - Strength",
	[Card.CARD_HANGED_MAN] = "XII - The Hanged Man",
	[Card.CARD_DEATH] = "XIII - Death",
	[Card.CARD_TEMPERANCE] = "XIV - Temperance",
	[Card.CARD_DEVIL] = "XV - The Devil",
	[Card.CARD_TOWER] = "XVI - The Tower",
	[Card.CARD_STARS] = "XVII - The Stars",
	[Card.CARD_MOON] = "XVIII - The Moon",
	[Card.CARD_SUN] = "XIX - The Sun",
	[Card.CARD_JUDGEMENT] = "XX - Judgement",
	[Card.CARD_WORLD] = "XXI - The World",
	[Card.CARD_CLUBS_2] = "2 of Clubs",
	[Card.CARD_DIAMONDS_2] = "2 of Diamonds",
	[Card.CARD_SPADES_2] = "2 of Spades",
	[Card.CARD_HEARTS_2] = "2 of Hearts",
	[Card.CARD_ACE_OF_CLUBS] = "Ace of Clubs",
	[Card.CARD_ACE_OF_DIAMONDS] = "Ace of Diamonds",
	[Card.CARD_ACE_OF_SPADES] = "Ace of Spades",
	[Card.CARD_ACE_OF_HEARTS] = "Ace of Hearts",
	[Card.CARD_JOKER] = "Joker",
	[Card.RUNE_HAGALAZ] = "Hagalaz",
	[Card.RUNE_JERA] = "Jera",
	[Card.RUNE_EHWAZ] = "Ehwaz",
	[Card.RUNE_DAGAZ] = "Dagaz",
	[Card.RUNE_ANSUZ] = "Ansuz",
	[Card.RUNE_PERTHRO] = "Perthro",
	[Card.RUNE_BERKANO] = "Berkano",
	[Card.RUNE_ALGIZ] = "Algiz",
	[Card.RUNE_BLANK] = "Blank Rune",
	[Card.RUNE_BLACK] = "Black Rune",
	[Card.CARD_CHAOS] = "Chaos Card",
	[Card.CARD_CREDIT] = "Credit Card",
	[Card.CARD_RULES] = "Rules Card",
	[Card.CARD_HUMANITY] = "A Card Against Humanity",
	[Card.CARD_SUICIDE_KING] = "Suicide King",
	[Card.CARD_GET_OUT_OF_JAIL] = "Get Out Of Jail Free Card",
	[Card.CARD_QUESTIONMARK] = "? Card",
	[Card.CARD_DICE_SHARD] = "Dice Shard",
	[Card.CARD_EMERGENCY_CONTACT] = "Emergency Contact",
	[Card.CARD_HOLY] = "Holy Card",
	[Card.CARD_HUGE_GROWTH] = "Huge Growth",
	[Card.CARD_ANCIENT_RECALL] = "Ancient Recall",
	[Card.CARD_ERA_WALK] = "Era Walk",
	[Card.RUNE_SHARD] = "Rune Shard",
	[Card.CARD_REVERSE_FOOL] = "0 - The Fool?",
	[Card.CARD_REVERSE_MAGICIAN] = "I - The Magician?",
	[Card.CARD_REVERSE_HIGH_PRIESTESS] = "II - The High Priestess?",
	[Card.CARD_REVERSE_EMPRESS] = "III - The Empress?",
	[Card.CARD_REVERSE_EMPEROR] = "IV - The Emperor?",
	[Card.CARD_REVERSE_HIEROPHANT] = "V - The Hierophant?",
	[Card.CARD_REVERSE_LOVERS] = "VI - The Lovers?",
	[Card.CARD_REVERSE_CHARIOT] = "VII - The Chariot?",
	[Card.CARD_REVERSE_JUSTICE] = "VIII - Justice?",
	[Card.CARD_REVERSE_HERMIT] = "IX - The Hermit?",
	[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = "X - Wheel of Fortune?",
	[Card.CARD_REVERSE_STRENGTH] = "XI - Strength?",
	[Card.CARD_REVERSE_HANGED_MAN] = "XII - The Hanged Man?",
	[Card.CARD_REVERSE_DEATH] = "XIII - Death?",
	[Card.CARD_REVERSE_TEMPERANCE] = "XIV - Temperance?",
	[Card.CARD_REVERSE_DEVIL] = "XV - The Devil?",
	[Card.CARD_REVERSE_TOWER] = "XVI - The Tower?",
	[Card.CARD_REVERSE_STARS] = "XVII - The Stars?",
	[Card.CARD_REVERSE_MOON] = "XVIII - The Moon?",
	[Card.CARD_REVERSE_SUN] = "XIX - The Sun?",
	[Card.CARD_REVERSE_JUDGEMENT] = "XX - Judgement?",
	[Card.CARD_REVERSE_WORLD] = "XXI - The World?",
	[Card.CARD_CRACKED_KEY] = "Cracked Key",
	[Card.CARD_QUEEN_OF_HEARTS] = "Queen of Hearts",
	[Card.CARD_WILD] = "Wild Card",
	[Card.CARD_SOUL_ISAAC] = "Soul of Isaac",
	[Card.CARD_SOUL_MAGDALENE] = "Soul of Magdalene",
	[Card.CARD_SOUL_CAIN] = "Soul of Cain",
	[Card.CARD_SOUL_JUDAS] = "Soul of Judas",
	[Card.CARD_SOUL_BLUEBABY] = "Soul of ???",
	[Card.CARD_SOUL_EVE] = "Soul of Eve",
	[Card.CARD_SOUL_SAMSON] = "Soul of Samson",
	[Card.CARD_SOUL_AZAZEL] = "Soul of Azazel",
	[Card.CARD_SOUL_LAZARUS] = "Soul of Lazarus",
	[Card.CARD_SOUL_EDEN] = "Soul of Eden",
	[Card.CARD_SOUL_LOST] = "Soul of the Lost",
	[Card.CARD_SOUL_LILITH] = "Soul of Lilith",
	[Card.CARD_SOUL_KEEPER] = "Soul of the Keeper",
	[Card.CARD_SOUL_APOLLYON] = "Soul of Apollyon",
	[Card.CARD_SOUL_FORGOTTEN] = "Soul of the Forgotten",
	[Card.CARD_SOUL_BETHANY] = "Soul of Bethany",
	[Card.CARD_SOUL_JACOB] = "Soul of Jacob and Esau",
}
SomethingWicked.ItemHelpers.CardDescsProper = {
	[Card.CARD_FOOL] = "Where journey begins",
	[Card.CARD_MAGICIAN] = "May you never miss your goal",
	[Card.CARD_HIGH_PRIESTESS] = "Mother is watching you",
	[Card.CARD_EMPRESS] = "May your rage bring power",
	[Card.CARD_EMPEROR] = "Challenge me!",
	[Card.CARD_HIEROPHANT] = "Two prayers for the lost",
	[Card.CARD_LOVERS] = "May you prosper and be in good health",
	[Card.CARD_CHARIOT] = "May nothing stand before you",
	[Card.CARD_JUSTICE] = "May your future become balanced",
	[Card.CARD_HERMIT] = "May you see what life has to offer",
	[Card.CARD_WHEEL_OF_FORTUNE] = "Spin the wheel of destiny",
	[Card.CARD_STRENGTH] = "May your power bring rage",
	[Card.CARD_HANGED_MAN] = "May you find enlightenment",
	[Card.CARD_DEATH] = "Lay waste to all that oppose you",
	[Card.CARD_TEMPERANCE] = "May you be pure in heart",
	[Card.CARD_DEVIL] = "Revel in the power of darkness",
	[Card.CARD_TOWER] = "Destruction brings creation",
	[Card.CARD_STARS] = "May you find what you desire",
	[Card.CARD_MOON] = "May you find all you have lost",
	[Card.CARD_SUN] = "May the light heal and enlighten you",
	[Card.CARD_JUDGEMENT] = "Judge lest ye be judged",
	[Card.CARD_WORLD] = "Open your eyes and see",
	[Card.CARD_CLUBS_2] = "Item multiplier",
	[Card.CARD_DIAMONDS_2] = "Item multiplier",
	[Card.CARD_SPADES_2] = "Item multiplier",
	[Card.CARD_HEARTS_2] = "Item multiplier",
	[Card.CARD_ACE_OF_CLUBS] = "Convert all",
	[Card.CARD_ACE_OF_DIAMONDS] = "Convert all",
	[Card.CARD_ACE_OF_SPADES] = "Convert all",
	[Card.CARD_ACE_OF_HEARTS] = "Convert all",
	[Card.CARD_JOKER] = "???",
	[Card.RUNE_HAGALAZ] = "Destruction",
	[Card.RUNE_JERA] = "Abundance",
	[Card.RUNE_EHWAZ] = "Passage",
	[Card.RUNE_DAGAZ] = "Purity",
	[Card.RUNE_ANSUZ] = "Vision",
	[Card.RUNE_PERTHRO] = "Change",
	[Card.RUNE_BERKANO] = "Companionship",
	[Card.RUNE_ALGIZ] = "Resistance",
	[Card.RUNE_BLANK] = "???",
	[Card.RUNE_BLACK] = "Void",
	[Card.CARD_CHAOS] = "???",
	[Card.CARD_CREDIT] = "Charge it!",
	[Card.CARD_RULES] = "???",
	[Card.CARD_HUMANITY] = "Something stinks...",
	[Card.CARD_SUICIDE_KING] = "A true ending?",
	[Card.CARD_GET_OUT_OF_JAIL] = "Open Sesame",
	[Card.CARD_QUESTIONMARK] = "Double active",
	[Card.CARD_DICE_SHARD] = "D6 + D20",
	[Card.CARD_EMERGENCY_CONTACT] = "Help from above",
	[Card.CARD_HOLY] = "You feel protected",
	[Card.CARD_HUGE_GROWTH] = "Become immense!",
	[Card.CARD_ANCIENT_RECALL] = "Draw 3 cards",
	[Card.CARD_ERA_WALK] = "Savor the moment",
	[Card.RUNE_SHARD] = "It still glows faintly",
	[Card.CARD_REVERSE_FOOL] = "Let go and move on",
	[Card.CARD_REVERSE_MAGICIAN] = "May no harm come to you",
	[Card.CARD_REVERSE_HIGH_PRIESTESS] = "Run",
	[Card.CARD_REVERSE_EMPRESS] = "May your love bring protection",
	[Card.CARD_REVERSE_EMPEROR] = "May you find a worthy opponent",
	[Card.CARD_REVERSE_HIEROPHANT] = "Two prayers for the forgotten",
	[Card.CARD_REVERSE_LOVERS] = "May your heart shatter to pieces",
	[Card.CARD_REVERSE_CHARIOT] = "May nothing walk past you",
	[Card.CARD_REVERSE_JUSTICE] = "May your sins come back to torment you",
	[Card.CARD_REVERSE_HERMIT] = "May you see the value of all things in life",
	[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = "Throw the dice of fate",
	[Card.CARD_REVERSE_STRENGTH] = "May you break their resolve",
	[Card.CARD_REVERSE_HANGED_MAN] = "May your greed know no bounds",
	[Card.CARD_REVERSE_DEATH] = "May life spring forth from the fallen",
	[Card.CARD_REVERSE_TEMPERANCE] = "May your hunger be satiated",
	[Card.CARD_REVERSE_DEVIL] = "Bask in the light of your mercy",
	[Card.CARD_REVERSE_TOWER] = "Creation brings destruction",
	[Card.CARD_REVERSE_STARS] = "May your loss bring fortune",
	[Card.CARD_REVERSE_MOON] = "May you remember lost memories",
	[Card.CARD_REVERSE_SUN] = "May the darkness swallow all around you",
	[Card.CARD_REVERSE_JUDGEMENT] = "May you redeem those found wanting",
	[Card.CARD_REVERSE_WORLD] = "Step into the abyss",
	[Card.CARD_CRACKED_KEY] = "???",
	[Card.CARD_QUEEN_OF_HEARTS] = "<3",
	[Card.CARD_WILD] = "Again",
	[Card.CARD_SOUL_ISAAC] = "Reroll... or not",
	[Card.CARD_SOUL_MAGDALENE] = "Give me your love!",
	[Card.CARD_SOUL_CAIN] = "Opens the unopenable",
	[Card.CARD_SOUL_JUDAS] = "Right behind you",
	[Card.CARD_SOUL_BLUEBABY] = "Chemical warfare",
	[Card.CARD_SOUL_EVE] = "Your very own murder",
	[Card.CARD_SOUL_SAMSON] = "Slay a thousand",
	[Card.CARD_SOUL_AZAZEL] = "Demon rage!",
	[Card.CARD_SOUL_LAZARUS] = "Life after death",
	[Card.CARD_SOUL_EDEN] = "Embrace chaos",
	[Card.CARD_SOUL_LOST] = "Leave your body behind",
	[Card.CARD_SOUL_LILITH] = "Motherhood",
	[Card.CARD_SOUL_KEEPER] = "$$$",
	[Card.CARD_SOUL_APOLLYON] = "Bringer of calamity",
	[Card.CARD_SOUL_FORGOTTEN] = "Skeletal protector",
	[Card.CARD_SOUL_BETHANY] = "Friends from beyond",
	[Card.CARD_SOUL_JACOB] = "Bound by blood",
}