SomethingWicked = RegisterMod("Something Wicked", 1)
SomethingWicked.game = Game()
SomethingWicked.sfx = SFXManager()

--i think i got this one from deliverance
function SomethingWicked:UtilGetAllPlayers() 
  local players = {}
    
  for i = 0, SomethingWicked.game:GetNumPlayers() - 1 do
      players[i + 1] = Isaac.GetPlayer(i)
  end

  return players
end

function SomethingWicked:UtilTableHasValue (tab, val)
  for index, value in pairs(tab) do
      if value == val then
          return true
      end
  end

  return false
end

function SomethingWicked:Clamp(val, max, min)
  return math.max(max, math.min(val, min))
end

--these two are also from tainted treasures
function SomethingWicked:utilRunUpdates(tab) --This is from Fiend Folio
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
function SomethingWicked:UtilScheduleForUpdate(func, delay, callback)
  callback = callback or ModCallbacks.MC_POST_UPDATE
  if not delayedFuncs[callback] then
      delayedFuncs[callback] = {}
      SomethingWicked:AddCallback(callback, function()
          SomethingWicked:utilRunUpdates(delayedFuncs[callback])
      end)
  end

  table.insert(delayedFuncs[callback], { Func = func, Delay = delay })
end


--i take-a lambchop's code
function SomethingWicked:utilForceBloodTear(tear)
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
function SomethingWicked:UtilAddSmeltedTrinket(trinket, player)
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

function SomethingWicked:UtilCompareColors(color1, color2)
  if color1.R == color2.R
  and color1.G == color2.G
  and color1.B == color2.B
  and color1.A == color2.A
  and color1.RO == color2.RO
  and color1.GO == color2.GO
  and color1.BO == color2.BO then
    return true
  end
  return false
end

function SomethingWicked:UtilGenerateWikiDesc(strings, quoteString)
  local wikiTable = 
  {
    {str = "Effect", fsize = 2, clr = 3, halign = 0},
  }

  for index, value in ipairs(strings) do
    table.insert(wikiTable,
  {str = "-"..value})
  end

  if quoteString ~= nil then
    table.insert(wikiTable, {str = ""})
    table.insert(wikiTable, {str = "- -- ----[]---- -- -", fsize = 1, halign = 0})
    table.insert(wikiTable, {str = ""})
    table.insert(wikiTable, {str = "\""..quoteString.."\""})
  end

  return { wikiTable }
end

function SomethingWicked:GetRandomElement(table, rng)
  local num = rng:RandomInt(#table) + 1
  return table[num]
end

--mom found the tainted treasures method i nabbed so the room gen stuff would work
function SomethingWicked:UtilShuffleTable(tbl, rng)
	for i = #tbl, 2, -1 do
    local j = rng:RandomInt(i) + 1
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

--not writing 99 null checks forgive me
SomethingWicked.encyclopediaLootPools = {
  POOL_TREASURE = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_TREASURE or -1,
  POOL_SHOP = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_SHOP or -1,
  POOL_BOSS = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_BOSS or -1,
  POOL_DEVIL = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_DEVIL or -1,
  POOL_ANGEL = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_ANGEL or -1,
  POOL_SECRET = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_SECRET or -1,
  POOL_LIBRARY = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_LIBRARY or -1,
  POOL_SHELL_GAME = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_SHELL_GAME or -1,
  POOL_GOLDEN_CHEST = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GOLDEN_CHEST or -1,
  POOL_RED_CHEST = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_RED_CHEST or -1,
  POOL_BEGGAR = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_BEGGAR or -1,
  POOL_DEMON_BEGGAR = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_DEMON_BEGGAR or -1,
  POOL_CURSE = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_CURSE or -1,
  POOL_KEY_MASTER = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_KEY_MASTER or -1,
  POOL_BATTERY_BUM = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_BATTERY_BUM or -1,
  POOL_MOMS_CHEST = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_MOMS_CHEST or -1,
  POOL_GREED_TREASURE = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_TREASURE or -1,
  POOL_GREED_BOSS = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_BOSS or -1,
  POOL_GREED_SHOP = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_SHOP or -1,
  POOL_GREED_DEVIL = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_DEVIL or -1,
  POOL_GREED_ANGEL = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_ANGEL or -1,
  POOL_GREED_CURSE = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_CURSE or -1,
  POOL_GREED_SECRET = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_GREED_SECRET or -1,
  POOL_CRANE_GAME	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_CRANE_GAME or -1,
  POOL_ULTRA_SECRET	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_ULTRA_SECRET or -1,
  POOL_BOMB_BUM	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_BOMB_BUM or -1,
  POOL_PLANETARIUM	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_PLANETARIUM or -1,
  POOL_OLD_CHEST	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_OLD_CHEST or -1,
  POOL_BABY_SHOP	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_BABY_SHOP or -1,
  POOL_WOODEN_CHEST	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_WOODEN_CHEST or -1,
  POOL_ROTTEN_BEGGAR	 = Encyclopedia ~= nil and Encyclopedia.ItemPools.POOL_ROTTEN_BEGGAR or -1,
}

local itemsToLoad = {
  --compact these into one file pleaaase juney
  "avengeremblem",
  "woodenhorn",
  --"lanternold",
  "silverring",
  "mammonstooth",
  "chiliPigEar",
  "whiterose",
  "ramshead",
  "corruption",
  "samyazasfeather",
  "lankymushroom",
  "bottleofshampoo",

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
  "childstoys",
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

  "dstock",
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
  
  --"themistake"
  "twofcoins",
  "scorchedwood",
  "stonekey",
  "bobsheart",
  "catseye",
  --"goldytomato", OUTDATED 
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
}
--[[local enemiesToLoad = {
  --"experiment",
  "menacefly",
  "dukeoftheabyss"
}]]

SomethingWicked.addedCollectibles = {}
SomethingWicked.addedTrinkets = {}

for _, i in ipairs(earlyMiscLoad) do
  include("scripts/misc/"..i)
end
local itemsMissingPools = "Items missing pools: "
local itemsMissingDescs = "Items missing descs: "
for _, i in ipairs(itemsToLoad) do
  --print(i)
  local item = include("scripts/items/"..i)
  for id, entry in pairs(item.EIDEntries) do
    if entry.isTrinket then
      table.insert(SomethingWicked.addedTrinkets, id)
    else
      table.insert(SomethingWicked.addedCollectibles, id)
    end
  if EID ~= nil then
    if entry.isTrinket == true then
      EID:addTrinket(id, entry.desc)
      if entry.metadataFunction ~= nil then
        entry.metadataFunction(id)
      end
    else
      EID:addCollectible(id, entry.desc)
    end
  end
  
  if Encyclopedia ~= nil then
      local table = {
        ID = id,
        ModName = "Something Wicked (The Unlisted Beta)",
        Class = "Something Wicked",
      }
      if entry.encycloDesc == nil then
        --[[table.WikiDesc = {
          {
            { str = "Test.", clr="1" },
            { str = "Test.", clr="2" },
            { str = "Test.", clr="3" },
            { str = "Test.", clr="4" }
          }
        }
        table.Hide = true
        itemsMissingDescs = itemsMissingDescs..id.." "]]--
        table.WikiDesc = Encyclopedia.EIDtoWiki(entry.desc or "???")
      else
        table.WikiDesc = entry.encycloDesc
      end
      table.Hide = entry.Hide or false
      if entry.isTrinket ~= true then
        
        if entry.pools == nil then
          itemsMissingPools = itemsMissingPools..id.." "
        else
          table.Pools = entry.pools
        end
        Encyclopedia.AddItem(table)
      else
        Encyclopedia.AddTrinket(table)
      end
    end
  end
end
--print(itemsMissingPools)
--print(itemsMissingDescs)
for _, i in ipairs(cardsToLoad) do
  local card = include("scripts/cards/"..i)
    for id, entry in pairs(card.EIDEntries) do
      if not SomethingWicked:UtilTableHasValue(SomethingWicked.BoonIDs, id) then
      end
      if EID ~= nil then
      EID:addCard(id, entry.desc)
      end
    end
  end
--[[for _, i in ipairs(enemiesToLoad) do
  include("scripts/enemies/"..i)
end]]
--include("scripts/players/abiah")
include("scripts/players/bsides")
for _, i in ipairs(postMiscLoad) do
  --print(i)
  include("scripts/misc/"..i)
end


--thanks to both Eternal Items: Repented and Deliverance for this amalgamation of yoinked code, for loading item files

--Also thanks to lambchop_is_ok, for tweaking up the sprite for the secret shop BG, aswell as sending me the GetPlayerFromTear method

if not StageAPI then
  --print("StageAPI is highly recomennded if yo want to experience all Something Wicked has. Download it please :)")
end
print("Something wicked this way comes...")

--Putting full credits here so i dont forget when i release the mod
--[[
Spriting Help: lambchop_is_ok, Dallan
Concept art + some general concepting: Nevernamed (Bt Y)
Music (not used yet): Hux
Special Thanks (Modding Help & Code used): lambchop_is_ok, fly_6, Agent Cucco, kittenchilly, Xalum, Fiend and the Fiendfolio team, the Tainted Treasures team
Special Thanks (Playtesting & feedback): TheTurtleMelon (Massive Emphasis Here, probably the most feedback and the most vocal feedback i got), We Strvn, Skkull, Not a Bot, Saturn
]]
