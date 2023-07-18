local mod = RegisterMod("Something Wicked", 1)
local game = Game()
SomethingWicked = mod

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
          return true
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

function SomethingWicked:UtilWeightedGetThing(pool, myRNG)
  if #pool > 0 then
    local totalWeights = 0
    for _, v in ipairs(pool) do
      totalWeights = totalWeights + v[2]
    end

    local unprocessedItemToGet = myRNG:RandomFloat() * totalWeights
    local allValues = {}
    for _, value in ipairs(pool) do
        unprocessedItemToGet = unprocessedItemToGet - value[2]
        table.insert(allValues, value[1])
        if unprocessedItemToGet <= 0 then
          return value[1]
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
  -- treasure, boss, shop, devil, angel, curse, secret
}
local bothModePools = {
  -- everything but the above
}
function mod:GetRandomPool(myRNG)
  local greed = game.Difficulty > Difficulty.DIFFICULTY_HARD
  local pool = greed and weightedGreedPools or weightedPools
  pool = mod:utilMerge(pool, bothModePools)
  return mod:UtilWeightedGetThing(pool, myRNG)
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
  --"meta/cardController"
}

for index, value in ipairs(earlyLoad) do
  incl(value)
end

local midLoad = {
  "items/wickedsoul",
  "items/dstock",
}
for index, value in ipairs(midLoad) do
  incl(value)
end
function mod:EvaluateGenericStatItems(player, flags)
  if not player then
    return
  end
  local wickedSoulMult = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WICKED_SOUL)

  if flags == CacheFlag.CACHE_DAMAGE then
    player.Damage = mod:DamageUp(player, 1 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM))
    player.Damage = mod:DamageUp(player, 0.5 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WOODEN_HORN))
    player.Damage = mod:DamageUp(player, 0.3 * mod:BoolToNum(player:HasCollectible(CollectibleType.SOMETHINGWICKED_SILVER_RING)))
    player.Damage = mod:DamageUp(player, 0.5 * wickedSoulMult)
  end
  if flags == CacheFlag.CACHE_FIREDELAY then
    player.MaxFireDelay = mod:TearsUp(player, 0.4 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_WHITE_ROSE))
    player.MaxFireDelay = mod:TearsUp(player, 0.5 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHAMPOO))
  end
  if flags == CacheFlag.CACHE_LUCK then
    player.Luck = player.Luck + (1 * wickedSoulMult) 
  end
  if flags == CacheFlag.CACHE_SPEED then
    player.MoveSpeed = player.MoveSpeed + (0.2 * wickedSoulMult)
    player.MoveSpeed = player.MoveSpeed + player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHAMPOO)*0.3
  end
  if flags == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed + (0.1 * wickedSoulMult) 
  end
  if flags == CacheFlag.CACHE_RANGE then
      player.TearRange = player.TearRange + (1.2 * wickedSoulMult * 40)
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.EARLY, mod.EvaluateGenericStatItems)

function mod:EvaluateLateStats(player, flags)
  if flags == CacheFlag.CACHE_DAMAGE then
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_SILVER_RING) then
      player.Damage = player.Damage * 1.1
    end
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WICKED_SOUL) then
      player.Damage = player.Damage * 1.3
    end
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.EvaluateLateStats)

function mod:GenericOnPickups(player, room, id)
  if id == CollectibleType.SOMETHINGWICKED_WHITE_ROSE then
    for i = 1, 4, 1 do
      player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, player.Position)
    end
  end
end
mod:AddCustomCBack(mod.ENUMS.CustomCallbacks.SWCB_PICKUP_ITEM, mod.GenericOnPickups)

function mod:OnNewFloor()
  local level = game:GetLevel()
  local currRoom = level:GetCurrentRoomDesc()
  local currIdx = level:GetCurrentRoomIndex()

  if level:GetStartingRoomIndex() == currIdx
  and currRoom.VisitedCount == 1 then
    -- new floor
    for index, value in ipairs(mod:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_WICKED_SOUL)) do
      mod:WickedSoulOnPickup(value)
    end
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.EARLY, mod.OnNewFloor)

--[[local itemsToLoad = {
  "ramshead",
  "lankymushroom",
  "wickedsoul"

  "discipleseye",
  "redlockbox",
  "batteryD",
  "newlocustitems",
  "voidbombs",
  "catfood",
  "whiterobe",
  "nightshade",
  "fitusfortunus",
  "oldurn",
  "apollyonscrown",
  "woodendice",
  "biretta",
  "wrath",
  "bravery",
  "superiority",
  "cursedcreditcard",
  "spidernest",
  "3dglasses",
  "legion",
  "teratomashield",
  "sacrificialheart",
  "planchette",
  "glitchcity",
  "crossedheart",
  "devilstail",
  "shotgrub",
  "minotaur",
  "balrogsheart",
  "carolinareapernagaviper",
  "cursemask",
  "red",
  "starspawn",
  "plasmaglobe",
  "bananamilk",
  "safetymasktemperance",
  "loversmask",
  "boxofvines",
  "mosaicshard",
  "knaveofhearts",
  "redqueen",
  "brokenbell",
  "hellfireCrownOfBlood",
  "saintshead",
  "eyeofprovidence",
  "tombstone",
  "blacksalt",
  "lanternbatterycellphonebattery",
  "ringofregen",
  "lourdeswater",
  "bloodhail",
  "redcap",
  "voidscall",
  "screwattack",
  "techmodulo",
  "pressurevalve",
  "lightsharddarkshard",
  "discord",
  "pendulum",
  "chrismatory",
  "yoyo",
  "spoolofyarn",
  "airfreshener",
  "pieceofsilver",
  "darkness",
  "ganymede",
  
  "rogueplanet",
  "minos",
  "yellowshard",
  "solomon",
  "devilsknife",
  "phobosanddeimos",
  "littleattractor",
  "msgonorrhea",
  "justiceandsplendor",
  "cutiefly",
  "fatwisp",
  "weirdapple",
  "jokerbaby",

  "balrogshead",
  "possumear",
  "osteophagy",
  "possumshead",
  "bookoflucifer",
  "toybox",
  "tiamatsdice",
  "cursedcandle",
  "dadswallet",
  "bookofinsanity",
  "voidegg",
  "chaosheart",
  "cursedmushroom",
  "olddice",
  "encyclopedia",
  "chasm",
  "fetusinfetu",
  "edenshead",
  "abandonedbox",
  "facestabber",
  "goldencard",
  "fearstalkstheland",
  "bookofleviathan",
  "marblesprouttaskmanager",
  "babymandrake",
  "icewand",
  "dudael",
  "magicclay",
  "boline",
  "oldbell",
  "lastprism",
  "assisttrophy",
  
  "twofcoins",
  "scorchedwood",
  "stonekey",
  "bobsheart",
  "catseye",
  "damnedsoulvirtuoussoul",
  "sugarcoatedpill",
  "treasurerskeycursedkey",
  "demoncore",
  "emptybook",
  "demoniumpage", -- demonium page
  "gachapon",
  "voidheart",
  "mrskits",
  "giftcard",
  "nightmarefuelvirtue",
  "zzzzzzmagnet",
  "redkeychain",
  "powerinveter",
  "diceroller"
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

local earlyMiscLoad = {
  "saveHandler",

  "redkeyLevelGenStuff",
  --"roomStuff/_core",

  "ezEnums",
  
  "newcallbacks",
  "slotmachinesfuckingsuck",
  "tearflagslibcore",
  
  "dirtystatupsdonedirtquick",
  "itemHelpers",
  "enemyHelpers",
  "familiarHelpers",
  "hitscanHelper",
  
  "statusEffects/__core",
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
  and the countless mods that i sampled for code when i didn't know how to code in lua
]]



print("Something wicked this way comes...")