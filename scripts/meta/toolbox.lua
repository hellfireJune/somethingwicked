--item helpers
local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

--[[function mods:GlobalPlayerHasCollectible(type, ignoreModifs)
    for index, value in ipairs(mod:UtilGetAllPlayers()) do
        if value:HasCollectible(type, ignoreModifs) then
            return true, value
        end
    end
    return false
end ]]

--[[function wicked:GlobalGetCollectibleNum(type, ignoreModifs)
    local num = 0
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            num = num + value:GetCollectibleNum(type)
    end
    return num
end]]

function mod:GlobalGetCollectibleRNG(type)
    local players = SomethingWicked:UtilGetAllPlayers()
    for index, player in ipairs(players) do
        if player:HasCollectible(type) then
            return player:GetCollectibleRNG(type)
        end
    end
    return players[1]:GetCollectibleRNG(type)
end

function mod:AllPlayersWithCollectible(type, ignoreModifs)
    local t = {}
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasCollectible(type, ignoreModifs) then
            table.insert(t, value)
        end
    end
    return t
end

--[[function modd:GlobalPlayerHasTrinket(type, ignoreModifs)
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasTrinket(type, ignoreModifs) then
            return true, value
        end
    end
    return false
end ]]

function mod:GlobalGetTrinketNum(type, ignoreModifs)
    local num = 0
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            num = num + value:GetTrinketMultiplier(type)
    end
    return num
end

function mod:AllPlayersWithTrinket(type, ignoreModifs)
    local t = {}
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        if value:HasTrinket(type, ignoreModifs) then
            table.insert(t, value)
        end
    end
    return t
end
--returns with the charge of the item and the slot of the item
function mod:CheckPlayerForActiveData(player, item)
    for i = 0, 3, 1 do
        local currentItem = player:GetActiveItem(i)
        if item == currentItem then
            local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)
            return charge, i
        end
    end
    return 0, -1
end

function SomethingWicked:GetAllActiveDatasOfType(player, item)
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
function mod:RemoveQueuedItem(player)
    --"oh boy how great is that to work with queued items. so much fun!" -Anonymous Repentance Plus Coder (Presumably Mr. SeemsGood)
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
    local bh_p = mod:GetBlackHeartsNum(player)
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
function mod:GetBlackHeartsNum(player, getFirstHeart, heartType)
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

local pickupsSpawnRegularEnMasseTable = {
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
--too cool to not reuse
function mod:SpawnPickupShmorgabord(payout, variant, rng, position, spawner, postSpawnFunction)
    local table = pickupsSpawnRegularEnMasseTable[variant]
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


function mod:GetPayoutVector(v_rng)
    local angle = v_rng:RandomInt(120)
    return Vector.FromAngle(angle + 30) * 5
end

function mod:CanPickupPickupGeneric(heart, player)
    if (not heart:IsShopItem() or (heart.Price > player:GetNumCoins() and player:IsExtraAnimationFinished()))
    then
        return true
    end
    return false
end

--use on collision to check if a hearts gettin picked up
local heartFuncs = {
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
function mod:WillHeartBePickedUp(heart, player)
    if heart.Type ~= EntityType.ENTITY_PICKUP
    and heart.Variant ~= PickupVariant.PICKUP_HEART then
        return false
    end
    if heartFuncs[heart.SubType] == nil then
        return false
    else
        return (heartFuncs[heart.SubType](player) and mod:CanPickupPickupGeneric(heart, player))
    end
end

local StackOverflowerPreventer = 0
function mod:ItemBlacklister(item, itempool, decrease, seed)
    SomethingWicked.save.runData.ItemBlacklist = SomethingWicked.save.runData.ItemBlacklist or {}
    if SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.ItemBlacklist, item) and StackOverflowerPreventer < 100 then
        StackOverflowerPreventer = StackOverflowerPreventer + 1
        local gItempool = SomethingWicked.game:GetItemPool()
        --print("Blacklisted item "..item.." spotted in itempool "..itempool)
        local collectible = gItempool:GetCollectible(itempool, decrease)
        return collectible
    end
    StackOverflowerPreventer = 0
end
mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, mod.ItemBlacklister)

function mod:HoldItemUseHelper(player, flags, item)
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

function mod:HoldItemUpdateHelper(player, item)
    
    local d = player:GetData()
    d.somethingWicked_isHoldingItem = d.somethingWicked_isHoldingItem or {}
    local charge, slot = mod:CheckPlayerForActiveData(player, item)

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

function mod:GetFireVector(player)
    return (player:GetAimDirection() * (player.ShotSpeed * 10) + player.Velocity):Resized(player.ShotSpeed * 10) 
end

function mod:DirectionToVector(direction)
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

local function GenerateLootData()
    SomethingWicked.save.runData.LootData = SomethingWicked.NewItemPools
end

function mod:RandomItemFromCustomPool(poolEnum, myRNG)
    if SomethingWicked.save.runData.LootData == nil then
        GenerateLootData()
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

function mod:FireSingularDynamic(player, ignoreLudo, args, rotate, additionalPosMod, is2020)
    ignoreLudo = ignoreLudo or false
    local dir = args.Direction:Rotated(rotate)
    additionalPosMod = additionalPosMod or Vector.Zero
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
        player:FireTechXLaser(args.Position, dir, 100 * args.DMGMult, player, args.DMGMult--[[position, direction, radius, source, damageMult]])
        return
    end
    if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
        local brim = player:FireBrimstone(dir, args.Source, args.DMGMult--[[direction, source, dmgMult]])
        brim.Position = args.Position
        brim.Parent = args.Source
        return
    end
    if player:HasWeaponType(WeaponType.WEAPON_BOMBS) then
        player:FireBomb(args.Position, dir, args.Source--[[position, direction, source]])
        return
    end
    if player:HasWeaponType(WeaponType.WEAPON_LASER) then
        player:FireTechLaser(args.Position, LaserOffset.LASER_TECH1_OFFSET, dir, false, false, args.Source, args.DMGMult--[[position, laserOffset, direction, leftEye, oneHit(?), source, damageMult]])
        return
    end
    player:FireTear(args.Position + additionalPosMod, is2020 and args.Direction or dir, args.CanEvilEye, true, false, args.Source, args.DMGMult)
end

function SomethingWicked:FireKnifeGood(player, vector)
    
end

--[[Args:
Position: vector
Direction: vector
Source: entity
DMGMult: float
CanEvilEye: boolean]]
function mod:AdaptiveFireFunction(player, ignoreLudo, args, rng)
    local shotNum, shotMods = GetNumProjectiles(player, rng)

    local spreadMult = 3
    for i = 1, shotNum, 1 do
        local spread = math.floor(i-(shotNum/2))
        if spread <= 0 and shotNum % 2 == 0 then
            spread = spread - 1
        end
        local addPos = Vector.Zero
        local is2020 = false
        if shotNum > 2 then
            if i == 1 or i == shotNum then
                addPos = -args.Direction
                spread = spread * 1.25
            end
        else
            is2020 = true
        end
        --n_args.Direction = n_args.Direction:Rotated(spread*spreadMult)
        mod:FireSingularDynamic(player, ignoreLudo, args, spread*spreadMult, addPos, is2020)
    end

    for i = 1, shotMods.EyeSore, 1 do
        mod:FireSingularDynamic(player, ignoreLudo, args, rng:RandomInt(360))
    end

    if shotMods.MomsEye then
        mod:FireSingularDynamic(player, ignoreLudo, args, 180)
    end
    if shotMods.LokisHorn then
        for i = 1, 3, 1 do
            mod:FireSingularDynamic(player, ignoreLudo, args, 90*i)
        end
    end
end

function SomethingWicked:TEARFLAG(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end

function SomethingWicked:ChargeFirstActive(player, chargeToAdd, skipBatteryCheck, chargeAllActually, func)
    func = func or function ()
        return true
    end
    chargeToAdd = chargeToAdd or 1

    for i = 0, 3, 1 do
        --print("Ah")
        local currentItem = player:GetActiveItem(i)
        if currentItem ~= 0 and player:NeedsCharge(i) then
            local maxCharge = Isaac.GetItemConfig():GetCollectible(currentItem).MaxCharges
            local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)

            local overCharge = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) or skipBatteryCheck
            local newMaxCharge = maxCharge * (overCharge and 2 or 1)
            if charge < newMaxCharge
            and func(player, currentItem, charge) then
                player:AddActiveCharge(chargeToAdd, i, true, overCharge)
                
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position - Vector(0, 60), Vector.Zero, player)
                game:GetHUD():FlashChargeBar(player, i)
                sfx:Play(SoundEffect.SOUND_BEEP)
                if not chargeAllActually then
                    goto outofloop
                end
            end
        end
    end
    ::outofloop::
end

function SomethingWicked:ChargeFirstActiveOfType(player, collectible, chargeToAdd, skipBatteryCheck, chargeAllActually, func)
    return mod:ChargeFirstActive(player, chargeToAdd, skipBatteryCheck, chargeAllActually, function (_, item)
        func = func or function ()
            
        end
        return func() and collectible == item
    end)

--[[    chargeToAdd = chargeToAdd or 1
    if skipBatteryCheck == nil then
        skipBatteryCheck = false
    end
    local items = mod:GetAllActiveDatasOfType(player, collectible)
    local maxCharge = Isaac.GetItemConfig():GetCollectible(collectible).MaxCharges

    local newMaxCharge = maxCharge * ((player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) or skipBatteryCheck) and 2 or 1)
    for slot, charge in pairs(items) do
        
        if charge < newMaxCharge then
            player:SetActiveCharge(math.min(newMaxCharge, charge + chargeToAdd), slot)

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position - Vector(0, 60), Vector.Zero, player)
            game:GetHUD():FlashChargeBar(player, slot)
            sfx:Play(SoundEffect.SOUND_BEEP)
            return
        end
    end]]
end


--Taken from encyclopedia, absolute lifesaver
--only needed for vanilla stuffs
mod.CardNamesProper = {
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
mod.CardDescsProper = {
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

--familiar based content
function mod:BasicFamiliarNum(player, collectible)
    local rng = player:GetCollectibleRNG(collectible)
    local sourceItem = Isaac.GetItemConfig():GetCollectible(collectible)
    local boxEffect = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local boxStacks = 0
    if boxEffect ~= nil then
        boxStacks = boxEffect.Count
    end
    local itemStacks = player:GetCollectibleNum(collectible)
    return itemStacks + (itemStacks > 0 and boxStacks or 0), rng, sourceItem
end

function mod:AddLocusts(player, amount, rng, position)
    position = position or player.Position
    for i = 1, amount, 1 do
        local subtype = rng:RandomInt(5) + 1
        local amountToSpawn = 1
        if subtype == LocustSubtypes.LOCUST_OF_CONQUEST then
            amountToSpawn = amountToSpawn + rng:RandomInt(3)
        end
        for _ = 1, amountToSpawn, 1 do
            local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype, position, Vector.Zero, player):ToFamiliar()
            locust.Parent = player
            locust.Player = player
        end
    end
end

function mod:DoesFamiliarShootPlayerTears(familiar)
	return (familiar.Variant == FamiliarVariant.INCUBUS
	or familiar.Variant == FamiliarVariant.SPRINKLER 
	or familiar.Variant == FamiliarVariant.TWISTED_BABY 
	or familiar.Variant == FamiliarVariant.BLOOD_BABY 
	or familiar.Variant == FamiliarVariant.UMBILICAL_BABY
    or familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION
    or familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION_B) 
end

--lamb's
function mod:utilForceBloodTear(tear)
	if tear.Variant == TearVariant.BLUE then
		tear:ChangeVariant(TearVariant.BLOOD)
	elseif tear.Variant == TearVariant.NAIL then
		tear:ChangeVariant(TearVariant.NAIL_BLOOD)
	elseif tear.Variant == TearVariant.GLAUCOMA then
		tear:ChangeVariant(TearVariant.GLAUCOMA_BLOOD)
	elseif tear.Variant == TearVariant.CUPID_BLUE then
		tear:ChangeVariant(TearVariant.CUPID_BLOOD)
	elseif tear.Variant == TearVariant.EYE then
		tear:ChangeVariant(TearVariant.EYE_BLOOD)
	elseif tear.Variant == TearVariant.PUPULA then
		tear:ChangeVariant(TearVariant.PUPULA_BLOOD)
	elseif tear.Variant == TearVariant.GODS_FLESH then
		tear:ChangeVariant(TearVariant.GODS_FLESH_BLOOD)
	end
end

function mod:GetOrbitalPositionInLayer(fcheck, player)
    local posInLayer local totalLayerSize = 0 local shouldReset = false
    for _, familiar in ipairs(Isaac.FindByType(3)) do
        familiar = familiar:ToFamiliar()
        if ((familiar.Parent and GetPtrHash(familiar.Parent) == GetPtrHash(player)) or GetPtrHash(familiar.Player) == GetPtrHash(player)) and familiar.OrbitLayer == fcheck.OrbitLayer then
            totalLayerSize = totalLayerSize + 1
            if GetPtrHash(familiar) == GetPtrHash(fcheck) then
                posInLayer = totalLayerSize
            end
            if familiar.FrameCount <= 1 or (familiar:HasEntityFlags(EntityFlag.FLAG_APPEAR) and familiar.FrameCount <= 6) then
                shouldReset = true
            end
        end
    end
    return posInLayer, totalLayerSize, shouldReset
end

function mod:DynamicOrbit(familiar, parent, speed, distance)
    local layerPos, size, shouldReset = mod:GetOrbitalPositionInLayer(familiar, parent)
    local f_data = familiar:GetData()
    
    if shouldReset then
        f_data.somethingWicked__dynamicOrbitPos = 0 + speed
    else
        f_data.somethingWicked__dynamicOrbitPos = (f_data.somethingWicked__dynamicOrbitPos or 0) + speed
    end
    return parent.Position + distance * Vector.FromAngle(f_data.somethingWicked__dynamicOrbitPos + ((layerPos / size) * 360)), shouldReset
end

function mod:FluctuatingOrbitFunc(familiar, player, lerp)
    lerp = lerp or 0.25
    local position = (familiar:GetOrbitPosition(player.Position + player.Velocity))
    position = player.Position + player.Velocity + ((player.Position + player.Velocity) - position) * math.sin(0.1 * familiar.FrameCount)
    if game:GetRoom():GetFrameCount() == 0 then
        familiar.Velocity = Vector.Zero
        familiar.Position = position
        --we stan a weird ass fuckin visual glitch
    else
        local velocity = (position) - familiar.Position
        familiar.Velocity = mod:Lerp(familiar.Velocity, velocity, lerp)
    end
end

function mod:SetFamiliarOrbitPosWOVisualBugs(familiar, pos, vel)
    if game:GetRoom():GetFrameCount() == 0 then
        familiar.Velocity = Vector.Zero
        familiar.Position = pos
    else
        familiar.Velocity = vel
    end
end

--Modified retribution function, thank you Xalum
function mod:GridAlignPosition(pos, scalar)
    local x = pos.X
    local y = pos.Y
    local tile = 40 * (scalar or 1)

    x = tile * math.floor(x/tile+0.5*scalar)
    y = tile * math.floor(y/tile+0.5*scalar)

    return Vector(x, y)
end

function mod:FindNearestVulnerableEnemy(pos, dis, blacklist)
    dis = dis or 80000
    local enemies = Isaac.FindInRadius(pos, dis, EntityPartition.ENEMY)
    local distance = 80009 local enemy = nil

    for index, value in ipairs(enemies) do
        local newDist = value.Position:Distance(pos)
        if value:IsVulnerableEnemy() and not value:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and  newDist < distance
        and (blacklist == nil or not blacklist[""..value.InitSeed]) then
            distance = newDist
            enemy = value
        end
    end

    return enemy
end

--bombs
function mod:ShouldConvertBomb(bomb, player, collectible, spritesheet, dataIdentifer, fetusChance)
    local bombData = bomb:GetData()
    if player:HasCollectible(collectible) then
        bombData[dataIdentifer] = true
        if bomb.Variant == 4 or bomb.Variant == 3 then
            return false
        end
        return true
    end
    return false
end

-- easy tears and damage modification

local CharacterDamageMultipliers = {
    [PlayerType.PLAYER_EVE] = function(player)
    if player:GetHearts() > 2 then
        return 0.75
    end end,
    [PlayerType.PLAYER_MAGDALENA_B] = 0.75,
    [PlayerType.PLAYER_XXX] = 1.05,
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_KEEPER] = 1.2,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
}

--This one was stolen from the damage multiplier stat mod. I thank them so so much
local DamageMultiplers = {
    [CollectibleType.COLLECTIBLE_MAXS_HEAD] = 1.5,
    [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = function (player)
      -- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
      if player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_BLOOD_MARTYR] = function (player)
      if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then return 1 end
  
      -- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
      if
        player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) or
        player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
      then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = 2.3,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_ODD_MUSHROOM_RATE] = 0.9,
    [CollectibleType.COLLECTIBLE_20_20] = 0.75,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
  
    [CollectibleType.COLLECTIBLE_SOY_MILK] = function (player)
      -- Almond Milk overrides Soy Milk
      if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then return 1 end
      return 0.2
    end,
    [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = function (player)
      if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then return 2 end
      return 1
    end,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.33,
    [CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 1.2,
}

local TearMultipliers = {
    [CollectibleType.COLLECTIBLE_BRIMSTONE] = 0.33,
    [CollectibleType.COLLECTIBLE_IPECAC] = 0.33,
    [CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = 0.2,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 0.66,
    [CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = 0.42,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 0.42,
    [CollectibleType.COLLECTIBLE_SOY_MILK] = 5.5,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 4,
    [CollectibleType.COLLECTIBLE_HAEMOLACRIA] = 0.66,
    [CollectibleType.COLLECTIBLE_INNER_EYE] = 0.66,
    [CollectibleType.COLLECTIBLE_DR_FETUS] = 0.4
}

-- no longer supports damage mults, DO IT MANUALLY WITH LATER CALLBACK PRIORITY
function mod:DamageUp(player, damage, flat)
    damage = damage or 0
    flat = flat or 0

    local baseMult = mod:GetCurrentDamageMultiplier(player)
    damage = damage * baseMult
    flat = flat * baseMult

    --TY to ipecac community mod for this easy damage up formula
    return (math.sqrt(player.Damage^2 + (damage * (14.694 * baseMult)))+flat)
end

function mod:GetCurrentDamageMultiplier(player)
    player = player:ToPlayer()
    local mult = 1
    local playerType = player:GetPlayerType()
    local charMult = CharacterDamageMultipliers[playerType]
    if type(charMult) == "function" then charMult = charMult(player) end
    if charMult ~= nil then mult = charMult end
    
    --Also, taken from the damage multiplier stat mod. Thanks to "FainT" so so so much
    for collectible, multiplier in pairs(DamageMultiplers) do
        if player:HasCollectible(collectible) then
            if type(multiplier) == "function" then multiplier = multiplier(player) end
            mult = mult * multiplier
        end
    end
    return mult
end

function mod:GetCurrentTearsMultiplier(player)
  local mult = 1
  for collectible, multiplier in pairs(TearMultipliers) do
    if type(multiplier) == "function" then
        multiplier = multiplier(player)
    end
    if player:HasCollectible(collectible) then
        if type(multiplier) == "function" then multiplier = multiplier(player) end
        mult = mult * multiplier
    end
end
return mult
end

function mod:TearsUp(player, tears, flat, mult)
  tears = tears or 0
  flat = flat or 0
  mult = mult or 1

  local baseMult = mod:GetCurrentTearsMultiplier(player)
  
  tears = tears * baseMult
  flat = flat * baseMult

  local currentTears = mod:GetTears(player.MaxFireDelay)
  local currmax = 5 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CANCER))
  tears = math.min(tears*1.1 + currentTears, math.max(currmax * baseMult * mult, currentTears)) - currentTears + flat
  return mod:GetFireDelay(math.max((currentTears + tears) * mult, 0.2))
end

--shamelessly nabbed from an old message from mr.seemsgood i found.
-- Helper functions to turn fire delay into equivalent tears up (since via api only fire delay is accessible, not tears)
 function mod:GetTears(fireDelay)
    return 30 / (fireDelay + 1)
end
function mod:GetFireDelay(tears)
    return math.max(30 / tears - 1, -0.9999)
end


--hitscan stuff

function mod:DoHitscan(pos, vector, player, func)
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, mod.CONST.HITSCAN_VAR, 0, pos, vector, nil):ToTear()
    tear.Scale = tear.Scale * 1.5
    tear.CollisionDamage = 3.5
    tear.Height = tear.Height * (player.TearRange / (40*6.5))
    local t_data = tear:GetData()
    t_data.sw_isHitScanner = true
    t_data.HitScanFunc = func
    tear:Update()
end

local function hitscanCollide(_, tear, colldier)
    if colldier:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
        tear:Update()
        return
    end
    
    local t_data = tear:GetData()
    if t_data.sw_isHitScanner then
        t_data.sw_stopHitscan = true
        tear.Position = colldier.Position - tear.Velocity*2
        tear:Remove()
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, hitscanCollide)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, tear)
    local t_data = tear:GetData()
    if t_data.sw_isHitScanner then
        local ang = mod:GetAngleDegreesButGood(tear.Velocity)
        local angIsDown = (ang < 120 and ang > 60) 
        local removeTearVelocity = t_data.sw_hitscanGridCollied and not angIsDown
        t_data.HitScanFunc(tear.Position + (removeTearVelocity and -tear.Velocity or tear.Velocity) + (angIsDown and -tear.PositionOffset or Vector.Zero))
    end
end, EntityType.ENTITY_TEAR)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    local t_data = tear:GetData()
    if t_data.sw_isHitScanner then
        local enemies = Isaac.FindInRadius(tear.Position, tear.Size/3, 8)
        t_data.sw_enemiesScanned = t_data.sw_enemiesScanned or {}
        local skip = false
        for index, value in ipairs(enemies) do
            if not mod:UtilTableHasValue(t_data.sw_enemiesScanned, GetPtrHash(value)) then
                if not (value:ToBomb() and value:ToBomb().IsFetus) then
                    skip = true
                end
            else
                table.insert(t_data.sw_enemiesScanned, GetPtrHash(value))
            end
        end
        if skip then
            return
        end
        local room = game:GetRoom()
        local grid = room:GetGridEntityFromPos(tear.Position + (tear.Velocity*2))
        if grid and grid.CollisionClass > 1 then
            t_data.sw_hitscanGridCollied = true
            tear:Remove()
            return
        end
        tear:Update()
    end
end)

--general velocity and vector stuff
--below 3 taken from fiendfolio

function mod:Lerp(first, second, percent, smoothIn, smoothOut)
    if smoothIn then
        percent = percent ^ smoothIn
    end

    if smoothOut then
        percent = 1 - percent
        percent = percent ^ smoothOut
        percent = 1 - percent
    end

	return (first + (second - first)*percent)
end

function mod:GetAngleDegreesButGood(vec)
    local angle = (vec):GetAngleDegrees()
    if angle < 0 then
        return 360 + angle
    else
        return angle
    end
end

function mod:GetAngleDifference(a1, a2)
    a1 = mod:GetAngleDegreesButGood(a1)
    a2 = mod:GetAngleDegreesButGood(a2)
    local sub = a1 - a2
    return (sub + 180) % 360 - 180
end

function SomethingWicked:AngularMovementFunction(familiar, target, speed, variance, lerpMult)
    local enemypos = target.Position or target
        
    local velToEnemy = (enemypos - familiar.Position)
    local minosVel = familiar.Velocity

    local newAng = 0
    local angularDiff = mod:GetAngleDifference(velToEnemy, minosVel)
    if angularDiff < variance and angularDiff > -variance then
        newAng = angularDiff
    else
        local m = mod:MathSign(angularDiff)
        newAng = variance * m
    end
    familiar.Velocity = mod:Lerp(minosVel, minosVel:Rotated(newAng), lerpMult):Resized(speed)
    return newAng
end

function SomethingWicked:SmoothOrbitVec(tear, oPos, oDis, speed)
    local dis = tear.Position - oPos
    local ang = mod:GetAngleDegreesButGood(dis) local len = dis:Length()
    len = mod:Lerp(len, oDis--[[tear.Size+10]], 0.1)

    ang = ang + speed 

    local orbVec = Vector.FromAngle(ang)*len
    return orbVec
end

function SomethingWicked:MathSign(number)
    --[[in my search to see if such a function exists in the base lua math class, i find this post on reddit
    https://www.reddit.com/r/lua/comments/e11dsl/does_mathsign_exists_in_lua_or_alternative_for_it/
    thank you u/ResponsibleMirror for saving me from having to do this myself]]

    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function mod:CollisionKnockback(mainPos, otherPos, currVelocity)
    --stolen from gungeon LMAO
    --(sorry dodge rell)
    local normal = (otherPos - mainPos):Normalized()
    local velAng = mod:GetAngleDegreesButGood(-currVelocity)
    local disAng = mod:GetAngleDegreesButGood(normal)
    local knockBackAngle = (velAng + 2 * (disAng - velAng))%360

    return Vector.FromAngle(knockBackAngle)
end

--optimised i think?
local tearsToUpdate = {}
local tearUpdateRefs = {}
--passes a tear as argument to the func
function SomethingWicked:AddToTearUpdateList(index, tear, func)
    if not tearUpdateRefs[index] then
        tearUpdateRefs[index] = func
    end

    tearsToUpdate[index] = tearsToUpdate[index] or {}
    table.insert(tearsToUpdate[index], tear)
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE,  function ()
    local room = game:GetRoom()
    if room:GetFrameCount() == 0 then
        tearsToUpdate = {}
    end

    for index, tears in pairs(tearsToUpdate) do
        for tidx, tear in ipairs(tears) do
            if not tear or not tear:Exists() then
                table.remove(tearsToUpdate[index], tidx)
            else
                tearUpdateRefs[index](mod, tear)
            end
            
        end
    end
end)

function SomethingWicked:ClearMovementModifyingTearFlags(tear)
    tear:ClearTearFlags(TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPIRAL | TearFlags.TEAR_ORBIT| TearFlags.TEAR_SQUARE| TearFlags.TEAR_BIG_SPIRAL|
    TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_TURN_HORIZONTAL| TearFlags.TEAR_LUDOVICO)
end

--for anything that should have special handling for how it modifies tear velocity
function SomethingWicked:ShouldMultiplyTearVelocity(tear)
    local t_data = tear:GetData()
    local gany = t_data.sw_gany == nil or (t_data.sw_gany.isBomb and not t_data.sw_gany.gp)
    return gany and not t_data.snakeTearData
end

function SomethingWicked:MultiplyTearVelocity(tear, index, wantedMult, bool)
    local t_data = tear:GetData()
    t_data.sw_velMults = t_data.sw_velMults or {}
    t_data.sw_velMults[index] = t_data.sw_velMults[index] or 1

    local lastMult = t_data.sw_velMults[index]
    if SomethingWicked:ShouldMultiplyTearVelocity(tear) then
        local multiplier = (1 / lastMult) * wantedMult

        tear.Velocity = tear.Velocity * multiplier
        tear.HomingFriction = tear.HomingFriction * multiplier
        t_data.sw_velMults[index] = wantedMult
    end
    if bool then
        mod:MultiplyTearFall(tear, index, wantedMult)
    end
    return lastMult
end

--Spam-changing this can lead to inconsistent projectile flight distances
function SomethingWicked:MultiplyTearFall(tear, index, wantedMult)
    local t_data = tear:GetData()
    t_data.sw_fallMults = t_data.sw_fallMults or {}
    t_data.sw_fallMults[index] = t_data.sw_fallMults[index] or 1

    local lastMult = t_data.sw_fallMults[index]
    --t_data.sw_lastFallSpeed = t_data.sw_lastFallSpeed or 0

    t_data.sw_lastFallSpeed = t_data.sw_lastFallSpeed or tear.Height
    local bounce = tear:HasTearFlags(TearFlags.TEAR_HYDROBOUNCE) and t_data.sw_lastFallSpeed > -6
    
    local diff = tear.Height - t_data.sw_lastFallSpeed
    if diff > 0 and tear.FallingSpeed >= 0 and not bounce and (t_data.sw_fakeStoneBounces or 0)< 3/wantedMult then
        tear.Height = t_data.sw_lastFallSpeed + diff*lastMult
    elseif bounce then
        t_data.sw_fakeStoneBounces = (t_data.sw_fakeStoneBounces or -1) + 1
        tear.FallingSpeed = math.min(0, (-18+2*t_data.sw_fakeStoneBounces)*1-wantedMult)
    end
    t_data.sw_lastFallSpeed = tear.Height
    t_data.sw_fallMults[index] = wantedMult
    
    return lastMult
end

function SomethingWicked:GetAllMultipliedTearVelocity(tear)
    local t_data = tear:GetData()
    local mult = 1
    if t_data.sw_velMults ~= nil then
        for key, value in pairs(t_data.sw_velMults) do
            mult = mult * value
        end
    end
    return mult
end

function SomethingWicked:GetCollectibleWithArgs(args, poolType, removeFromPool)
    local pool = game:GetItemPool()
    local itemConfig = Isaac.GetItemConfig()
    if removeFromPool == nil then
        removeFromPool = false
    end
    if poolType == nil then
        local room = game:GetRoom()
        poolType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
        if poolType == -1 then poolType = ItemPoolType.POOL_TREASURE end
    end
    

    for i = 1, 1000, 1 do
        local newCollectible = pool:GetCollectible(poolType, removeFromPool)
        local conf = itemConfig:GetCollectible(newCollectible)
        if args(conf, newCollectible) then
            return newCollectible
        end
    end
    return 1
end

function SomethingWicked:Current45VoltCharge()
    local level = game:GetLevel()
    return 40 + 20*level:GetAbsoluteStage()
end

function SomethingWicked:SetEasyTearTrail(tear)
    local t_data = tear:GetData() 
    local init = false
    if not t_data.sw_tearTrail then
        init = true
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear):ToEffect()
        trail.MinRadius = 0.2
        trail:FollowParent(tear)
        trail.ParentOffset = tear.PositionOffset
        t_data.sw_tearTrail = trail
    end
    t_data.sw_tearTrail.ParentOffset = tear.PositionOffset
    return t_data.sw_tearTrail, init
end

function SomethingWicked:SpawnTearSplit(tear, player, pos, vel, mult)
    local t_data = tear:GetData()
    local haemoDowngrade = t_data.sw_isHaemoSplitShot
    mult = mult or 1

    local nt = player:FireTear(pos, vel, false, true, false, nil, math.min(tear.CollisionDamage / player.Damage,1)*mult)
    nt.Scale = tear.Scale*(mult^0.5)
    nt.Parent = nil
    if haemoDowngrade then
        nt:ClearTearFlags(TearFlags.TEAR_BURSTSPLIT)
        nt:ChangeVariant(tear.Variant) --not using the custom function here because the custom function wont override haemolacria. iirc
        nt.FallingAcceleration = 1.3
        local rng = nt:GetDropRNG()
        local fallSpeed = rng:RandomInt(-12, -4)
        nt.FallingSpeed = fallSpeed
    end
    return nt
end

--fake fake knives

--creates an invisible moms knife entity, then updates it to the stats and tearflags provided and forces it to collide with the enemy
--should be a cheap way to do synergies, might be a bit laggy now though it runs the damage cache everytime
function SomethingWicked:DoKnifeDamage(target, player, damage)
    damage = damage or player.Damage

    local knife = Isaac.Spawn(EntityType.ENTITY_KNIFE, mod.KNIFE_THING, 0, Vector(80000,80000), Vector.Zero, nil):ToKnife()
    local params = player:GetTearHitParams(WeaponType.WEAPON_TEARS)
    local flags = params.TearFlags

    knife.Variant = 0
    knife.Parent = player
    knife.SpawnerEntity = player
    knife.TearFlags = flags
    player.Damage=damage/6
    knife:Shoot(100, 1)
    knife.Position = target.Position

    knife:ForceCollide(target, true)

    --knife.Position = Vector(80000, 80000)
    knife.Variant = mod.KNIFE_THING
    knife.Parent = nil
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    --knife.SpawnerEntity = nil
end