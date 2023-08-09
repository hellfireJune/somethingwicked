--june will put all global colours and etc here
local mod = SomethingWicked

EffectVariant.SOMETHINGWICKED_CHRISMATORYFIRE = Isaac.GetEntityVariantByName("Chrismatory Fire")

mod.CONST.HITSCAN_VAR = Isaac.GetEntityVariantByName("[SW] Hitscan Helper")

mod.ColourGold = Color(0.9, 0.8, 0, 1, 0.85, 0.75)
mod.CurseStatusColor = Color(1, 1, 1, 1, 0.1, 0, 0.3)
mod.BitterStatusColor = Color(0.5, 0.5, 0, 1, 0.6, 0.3, 0)
mod.DreadStatusColor = Color(1, 1, 1, 1, 0.4)
mod.ElectroStunStatusColor = Color(1, 1, 1, 1, 0.5, 0.82, 1)

--FAMILIARS
FamiliarVariant.SOMETHINGWICKED_FUZZY_FLY = Isaac.GetEntityVariantByName("Fuzzy Fly Familiar")
FamiliarVariant.SOMETHINGWICKED_CUTIE_FLY = Isaac.GetEntityVariantByName("Cutie Fly")
FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE = Isaac.GetEntityVariantByName("Devilsknife")
FamiliarVariant.SOMETHINGWICKED_DUDAEL_GHOST = Isaac.GetEntityVariantByName("Dudael Ghost")
FamiliarVariant.SOMETHINGWICKED_BIG_WISP = Isaac.GetEntityVariantByName("Fat Wisp")
FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR = Isaac.GetEntityVariantByName("Splendorous Sword")
FamiliarVariant.SOMETHINGWICKED_PRISM_HELPER = Isaac.GetEntityVariantByName("Prism Helper")
FamiliarVariant.SOMETHINGWICKED_LEGION = Isaac.GetEntityVariantByName("Legion Familiar")
FamiliarVariant.SOMETHINGWICKED_LEGION_B = Isaac.GetEntityVariantByName("Legion Familiar B")
FamiliarVariant.SOMETHINGWICKED_ALMOST_ISAAC = Isaac.GetEntityVariantByName("Cherry Isaac Familiar")
FamiliarVariant.SOMETHINGWICKED_LITTLE_ATTRACTOR = Isaac.GetEntityVariantByName("Little Attractor Familiar")
FamiliarVariant.SOMETHINGWICKED_MINOS_HEAD = Isaac.GetEntityVariantByName("Minos (Head)")
FamiliarVariant.SOMETHINGWICKED_MINOS_BODY = Isaac.GetEntityVariantByName("Minos (Body)")
FamiliarVariant.SOMETHINGWICKED_THE_MISTAKE = Isaac.GetEntityVariantByName("Mistake Familiar") -- giga unfinished
FamiliarVariant.SOMETHINGWICKED_MS_GONORRHEA = Isaac.GetEntityVariantByName("Ms. Gonorrhea")

mod.CONST.CursePool = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_BLIND,
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
mod.ENUMS = {}
mod.ENUMS.CustomCallbacks = {
    SWCB_PICKUP_ITEM = 1,
    SWCB_ON_ENEMY_HIT = 2,
    SWCB_ON_BOSS_ROOM_CLEARED = 3,
    SWCB_ON_LASER_FIRED = 4,
    SWCB_ON_FIRE_PURE = 5,
    SWCB_POST_PURCHASE_PICKUP = 6,
    --SWCB_ON_MINIBOSS_ROOM_CLEARED = 7,
    SWCB_NEW_WAVE_SPAWNED = 8,
    SWCB_ON_ITEM_SHOULD_CHARGE = 9,
    SWCB_EVALUATE_TEMP_WISPS = 10
}
mod.ENUMS.MachineVariant = {
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
mod.ENUMS.ItemPools = {
    TERATOMA_BEGGAR = 1
}
mod.ENUMS.CustomTearFlags = {
    FLAG_SHOTGRUB = 1 << 0,
    FLAG_KNAVE_OF_HEARTS = 1 << 1,
    FLAG_DREAD = 1 << 2,
    FLAG_BALROG_HEART = 1 << 3,
    FLAG_BITTER = 1 << 4,
    FLAG_ELECTROSTUN = 1 << 5,
    FLAG_SHADOWSTATUS = 1 << 6,
    FLAG_MAGNIFYING = 1 << 7,
    FLAG_PROVIDENCE = 1 << 8,
    FLAG_BLACK_SALT = 1 << 9,
    FLAG_RAIN_HELLFIRE = 1 << 10,
    FLAG_STICKER_BOOK = 1 << 11,
    FLAG_SCREW_ATTACK = 1 << 12,
    FLAG_CAT_TEASER = 1 << 13,
    FLAG_UNRAVEL = 1 << 14,
    FLAG_DARKNESS = 1 << 15,
    FLAG_COINSHOT = 1 << 16,
}
mod.ENUMS.CustomCardTypes = {
    CARDTYPE_THOTH = 1,
    CARDTYPE_THOTH_REVERSED = 2,
    CARDTYPE_FRENCH_PLAYING = 3,
}