local mod = RegisterMod("Something Wicked", 1)
SomethingWicked = mod

if not REPENTOGON then
  print("DOWNLOAD REPENTOGON FOR SOMETHING WICKED")
end

local game = Game()
local sfx = SFXManager()

--i think i got this one from deliverance
function mod:UtilGetAllPlayers() 
  local players = {}
    
  for i = 0, game:GetNumPlayers() - 1 do
      players[i + 1] = Isaac.GetPlayer(i)
  end

  return players
end

function mod:UtilTableHasValue (tab, val)
  for index, value in pairs(tab) do
      if value == val then
          return true, index
      end
  end

  return false
end

function mod:Clamp(val, max, min)
  return math.max(max, math.min(val, min))
end

--these two are also from tainted treasures
function mod:utilRunUpdates(tab) --"This is from Fiend Folio"
  for i = #tab, 1, -1 do
      local f = tab[i]
      f.Delay = f.Delay - 1
      if f.Delay <= 0 then
          f.Func()
          table.remove(tab, i)
      end
  end
end

local delayedFuncs = {}
function mod:UtilScheduleForUpdate(func, delay, callback)
  callback = callback or ModCallbacks.MC_POST_UPDATE
  if not delayedFuncs[callback] then
      delayedFuncs[callback] = {}
      mod:AddCallback(callback, function()
          mod:utilRunUpdates(delayedFuncs[callback])
      end)
  end

  table.insert(delayedFuncs[callback], { Func = func, Delay = delay })
end

--removes the player's current trinkets, gives the player the one you provided, uses the smelter, then gives the player back the original trinkets.
--TY to kittenchilly for this snippet.
function mod:UtilAddSmeltedTrinket(trinket, player)
  if not player then
      player = Isaac.GetPlayer(0)
  end

  --get the trinkets they're currently holding
  local trinket0 = player:GetTrinket(0)
  local trinket1 = player:GetTrinket(1)

  --remove them
  if trinket0 ~= 0 then
      player:TryRemoveTrinket(trinket0)
  end
  if trinket1 ~= 0 then
      player:TryRemoveTrinket(trinket1)
  end

  --make sure they don't already have it smelted
  if not player:HasTrinket(trinket) then
      player:AddTrinket(trinket) --add the trinket
      player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, false, false) --smelt it
  end

  --give their trinkets back
  if trinket0 ~= 0 then
      player:AddTrinket(trinket0)
  end
  if trinket1 ~= 0 then
      player:AddTrinket(trinket1)
  end
end

--lambchop_is_ok gave me this one, big thanks go to her
--Checks the spawner entity of a tear, or any tear likes. Will also check incubus
function SomethingWicked:UtilGetPlayerFromTear(tear, onlyIncubus)
  onlyIncubus = onlyIncubus or false
  for i=1, 2 do
      local check = nil
      if i == 1 then
          check = tear.Parent
      elseif i == 2 then
          check = tear.SpawnerEntity
      end
      if check then
          if check.Type == EntityType.ENTITY_PLAYER then
              return check:ToPlayer()
          elseif check.Type == EntityType.ENTITY_FAMILIAR and 
          ((check.Variant == FamiliarVariant.INCUBUS or check.Variant == FamiliarVariant.TWISTED_BABY) or onlyIncubus) then
              return check:ToFamiliar().Player:ToPlayer()
          end
      end
  end
end
function mod:utilMerge(t1, t2)
  for k,v in ipairs(t2) do
     table.insert(t1, v)
  end

  return t1
end
local weightedPools = {
  { ItemPoolType.POOL_TREASURE, 405 },
  { ItemPoolType.POOL_SHOP, 95 },
  { ItemPoolType.POOL_BOSS, 59 },
  { ItemPoolType.POOL_DEVIL, 92 },
  { ItemPoolType.POOL_ANGEL, 62 },
  { ItemPoolType.POOL_CURSE, 33 },
  { ItemPoolType.POOL_SECRET, 62 },
}
local weightedGreedPools = {
  { ItemPoolType.POOL_GREED_TREASURE, 343 },
  { ItemPoolType.POOL_GREED_SHOP, 87 },
  { ItemPoolType.POOL_GREED_BOSS, 83 },
  { ItemPoolType.POOL_GREED_DEVIL, 83 },
  { ItemPoolType.POOL_GREED_ANGEL, 51 },
  { ItemPoolType.POOL_GREED_CURSE, 30 },
  { ItemPoolType.POOL_GREED_SECRET, 58 },
}
local bothModePools = {
  { ItemPoolType.POOL_LIBRARY, 15 },
  { ItemPoolType.POOL_GOLDEN_CHEST, 25 },
  { ItemPoolType.POOL_RED_CHEST, 15 },
  { ItemPoolType.POOL_BEGGAR, 27 },
  { ItemPoolType.POOL_DEMON_BEGGAR, 35 },
  { ItemPoolType.POOL_KEY_MASTER, 22 },
  { ItemPoolType.POOL_BOMB_BUM, 20 },
  { ItemPoolType.POOL_PLANETARIUM, 11 },
  { ItemPoolType.POOL_ULTRA_SECRET, 92 },
  { ItemPoolType.POOL_CRANE_GAME, 96 },
  { ItemPoolType.POOL_SHELL_GAME, 6 },
  { ItemPoolType.POOL_ROTTEN_BEGGAR, 9 },
  { ItemPoolType.POOL_BATTERY_BUM, 10 },
  { ItemPoolType.POOL_OLD_CHEST, 25 },
  { ItemPoolType.POOL_WOODEN_CHEST, 11 },
  { ItemPoolType.POOL_MOMS_CHEST, 20 },
  { ItemPoolType.POOL_BABY_SHOP, 84 },
}
local poolPickerNormal = WeightedOutcomePicker()
local poolPickerGreed = WeightedOutcomePicker()
for key, value in pairs(bothModePools) do
  poolPickerGreed:AddOutcomeFloat(value[1], value[2])
  poolPickerNormal:AddOutcomeFloat(value[1], value[2])
end
for key, value in pairs(weightedPools) do
  poolPickerNormal:AddOutcomeFloat(value[1], value[2])
end
for key, value in pairs(weightedGreedPools) do
  poolPickerGreed:AddOutcomeFloat(value[1], value[2])
end
function mod:GetRandomPool(myRNG)
  local greed = game.Difficulty > Difficulty.DIFFICULTY_HARD
  local pool = greed and poolPickerGreed or poolPickerNormal
  return pool:PickOutcome(myRNG)
end

function mod:GetRandomElement(table, rng)
  local num = rng:RandomInt(#table) + 1
  return table[num]
end

--mom found the tainted treasures method i nabbed so the room gen stuff would work
function mod:UtilShuffleTable(tbl, rng)
	for i = #tbl, 2, -1 do
    local j = rng:RandomInt(i) + 1
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function mod:BoolToNum(bool)
  if bool then
    return 1
  end
  return 0
end

local function incl(script)
  --print(script)
  include("scripts/"..script)
end


mod.CONST = {}
local earlyLoad = {
  "constants/constants",
  "constants/items",
  "constants/desc",
  "meta/toolbox",
  "meta/savedata",
  "meta/callbacks",
  "meta/customslots",
  "meta/cardController",
  "meta/customTearFlags",
  "meta/customTearVariants",
  "meta/redkeyLevelGen",

  "effects/__core",
  "familiars/nightmares",
}

for index, value in ipairs(earlyLoad) do
  incl(value)
end

local i_ = "items/"
local p_ = i_.."passive/"
local a_ = i_.."active/"
local f_ = i_.."familiars/"
local m_ = i_.."misc/"
local t_ = i_.."trinkets/"

local midLoad = {
  m_.."itemPopup",
  m_.."d4trackers",

  p_.."wickedSoul",
  a_.."dStock",
  p_.."electricDiceBustedBattery",
  p_.."hellfireCrownOfBlood",
  p_.."oldUrn",
  a_.."assistTrophyItemBox",
  a_.."trinketSmasher",
  a_.."cursedMushroom",
  p_.."starSpawn",
  p_.."bravery",
  p_.."planchette",
  a_.."encyclopedia",
  p_.."lourdesWater",
  a_.."boline",
  a_.."woodenDiceBookOfExodus",
  p_.."techModulo",
  p_.."apollyonsCrown",
  f_.."strangeApple",
  m_.."fruitMilkHalloweenCandyFlagMods",
  a_.."tiamatsDice",
  p_.."cursedCreditCard",
  p_.."red",
  p_.."lanternBatteryCellphoneBattery",
  a_.."oldDice",
  a_.."cursedCandle",
  a_.."abandonedBox",
  p_.."redCap",
  p_.."wickedRing",
  p_.."darkness",
  p_.."ganymede",
  p_.."airFreshener",
  p_.."wrath",
  p_.."nightshade",
  p_.."loversMask",
  p_.."carolinaReaperNagaViper",
  m_.."newLocustItems",
  p_.."chrismatory",
  p_.."fitusFortunus",
  p_.."crossedHeart",
  p_.."superiority",
  p_.."3dGlasses",

  t_.."twoOfCoins",
  t_.."stoneKey",
  t_.."treasurersKeyCursedKey",
  t_.."blankBook",
  t_.."diceRoller",
  t_.."gachapon",
  t_.."powerInverter",
  t_.."scorchedWood",
  t_.."demoniumPage",
}
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_ELECTROSTUN, {
  ApplyLogic = function (_, p, tear)
      if p:HasCollectible(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) then
          local rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PLASMA_GLOBE) 
          local proc = p.Luck >= 0 and (mod.PlasmaGlobeBaseProc + (mod.PlasmaGlobeBaseProc * (p.Luck / 2))) or (mod.PlasmaGlobeBaseProc / math.abs(p.Luck))
          if rng:RandomFloat() > proc then
              return
          end
          return true
      end
  end,
  EnemyHitEffect = function (_, tear, pos, enemy)
      local p = mod:UtilGetPlayerFromTear(tear)
      mod:UtilAddElectrostun(enemy, p, 60)
  end,
  TearColor = mod.ElectroStunTearColor
})

for index, value in ipairs(midLoad) do
  incl(value)
end
function mod:EvaluateGenericStatItems(player, flags)
  if not player then
    return
  end
  local wickedSoulMult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WICKED_SOUL)
  local goldenWatchMult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_GOLDEN_WATCH)
  local lankyMushMult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANKY_MUSHROOM)
  local gachaponMult = mod:GachaponStatsEvaluate(player)
  local p_data = player:GetData()
  local lourdesBuff = p_data.sw_shouldEdithBoost

  if flags == CacheFlag.CACHE_DAMAGE then
    player.Damage = mod:DamageUp(player, 0.5 * wickedSoulMult)
    player.Damage = mod:DamageUp(player, lankyMushMult * 0.7)
    player.Damage = mod:DamageUp(player, 0.6 * gachaponMult)

    player.Damage = mod:DamageUp(player, 1 * mod:BoolToNum(player:HasCollectible(CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM)))
    player.Damage = mod:DamageUp(player, 0.5 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WOODEN_HORN))
    player.Damage = mod:DamageUp(player, 0.3 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_SILVER_RING))
    player.Damage = mod:DamageUp(player, p_data.SomethingWickedPData.EncycloBelialBuff or 0)
    player.Damage = mod:DamageUp(player, (0.7 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_CROSSED_HEART)))
    
    if p_data.SomethingWickedPData.inverterdmgToAdd then
        player.Damage = mod:DamageUp(player, 0, p_data.SomethingWickedPData.inverterdmgToAdd)
    end
    if p_data.sw_supCount ~= nil then
        player.Damage = mod:DamageUp(player, 0, 0.7*math.min(p_data.sw_supCount, 7))
    end
  end
  if flags == CacheFlag.CACHE_FIREDELAY then
    player.MaxFireDelay = mod:TearsUp(player, lankyMushMult * -0.4)
    player.MaxFireDelay = mod:TearsUp(player, gachaponMult*0.2)
    player.MaxFireDelay = mod:TearsUp(player, 0.45 * goldenWatchMult)

    player.MaxFireDelay = mod:TearsUp(player, 0.4 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WHITE_ROSE))
    player.MaxFireDelay = mod:TearsUp(player, 0.5 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHAMPOO))
  end
  if flags == CacheFlag.CACHE_LUCK then
    player.Luck = player.Luck + (1 * (wickedSoulMult+gachaponMult+goldenWatchMult))
  end
  if flags == CacheFlag.CACHE_SPEED then
    player.MoveSpeed = player.MoveSpeed + (0.2 * (wickedSoulMult+gachaponMult+goldenWatchMult))

    player.MoveSpeed = player.MoveSpeed + player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHAMPOO)*0.3
  end
  if flags == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed + (0.1 * (wickedSoulMult+gachaponMult))
      player.ShotSpeed = player.ShotSpeed - (0.2 * mod:BoolToNum(player:HasCollectible(CollectibleType.SOMETHINGWICKED_GANYMEDE)))
  end
  if flags == CacheFlag.CACHE_RANGE then
      player.TearRange = player.TearRange + (1.2 * wickedSoulMult * 40)
      player.TearRange = player.TearRange + (40 * 0.75 * (lankyMushMult+gachaponMult+goldenWatchMult))
  end
  if flags == CacheFlag.CACHE_TEARFLAG then
    if lourdesBuff then
      player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
    end
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_FRUIT_MILK) then
        if not p_data.SomethingWickedPData.FruitMilkFlags then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_FRUIT_MILK)
            local newFlags = mod:GenerateFruitFlag(c_rng)
            p_data.SomethingWickedPData.FruitMilkFlags = newFlags
        end

        --print(p_data.SomethingWickedPData.FruitMilkFlags)
        player.TearFlags = player.TearFlags | p_data.SomethingWickedPData.FruitMilkFlags
    end

    if p_data.SomethingWickedPData.BonusVanillaFlags then
        player.TearFlags = player.TearFlags | p_data.SomethingWickedPData.BonusVanillaFlags
    end
  end
  if flags == CacheFlag.CACHE_TEARCOLOR then
    if lourdesBuff then
      player.TearColor = player.TearColor * Color(1.5, 2, 2, 1, 0.15, 0.17, 0.17)
    end
  end
  if  flags == CacheFlag.CACHE_FAMILIARS then
    local stacks, rng, source = mod:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_STRANGE_APPLE)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_RETROSNAKE, stacks, rng, source)
  end

  if flags == CacheFlag.CACHE_SIZE then
    player.SpriteScale = player.SpriteScale * (lankyMushMult == 0 and Vector(1, 1) or Vector(0.75, 1.5))
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.EARLY, mod.EvaluateGenericStatItems)

function mod:EvaluateLateStats(player, flags)
  local shouldBoost = player:GetData().sw_shouldEdithBoost
  if flags == CacheFlag.CACHE_FIREDELAY then
    if shouldBoost then
      player.MaxFireDelay = mod:TearsUp(player, 0, 0, 1.5)
    end
  end
  if flags == CacheFlag.CACHE_DAMAGE then
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_SILVER_RING) then
      player.Damage = player.Damage * 1.1
    end
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WICKED_SOUL) then
      player.Damage = player.Damage * 1.3
    end
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_FRUIT_MILK) then
      player.Damage = player.Damage * 0.2
    end
    if shouldBoost then
      player.Damage = player.Damage * 1.2
    end
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_TECH_MODULO) then
        player.Damage = player.Damage * 2/3
    end
  end
  mod:StarSpawnEval(player, flags)
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.EvaluateLateStats)

local quickThrowables = {
  CollectibleType.SOMETHINGWICKED_CURSED_CANDLE,
}
function mod:useItemGeneric(id, rng, player, flags)
  if id == CollectibleType.SOMETHINGWICKED_EDENS_HEAD then  
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
      return
    end

    local throwable = SomethingWicked:GetRandomElement(mod.edensHeadthrowables, rng)
    player:UseActiveItem(throwable)
    return
  end
  if mod:UtilTableHasValue(quickThrowables, id) then
    return mod:HoldItemUseHelper(player, flags, id)
  end
  if id == CollectibleType.SOMETHINGWICKED_EVIL_PIGGYBANK
  or id == CollectibleType.SOMETHINGWICKED_DADS_WALLET then
      return { Discharge = false, ShowAnim = true}
  end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useItemGeneric)

function mod:GenericOnPickups(player, room, id)
  if id == CollectibleType.SOMETHINGWICKED_WHITE_ROSE then
    for i = 1, 4, 1 do
      player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, player.Position)
    end
    return
  end
  if id == CollectibleType.SOMETHINGWICKED_RED_LOCKBOX then
    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_RED_LOCKBOX)
    for i = 1, 4 + c_rng:RandomInt(3), 1 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end
    return
  end
  if id == CollectibleType.SOMETHINGWICKED_WICKERMAN then
    for i = 1, 2, 1 do
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
    end
    return
  end
  mod:OldUrnPickup(player, room, id)
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, mod.GenericOnPickups)

function mod:GenericPostPurchase(player, pickup, isDevil)
  local p_data = player:GetData()
  if not isDevil then
    for i = 1, player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_GOLDEN_WATCH), 1 do
      player:RemoveCollectible(CollectibleType.SOMETHINGWICKED_GOLDEN_WATCH)
      mod:QueueItemPopUp(player, CollectibleType.SOMETHINGWICKED_GOLDEN_WATCH, 1, 1)

      sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
    end

    if pickup.Price == PickupPrice.PRICE_FREE then
      local id = p_data.somethingWicked_isMammonItem and CollectibleType.SOMETHINGWICKED_EVIL_PIGGYBANK or CollectibleType.SOMETHINGWICKED_DADS_WALLET
      
      local charge, slot = mod:CheckPlayerForActiveData(player, id)
      if slot == -1 then
          local _, np = mod:GlobalPlayerHasCollectible(id)
          if not np then
              return
          end
          charge, slot = mod:CheckPlayerForActiveData(np, id)
          player = np
      end
      
      if slot ~= -1 and charge > 0 then
        player:SetActiveCharge(charge - 1, slot)
        if charge == 1 then
            player:RemoveCollectible(id)
        end
      end
    end
  end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_POST_PURCHASE_PICKUP, mod.GenericPostPurchase)

function mod:LatePickupUpdate(pickup)
  local p_data = pickup:GetData()
  
  if pickup:IsShopItem() then
    if mod:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_DADS_WALLET) then
      if pickup.Price > 0 then
        pickup.Price = PickupPrice.PRICE_FREE
      end
    end
    if mod:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_EVIL_PIGGYBANK)
    and pickup.Price ~= PickupPrice.PRICE_FREE then
      if pickup.Price < 0 then
        pickup.Price = PickupPrice.PRICE_FREE
  
        p_data.somethingWicked_isMammonItem = true
      end
    else
      p_data.somethingWicked_isMammonItem = false
    end
    
    if mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_MEAL_COUPON) then
      if pickup.Price > 0 then
          pickup.Price = PickupPrice.PRICE_FREE
      end
    end
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CallbackPriority.LATE, mod.LatePickupUpdate)

function mod:OnNewRoom()
  local level = game:GetLevel()
  local currRoom = level:GetCurrentRoomDesc()
  local currIdx = level:GetCurrentRoomIndex()

  if currRoom.VisitedCount == 1 and level:GetStartingRoomIndex() == currIdx then
      -- new floor
      mod.save.runData.CurseList = {}
      mod.HasGenerateRedThisFloor = false
      
      for _, player in ipairs(mod:UtilGetAllPlayers()) do
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WOODEN_DICE) then
          player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
        
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WICKED_SOUL) then
          mod:WickedSoulOnPickup(player)
        end

        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_RED_NIGHTMARE) then
          mod:RedGenerate(game, level, player)
        end
      end

      --wickerman
      if mod:GenericShouldGenerateRoom(level, game) then
        local flag, player = mod:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_WICKERMAN)
        if flag and player then
            local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_WICKERMAN)
            if not mod:RoomTypeCurrentlyExists(RoomType.ROOM_SACRIFICE, level, rng) then
                mod:GenerateSpecialRoom("sacrifice", 1, 5, true, rng)
            end
        end
      end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.EARLY, mod.OnNewRoom)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
  local room = game:GetRoom()
  local rtype = room:GetType()

  local level = game:GetLevel()
  local currRoom = level:GetCurrentRoomDesc()
  local currIdx = level:GetCurrentRoomIndex()

  if currRoom.VisitedCount == 1 then
    --cats eye
    if rtype == RoomType.ROOM_SECRET or rtype == RoomType.ROOM_SUPERSECRET then
      for i = 1, mod:GlobalGetTrinketNum(TrinketType.SOMETHINGWICKED_CATS_EYE), 1 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos()), Vector.Zero, nil)
      end
    end
  end
  
  local glitch = mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_ZZZZZZ_MAGNET)
  local curse = mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_CURSED_KEY)
  local treasure = mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_TREASURERS_KEY)

  for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
    local door = room:GetDoor(i)
    if door then
      mod:CurseKeyTreasurersKeyDoorChecks(door, currIdx, curse, treasure)

      if glitch then
        mod:ZZZZZZConvertDoor(door)
      end
    end
  end

  local abyssLocusts = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST)
  for _, player in ipairs(mod:UtilGetAllPlayers()) do
    mod:DestroyCrownLocustsWithInitSeeds(nil, abyssLocusts, player)
  end
end)

function mod:PostEntityTakeDMG(ent, amount, flags, source, dmgCooldown)
  if not ent then
    return
  end
  local p = ent:ToPlayer()
  if p then
    mod:StarSpawnPlayerDamage(p)
    mod:BolineTakeDMG(p)

    --indulgence
    if p:HasTrinket(TrinketType.SOMETHINGWICKED_PRINT_OF_INDULGENCE) then
      local t_rng = p:GetTrinketRNG(TrinketType.SOMETHINGWICKED_PRINT_OF_INDULGENCE)
      if t_rng:RandomFloat() < 0.1*p:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_PRINT_OF_INDULGENCE) then
          local room = game:GetRoom()
          local pos = room:FindFreePickupSpawnPosition(p.Position)
          Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, pos, Vector.Zero, p)
      end
    end

    return
  end

  local w = ent:ToFamiliar()
  if w then
    if w.Variant == FamiliarVariant.WISP then
      local collectibleType = w.SubType

      mod:PostBolineWispTakeDamage(w, collectibleType)
    end

    return
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, mod.PostEntityTakeDMG)

function mod:OnUsePill(effect, player)
  if player:HasTrinket(TrinketType.SOMETHINGWICKED_SUGAR_COATED_PILL) then
    mod.save.runData.sugarCoatedPillEffect = effect
    player:TryRemoveTrinket(TrinketType.SOMETHINGWICKED_SUGAR_COATED_PILL)

    sfx:Play(SoundEffect.SOUND_VAMP_GULP)
end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.OnUsePill)

function mod:GetPillEffect(effect)
  local sugar = (mod.save.runData.sugarCoatedPillEffect)
  if sugar and sugar == effect then
    return PillEffect.PILLEFFECT_FULL_HEALTH
  end
end
mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, mod.GetPillEffect)

local bombVariants = {
  [2761] = { CollectibleType.SOMETHINGWICKED_VOID_BOMBS, "sw_isVoidBomb" }
}
function mod:BombInit(bomb)
  local p = bomb.SpawnerEntity
  if not p then return end
  p = p:ToPlayer()
  local b_data = bomb:GetData()

  if not p then return end
  
    for index, value in pairs(bombVariants) do
      local id = value[1]
      if type(id) == "function" then
        id = id(bomb, p)
      else
        id = p:HasCollectible(id)
      end

      if id then
        b_data[value[2]] = true

        if bomb.Variant > 4 or bomb.Variant < 3 then
          bomb.Variant = index
        end
      end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, mod.BombInit)
function mod:BombUpdate(bomb)
  local p = bomb.SpawnerEntity
  if not p then return end
  p = p:ToPlayer()
  if not p then return end

  local b_data = bomb:GetData()
    local b_s = bomb:GetSprite()
    if b_s:IsPlaying("Explode") then
      --void bombs
      if b_data.sw_isVoidBomb then
        local c_rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_VOID_BOMBS)
        if not bomb.IsFetus or (c_rng:RandomFloat() > 0.2 + (0.026 * p.Luck)) then
          local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MOTV_HELPER, 0, bomb.Position, Vector.Zero, p)
          local void = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, bomb.Position, Vector.Zero, p)
          void=void:ToLaser()

          effect.Visible = false
          void.Parent = effect
          void.Timeout = 76
          void:AddTearFlags(TearFlags.TEAR_PULSE)
          void.CollisionDamage = bomb.ExplosionDamage/12

          local scaleMult = math.max(0.4, bomb.ExplosionDamage/100)
          void.Size = void.Size*scaleMult
          void:Update()
          void.SpriteScale = Vector(scaleMult, scaleMult)
          void.SizeMulti = Vector(scaleMult, scaleMult)
          void.Radius = 80*scaleMult

          sfx:Play(SoundEffect.SOUND_MAW_OF_VOID, 1, 0)
        end
      end
    end
  end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.BombUpdate)

--[[local itemsToLoad = {
  !-"ramshead",

  !-"discipleseye",
  !-"catfood",
  !-"fitusfortunus",
  !-"biretta",
  !-"spidernest",
  "legion",
  !-"teratomashield",
  !-"glitchcity",
  !!-"devilstail",
  "shotgrub",
  "minotaur",
  "balrogsheart",
  "cursemask",
  "bananamilk",
  "safetymasktemperance",
  "redqueen",
  "brokenbell",
  "saintshead",
  "eyeofprovidence",
  "tombstone",
  "blacksalt",
  "bloodhail",
  "voidscall",
  "screwattack",
  "pressurevalve",
  "lightsharddarkshard",
  "pendulum",
  "yoyo",
  "pieceofsilver",
  "darkness",
  "ganymede",
  
  !-"rogueplanet",
  !-"minos",
  !-"yellowshard",
  !-"solomon",
  !-"devilsknife",
  "phobosanddeimos",
  "littleattractor",
  "msgonorrhea",
  !-"justiceandsplendor",
  "cutiefly",
  "fatwisp",
  "jokerbaby",

  !-"balrogshead",
  !-"bookoflucifer",
  !-"toybox",
  !-"bookofinsanity",
  !-"voidegg",
  !-"chaosheart",
  !-"chasm",
  !-"fetusinfetu",
  "facestabber",
  !-"goldencard",
  "fearstalkstheland",
  "bookofleviathan",
  "marblesprouttaskmanager",
  "babymandrake",
  "icewand",
  "dudael",
  "magicclay",
  "lastprism",
  
  !-"bobsheart",
  !-"damnedsoulvirtuoussoul",
  !-"demoncore",
  !-"voidheart",
  "mrskits",
  !-"giftcard",
  !-"nightmarefuelvirtue",
  "zzzzzzmagnet",
  "redkeychain",
}

local cardsToLoad = {
  "conjure",
  "boonofthemagpieeye",
  --"k0",
  --"mantis_mantisgod",

  "theAeon",
  "theMagus",
  "TheAdjustment",
  "theLust",
  "theFortune",
  "theArt",

  --"theAeonReversed",
  --"theMagusReversed",
  "theFortuneReversed",

  --"turkeyvulture", --also void beggar and rotten beggar
  "bourgeoisTarot",
}
local postMiscLoad = {
  "EIDadder",
  "unlockHandler",
  "itempools",
  "cardController",
  "compat/____core",
  "dss/deadseascrolls"
}]]

--thanks to both Eternal Items: Repented and Deliverance for this amalgamation of yoinked code, for loading item files

--Putting full credits here so i dont forget when i release the mod
--[[
Lead coder and spriter: hellfireJune
Guest spriter (costumes and death items): steve2552
Concept art + some general concepting: Nevernamed
Playtesting, feedback, and reporting bugs: 
  TheTurtleMelon
  We Strvn
  Skkull
  Saturn
  oilyspoily
  SinBiscuit
  Steve2552
  Sosor
  lwrachnya
  Aeronaut
  Some Bunny
Special thanks: 
  lambchop_is_ok
  PattieMurr (music, unused)
  DungeonPenguin
  Onehand and Unobtained (the turtlemelon tattoo)
  The Fiend Folio team
  The Gungeon Modding Crew
  and the countless mods that i looked at for reference when i didn't know how to code in lua
]]



print("Something wicked this way comes...")