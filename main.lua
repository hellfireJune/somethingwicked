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
  "meta/unlocks",
  "meta/savedata",
  "meta/callbacks",
  "meta/customslots",
  "meta/cardController",
  "meta/customTearFlags",
  "meta/customTearVariants",
  "meta/redkeyLevelGen",
  "meta/multishotcallbackfix",

  "effects/__core",
  "familiars/nightmares",
  "familiars/teratomas",
  "compat/main",
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
local c_ = "cards/"

local midLoad = {
  m_.."itemPopup",
  m_.."d4TrackingAgain",
  m_.."blanks",

  p_.."wickedSoul",
  a_.."dStock",
  p_.."electricDiceBustedBattery",
  p_.."hellfireCrownOfBlood",
  p_.."oldUrn",
  a_.."assistTrophyItemBox",
  a_.."trinketSmasher",
  a_.."cursedMushroomFearStalksTheLand",
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
  a_.."bookOfLucifer",
  a_.."chasm",
  a_.."chaosHeart",
  m_.."boosterBoxGoldenCard",
  a_.."toybox",
  a_.."balrogsHead",
  p_.."minosTheSnake",
  a_.."toybox",
  p_.."disciplesEye",
  f_.."devilsknife",
  a_.."voidEgg",
  f_.."solomon",
  f_.."justiceAndSplendor",
  p_.."glitchCity",
  p_.."spiderNest",
  f_.."roguePlanet",
  a_.."familiarDupeItem",
  p_.."disAcheron",
  p_.."reliquary",
  a_.."bookOfInsanity",
  p_.."witchsSalt",
  p_.."boltsOfLight",
  p_.."livingWater",
  p_.."lightShardDarkShard",
  a_.."bookOfLeviathan",
  p_.."astigmatism",
  p_.."curseMask",
  p_.."starOfProvidence",
  m_.."catTeaser",
  p_.."sudariumOfOviedo",
  p_.."tefelin",
  p_.."doublesFullHouse",
  p_.."19inchrack",
  p_.."ultrachancesplititemthing",
  p_.."yoyo",

  t_.."twoOfCoins",
  t_.."stoneKey",
  t_.."treasurersKeyCursedKey",
  t_.."blankBook",
  t_.."diceRoller",
  t_.."gachapon",
  t_.."powerInverter",
  t_.."scorchedWood",
  t_.."demoniumPage",
  t_.."giftCard",
  t_.."bobsHeart",
  t_.."ticketRoll",
  t_.."demonCore",

  c_.."bourgeoisTarot",
}
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_ELECTROSTUN, {
  ApplyLogic = function (_, p, tear)
      if p:HasCollectible(mod.ITEMS.PLASMA_GLOBE) then
          local rng = p:GetCollectibleRNG(mod.ITEMS.PLASMA_GLOBE) 
          local proc = p.Luck >= 0 and (mod.PlasmaGlobeBaseProc + (mod.PlasmaGlobeBaseProc * (p.Luck / 2))) or (mod.PlasmaGlobeBaseProc / math.abs(p.Luck))
          if rng:RandomFloat() > proc then
              return
          end
          return true
      end
  end,
  EnemyHitEffect = function (_, tear, pos, enemy, p)
      mod:UtilAddElectrostun(enemy, p, 60)
  end,
  TearColor = mod.ElectroStunTearColor
})
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_DREAD, {
  ApplyLogic = function (_, p, tear)
    if p:HasCollectible(mod.ITEMS.MONOKUMA) then
      return true, true
    end
    if p:HasCollectible(mod.ITEMS.MALEDICTION) then
        local rng = p:GetCollectibleRNG(mod.ITEMS.MALEDICTION) 
        local proc = 1/(4-(p.Luck*0.25))
        if rng:RandomFloat() < proc then
            return true
        end
    end
  end,
  EnemyHitEffect = function (_, tear, pos, enemy, p)
      mod:UtilAddDread(enemy, 2, p)
  end,
  TearColor = mod.DreadTearColor
})

for index, value in ipairs(midLoad) do
  incl(value)
end
function mod:EvaluateGenericStatItems(player, flags)
  if not player then
    return
  end
  local effects = player:GetEffects()
  local wickedSoulMult = player:GetCollectibleNum(mod.ITEMS.WICKED_SOUL)
  local goldenWatchMult = player:GetCollectibleNum(mod.ITEMS.GOLDEN_WATCH)
  local lankyMushMult = player:GetCollectibleNum(mod.ITEMS.LANKY_MUSHROOM)
  local gachaponMult = mod:GachaponStatsEvaluate(player)
  local roguePlanet = mod:BoolToNum(player:HasCollectible(mod.ITEMS.ROGUE_PLANET_ITEM))

  local soulId = ((game:GetLevel():GetCurses() == LevelCurse.CURSE_NONE) and mod.TRINKETS.VIRTUOUS_SOUL or mod.TRINKETS.DAMNED_SOUL)
  local curseSoulMult = player:GetTrinketMultiplier(soulId)

  local bolts = mod:BoolToNum(player:HasCollectible(mod.ITEMS.BOLTS_OF_LIGHT))

  local p_data = player:GetData()
  local lourdesBuff = p_data.sw_shouldEdithBoost

  if flags == CacheFlag.CACHE_DAMAGE then
    player.Damage = mod:DamageUp(player, 0.5 * wickedSoulMult)
    player.Damage = mod:DamageUp(player, lankyMushMult * 0.7)
    player.Damage = mod:DamageUp(player, 0.6 * gachaponMult)
    player.Damage = mod:DamageUp(player, 0.3 * curseSoulMult)

    player.Damage = mod:DamageUp(player, 1 * mod:BoolToNum(player:HasCollectible(mod.ITEMS.AVENGER_EMBLEM)))
    player.Damage = mod:DamageUp(player, 0.5 * player:GetCollectibleNum(mod.ITEMS.WOODEN_HORN))
    player.Damage = mod:DamageUp(player, 0.3 * player:GetCollectibleNum(mod.ITEMS.SILVER_RING))
    player.Damage = mod:DamageUp(player, p_data.WickedPData.EncycloBelialBuff or 0)
    player.Damage = mod:DamageUp(player, (0.7 * player:GetCollectibleNum(mod.ITEMS.CROSSED_HEART)))
    player.Damage = mod:DamageUp(player, 0.7 * player:GetCollectibleNum(mod.ITEMS.RAMS_HEAD))
    player.Damage = mod:DamageUp(player, 0.4 * effects:GetCollectibleEffectNum(mod.ITEMS.BOOK_OF_LUCIFER))
    
    if p_data.WickedPData.inverterdmgToAdd then
        player.Damage = mod:DamageUp(player, 0, p_data.WickedPData.inverterdmgToAdd)
    end
    if p_data.sw_supCount ~= nil then
        player.Damage = mod:DamageUp(player, 0, 0.7*math.min(p_data.sw_supCount, 7))
    end
  end
  if flags == CacheFlag.CACHE_FIREDELAY then
    player.MaxFireDelay = mod:TearsUp(player, lankyMushMult * -0.4)
    player.MaxFireDelay = mod:TearsUp(player, gachaponMult*0.2)
    player.MaxFireDelay = mod:TearsUp(player, 0.45 * goldenWatchMult)
    player.MaxFireDelay = mod:TearsUp(player, 0, 0.5 * curseSoulMult)

    player.MaxFireDelay = mod:TearsUp(player, 0.4 * player:GetCollectibleNum(mod.ITEMS.WHITE_ROSE))
    player.MaxFireDelay = mod:TearsUp(player, 0.5 * player:GetCollectibleNum(mod.ITEMS.BOTTLE_OF_SHAMPOO))
    player.MaxFireDelay = mod:TearsUp(player, player:GetCollectibleNum(mod.ITEMS.RAMS_HEAD) * 0.5)
    player.MaxFireDelay = mod:TearsUp(player, player:GetCollectibleNum(mod.ITEMS.ASTIGMATISM)* 0.35)
    player.MaxFireDelay = mod:TearsUp(player, player:GetTrinketMultiplier(mod.TRINKETS.FLUKE_WORM)* 0.46)

    player.MaxFireDelay = mod:TearsUp(player, 0.5 * effects:GetNullEffectNum(mod.NULL.VIATHAN))
    if p_data.WickedPData.sudariumRooms then
      player.MaxFireDelay = mod:TearsUp(player, 0, (p_data.WickedPData.sudariumRooms/6)*2)
    end
    if p_data.sw_mantleSudariumFrames then
      player.MaxFireDelay = mod:TearsUp(player, 0, (p_data.sw_mantleSudariumFrames)/60)
    end
    if p_data.WickedPData.reliqBuff then
        player.MaxFireDelay = mod:TearsUp(player, 0, p_data.WickedPData.reliqBuff*0.25)
    end
  end
  if flags == CacheFlag.CACHE_LUCK then
    player.Luck = player.Luck + (1 * (wickedSoulMult+gachaponMult+goldenWatchMult+curseSoulMult))
    player.Luck = player.Luck + player:GetCollectibleNum(mod.ITEMS.ADDER_STONE)
  end
  if flags == CacheFlag.CACHE_SPEED then
    player.MoveSpeed = player.MoveSpeed + (0.2 * (wickedSoulMult+gachaponMult+goldenWatchMult))
    player.MoveSpeed = player.MoveSpeed + (0.15 * curseSoulMult)

    player.MoveSpeed = player.MoveSpeed + player:GetCollectibleNum(mod.ITEMS.BOTTLE_OF_SHAMPOO)*0.3

    local leviathanBuff = effects:GetNullEffectNum(mod.NULL.VIATHAN)
    leviathanBuff = math.min(leviathanBuff, 4)
    leviathanBuff = ((2^leviathanBuff)-1)/(2^leviathanBuff)/0.9375
    player.MoveSpeed = player.MoveSpeed + leviathanBuff*0.4
  end
  if flags == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed + (0.1 * (wickedSoulMult+gachaponMult+curseSoulMult))
      player.ShotSpeed = player.ShotSpeed + (0.14 * player:GetCollectibleNum(mod.ITEMS.STAR_TREAT))
      player.ShotSpeed = player.ShotSpeed - (0.16 * bolts)
  end
  if flags == CacheFlag.CACHE_RANGE then
      player.TearRange = player.TearRange + (1.2 * wickedSoulMult * 40)
      player.TearRange = player.TearRange + (40 * 0.75 * (lankyMushMult+gachaponMult+goldenWatchMult+curseSoulMult))
      player.TearRange = player.TearRange + (roguePlanet * 13*40)
  end
  if flags == CacheFlag.CACHE_TEARFLAG then
    if lourdesBuff then
      player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
    end
    if player:HasCollectible(mod.ITEMS.FRUIT_MILK) then
        if not p_data.WickedPData.FruitMilkFlags then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.FRUIT_MILK)
            local newFlags = mod:GenerateFruitFlag(c_rng)
            p_data.WickedPData.FruitMilkFlags = newFlags
        end

        --print(p_data.WickedPData.FruitMilkFlags)
        player.TearFlags = player.TearFlags | p_data.WickedPData.FruitMilkFlags
    end
    if player:HasCollectible(mod.ITEMS.GANYMEDE) or player:HasTrinket(mod.TRINKETS.FLUKE_WORM) then
      player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
    end

    if player:HasCollectible(mod.ITEMS.ROGUE_PLANET_ITEM) then
      player.TearFlags = player.TearFlags | (TearFlags.TEAR_ORBIT | TearFlags.TEAR_SPECTRAL)
    end

    if p_data.WickedPData.BonusVanillaFlags then
        player.TearFlags = player.TearFlags | p_data.WickedPData.BonusVanillaFlags
    end
  end
  if flags == CacheFlag.CACHE_TEARCOLOR then
    if lourdesBuff then
      player.TearColor = player.TearColor * Color(1.5, 2, 2, 1, 0.15, 0.17, 0.17)
    end
    if bolts > 0 then
      player.TearColor = player.TearColor * Color(1,1,1)
    end
    if player:HasCollectible(mod.ITEMS.MONOKUMA) then
      player.TearColor = player.TearColor * mod.DreadTearColor
    end
  end
  if  flags == CacheFlag.CACHE_FAMILIARS then
    local stacks, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.STRANGE_APPLE)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_RETROSNAKE, stacks, rng, source)
    
    stacks, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.DEVILSKNIFE_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE, stacks, rng, source)
    
    stacks, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.SOLOMON_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_SOLOMON, stacks, rng, source)
    
    stacks, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.JUSTICE_AND_SPLENDOR)
    if player:HasCollectible(mod.ITEMS.JUSTICE_AND_SPLENDOR) then
        if p_data.WickedPData.isSplendorful
        or player:GetHearts() >= player:GetEffectiveMaxHearts() then
            stacks = stacks + 1
        else
            stacks = 0
        end
    end
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR, stacks, rng, source)
    
    _, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.ROGUE_PLANET_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET, roguePlanet, rng, source)
    
    stacks, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.FLY_SCREEN_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_FLY_SCREEN, stacks, rng, source)
    
    stacks, rng, source = mod:BasicFamiliarNum(player, mod.ITEMS.MINOS_ITEM)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD, mod:BoolToNum(player:HasCollectible(mod.ITEMS.MINOS_ITEM)), rng, source)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_MINOS_BODY, (stacks * 2) + (stacks > 0 and 2 - stacks or 0), rng, source)

    stacks = mod:BoolToNum(player:HasTrinket(mod.TRINKETS.NIGHTMARE_FUEL)) rng = player:GetTrinketRNG(mod.TRINKETS.NIGHTMARE_FUEL)
    source = Isaac.GetItemConfig():GetTrinket(mod.TRINKETS.NIGHTMARE_FUEL)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, stacks+(p_data.sw_nightmaresDiedToday or 0), rng, source, mod.NightmareSubTypes.NIGHTMARE_TRINKET)
  end

  if flags == CacheFlag.CACHE_SIZE then
    player.SpriteScale = player.SpriteScale * (lankyMushMult == 0 and Vector(1, 1) or Vector(0.75, 1.5))
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.EARLY, mod.EvaluateGenericStatItems)

function mod:EvaluateLateStats(player, flags)
  local p_data = player:GetData()

  local shouldBoost = p_data.sw_shouldEdithBoost
  local waterBoosts = p_data.sw_currentWaterAuras or 0
  local boltsOfLight = player:HasCollectible(mod.ITEMS.BOLTS_OF_LIGHT)
  if flags == CacheFlag.CACHE_FIREDELAY then
    if shouldBoost then
      player.MaxFireDelay = mod:TearsUp(player, 0, 0, 1.5)
    end
    if player:HasCollectible(mod.ITEMS.DOUBLES) then
      player.MaxFireDelay = mod:TearsUp(player, 0, 0, 0.456)
    end
    if boltsOfLight then
      player.MaxFireDelay = mod:TearsUp(player, 0, 0, 3.6)
    end
    player.MaxFireDelay = mod:TearsUp(player, 0, 0, 1+(waterBoosts/5))
  end
  if flags == CacheFlag.CACHE_DAMAGE then
    if player:HasCollectible(mod.ITEMS.SILVER_RING) then
      player.Damage = player.Damage * 1.1
    end
    if player:HasCollectible(mod.ITEMS.WICKED_SOUL) then
      player.Damage = player.Damage * 1.3
    end
    if player:HasCollectible(mod.ITEMS.FRUIT_MILK) then
      player.Damage = player.Damage * 0.25
    end
    if shouldBoost or waterBoosts > 0 then
      player.Damage = player.Damage * 1.2
    end
    if player:HasCollectible(mod.ITEMS.TECH_MODULO) then
        player.Damage = player.Damage * 2/3
    end
    if boltsOfLight then
      player.Damage = player.Damage * 0.2777776
    end
  end
  mod:StarSpawnEval(player, flags)
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.EvaluateLateStats)

local quickThrowables = {
  mod.ITEMS.CURSED_CANDLE,
  mod.ITEMS.BALROGS_HEAD,
}
function mod:useItemGeneric(id, rng, player, flags)
  if id == mod.ITEMS.EDENS_HEAD then  
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
  if id == mod.ITEMS.ACTIVATED_CHARCOAL then
    return true
  end
  if id == mod.ITEMS.EVIL_PIGGYBANK
  or id == mod.ITEMS.DADS_WALLET then
      return { Discharge = false, ShowAnim = true}
  end
  if id == mod.ITEMS.VOID_EGG then
    mod:AddLocusts(player, rng:RandomInt(3) + 2, rng) return true
  end

  if id == mod.ITEMS.BABY_MANDRAKE then
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MANDRAKE_SCREAM_LARGE, 0, player.Position, Vector.Zero, player)
    sfx:Play(SoundEffect.SOUND_MULTI_SCREAM)

    return true
  end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useItemGeneric)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player)
  local pEffects = player:GetEffects()
  if pEffects:HasCollectibleEffect (mod.ITEMS.ACTIVATED_CHARCOAL) then
    mod:AddItemWispForEval(player, CollectibleType.COLLECTIBLE_IPECAC)
  end
  if pEffects:HasCollectibleEffect(mod.ITEMS.THE_SHRINKS) then
    mod:AddItemWispForEval(player, CollectibleType.COLLECTIBLE_PLUTO)
  end
  if pEffects:HasNullEffect(mod.NULL.LUSTEFFECT) then
    mod:AddItemWispForEval(player, CollectibleType.COLLECTIBLE_HOLY_MANTLE)
  end

  if (player:GetCard(0) == mod.CARDS.MAGPIE_EYE_BOON or player:GetCard(1) == mod.CARDS.MAGPIE_EYE_BOON) then
    mod:AddItemWispForEval(player, CollectibleType.COLLECTIBLE_THERES_OPTIONS)
    mod:AddItemWispForEval(player, CollectibleType.COLLECTIBLE_MORE_OPTIONS)
  end

  local p_data = player:GetData()
  if player:HasTrinket(mod.TRINKETS.OPTIONS_TRINKET) and p_data.thatOneTrinketItem then
    mod:AddItemWispForEval(player, p_data.thatOneTrinketItem)
  end
  if player:HasCollectible(mod.ITEMS.MAGIC_EYE) and p_data.magicEyeItem then
    mod:AddItemWispForEval(player, p_data.magicEyeItem)
  end
end)

function mod:useCardGeneric(id, player, useflags)
  if id == mod.CARDS.STONE_OF_THE_PIT then    
    sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 1, 0)
    local trinket = game:GetItemPool():GetTrinket()
    player:AnimateTrinket(trinket, "Pickup")
    mod:UtilAddSmeltedTrinket(trinket, player)
    mod:IncrementStonesOfThePitUsed()
    return
  end
  if id == mod.CARDS.MAGPIE_EYE then
    mod:UseBoonCard(mod.CARDS.MAGPIE_EYE, mod.CARDS.MAGPIE_EYE_BOON, player, useflags)
    return
  end
  
  local pEffects = player:GetEffects()
  if id == mod.CARDS.THOTH_LUST then
    --player:AddSoulHearts(1)
    pEffects:AddNullEffect(mod.NULL.LUSTEFFECT, 6)
  end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useCardGeneric)

function mod:peffectGenericUpdate(player)
  local p_data = player:GetData()

  if player:HasTrinket(mod.TRINKETS.DAMNED_SOUL) or player:HasTrinket(mod.TRINKETS.VIRTUOUS_SOUL) then
    local hadCurse = (game:GetLevel():GetCurses() == LevelCurse.CURSE_NONE)
    if hadCurse ~= p_data.sw_hadCurse then
        p_data.sw_hadCurse = hadCurse
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
  end

  if p_data.WickedPData.queueNextItemBox and player.QueuedItem.Item == nil then
    p_data.WickedPData.queueNextItemBox = false
  end

  mod:SOPPlayerUpdate(player)
  mod:sudariumPeffectUpdate(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.peffectGenericUpdate)

function mod:GenericOnPickups(player, room, id)
  if id == mod.ITEMS.WHITE_ROSE then
    for i = 1, 4, 1 do
      player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, player.Position)
    end
    return
  end
  local getPos = function ()
    return room:FindFreePickupSpawnPosition(player.Position)
  end
  if id == mod.ITEMS.RED_LOCKBOX then
    local c_rng = player:GetCollectibleRNG(mod.ITEMS.RED_LOCKBOX)
    for i = 1, 4 + c_rng:RandomInt(3), 1 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, getPos(), Vector.Zero, player)  
    end
    return
  end
  if id == mod.ITEMS.WICKERMAN then
    for i = 1, 2, 1 do
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, getPos(), Vector.Zero, player)
    end
    return
  end
  if id == mod.ITEMS.ADDER_STONE then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, mod.CARDS.STONE_OF_THE_PIT, getPos(), Vector.Zero, player)
    return
  end
  if id == mod.ITEMS.TWO_DOLLAR_COIN then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, getPos(), Vector.Zero, player)
    return
  end
  local p_data = player:GetData()
  if id == mod.ITEMS.TEFILIN then
    p_data.WickedPData.tefilinUp = true
    local level = game:GetLevel()
    level:AddAngelRoomChance(276)
    return
  end
  mod:OldUrnPickup(player, room, id)

  if p_data.WickedPData.queueNextItemBox then
    mod:AddItemToTrack(player, id, "sampleBox")
    p_data.WickedPData.queueNextItemBox = false
  end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, mod.GenericOnPickups)

function mod:GenericPostPurchase(player, pickup, isDevil, coinsLost)
  local p_data = player:GetData()
  if not isDevil then
    for i = 1, player:GetCollectibleNum(mod.ITEMS.GOLDEN_WATCH), 1 do
      player:RemoveCollectible(mod.ITEMS.GOLDEN_WATCH)
      mod:QueueItemPopUp(player, mod.ITEMS.GOLDEN_WATCH, 1, 1)

      sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
    end

    if --[[player:HasTrinket(mod.TRINKETS.SAMPLE_BOX) and ]]pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        local idToRemove = mod:GetItemFromTrack(player, "sampleBox", true)
        if idToRemove then
          if not player:HasCollectible(idToRemove) then
            for index, value in ipairs(Isaac.FindByType(5, 100, idToRemove)) do
              if value.FrameCount > 1 then
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, value.Position, Vector.Zero, value)
                value:Remove()
                sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
                goto skipSkipSkip
              end
              value:Remove()
              goto dontSkip
            end
            goto skipSkipSkip
          end
          ::dontSkip::
          player:RemoveCollectible(idToRemove)
          mod:QueueItemPopUp(player, idToRemove, 1, 1)

          sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        end
    end
    ::skipSkipSkip::
    if pickup.Price == PickupPrice.PRICE_FREE or pickup.Price == 0 then
      if player:HasTrinket(mod.TRINKETS.SAMPLE_BOX) and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        p_data.WickedPData.queueNextItemBox = true --
        return
      end
        local id = p_data.somethingWicked_isMammonItem and mod.ITEMS.EVIL_PIGGYBANK or mod.ITEMS.DADS_WALLET
      
        local charge, slot = mod:CheckPlayerForActiveData(player, id)
        if slot == -1 then
            local np = PlayerManager.FirstCollectibleOwner(id)
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

--[[function mod:LatePickupUpdate(pickup)
  local p_data = pickup:GetData()
  
  --[[if pickup:IsShopItem() then
    if PlayerManager.AnyoneHasCollectible(mod.ITEMS.DADS_WALLET) then
      if pickup.Price > 0 then
        pickup.Price = PickupPrice.PRICE_FREE
      end
    end
    if PlayerManager.AnyoneHasCollectible(mod.ITEMS.EVIL_PIGGYBANK)
    and pickup.Price ~= PickupPrice.PRICE_FREE then
      if pickup.Price < 0 then
        pickup.Price = PickupPrice.PRICE_FREE
  
        p_data.somethingWicked_isMammonItem = true
      end
    else
      p_data.somethingWicked_isMammonItem = false
    end
    
    if PlayerManager.AnyoneHasTrinket(mod.TRINKETS.MEAL_COUPON) then
      if pickup.Price > 0 then
          pickup.Price = PickupPrice.PRICE_FREE
      end
    end
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CallbackPriority.LATE, mod.LatePickupUpdate)]]

mod:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, function (_, variant, id, shop, price)
  
  if PlayerManager.AnyoneHasCollectible(mod.ITEMS.DADS_WALLET) or (variant == PickupVariant.PICKUP_HEART and PlayerManager.AnyoneHasTrinket(mod.TRINKETS.MEAL_COUPON))
  or (variant == PickupVariant.PICKUP_COLLECTIBLE and PlayerManager.AnyoneHasTrinket(mod.TRINKETS.SAMPLE_BOX)) then
    if price > 0 then
      return PickupPrice.PRICE_FREE
    end
  end
  if PlayerManager.AnyoneHasCollectible(mod.ITEMS.EVIL_PIGGYBANK)
  and price ~= PickupPrice.PRICE_FREE then
    if price < 0 then
      return PickupPrice.PRICE_FREE
    end
  end
end)

function mod:OnNewRoom()
  local level = game:GetLevel()
  local currRoom = level:GetCurrentRoomDesc()
  local currIdx = level:GetCurrentRoomIndex()

  if currRoom.VisitedCount == 1 and level:GetStartingRoomIndex() == currIdx then
      -- new floor
      mod.save.runData.CurseList = {}
      mod.HasGenerateRedThisFloor = false
      mod.generatedLuciferMiniboss = false
      
      local hasSpawnedBirettaYet, hasSpawnedWickermanYet, shouldGenRoom = false, false, mod:GenericShouldGenerateRoom(level, game)
      for _, player in ipairs(mod:UtilGetAllPlayers()) do
        local p_data = player:GetData()
        p_data.WickedPData.CurseRoomsHealedOff = {}
        if player:HasCollectible(mod.ITEMS.WOODEN_DICE) then
          player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
        
        if player:HasCollectible(mod.ITEMS.WICKED_SOUL) then
          mod:WickedSoulOnPickup(player)
        end

        if player:HasCollectible(mod.ITEMS.RED_NIGHTMARE) then
          mod:RedGenerate(game, level, player)
        end
        
        if p_data.WickedPData.demonCoreFlag ~= nil then 
          p_data.WickedPData.demonCoreFlag = false
        end
        
        if not hasSpawnedBirettaYet and player:HasCollectible(mod.ITEMS.BIRETTA) then
          mod:SpawnMachineQuick(Vector(520, 120), mod.MachineVariant.MACHINE_CONFESSIONAL, player)
        end
        
        mod:BookOfLuciferNewFloor(player, shouldGenRoom)
        mod:tefilinNewFloorPlayer(player)

        p_data.magicEyeItem = mod:GetRandomElement(mod.magicEyeItems, player:GetCollectibleRNG(mod.ITEMS.MAGIC_EYE))
        p_data.thatOneTrinketItem = mod:GetRandomElement(mod.optionTrinketsItem, player:GetTrinketRNG(mod.TRINKETS.OPTIONS_TRINKET))

        if shouldGenRoom then
          if not hasSpawnedWickermanYet and player:HasCollectible(mod.ITEMS.WICKERMAN) then
            local rng = player:GetCollectibleRNG(mod.ITEMS.WICKERMAN)
            if not mod:RoomTypeCurrentlyExists(RoomType.ROOM_SACRIFICE, level, rng) then
                mod:GenerateSpecialRoom("sacrifice", 1, 5, true, rng)
            end
          end
        end
        local ceffects = player:GetEffects()
        ceffects:RemoveNullEffect(mod.NULL.VIATHAN, -1)
      end
      mod.tef_removeNextFloor = nil

      for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, mod.NightmareSubTypes.NIGHTMARE_FLOORONLY)) do
        value:Remove()
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
      for i = 1, mod:GlobalGetTrinketNum(mod.TRINKETS.CATS_EYE), 1 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos()), Vector.Zero, nil)
      end
    end
  end
  
 -- local glitch = PlayerManager.AnyoneHasTrinket(mod.TRINKETS.ZZZZZZ_MAGNET)
  local curse = PlayerManager.AnyoneHasTrinket(mod.TRINKETS.CURSED_KEY)
  local treasure = PlayerManager.AnyoneHasTrinket(mod.TRINKETS.TREASURERS_KEY)

  for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
    local door = room:GetDoor(i)
    if door then
      mod:CurseKeyTreasurersKeyDoorChecks(door, currIdx, curse, treasure)
      mod:IsDevilDoor(door)

      --if glitch then
        --mod:ZZZZZZConvertDoor(door)
      --end
    end
  end

  local abyssLocusts = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST)
  for _, player in ipairs(mod:UtilGetAllPlayers()) do
    local pEffects = player:GetEffects()
    pEffects:RemoveNullEffect(mod.NULL.LUSTEFFECT, 1)

    mod:DestroyCrownLocustsWithInitSeeds(nil, abyssLocusts, player)

    if player:HasTrinket(mod.TRINKETS.NIGHTMARE_FUEL) then
      local p_data = player:GetData()
      p_data.sw_nightmaresDiedToday = 0
      player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
      player:EvaluateItems()
    end
    mod:sudariumNewRoom(player)
  end
end)

function mod:PostEntityTakeDMG(ent, amount, flags, source, dmgCooldown)
  if not ent then
    return
  end
  local p = ent:ToPlayer()
  if p then
    local p_data = p:GetData()
    mod:StarSpawnPlayerDamage(p)
    mod:BolineTakeDMG(p)

    --indulgence
    if p:HasTrinket(mod.TRINKETS.PRINT_OF_INDULGENCE) then
      local t_rng = p:GetTrinketRNG(mod.TRINKETS.PRINT_OF_INDULGENCE)
      if t_rng:RandomFloat() < 0.1*p:GetTrinketMultiplier(mod.TRINKETS.PRINT_OF_INDULGENCE) then
          local room = game:GetRoom()
          local pos = room:FindFreePickupSpawnPosition(p.Position)
          Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, pos, Vector.Zero, p)
      end
    end

    if p:HasTrinket(mod.TRINKETS.DEMON_CORE) then
      if p_data.WickedPData.demonCoreFlag ~= true then
        local room = game:GetRoom()
        room:MamaMegaExplosion(p.Position)

        p_data.WickedPData.demonCoreFlag = true
      end
    end
    
    if p:HasCollectible(mod.ITEMS.YELLOW_SIGIL) then
      local c_rng = p:GetCollectibleRNG(mod.ITEMS.YELLOW_SIGIL)
      if c_rng:RandomFloat() < 0.5 then
        mod:SpawnNightmare(p, p.Position, mod.NightmareSubTypes.NIGHTMARE_FLOORONLY)
      end
    end

    local ceffects = p:GetEffects()
    --mod:BookOfLeviathanOnDamage(p, ceffects)
    if ceffects:HasNullEffect(mod.NULL.LUSTEFFECT) then
      sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
      ceffects:RemoveNullEffect(mod.NULL.LUSTEFFECT, -1)
    end
    if p:HasCollectible(mod.ITEMS.THE_SHRINKS) then
      if not ceffects:HasCollectibleEffect(mod.ITEMS.THE_SHRINKS) then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, p)
        poof.SpriteScale = Vector(0.75, 0.75)
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
      end
      ceffects:AddCollectibleEffect(mod.ITEMS.THE_SHRINKS)
    end
    mod:sudariumPostDMG(p)

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

  mod:PostDreadNormalDMG(ent, amount, flags, source, dmgCooldown)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, mod.PostEntityTakeDMG)

function mod:PreEntityTakeDMG(ent, amount, flags, source, dmgCooldown)
  if not ent then
    return
  end
  local p = ent:ToPlayer()
  if p then
    if p:HasCollectible(mod.ITEMS.STAR_OF_PROVIDENCE) and flags & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
      return false
    end
  end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.PreEntityTakeDMG)

function mod:OnUsePill(effect, player, flags)
  if flags & UseFlag.USE_NOANIM > 0 then
    return
  end

  if player:HasTrinket(mod.TRINKETS.SUGAR_COATED_PILL) then
    mod.save.runData.sugarCoatedPillEffect = effect
    player:TryRemoveTrinket(mod.TRINKETS.SUGAR_COATED_PILL)

    sfx:Play(SoundEffect.SOUND_VAMP_GULP)
  end
  if player:HasTrinket(mod.TRINKETS.VICODIN) and effect ~= PillEffect.PILLEFFECT_PERCS then
    player:UsePill(PillEffect.PILLEFFECT_PERCS, 0, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
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
  [2761] = { mod.ITEMS.VOID_BOMBS, "sw_isVoidBomb" },
  [2762] = { mod.ITEMS.STAR_OF_PROVIDENCE, "sw_isBlankBomb" }
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
      mod:CheckEnemiesInExplosion(bomb, p)
      if b_data.sw_isVoidBomb then
        local c_rng = p:GetCollectibleRNG(mod.ITEMS.VOID_BOMBS)
        if not bomb.IsFetus or (c_rng:RandomFloat() < 0.15 + (0.026 * p.Luck)) then
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
      if b_data.sw_isBlankBomb then
        mod:SoPBombExplode(bomb, p)
      end   
    else
      if b_data.sw_isBlankBomb then
        mod:SoPBombUpdate(bomb, p)
      end
    end
  end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.BombUpdate)


local function BossRoomClear(_, pos)
  local player = PlayerManager.FirstCollectibleOwner(mod.ITEMS.CAT_FOOD)
  if player then
      local numCatFood = PlayerManager.GetNumCollectibles(mod.ITEMS.CAT_FOOD)
      for i = 1, numCatFood * 5, 1 do
          Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, pos, RandomVector() * 5, player)
      end
  end
end

mod:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_BOSS_ROOM_CLEARED, BossRoomClear)

--flyscreen
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
  familiar:MoveDiagonally(1)
  game:UpdateStrangeAttractor(familiar.Position)
end, FamiliarVariant.SOMETHINGWICKED_FLY_SCREEN)

--baby mandrake

--[[local itemsToLoad = {
  "legion",
  %-"teratomashield",
  %-"devilstail",
  "shotgrub",
  "minotaur",
  "balrogsheart",
  "cursemask",
  "safetymasktemperance",
  "redqueen",
  "brokenbell",
  "saintshead",
  "eyeofprovidence",
  "tombstone",
  "bloodhail",
  "voidscall",
  "screwattack",
  "pendulum",
  "yoyo",
  "pieceofsilver",
  
  "phobosanddeimos",
  "littleattractor",
  "msgonorrhea",
  "cutiefly",
  "fatwisp",
  "jokerbaby",

  %-"fetusinfetu",
  "facestabber",
  "fearstalkstheland",
  "marblesprouttaskmanager",
  "babymandrake",
  "icewand",
  "dudael",
  "magicclay",
  "lastprism",
  
  %-"voidheart",
  "mrskits",
  %-"nightmarefuelvirtue",
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
  Ninji
Special thanks: 
  lambchop_is_ok
  PattieMurr (music, unused)
  Onehand and Unobtained (the turtlemelon tattoo)
  The Fiend Folio team
  The Gungeon Modding Crew
  and the countless mods that i looked at for reference when i didn't know how to code in lua
]]



print("Something wicked this way comes...")