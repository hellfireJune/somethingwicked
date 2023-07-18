local function genericWikiTable(id)
    return {
        ID = id,
        ModName = "Something Wicked (The Unlisted Beta)",
        Class = "Something Wicked",
    }
end
--not writing 99 null checks forgive me
local encyclopediaLootPools = {
  POOL_TREASURE = Encyclopedia and Encyclopedia.ItemPools.POOL_TREASURE or -1,
  POOL_SHOP = Encyclopedia and Encyclopedia.ItemPools.POOL_SHOP or -1,
  POOL_BOSS = Encyclopedia and Encyclopedia.ItemPools.POOL_BOSS or -1,
  POOL_DEVIL = Encyclopedia and Encyclopedia.ItemPools.POOL_DEVIL or -1,
  POOL_ANGEL = Encyclopedia and Encyclopedia.ItemPools.POOL_ANGEL or -1,
  POOL_SECRET = Encyclopedia and Encyclopedia.ItemPools.POOL_SECRET or -1,
  POOL_LIBRARY = Encyclopedia and Encyclopedia.ItemPools.POOL_LIBRARY or -1,
  POOL_SHELL_GAME = Encyclopedia and Encyclopedia.ItemPools.POOL_SHELL_GAME or -1,
  POOL_GOLDEN_CHEST = Encyclopedia and Encyclopedia.ItemPools.POOL_GOLDEN_CHEST or -1,
  POOL_RED_CHEST = Encyclopedia and Encyclopedia.ItemPools.POOL_RED_CHEST or -1,
  POOL_BEGGAR = Encyclopedia and Encyclopedia.ItemPools.POOL_BEGGAR or -1,
  POOL_DEMON_BEGGAR = Encyclopedia and Encyclopedia.ItemPools.POOL_DEMON_BEGGAR or -1,
  POOL_CURSE = Encyclopedia and Encyclopedia.ItemPools.POOL_CURSE or -1,
  POOL_KEY_MASTER = Encyclopedia and Encyclopedia.ItemPools.POOL_KEY_MASTER or -1,
  POOL_BATTERY_BUM = Encyclopedia and Encyclopedia.ItemPools.POOL_BATTERY_BUM or -1,
  POOL_MOMS_CHEST = Encyclopedia and Encyclopedia.ItemPools.POOL_MOMS_CHEST or -1,
  POOL_GREED_TREASURE = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_TREASURE or -1,
  POOL_GREED_BOSS = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_BOSS or -1,
  POOL_GREED_SHOP = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_SHOP or -1,
  POOL_GREED_DEVIL = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_DEVIL or -1,
  POOL_GREED_ANGEL = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_ANGEL or -1,
  POOL_GREED_CURSE = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_CURSE or -1,
  POOL_GREED_SECRET = Encyclopedia and Encyclopedia.ItemPools.POOL_GREED_SECRET or -1,
  POOL_CRANE_GAME = Encyclopedia and Encyclopedia.ItemPools.POOL_CRANE_GAME or -1,
  POOL_ULTRA_SECRET = Encyclopedia and Encyclopedia.ItemPools.POOL_ULTRA_SECRET or -1,
  POOL_BOMB_BUM	= Encyclopedia and Encyclopedia.ItemPools.POOL_BOMB_BUM or -1,
  POOL_PLANETARIUM = Encyclopedia and Encyclopedia.ItemPools.POOL_PLANETARIUM or -1,
  POOL_OLD_CHEST = Encyclopedia and Encyclopedia.ItemPools.POOL_OLD_CHEST or -1,
  POOL_BABY_SHOP = Encyclopedia and Encyclopedia.ItemPools.POOL_BABY_SHOP or -1,
  POOL_WOODEN_CHEST	= Encyclopedia and Encyclopedia.ItemPools.POOL_WOODEN_CHEST or -1,
  POOL_ROTTEN_BEGGAR = Encyclopedia and Encyclopedia.ItemPools.POOL_ROTTEN_BEGGAR or -1,
}

if EID then
    local icon = Sprite()
    icon:Load("gfx/ui/eid_icon.anm2", true)

    EID:addIcon("SomethingWicked", "Idle", 0, 32, 32, 6, 4, icon)

    EID:setModIndicatorName("Something Wicked")
    EID:setModIndicatorIcon("SomethingWicked")

end
local collectibles = {
    [CollectibleType.SOMETHINGWICKED_AVENGER_EMBLEM] = {
        desc = "↑ {{Damage}} +1 Damage up",
        pools = {
            encyclopediaLootPools.POOL_BOSS,
            encyclopediaLootPools.POOL_GREED_BOSS
        }
    },
    [CollectibleType.SOMETHINGWICKED_WOODEN_HORN] = {
        desc = "↑ {{Damage}} +0.5 Damage up#{{BlackHeart}} +1 Black Heart",
        pools = {
            encyclopediaLootPools.POOL_BOSS,
            encyclopediaLootPools.POOL_GREED_BOSS,
            encyclopediaLootPools.POOL_WOODEN_CHEST
        }
    },
    [CollectibleType.SOMETHINGWICKED_SILVER_RING] = {
        desc = "↑ {{Damage}} +0.3 Damage up#↑ {{Damage}} +10% Damage Multiplier",
        pools = {
            encyclopediaLootPools.POOL_GOLDEN_CHEST,
            encyclopediaLootPools.POOL_CRANE_GAME,
        },
    },
    [CollectibleType.SOMETHINGWICKED_WHITE_ROSE] = {
        desc = "↑ {{Tears}} +0.4 Tears up#1 soul heart#↑ Spawns four {{Collectible584}} Book of Virtues wisps on pickup",
        pools = {
            encyclopediaLootPools.POOL_BOSS,
            encyclopediaLootPools.POOL_GREED_BOSS,
            encyclopediaLootPools.POOL_TREASURE,
            encyclopediaLootPools.POOL_ANGEL,
            encyclopediaLootPools.POOL_GREED_ANGEL
        },
    },
    [CollectibleType.SOMETHINGWICKED_WICKED_SOUL] = {
        desc = [[↑ {{Damage}} +30% Damage Multiplier#↑ {{Damage}} +0.5 Damage#↑ {{Luck}} +1 Luck up #↑ {{Speed}} +0.2 Speed up
        #↑ {{ShotSpeed}} +0.1 Shot Speed up #↑{{Range}} +1.2 Range up#!!! A bonus curse will be added every floor]],
        pools = {
            encyclopediaLootPools.POOL_TREASURE,
            encyclopediaLootPools.POOL_CURSE,
            encyclopediaLootPools.POOL_GREED_TREASURE,
        },
    },
    [CollectibleType.SOMETHINGWICKED_BOTTLE_OF_SHAMPOO] = {
        desc = "↑ {{Tears}} +0.5 Tears up#↑ {{Speed}} +0.3 Speed up"
    },
    [CollectibleType.SOMETHINGWICKED_D_STOCK] = {
        desc = "{{Shop}} Restocks the current shop if used inside a shop#Will also similarly restock {{DevilRoom}} Devil Deals and {{Collectible586}} Stairway shops",
        pools = {
            encyclopediaLootPools.POOL_SHOP,
            encyclopediaLootPools.POOL_GREED_SHOP,
        },
    }
}

for index, value in pairs(collectibles) do
    print(index, value.desc)
    if value.desc then
        if EID then
            EID:addCollectible(index, value.desc)
        end
            
        if Encyclopedia and Encyclopedia.EIDToWiki then --/shrug
            local tab = genericWikiTable(index)
            tab.WikiDesc = Encyclopedia.EIDToWiki(value.desc)
            tab.Pools = value.pools
            tab.Hide = value.Hide or false
            Encyclopedia.AddItem(tab)
        end
    end
end

if EID then
    --abyss
    EID.descriptions["en_us"].abyssSynergies[CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM] = "Purple cursing locust"

    --bov
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM] = "Curses nearby enemies on destruction"
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER] = "Spawns two wisps on destroyed trinket, spawns bonus wisps if the trinket was worth more (eg. Golden Trinkets)"
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_FETUS_IN_FETU] = "Do nothing by themselves, will destroy self and spawn a blue spider if the item is used again"
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_GOLDEN_CARD] = "Does another random card effect on death"
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_BOLINE] = "Double HP wisps that spawn weaker maw of the void rings on damage"
end