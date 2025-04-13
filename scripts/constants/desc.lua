local mod = SomethingWicked
local function genericWikiTable(id, desc)
    return {
        ID = id,
        ModName = "Something Wicked (The Unlisted Beta)",
        Class = "Something Wicked",
        WikiDesc = Encyclopedia.EIDtoWiki(desc)
    }
end
--not writing 99 null checks forgive me
local pools = {
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

    local curseIcon = Sprite()
    curseIcon:Load("gfx/somethingwicked_status_effects.anm2", true)
    EID:addIcon("SWCurseStatusIcon", "Curse", 0, 14, 14, 6, 4, curseIcon)
    EID:addIcon("SWDreadStatusIcon", "Dread", 0, 14, 14, 6, 4, curseIcon)

    --[[local cardsSprite = Sprite()
    cardsSprite:Load()]]
end
mod.GENERIC_DESCRIPTIONS = {
    CURSE = "#{{SWCurseStatusIcon}} Cursed enemies will take 1.5x damage, and will gain a slight slowing effect",
    ELECTROSTUN = "",
    DREAD = "#{{SWDreadStatusIcon}} Enemies with dread take damage over time, damaging more frequently as the effect goes on",

    NIGHTMARES = "#Nightmares will orbit the player invulnerable, but will stop moving and lose invulnerability to fire homing tears while Isaac is firing tears",
    TERATOMAS = "",

    CARDDRAW = "Cannot use The Fool? The Lovers?, The Stars? or Wheel of Fortune?#Teleport cards will only be rarely used, and cannot be drawn during boss fights",
    SOULTRINKETSTATS = "#↑{{Damage}} +0.3 Damage up#↑{{Tears}} +0.5 Tears up#↑{{Luck}} +1 Luck up"..
    "#↑{{Speed}} +0.15 Speed up#↑{{Shotspeed}} +0.1 Shot Speed#↑{{Range}} +0.75 Range up"
}
local soulMetadataFunc = function (item)
    EID:addGoldenTrinketMetadata(item, nil, { 0.3, 0.5, 1, 0.15, 0.1, 0.75 } )
end
local collectibles = {
    [mod.ITEMS.AVENGER_EMBLEM] = {
        desc = "↑ {{Damage}} +1 Damage up",
        pools = {
            pools.POOL_BOSS,
            pools.POOL_GREED_BOSS
        }
    },
    [mod.ITEMS.WOODEN_HORN] = {
        desc = "↑ {{Damage}} +0.5 Damage up#{{BlackHeart}} +1 Black Heart",
        pools = {
            pools.POOL_BOSS,
            pools.POOL_GREED_BOSS,
            pools.POOL_WOODEN_CHEST
        }
    },
    [mod.ITEMS.SILVER_RING] = {
        desc = "↑ {{Damage}} +0.3 Damage up#↑ {{Damage}} +10% Damage Multiplier",
        pools = {
            pools.POOL_GOLDEN_CHEST,
            pools.POOL_CRANE_GAME,
        },
    },
    [mod.ITEMS.WHITE_ROSE] = {
        desc = "↑ {{Tears}} +0.4 Tears up#{{SoulHeart}} +1 Soul Heart#↑ Spawns four {{Collectible584}} Book of Virtues wisps on pickup",
        pools = {
            pools.POOL_BOSS,
            pools.POOL_GREED_BOSS,
            pools.POOL_TREASURE,
            pools.POOL_ANGEL,
            pools.POOL_GREED_ANGEL
        },
    },
    [mod.ITEMS.WICKED_SOUL] = {
        desc = [[↑ {{Damage}} +30% Damage Multiplier#↑ {{Damage}} +0.5 Damage#↑ {{Luck}} +1 Luck up #↑ {{Speed}} +0.2 Speed up#↑ {{Shotspeed}} +0.1 Shot Speed up #↑ {{Range}} +1.2 Range up#!!! A bonus curse will be added every floor]],
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_CURSE,
            pools.POOL_GREED_TREASURE,
        },
    },
    [mod.ITEMS.BOTTLE_OF_SHAMPOO] = {
        desc = "↑ {{Tears}} +0.5 Tears up#↑ {{Speed}} +0.3 Speed up",
        pools = {
            pools.POOL_BOSS,
            pools.POOL_GOLDEN_CHEST,
            pools.POOL_GREED_BOSS
        }
    },
    [mod.ITEMS.D_STOCK] = {
        desc = "{{Shop}} Restocks the current shop if used inside a shop#Will also similarly restock {{DevilRoom}} Devil Deals and {{Collectible586}} Stairway shops",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
        },
    },
    [mod.ITEMS.LANKY_MUSHROOM] = {
        desc = "↑ {{Damage}} +0.7 Damage up#↓ {{Tears}} -0.4 Tears down#↑ {{Range}} 0.75 Range up#Makes Isaac 50% taller and 25% thinner",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_SECRET,
            pools.POOL_GREED_TREASURE,
            pools.POOL_GREED_BOSS
        }
    },
    [mod.ITEMS.ELECTRIC_DICE] = {
        desc = "↑ Has a chance to use an active item 1-2 more times on use",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP
        },
    },
    [mod.ITEMS.HELLFIRE] = {
        desc = "{{Collectible118}} On death, enemies have a chance to stay alive for slightly longer, then explode and fire 4 brimstone lasers in the cardinal directions#{{Luck}} Scales with luck",
        pools = { pools.POOL_DEVIL, pools.POOL_ULTRA_SECRET,
            pools.POOL_GREED_DEVIL}
    },
    [mod.ITEMS.CROWN_OF_BLOOD] = {
        desc = "!!! Enemies respawn at half health on death#↑ Room clear rewards will run twice#↑ +2 luck",
        Hide = true,
    },
    [mod.ITEMS.OLD_URN] = {
        desc = "{{Card81}} Spawns 3 soul stones on pickup#{{Rune}} Will spawn runes if no soul stones are unlocked",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_SECRET,
            pools.POOL_GREED_SHOP,
            pools.POOL_GREED_SECRET
        }
    },
    [mod.ITEMS.RED_LOCKBOX] = {
        desc = "{{SoulHeart}} Spawns 4-6 soul hearts on pickup",
        pools = {
            pools.POOL_RED_CHEST,
            pools.POOL_DEMON_BEGGAR,
            pools.POOL_KEY_MASTER,
            pools.POOL_ULTRA_SECRET,
        },
    },
    [mod.ITEMS.ITEM_BOX] = {
        desc = "\1 Grants the effect of 4 random items for the current room",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_SECRET }
    },
    [mod.ITEMS.CURSED_MUSHROOM] = {
        desc = "Upon use, curses all enemies in the room for 7 seconds"..mod.GENERIC_DESCRIPTIONS.CURSE,
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_CRANE_GAME,
            pools.POOL_GREED_TREASURE,
        },
    },
    [mod.ITEMS.TRINKET_SMASHER] = {
        desc = "{{Trinket}} Destroys any held trinkets on use#Spawns 3-4 random pickups on trinket destroy#Increases the spawn rate of trinkets",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP
        }
    },
    [mod.ITEMS.STAR_SPAWN] = {
        desc = "↑ {{Damage} 1.2x Damage#↑ {{Tears}} 1.2x Tears#\1 On damage, applies a random multiplier to both tears and damage#Lowest multipler can be 0.5x, Highest multipler can be 2.4x",
        pools = { pools.POOL_TREASURE, pools.POOL_CRANE_GAME,
            pools.POOL_ULTRA_SECRET, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.BRAVERY] = {
        desc = "↑ 1.5x damage against bosses and champion enemies",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GOLDEN_CHEST,
            pools.POOL_CRANE_GAME,
            pools.POOL_GREED_TREASURE,
        }
    },
    [mod.ITEMS.PLANCHETTE] = {
        desc = "↑ {{Collectible163}} All Wisps, Nightmares, and other ghost-like familiars have double HP and deal double damage#"
        .."{{Collectible584}} Spawns four unique Book of Virtues wisps on pickup#{{BlackHeart}} +1 Black Heart",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
            pools.POOL_CURSE,
            pools.POOL_GREED_CURSE
        }
    },
    [mod.ITEMS.AIR_FRESHENER] = {
        desc = "While in combat, spawns tears around you which home onto nearby enemies",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE,
        }
    },
        [mod.ITEMS.ENCYCLOPEDIA] = {
            desc = "↑ Bonus 33% chance to spawn a {{Library}} Library on new floor entry while held#{{Library}} Teleports the player to the Library on use# !!! Only charged if there is a library on the floor",
            pools = {
                pools.POOL_LIBRARY,
                pools.POOL_TREASURE
            }
        },
    [mod.ITEMS.PLASMA_GLOBE] = {
        desc = "{{Confusion}} Tears have a chance to confuse enemies for 2 seconds and cause them to shoot lightning out in random directions#{{Luck}} 100% chance at 14 Luck",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_CRANE_GAME,
            pools.POOL_GREED_TREASURE
        }
    },
    [mod.ITEMS.VOID_BOMBS] = {
        desc = "{{Bomb}} +5 bombs #{{Collectible399}} Isaac's bombs spawn a Maw of The Void ring upon exploding",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL,
            pools.POOL_BOMB_BUM
        }
    },
    [mod.ITEMS.BOLINE] = {
        desc = "{{Collectible399}} Throws a Maw of the Void ring on use#Will also recharge on taking damage",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL,
        }
    }, 
    [mod.ITEMS.LOURDES_WATER] = {
        desc = "↑ Every room, a random rock will turn into an angellic statue#Standing inside the statue's aura grants:#↑ {{Damage}} +20% Damage#↑ {{Tears}} +150% Tears Multiplier#Homing tears#↑ Enemies that try to enter the aura will be damaged and repelled",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_ANGEL,
        }
    },
    [mod.ITEMS.BOOK_OF_EXODUS] = {
        desc = "{{Trinket}} Converts any trinkets to golden trinkets on use↑ While held, doubles all trinket spawns#↑ {{Luck}} +1 Luck while held",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
            pools.POOL_LIBRARY
        }
    },
    [mod.ITEMS.WOODEN_DICE] = {
        desc = "{{Trinket}} Rerolls any trinkets on you, smelted or not, upon use#↑ While held, smelts one trinket upon entering a new floor#↑ {{Luck}} +1 Luck while held",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
        }
    },
    [mod.ITEMS.WICKERMAN] = {
        desc = "↑ Every floor will spawn a {{SacrificeRoom}} Sacrifice Room if possible#Spawns 2 red hearts on pickup",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_CRANE_GAME
        }
    },
    [mod.ITEMS.APOLLYONS_CROWN] = {
        desc = "{{Collectible706}}Spawns 2-4 permanent abyss locusts as companions#Can rarely spawn unique locusts with the effects of other item's locusts",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_DEVIL,
            pools.POOL_BABY_SHOP,
            pools.POOL_GREED_TREASURE
        }
    },
    [mod.ITEMS.TECH_MODULO] = {
        desc = "Firing a tear will fire two perpendicular half damage lasers at wherever the tear would land#↓ {{Damage}} -33.3% damage down",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_CRANE_GAME}
    },
    [mod.ITEMS.STRANGE_APPLE] = {
        desc = [[↑ Spawns a snake familiar that takes up half a grid of position and moves along the grid every 6 frames#Deals 10 damage from the head, 5 damage from the body, and does individual damage from every segment colliding]],
        pools = {
            pools.POOL_TREASURE, pools.POOL_SECRET,
            pools.POOL_ULTRA_SECRET, pools.POOL_BABY_SHOP,
            pools.POOL_GREED_TREASURE, pools.POOL_GREED_SECRET
        }
    },
    [mod.ITEMS.TIAMATS_DICE] = {
        desc = "Rerolls items into items from a random item pool, with a random cost",
        pools = {
            pools.POOL_SECRET,
            pools.POOL_GREED_SECRET
        }
    },
    [mod.ITEMS.CURSED_CREDIT_CARD] = {
        desc = "{{DevilRoom}} Buying a devil deal Item has a 50% chance to not cost hearts#Has less of a chance to activate on items with a bigger heart price#{{BlackHeart}} +1 Black Heart",
        pools = {
            pools.POOL_CURSE,
            pools.POOL_ULTRA_SECRET,
        },
        --encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Buying a Devil Deal Item has a "..(this.ProcChance * 100).."% chance to not cost hearts","Items which cost more hearts have less of a chance to work","Adds 1 black heart on pickup"})
    },
    [mod.ITEMS.RED_NIGHTMARE] = {
        desc = "Adds an extra {{UltraSecretRoom}} Ultra Secret Room to each floor#{{Card78}} Spawns 1-3 Cracked Keys",
        pools = { pools.POOL_ULTRA_SECRET}
    },
    [mod.ITEMS.FRUIT_MILK] = {
        desc = "Each one of Isaac's tears gets four different effects#↓ {{Damage}} x0.2 Damage multiplier",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.LANTERN_BATTERY] = {
        desc = "{{Battery}} 25% chance to give bonus charge on room clear or wave clear#Spawns a battery on pickup",
        pools = { pools.POOL_SHOP, pools.POOL_GREED_SHOP}
    },
    [mod.ITEMS.OLD_DICE] = {
        desc = [[Upon use, rerolls the current item being picked up into a random passive item
            #Does nothing if you are not picking up an item
            #If dropped to pick up another active, can be used while you are picking up the active]],
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_SHOP,
            pools.POOL_CRANE_GAME
        },
    },
    [mod.ITEMS.EDENS_HEAD] = {
        desc = "Uses a random throwable active item on use",
        encycloDesc = "Uses a random throwable active item on use",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE}
    },
    [mod.ITEMS.CURSED_CANDLE] = {
        desc = "Throws a flame on use which curses enemies for 6 seconds on contact"..mod.GENERIC_DESCRIPTIONS.CURSE,
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
        },
    },
    [mod.ITEMS.ABANDONED_BOX] = {
        desc = "{{Warning}} SINGLE USE {{Warning}}#Spawns a random familiar from the current room's item pool",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP
        }
    },
    [mod.ITEMS.RED_CAP] = {
        desc = "{{SoulHeart}} Picking up a soul heart with empty red hearts will convert it to red hearts, at a 2x rate#↑ {{Heart}} +2 Health up#+Heals 3 hearts on pickup#↓ {{Shotspeed}} -0.15 Shot Speed down#↓ {{Range}} -0.8 Range down",
        pools = { pools.POOL_TREASURE, pools.POOL_SECRET, pools.POOL_ULTRA_SECRET }
    },
    [mod.ITEMS.DADS_WALLET] = {
        desc = "{{Shop}} Allows Isaac to take 4 shop items for free#Charge corresponds to items left to take",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
            pools.POOL_OLD_CHEST,
        },
    },
    [mod.ITEMS.WICKED_RING] = {
        desc = "{{Battery}} Chance to shoot tears with increased damage that add charge to active items after doing enough damage#Damage needed per charge increases each floor#{{Luck}} Scales with luck",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_CURSE,
            pools.POOL_GREED_DEVIL
        }
    },
    [mod.ITEMS.WRATH] = {
        desc = "↑ Damaging an enemy will send out a tear that homes onto that enemy and deals 1/3 of your damage#{{BrokenHeart}} +3 Broken Hearts",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL,
            pools.POOL_CURSE,
            pools.POOL_GREED_CURSE,
            pools.POOL_ULTRA_SECRET,
        },
    },
    [mod.ITEMS.ASSIST_TROPHY] = {
        desc = "\1 Grants the effect of a random familiar item for the current room",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_CRANE_GAME }
    },
    [mod.ITEMS.NIGHTSHADE] = {
        desc = "Spawns wisps with homing tears upon killing an enemy#These wisps are removed upon entering a new room, or after 4 seconds",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE,
            pools.POOL_CRANE_GAME,
        }
    },
    [mod.ITEMS.LOVERS_MASK] = {
        desc = "{{Heart}} 30% chance to block any red heart damage#↑ Prevents the devil deal chance damage penalty",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.THREED_GLASSES] = {
        name = "3D Glasses",
        desc = "↑ 25% chance to shoot 2 additional tears that deal half of your damage",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_CRANE_GAME,
            pools.POOL_GREED_TREASURE,
        }
    },
    [mod.ITEMS.STAR_OF_THE_BOTTOMLESS_PIT] = {
        desc =  "↑ Converts all blue flies into locusts#↑ Chance to spawn a blue fly upon killing enemies#{{Luck}} Scales with Luck",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL,
            pools.POOL_ANGEL,
            pools.POOL_GREED_ANGEL
        }
    },
    [mod.ITEMS.CHRISMATORY] = {
        desc = "Firing a tear has a chance to shoot out nine ghost tears that home in on enemies#Applies knockback and a greater tear cooldown after firing#Isaac will glow white if the next shot will shoot ghosts",
        pools = { pools.POOL_ANGEL, pools.POOL_GREED_ANGEL }
    },
    [mod.ITEMS.FITUS_FORTUNUS] = {
        desc = "↑ 33% chance to spawn a random pickup upon killing a champion",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GREED_SHOP,
        },
    },
    [mod.ITEMS.CROSSED_HEART] = {
        desc = "↑ {{Damage}} +0.7 Damage up#{{Heart}} Picking up a red heart has a 50% chance to heal for a bonus half red heart",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE,
            pools.POOL_CRANE_GAME
        }
    },
    [mod.ITEMS.SUPERIORITY] = {
        desc = "↑ {{Damage}} +0.7 Damage for every enemy alive in the room, minus one#Caps at 7 enemies.",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE,
            pools.POOL_CRANE_GAME,
        },
    },
    [mod.ITEMS.BOOK_OF_LUCIFER] = {
        desc = "↑ {{Damage}} +0.6 Damage for the current floor#↑ A bonus sin miniboss will appear on every floor outside of greed mode",
        
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_LIBRARY,
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL,
            pools.POOL_GREED_TREASURE
        },
    },
    [mod.ITEMS.CHASM] = {
        desc = "↑ Destroys all items in the rooms and gives the user a 10% chance to deal 2.6x damage on anything they fire# !!! No bonus for destroying over 10 items",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE
        }
    },
    [mod.ITEMS.CAT_FOOD] = {
        desc = "↑ {{Heart}} +1 Health#{{Heart}} Heals 1 heart#Boss rooms drop 5 half red hearts upon defeating the boss",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_CRANE_GAME,
            pools.POOL_BEGGAR,
        }
    },
    [mod.ITEMS.CHAOS_HEART] = {
        desc = "{{Heart}} Heal 1 red heart#!!! After 5 uses, has a chance to do a {{Collectible483}} Mama Mega explosion for the current room, and remove the item#Guaranteed to explode at 9 uses",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_ULTRA_SECRET,
            pools.POOL_GREED_TREASURE,
        },
    },
    [mod.ITEMS.GOLDEN_CARD] = {
        desc = "Uses 1-2 random tarot cards#"..mod.GENERIC_DESCRIPTIONS.CARDDRAW,
        pools = { pools.POOL_SHOP, pools.POOL_SECRET, 
        pools.POOL_GREED_SHOP}
    },
    [mod.ITEMS.BOOSTER_BOX] = {
        desc = "Killing an enemy has a chance to use a random tarot cards effect#Reduces the chance to use a card for the next 5 rooms on activation#"..mod.GENERIC_DESCRIPTIONS.CARDDRAW,
        pools = {pools.POOL_TREASURE, pools.POOL_SECRET,
        pools.POOL_GREED_TREASURE}
    },
    [mod.ITEMS.BIRETTA] = {
        desc = "A confessional spawns upon entering a new floor",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_ANGEL,
            pools.POOL_ULTRA_SECRET
        },
    },
    [mod.ITEMS.RAMS_HEAD] = {
        desc = "↑  {{Tears}} +0.5 Tears up#↑ {{Damage}} +0.7 Damage up",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_CRANE_GAME,
            pools.POOL_GREED_TREASURE,
            pools.POOL_GREED_BOSS,
        }
    },
    [mod.ITEMS.TOYBOX] = {
        desc = "{{Warning}} SINGLE USE {{Warning}}#{{Trinket}} Smelts four random trinkets onto you",
        pools = {
            pools.POOL_SHOP,
            pools.POOL_GOLDEN_CHEST,
            pools.POOL_KEY_MASTER,
            pools.POOL_GREED_SHOP,
        },
    },
    [mod.ITEMS.BALROGS_HEAD] = {
        desc = "Throwable fire bomb#Spawns 4 fires which do 23 damage, and 1 fire which does 50 damage",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE
        },
    },
    [mod.ITEMS.MINOS_ITEM] = {
        desc = "Spawns a snake familiar which charges at enemies you fire in the direction of",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_BABY_SHOP,
            pools.POOL_GREED_DEVIL,
            pools.POOL_ULTRA_SECRET
        },
    },
    [mod.ITEMS.HYDRUS] = {
        desc = "Spawns a trail of tears that will charge into any nearby enemies#Will respawn in a new room, or after a brief period after it dies",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_ULTRA_SECRET}
    },
    [mod.ITEMS.DEVILSKNIFE_ITEM] = {
        desc = "Spawns an orbiting knife familiar which will deal heavy contact damage and will oscillate in distance from the player",
        pools = {pools.POOL_DEVIL, pools.POOL_GREED_DEVIL, 
        pools.POOL_CURSE, pools.POOL_ULTRA_SECRET, 
        pools.POOL_BABY_SHOP},
    },
    [mod.ITEMS.VOID_EGG] = {
        desc = "Spawns 1-3 locusts on use# !!! Picking up a red heart while this item is uncharged will instead charge this item",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_CURSE,
            pools.POOL_GREED_DEVIL,
            pools.POOL_DEMON_BEGGAR,
            pools.POOL_GREED_CURSE,
            pools.POOL_CRANE_GAME
        }
    },
    [mod.ITEMS.SOLOMON_ITEM] = {
        desc = "{{Collectible712}} Spawns 1 Lemegeton wisp every 8 rooms",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_BABY_SHOP,
            pools.POOL_GREED_DEVIL
        },
    },
    [mod.ITEMS.JUSTICE_AND_SPLENDOR] = {
        desc = "↑ Every 3 seconds, spawns 2 sword familiars that orbit the player that deal 45 contact damage per second#The swords will remain for 4 seconds after spawn#"..
        "The swords will stay permanently if Isaac has no damaged red heart containers, but will move slower when they would be gone",
        pools = { pools.POOL_ANGEL, pools.POOL_BABY_SHOP, pools.POOL_GREED_ANGEL}
    },
    [mod.ITEMS.GLITCHCITY] = {
        desc = "Periodically spawns \"Glitched Tiles\" while held, which destroy rocks, block projectiles and damage enemies"..
        "#!!! While held, every minute and a half, another random item held will turn into GLITCHCITY",
        pools = {
            pools.POOL_SECRET,
            pools.POOL_GREED_SECRET
        }
    },
    [mod.ITEMS.SPIDER_EGG] = {
        desc = "↑ Will spawn a spider egg every 5 seconds while Isaac is firing, which spawns a blue spider on landing",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_ROTTEN_BEGGAR,
            pools.POOL_KEY_MASTER,
            pools.POOL_GREED_TREASURE,
        }
    },
    [mod.ITEMS.ROGUE_PLANET_ITEM] = {
        desc = "↑ {{Range}} +13 Range up#Spawns a planetoid orbital that your tears will orbit",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_BABY_SHOP,
            pools.POOL_GREED_TREASURE
        }
    },
    [mod.ITEMS.STAR_TREAT] = {
        desc = "↑ {{Heart}} +1 Health#{{Heart}} Heals 1 heart#↑ {{ShotSpeed}} +0.14 Shot Speed up",
        pools = {
            pools.POOL_BOSS,
            pools.POOL_GREED_BOSS,
        }
    },
    [mod.ITEMS.BOOK_OF_INSANITY] = {
        desc = "Spawns a Nightmare familiar upon use"..mod.GENERIC_DESCRIPTIONS.NIGHTMARES,
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_LIBRARY,
            pools.POOL_GREED_TREASURE
        },
    },
    [mod.ITEMS.YELLOW_SIGIL] = {
        desc = "{{Collectible"..mod.ITEMS.BOOK_OF_INSANITY.."}} 50% chance to spawn a nightmare familiar for the current floor on damage"..mod.GENERIC_DESCRIPTIONS.NIGHTMARES,
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE,
        },
    },
    [mod.ITEMS.RELIQUARY] = {
        desc = "{{Heart}} Items that give heart containers also give +2 {{SoulHeart}} Soul Hearts and {{Tears}} +0.5 Tears up#{{SoulHeart}} +1 Soul Heart",
        pools = {
            pools.POOL_ANGEL,
            pools.POOL_GREED_ANGEL
        }
    },
    [mod.ITEMS.DIS] = {
        desc = "Picking up an item will grant another temporary item from the same pool, until you take damage or you reach the next floor",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL
        }
    },
    [mod.ITEMS.ACTIVATED_CHARCOAL] = {
        desc = "{{Collectible149}} Grants the effect of Ipecac for the current room",
        pools = {
            pools.POOL_TREASURE,
            pools.POOL_GREED_TREASURE,
        }
    },
    [mod.ITEMS.LIGHT_SHARD] = {
        desc = "Fire an additional homing tear at a faster rate but with reduced damage if Isaac has no damaged heart containers#{{EternalHeart}} +1 Eternal Heart",
        pools = {
            pools.POOL_ANGEL,
            pools.POOL_GREED_ANGEL,
        }
    },
    [mod.ITEMS.DARK_SHARD] = {
        desc = "Fire an additional homing tear at a faster rate but with reduced damage if Isaac has no red hearts#{{BlackHeart}} +1 Black Heart",
        pools = {
            pools.POOL_DEVIL,
            pools.POOL_GREED_DEVIL,
        }
    },
    [mod.ITEMS.DISCIPLES_EYE] = {
        desc = "{{UltraSecretRoom}} Reveals the Ultra Secret room#{{Card78}} 33% chance to spawn a cracked key upon using sacrifice rooms#{{Card78}} Spawns a cracked key on pickup",
        pools = {
            pools.POOL_CURSE,
            pools.POOL_SECRET,
            pools.POOL_ULTRA_SECRET,
        },
    },
    [mod.ITEMS.CAROLINA_REAPER] = {
        desc = "Chance to shoot a cursing purple fire, which gives enemies the cursed status effect#Cursed enemies take 1.5x damage#{{Luck}} 50% chance to fire at 10 luck",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE}
    },
    [mod.ITEMS.NAGA_VIPER] = {
        desc = "Chance to shoot green fires, which explode on contact#{{Luck}} 50% chance to fire at 10 luck",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_RED_CHEST}
    },
    [mod.ITEMS.GOLDEN_WATCH] = {
        desc = "!!! Buying anything from the shop will destroy this item#\1 {{Tears}} +0.2 Tears up #\1 {{Speed}} +0.2 Speed up #↑ {{Range}} +0.75 Range up#\1 {{Luck}} +1 Luck up",
        pools = { pools.POOL_SHOP, pools.POOL_GREED_SHOP }
    },
    [mod.ITEMS.BOOK_OF_LEVIATHAN] = {
        name = "Book of Leviathan",
        desc = "{{CurseBlind}} Cannot be used on floors without curses#{{BlackHeart}} +1 Black Heart#\1 {{Tears}} +0.5 Tears up for the current floor#\1 {{Speed}} +0.1 Speed up for the current floor",
        pools = { pools.POOL_CURSE, pools.POOL_LIBRARY, pools.POOL_GREED_DEVIL, pools.POOL_GREED_CURSE},
    },
    [mod.ITEMS.GANYMEDE] = {
        name = "Ganymede",
        desc = "\1 Every 5 tears fired, fire a burst of 4 stationary tears#If these tears are in range of other tears, they will orbit the tears and gain homing#Spectral tears",
        pools = { pools.POOL_PLANETARIUM }
    },
    [mod.ITEMS.FLY_SCREEN_ITEM] = {
        desc = "Bounces around the room#Deals contact damage and attracts enemies and pickups",
        pools = {pools.POOL_TREASURE, pools.POOL_BABY_SHOP, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.THE_SHRINKS] = {
        desc = "{{Collectible598}} Grants the effect of Pluto for the current room upon taking damage",
        pools = {pools.POOL_TREASURE, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.CURSE_MASK] = {
        desc = "{{CursedRoom}} Blocks all damage from Curse Rooms#{{Heart}} Curse Rooms heal upon entering for the first time",
        Hide = true,
    },
    [mod.ITEMS.ADDER_STONE] = {
        desc = "\1 {{Luck}} +1 Luck up#Spawns a Stone of the Pit",
        Hide = true,
    },
    [mod.ITEMS.TWO_DOLLAR_COIN] = {
        desc = "Spawns a Golden Penny on pickup",
        pools = { pools.POOL_BOSS, pools.POOL_GREED_BOSS}
    },
    [mod.ITEMS.TEFILIN] = {
        desc = "{{AngelRoom}} Guarantees an Angel Room will spawn at the next possible opportunity",
        pools = { pools.POOL_SHOP, pools.POOL_GREED_SHOP}
    },
    [mod.ITEMS.DOUBLES] = {
        desc = "Isaac shoots 1-6 tears at once#↓ {{Tears}} Tears down, increasing with the number of tears fired",
        pools = {pools.POOL_TREASURE, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.FEAR_STALKS_THE_LAND] = {
        desc = "Any enemies who take damage gain dread temporarily"..mod.GENERIC_DESCRIPTIONS.DREAD,
        pools = {pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_LIBRARY }
    },
    [mod.ITEMS.MONOKUMA] = {
        desc = "Dread tears"..mod.GENERIC_DESCRIPTIONS.DREAD,
        pools = {pools.POOL_TREASURE, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.MAGIC_EYE] = {
        desc = "Grants the effect of a random mapping item every floor",
        pools = { pools.POOL_SHOP }
    },
    [mod.ITEMS.ACHERON] = {
        desc = "{{DevilRoom}} Killing enemies sometimes grants the effects of random Devil Room items for 90 seconds",
        pools = { pools.POOL_DEVIL, pools.POOL_GREED_DEVIL }
    },
    [mod.ITEMS.DARKNESS] = {
        desc = "↑ {{Damage}} +0.3 Damage up#↑ {{Range}} +0.75 Range up#↓ {{Shotspeed}} -0.16 Shot Speed down#↓ {{Tears}} -0.4 Tears down#Shooting tears cause other tears to slow down, piercing and dealing 33% damage to enemies multiple to times#!!! Tear effects do not apply while phasing",
        pools = { pools.POOL_DEVIL, pools.POOL_GREED_DEVIL }
    },
    [mod.ITEMS.ZERO_POINT_REACTOR] = {
        desc = "Tears fire additional orbital spectral tears upon hitting anything",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE }
    },
    [mod.ITEMS.LIVING_WATER] = {
        desc = "12% chance to shoot sticky tears which create a holy aura while stuck to an enemy#{{Luck}} Not affected by luck#Standing inside a tear's aura grants:#↑ {{Tears}} +150% Tears Multiplier#Homing tears",
        pools = { pools.POOL_TREASURE, pools.POOL_ANGEL, pools.POOL_GREED_TREASURE, pools.POOL_ANGEL }
    },
    [mod.ITEMS.DEMONIUM_PAGE] = {
        desc = "{{BossRoom}} Boss Room items grant additional stats up if you didn't take damage during the boss",
        pools = { pools.POOL_DEVIL, pools.POOL_GREED_DEVIL }
    },
    [mod.ITEMS.THE_SON] = {
        desc = "{{SacrificeRoom}} Sacrifice Rooms will do fake damage instead of actual damage#{{SoulHeart}} +3 Soul Hearts",
        pools = { pools.POOL_ANGEL }
    },
    [mod.ITEMS.HOT_POTATO_BOOK] = {
        desc = "{{Damage}} 1.1x Damage permanently on use#!!! Does not charge on room clear, can only be charged through batteries, items, or any other usual way",
        pools = { pools.POOL_TREASURE, pools.POOL_GREED_TREASURE, pools.POOL_LIBRARY}
    }
}

for index, value in pairs(collectibles) do
    --print(index, value.desc)
    if EID then
        EID:addCollectible(index, value.desc, value.name)
    end

    if Encyclopedia and Encyclopedia.EIDtoWiki then --/shrug
        local tab = genericWikiTable(index, value.desc)
        tab.Pools = value.pools
        tab.Hide = value.Hide or false
        Encyclopedia.AddItem(tab)
    end
end

local trinkets = {
    [mod.TRINKETS.TWO_OF_COINS] = {
        desc = "{{Heart}} Spawns 2-4 coins upon picking up a red heart"
    },
    [mod.TRINKETS.CATS_EYE] = {
        desc = "↑ Spawns 1 sack upon entering a {{SecretRoom}} Secret Room",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, nil, 1)
        end
    },
    [mod.TRINKETS.STONE_KEY] = {
        desc = "↑ Opening a secret room will refund one bomb#Walking into bomb chests opens them for free",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, {"25% chance to spawn an additional bomb from opening Secret Rooms",
            "50% chance to spawn an additional bomb from opening Secret Rooms"})
        end
    },
    [mod.TRINKETS.TREASURERS_KEY] = {
        desc = "{{TreasureRoom}} Treasure Rooms and {{Planetarium}} Planetariums will spawn unlocked",
    },
    [mod.TRINKETS.CURSED_KEY] = {
        desc = "{{CursedRoom}} All locked doors will spawn as unlocked Curse Room doors",
    },
    [mod.TRINKETS.DICE_ROLLER] = {
        desc = "Using an active item has a chance to trigger one of the following effects:#{{Collectible105}} D6#{{Collectible406}} D8#{{Collectible285}} D10#{{Collectible386}} D12#{{Collectible166}} D20#Chance scales with the charge of the item used"
    },
    [mod.TRINKETS.GACHAPON] = {
        desc = "{{Trinket}} If rerolled or destroyed by any means, grants the following to the player who held it last"
        ..": #\1 {{Damage}} +0.6 Damage#\1 {{Tears}} +0.2 Tears up #\1 {{Speed}} +0.2 Speed up#↑ {{ShotSpeed}} +0.1 Shot Speed up #↑ {{Range}} +0.75 Range up#\1 {{Luck}} +1 Luck up",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, nil, { 0.6, 0.5, 0.2, 0.1, 0.75, 1 } )
        end
    },
    [mod.TRINKETS.POWER_INVERTER] = {
        desc = "{{Battery}} Batteries give a {{Damage}} +0.9 Damage up for the current floor",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, nil, {0.9})
        end
    },
    [mod.TRINKETS.SUGAR_COATED_PILL] = {
        desc = "{{Pill}} Using a pill will turn all pills of that type into Full Health pills for the rest of the run#This trinket is consumed on pill use",
    },
    [mod.TRINKETS.PRINT_OF_INDULGENCE] = {
        desc = "{{EternalHeart}} Chance to spawn an Eternal Heart upon taking damage",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, {"Chance increased!"})
        end
    },
    [mod.TRINKETS.GODLY_TOMATO] = {
        desc = "{{Collectible331}} Chance to give a fired tear a Godhead aura",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, {"↑ Chance doubled!", "↑ Chance tripled!"} )
        end,
    },
    [mod.TRINKETS.POPPET] = {
        desc = "{{Collectible462}} Chance to give a fired tear the effects of Eye of Belial",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, {"↑ Chance doubled!", "↑ Chance tripled!"} )
        end,
    },
    [mod.TRINKETS.HALLOWEEN_CANDY] = {
        desc = "you wanna know wh",
        Hide = true
    },
    [mod.TRINKETS.CELLPHONE_BATTERY] = {
        desc = "{{Battery}} 25% chance to gain an extra item charge on clearing a room#!!! All batteries are turned into bombs",
    },
    [mod.TRINKETS.SCORCHED_WOOD] = {
        desc =  "Enemies have a 33% chance to spawn a {{Collectible289}} Red Candle fire upon kill",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, nil, 33)
        end
    },
    [mod.TRINKETS.EMPTY_BOOK] = {
        desc = "{{Bookworm}} While held, counts as 1 item towards the Bookworm transformation",
    },
    [mod.TRINKETS.OWL_FEATHER] = {
        desc = "{{Trinket113}} 25% chance for a blue fly to turn into a Locust of War",
    },
    [mod.TRINKETS.GIFT_CARD] = {
        desc = "While held, your coins can never fall below 6 coins"..
        "#!!! 5% chance for the trinket to break upon refilling coins",
    },
    [mod.TRINKETS.BOBS_HEART] = {
        desc = "{{RottenHeart}} Turns all red hearts into rotten hearts.",
    },
    [mod.TRINKETS.TICKET_ROLL] = {
        desc = "A slot machine spawns upon clearing a boss room",
    },
    [mod.TRINKETS.DEMON_CORE] = {
        desc = "{{Collectible483}} Taking damage will spawn a Mama Mega explosion for the current room#Works only once per floor",
    },
    [mod.TRINKETS.DAMNED_SOUL] = {
        desc = "!!! When there is a curse on the current floor:"..mod.GENERIC_DESCRIPTIONS.SOULTRINKETSTATS,
        metadataFunction = soulMetadataFunc,
    },
    [mod.TRINKETS.VIRTUOUS_SOUL] = {
        desc = "!!! When there is no curse on the current floor:"..mod.GENERIC_DESCRIPTIONS.SOULTRINKETSTATS,
        metadataFunction = soulMetadataFunc,
    },
    [mod.TRINKETS.SAMPLE_BOX] = {
        desc = "{{Shop}} All items in the shop are free, but buying an item will remove any previous items bought with this item"
    },
    [mod.TRINKETS.NIGHTMARE_FUEL] = {
        desc = "Spawns a nightmare familiar"..mod.GENERIC_DESCRIPTIONS.NIGHTMARES.."#Respawns every room"
    },
    [mod.TRINKETS.VICODIN] = {
        desc = "{{Pill}} Using a pill will additionally use a Percs pill"
    },
    [mod.TRINKETS.CARD_GRAVEYARD] = {
        desc = "{{Card}} 50% chance to use a random card on damage#"..mod.GENERIC_DESCRIPTIONS.CARDDRAW
    },
    [mod.TRINKETS.RUNIC_CUBE] = {
        desc = "{{Rune}} 50% chance to use Jera on damage#"
    }
}

for key, value in pairs(trinkets) do
    if value.desc then
        if EID then
            EID:addTrinket(key, value.desc)

            if value.metadataFunction then
                value.metadataFunction(key)
            end
        end

        if Encyclopedia and Encyclopedia.EIDtoWiki then
            local tab = genericWikiTable(key, value.desc)
            tab.Hide = value.Hide or false
            Encyclopedia.AddTrinket(tab)
        end
    end
end

local cards = {
    [mod.CARDS.STONE_OF_THE_PIT] = {
        desc = "{{Trinket}} Smelts one random trinket onto you."
    },
    [mod.CARDS.KNIGHT_OF_CLUBS] = {
        desc = "{{Bomb}} Spawns 4 bombs worth of pickups"
    },
    [mod.CARDS.KNIGHT_OF_HEARTS] = {
        desc = "{{Heart}} Spawns 6 hearts worth of pickups"
    },
    [mod.CARDS.KNIGHT_OF_SPADES] = {
        desc = "{{Key}} Spawns 4 keys worth of pickups"
    },
    [mod.CARDS.KNIGHT_OF_DIAMONDS] = {
        desc = "{{Coin}} Spawns 12 coins worth of pickups"
    },
    [mod.CARDS.THE_GAME] = {
        desc = "{{Card}} Spawns 3 playing cards"
    },
    [mod.CARDS.MAGPIE_EYE] = {
        desc = "!!! Upon using this card, this card will become undroppable, and cannot be swapped out#While holding the used card, grants the effects of both {{Collectible414}}More Options and {{Collectible249}}There's Options#Using the card again will remove it"
    },
    [mod.CARDS.MAGPIE_EYE_BOON] = {
        desc = "Grants the effects of both {{Collectible414}} More Options and {{Collectible249}} There's Options while held#Cannot be dropped or swapped out"
    },
    [mod.CARDS.THOTH_LUST] = {
        desc = "{{Collectible313}} Grants the effect of Holy Mantle for 6 rooms"
    },
    [mod.CARDS.THOTH_THE_MAGUS] = {
        desc = "{{Battery}} Spawns two Batteries"
    },
}
for index, value in pairs(cards) do
    if EID ~= nil then
        EID:addCard(index, value.desc)
    end
end

if EID then
    --abyss
    EID.descriptions["en_us"].abyssSynergies[mod.ITEMS.CURSED_MUSHROOM] = "Purple cursing locust"

    --bov
    EID.descriptions["en_us"].bookOfVirtuesWisps[mod.ITEMS.CURSED_MUSHROOM] = "Curses nearby enemies on destruction"
    EID.descriptions["en_us"].bookOfVirtuesWisps[mod.ITEMS.TRINKET_SMASHER] = "Spawns two wisps on destroyed trinket, spawns bonus wisps if the trinket was worth more (eg. Golden Trinkets)"
    EID.descriptions["en_us"].bookOfVirtuesWisps[mod.ITEMS.FETUS_IN_FETU] = "Do nothing by themselves, will destroy self and spawn a blue spider if the item is used again"
    EID.descriptions["en_us"].bookOfVirtuesWisps[mod.ITEMS.GOLDEN_CARD] = "Does another random card effect on death"
    EID.descriptions["en_us"].bookOfVirtuesWisps[mod.ITEMS.BOLINE] = "Double HP wisps that spawn weaker maw of the void rings on damage"
    EID.descriptions["en_us"].bookOfVirtuesWisps[mod.ITEMS.ENCYCLOPEDIA] = "Spawns 4 wisps that dissapear if there is not a library on the floor, cannot have more than 4 wisps at once"
end