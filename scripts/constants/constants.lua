--june will put all global colours and etc here
local mod = SomethingWicked

EffectVariant.SOMETHINGWICKED_CHRISMATORYFIRE = Isaac.GetEntityVariantByName("Chrismatory Fire")
EffectVariant.SOMETHINGWICKED_MOTV_HELPER = Isaac.GetEntityVariantByName("[SW] maw of the void helper")
EffectVariant.SOMETHINGWICKED_ONERENDERHELPER = Isaac.GetEntityVariantByName("[SW] tear back helper")
EffectVariant.SOMETHINGWICKED_HOLY_STATUE_CIRCLE = Isaac.GetEntityVariantByName("Holy Statue Circle")
EffectVariant.SOMETHINGWICKED_WISP_TRAIL = Isaac.GetEntityVariantByName("Wisp Trail")
EffectVariant.SOMETHINGWICKED_WISP_EXPLODE = Isaac.GetEntityVariantByName("Wisp Tear Explode")
EffectVariant.SOMETHINGWICKED_THE_FOG_IS_COMING = Isaac.GetEntityVariantByName("Tombstone Fog")
EffectVariant.SOMETHINGWICKED_TOMBSTONE = Isaac.GetEntityVariantByName("Enemy Tombstone")
EffectVariant.SOMETHINGWICKED_DICE_OVERHEAD = Isaac.GetEntityVariantByName("Dice Overhead VFX")
EffectVariant.SOMETHINGWICKED_ITEMPOPUP = Isaac.GetEntityVariantByName("Wicked Item Pop-up")
EffectVariant.SOMETHINGWICKED_SPIDER_EGG = Isaac.GetEntityVariantByName("Spider Egg")
EffectVariant.SOMETHINGWICKED_GLITCHED_TILE = Isaac.GetEntityVariantByName("Glitchcity Glitched Tile")
EffectVariant.SOMETHINGWICKED_GLITCH_POOF = Isaac.GetEntityVariantByName("Glitchcity Explode")
EffectVariant.SOMETHINGWICKED_DIS_WISP = Isaac.GetEntityVariantByName("Dis Indicator")
EffectVariant.SOMETHINGWICKED_BLACK_SALT = Isaac.GetEntityVariantByName("Black salt effect")
EffectVariant.SOMETHINGWICKED_TEAR_HOLY_AURA = Isaac.GetEntityVariantByName("Tiny Holy Aura")
EffectVariant.SOMETHINGWICKED_BLANK = Isaac.GetEntityVariantByName("Wicked Blank")
EffectVariant.SOMETHINGWICKED_MANDRAKE_SCREAM_LARGE = Isaac.GetEntityVariantByName("Mandrake Scream (Large)")

TearVariant.SOMETHINGWICKED_GANYSPARK = Isaac.GetEntityVariantByName("Ganymede Spark Tear")
TearVariant.SOMETHINGWICKED_BALROG_CLUSTER = Isaac.GetEntityVariantByName("Balrog Tear")
TearVariant.SOMETHINGWICKED_WISP = Isaac.GetEntityVariantByName("Wrath Wisp Tear")
TearVariant.SOMETHINGWICKED_STICKERBOOK_STICKER = Isaac.GetEntityVariantByName("Sticker Tear")
TearVariant.SOMETHINGWICKED_FACESTABBER = Isaac.GetEntityVariantByName("Facestabber")
TearVariant.SOMETHINGWICKED_VOIDSBLADE = Isaac.GetEntityVariantByName("Call of the Void Tear")
TearVariant.SOMETHINGWICKED_LIGHT_SHARD = Isaac.GetEntityVariantByName("Light Shard Tear")

SomethingWicked.KNIFE_THING = Isaac.GetEntityVariantByName("[SW] Secret Knife")

SomethingWicked.ACHIEVEMENTS = {}
SomethingWicked.ACHIEVEMENTS.TECHNICALACHIEVEMENT = Isaac.GetAchievementIdByName("Wicked - Don't Unlock Me!")
SomethingWicked.ACHIEVEMENTS.BOLTS_OF_LIGHT = Isaac.GetAchievementIdByName("Wicked - Bolts of Light")
SomethingWicked.ACHIEVEMENTS.ADDER_STONE = Isaac.GetAchievementIdByName("Wicked - Adder Stone")

mod.CONST.HITSCAN_VAR = Isaac.GetEntityVariantByName("[SW] Hitscan Helper")

mod.ColourGold = Color(0.9, 0.8, 0, 1, 0.85, 0.75)
mod.CurseStatusColor = Color(1, 1, 1, 1, 0.1, 0, 0.3)
mod.BitterStatusColor = Color(0.5, 0.5, 0, 1, 0.6, 0.3, 0)
mod.DreadStatusColor = Color(1, 1, 1, 1, 0.2)
mod.DreadTearColor = Color(1, 0.3, 0.3, 1, 0.1)
mod.ElectroStunStatusColor = Color(1, 1, 1, 1, 0.5, 0.82, 1)
SomethingWicked.SlowColour = Color(1.2,1.2,1.2,1,0.1,0.1,0.1)

mod.ElectroStunTearColor = Color(1, 1, 1, 1, 0.4, 0.656, 0.8)
mod.PlasmaGlobeBaseProc = 0.125

mod.WickedFireSubtype = 23

--FAMILIARS
FamiliarVariant.SOMETHINGWICKED_FUZZY_FLY = Isaac.GetEntityVariantByName("Fuzzy Fly Familiar") -- unfinished
FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY = Isaac.GetEntityVariantByName("Cutie Fly") -- unfinished
FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE = Isaac.GetEntityVariantByName("Devilsknife")
FamiliarVariant.SOMETHINGWICKED_DUDAEL_GHOST = Isaac.GetEntityVariantByName("Dudael Ghost") -- unfinished
FamiliarVariant.SOMETHINGWICKED_BIG_WISP = Isaac.GetEntityVariantByName("Fat Wisp") -- unfinished
FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR = Isaac.GetEntityVariantByName("Splendorous Sword")
FamiliarVariant.SOMETHINGWICKED_PRISM_HELPER = Isaac.GetEntityVariantByName("Prism Helper") -- ybfubusged
FamiliarVariant.SOMETHINGWICKED_LEGION = Isaac.GetEntityVariantByName("Legion Familiar") -- unfinished
FamiliarVariant.SOMETHINGWICKED_LEGION_B = Isaac.GetEntityVariantByName("Legion Familiar B")
FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC = Isaac.GetEntityVariantByName("Cherry Isaac Familiar") -- unfinished
FamiliarVariant.SOMETHINGWICKED_FLY_SCREEN = Isaac.GetEntityVariantByName("Fly Screen Familiar") --unfinished
FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD = Isaac.GetEntityVariantByName("Minos (Head)")
FamiliarVariant.SOMETHINGWICKED_MINOS_BODY = Isaac.GetEntityVariantByName("Minos (Body)")
FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA = Isaac.GetEntityVariantByName("Ms. Gonorrhea") --unfinished
FamiliarVariant.SOMETHINGWICKED_YOYO = Isaac.GetEntityVariantByName("Wicked Yo-Yo") --still unfnished but oh well
FamiliarVariant.SOMETHINGWICKED_NIGHTMARE = Isaac.GetEntityVariantByName("Nightmare") -- reworkin
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE = Isaac.GetEntityVariantByName("Retro Snake")
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY = Isaac.GetEntityVariantByName("Retro Snake (body)")
FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL = Isaac.GetEntityVariantByName("Teratoma Orbital")
FamiliarVariant.SOMETHINGWICKED_SOLOMON = Isaac.GetEntityVariantByName("Solomon")
FamiliarVariant.SOMETHINGWICKED_ROGUE_PLANET = Isaac.GetEntityVariantByName("Rogue planet")

LocustSubtypes.SOMETHINGWICKED_LOCUST_OF_WORMWOOD = 21
LocustSubtypes.SOMETHINGWICKED_GLITCH_LOCUST = 22

FamiliarVariant.SOMETHINGWICKED_THE_CHECKER = Isaac.GetEntityVariantByName("[SW] room clear checker")

--[LAMP OIL, ROPE,] BOMBS
BombVariant.SOMETHINGWICKED_VOID = 2761

mod.CONST.CursePool = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_BLIND,
}
mod.PlanchetteFamiliars = {
    FamiliarVariant.ITEM_WISP,
    FamiliarVariant.WISP,
    FamiliarVariant.SOMETHINGWICKED_NIGHTMARE,
    FamiliarVariant.GHOST_BABY
}
mod.edensHeadthrowables = {
    CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD,
    CollectibleType.COLLECTIBLE_CANDLE,
    CollectibleType.COLLECTIBLE_RED_CANDLE,
    CollectibleType.COLLECTIBLE_BOOMERANG,
    CollectibleType.COLLECTIBLE_GLASS_CANNON,
    CollectibleType.COLLECTIBLE_DOCTORS_REMOTE,
    CollectibleType.COLLECTIBLE_BLACK_HOLE
}
mod.magicEyeItems = {
    CollectibleType.COLLECTIBLE_TREASURE_MAP,
    CollectibleType.COLLECTIBLE_BLUE_MAP,
    CollectibleType.COLLECTIBLE_COMPASS,
}
mod.optionTrinketsItem = {
    CollectibleType.COLLECTIBLE_MORE_OPTIONS,
    CollectibleType.COLLECTIBLE_THERES_OPTIONS,
    CollectibleType.COLLECTIBLE_OPTIONS,
}
SomethingWicked.MachineVariant = {
    MACHINE_SLOT = 1,
    MACHINE_BLOOD = 2,
    MACHINE_FORTUNE = 3,
    MACHINE_BEGGAR = 4,
    MACHINE_DEVIL_BEGGAR = 5,
    MACHINE_SHELL_GAME = 6,
    MACHINE_KEYMASTER = 7,
    MACHINE_DONATION = 8,
    MACHINE_BOMBBUM = 9,
    MACHINE_RESTOCK = 10,
    MACHINE_DONATION_GREED = 11,
    MACHINE_DRESSING_TABLE = 12,
    MACHINE_BATTERY_BUM = 13,
    MACHINE_TAINTED_PLAYER = 14,
    MACHINE_HELL_GAME = 15, --THIS IS LIKE BLACK MIDI
    MACHINE_CRANE_GAME = 16,
    MACHINE_CONFESSIONAL = 17,
    MACHINE_BEGGAR_ROTTEN = 18,

    MACHINE_VOIDBLOOD = Isaac.GetEntityVariantByName("Abyssal Machine"),
    MACHINE_TERATOMA_BEGGAR = Isaac.GetEntityVariantByName("Teratoma Beggar"),
    MACHINE_VOID_BEGGAR = Isaac.GetEntityVariantByName("Void Beggar"),
    MACHINE_INFINITEBEGGAR = Isaac.GetEntityVariantByName("Infinite Beggar")
}
mod.CONST.InfinityBeggarMachinePool = {
    mod.MachineVariant.MACHINE_SLOT,
    mod.MachineVariant.MACHINE_BLOOD,
    mod.MachineVariant.MACHINE_FORTUNE,
    mod.MachineVariant.MACHINE_BEGGAR,
    mod.MachineVariant.MACHINE_DEVIL_BEGGAR,
    mod.MachineVariant.MACHINE_SHELL_GAME,
    mod.MachineVariant.MACHINE_KEYMASTER,
    mod.MachineVariant.MACHINE_BOMBBUM,
    mod.MachineVariant.MACHINE_RESTOCK,
    mod.MachineVariant.MACHINE_BATTERY_BUM,
    mod.MachineVariant.MACHINE_HELL_GAME,
    mod.MachineVariant.MACHINE_CRANE_GAME,
    mod.MachineVariant.MACHINE_TERATOMA_BEGGAR,
    mod.MachineVariant.MACHINE_VOID_BEGGAR,
    mod.MachineVariant.MACHINE_VOIDBLOOD,
    mod.MachineVariant.MACHINE_BEGGAR_ROTTEN,
    mod.MachineVariant.MACHINE_CONFESSIONAL,
}

--enums
SomethingWicked.CustomCallbacks = {
    SWCB_PICKUP_ITEM = 1, -- obsolete with repentogon
    SWCB_ON_ENEMY_HIT = 2,
    SWCB_ON_BOSS_ROOM_CLEARED = 3,
    SWCB_ON_LASER_FIRED = 4,
    SWCB_ON_FIRE_PURE = 5, -- obsolete with repentogon
    SWCB_PRE_PURCHASE_PICKUP = 6,
    SWCB_POST_PURCHASE_PICKUP = 7, -- obsolete with repentogon
    --SWCB_ON_MINIBOSS_ROOM_CLEARED = 7,
    SWCB_NEW_WAVE_SPAWNED = 8,
    SWCB_ON_ITEM_SHOULD_CHARGE = 9,
    SWCB_EVALUATE_TEMP_WISPS = 10,
    SWCB_ON_NPC_EFFECT_TICK = 11,
    SWCB_POST_DEAL_DOOR_INIT = 12,
}
SomethingWicked.ItemPools = {
    TERATOMA_BEGGAR = 1
}
SomethingWicked.CustomTearFlags = {
    FLAG_ULTRASPLIT = 1 << 0,
    FLAG_KNAVE_OF_HEARTS = 1 << 1,
    FLAG_DREAD = 1 << 2,
    FLAG_BALROG_HEART = 1 << 3,
    FLAG_GODSTICKY = 1 << 4,
    FLAG_ELECTROSTUN = 1 << 5,
    FLAG_COINSHOT = 1 << 6,
    FLAG_PROVIDENCE = 1 << 8,
    FLAG_WITCHS_SALT = 1 << 9,
    FLAG_RAIN_HELLFIRE = 1 << 10,
    FLAG_STICKER_BOOK = 1 << 11,
    FLAG_SCREW_ATTACK = 1 << 12,
    FLAG_CAT_TEASER = 1 << 13,
    FLAG_ULTRAHOMING = 1 << 14,
    FLAG_DARKNESS = 1 << 15,
    FLAG_CRITCHARGE = 1 << 16,
    FLAG_PING = 1 << 17,
}
SomethingWicked.CustomCardTypes = {
    CARDTYPE_THOTH = 1,
    CARDTYPE_THOTH_REVERSED = 2,
    CARDTYPE_FRENCH_PLAYING = 3,
    CARDTYPE_RUNE_WICKEDMISC = 4,
}
SomethingWicked.NightmareSubTypes = {
    NIGHTMARE_STANDARD = 0,
    NIGHTMARE_TRINKET = 1,
    NIGHTMARE_FLOORONLY = 2,
    NIGHTMARE_BIG = 3,
}
SomethingWicked.ItemPopupSubtypes = {
    STANDARD = 1,
    
    MOVE_TO_PLAYER = 11,
    DIS_FUNNY_MOMENTS = 12,
}
SomethingWicked.MOTVHelperSubtypes = {
    STANDARD = 0,
    MOVELERP = 1,
    DARKNESSTRAIL = 2,
    LOURDESWATER = 4,
}