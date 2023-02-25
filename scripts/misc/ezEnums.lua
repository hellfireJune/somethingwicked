local mod = SomethingWicked
mod.CustomCallbacks = {
    SWCB_PICKUP_ITEM = 1,
    SWCB_ON_ENEMY_HIT = 2,
    SWCB_ON_BOSS_ROOM_CLEARED = 3,
    SWCB_ON_LASER_FIRED = 4,
    SWCB_ON_FIRE_PURE = 5,
    SWCB_KNIFE_EFFECT_EVAL = 6,
    SWCB_ON_MINIBOSS_ROOM_CLEARED = 7,
    SWCB_NEW_WAVE_SPAWNED = 8,
    SWCB_ON_ITEM_SHOULD_CHARGE = 9,
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
    MACHINE_BEGGAR_ROTTEN = 18
}
mod.ItemPoolEnum = {
    TERATOMA_BEGGAR = 1
}
mod.CustomTearFlags = {
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
}
mod.CustomCardTypes = {
    CARDTYPE_THOTH = 1,
    CARDTYPE_THOTH_REVERSED = 2,
    CARDTYPE_FRENCH_PLAYING = 3,
}