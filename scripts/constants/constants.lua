--june will put all global colours and etc here
local mod = SomethingWicked

EffectVariant.SOMETHINGWICKED_CHRISMATORYFIRE = Isaac.GetEntityVariantByName("Chrismatory Fire")
EffectVariant.SOMETHINGWICKED_MOTV_HELPER = Isaac.GetEntityVariantByName("[SW] maw of the void helper")
EffectVariant.SOMETHINGWICKED_HOLY_STATUE_CIRCLE = Isaac.GetEntityVariantByName("Holy Statue Circle")
EffectVariant.SOMETHINGWICKED_WISP_TRAIL = Isaac.GetEntityVariantByName("Wisp Trail")
EffectVariant.SOMETHINGWICKED_WISP_EXPLODE = Isaac.GetEntityVariantByName("Wisp Tear Explode")
EffectVariant.SOMETHINGWICKED_THE_FOG_IS_COMING = Isaac.GetEntityVariantByName("Tombstone Fog")
EffectVariant.SOMETHINGWICKED_TOMBSTONE = Isaac.GetEntityVariantByName("Enemy Tombstone")
EffectVariant.SOMETHINGWICKED_DICE_OVERHEAD = Isaac.GetEntityVariantByName("Dice Overhead VFX")
EffectVariant.SOMETHINGWICKED_ITEMPOPUP = Isaac.GetEntityVariantByName("Wicked Item Pop-up")
EffectVariant.SOMETHINGWICKED_SPIDER_EGG = Isaac.GetEntityVariantByName("Spider Egg")

TearVariant.SOMETHINGWICKED_REALLY_GOOD_PLACEHOLDER = Isaac.GetEntityVariantByName("Wicked Placeholder Tear")
TearVariant.SOMETHINGWICKED_BALROG_CLUSTER = Isaac.GetEntityVariantByName("Balrog Tear")
TearVariant.SOMETHINGWICKED_WISP = Isaac.GetEntityVariantByName("Wrath Wisp Tear")
TearVariant.SOMETHINGWICKED_STICKERBOOK_STICKER = Isaac.GetEntityVariantByName("Sticker Tear")
TearVariant.SOMETHINGWICKED_FACESTABBER = Isaac.GetEntityVariantByName("Facestabber")
TearVariant.SOMETHINGWICKED_VOIDSBLADE = Isaac.GetEntityVariantByName("Call of the Void Tear")

mod.CONST.HITSCAN_VAR = Isaac.GetEntityVariantByName("[SW] Hitscan Helper")

mod.ColourGold = Color(0.9, 0.8, 0, 1, 0.85, 0.75)
mod.CurseStatusColor = Color(1, 1, 1, 1, 0.1, 0, 0.3)
mod.BitterStatusColor = Color(0.5, 0.5, 0, 1, 0.6, 0.3, 0)
mod.DreadStatusColor = Color(1, 1, 1, 1, 0.4)
mod.ElectroStunStatusColor = Color(1, 1, 1, 1, 0.5, 0.82, 1)

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
FamiliarVariant.SOMETHINGWICKED_LITTLE_ATTRACTOR = Isaac.GetEntityVariantByName("Little Attractor Familiar") --unfinished
FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD = Isaac.GetEntityVariantByName("Minos (Head)")
FamiliarVariant.SOMETHINGWICKED_MINOS_BODY = Isaac.GetEntityVariantByName("Minos (Body)")
FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA = Isaac.GetEntityVariantByName("Ms. Gonorrhea") --unfinished
FamiliarVariant.SOMETHINGWICKED_YOYO = Isaac.GetEntityVariantByName("Wicked Yo-Yo") --still unfnished but oh well
FamiliarVariant.SOMETHINGWICKED_NIGHTMARE = Isaac.GetEntityVariantByName("Nightmare") -- reworkin
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE = Isaac.GetEntityVariantByName("Retro Snake")
FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY = Isaac.GetEntityVariantByName("Retro Snake (body)")
FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL = Isaac.GetEntityVariantByName("Teratoma Orbital")
FamiliarVariant.SOMETHINGWICKED_PHOBOS = Isaac.GetEntityVariantByName("Phobos Familiar")
FamiliarVariant.SOMETHINGWICKED_DEIMOS = Isaac.GetEntityVariantByName("Deimos Familiar")
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

--enums
mod.CustomCallbacks = {
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
}
mod.MachineVariant = {
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
mod.ItemPools = {
    TERATOMA_BEGGAR = 1
}
mod.CustomTearFlags = {
    FLAG_SHOTGRUB = 1 << 0,
    FLAG_KNAVE_OF_HEARTS = 1 << 1,
    FLAG_DREAD = 1 << 2,
    FLAG_BALROG_HEART = 1 << 3,
    FLAG_BITTER = 1 << 4,
    FLAG_ELECTROSTUN = 1 << 5,
    FLAG_COINSHOT = 1 << 6,
    FLAG_PROVIDENCE = 1 << 8,
    FLAG_BLACK_SALT = 1 << 9,
    FLAG_RAIN_HELLFIRE = 1 << 10,
    FLAG_STICKER_BOOK = 1 << 11,
    FLAG_SCREW_ATTACK = 1 << 12,
    FLAG_CAT_TEASER = 1 << 13,
    FLAG_UNRAVEL = 1 << 14,
    FLAG_DARKNESS = 1 << 15,
    FLAG_CRITCHARGE = 1 << 16,
}
mod.CustomCardTypes = {
    CARDTYPE_THOTH = 1,
    CARDTYPE_THOTH_REVERSED = 2,
    CARDTYPE_FRENCH_PLAYING = 3,
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
mod.NightmareSubTypes = {
    NIGHTMARE_STANDARD = 0,
    NIGHTMARE_TRINKET = 1,
    NIGHTMARE_FLOORONLY = 2,
    NIGHTMARE_BIG = 3,
}