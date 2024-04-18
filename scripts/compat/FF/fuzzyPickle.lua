local mod = SomethingWicked
local references = {
    Actives = {
        {ID = mod.ITEMS.BALROGS_HEAD, Reference = "King Gizzard and the Lizard Wizard"},
        {ID = mod.ITEMS.CHAOS_HEART, Reference = "Ring of Pain"},
        {ID = mod.ITEMS.CURSED_MUSHROOM, Reference = "Super Mario Bros: The Lost Levels"},
        {ID = mod.ITEMS.ASSIST_TROPHY, Reference = "Super Smash Bros"},
        {ID = mod.ITEMS.ITEM_BOX, Reference = "Mario Kart"},
        {ID = mod.ITEMS.BOOK_OF_INSANITY, Reference = "The King in Yellow"},
        {ID = mod.ITEMS.BOLINE, Reference = "King Gizzard and the Lizard Wizard", Partial=true},

        --currently unused
        {ID = mod.ITEMS.ICE_WAND, Reference = "Terraria"},
        {ID = mod.ITEMS.LAST_PRISM, Reference = "Terraria"},
        {ID = mod.ITEMS.DOUBLING_CHERRY, Reference = "Super Mario 3D World"},
        {ID = mod.ITEMS.FLYING_GUILLOTINE, Reference = "Thee Oh Sees, Team Fortress 2"}
    },
    Passives = {
        {ID = mod.ITEMS.AVENGER_EMBLEM, Reference = "Terraria"},
        {ID = mod.ITEMS.CAT_FOOD, Reference = "King Crimson"},
        {ID = mod.ITEMS.RED_NIGHTMARE, Reference = "King Crimson"},
        {ID = mod.ITEMS.ROGUE_PLANET_ITEM, Reference = "Thee Oh Sees"},
        {ID = mod.ITEMS.SUPERIORITY, Reference = "the assassination of John Lennon"},
        {ID = mod.ITEMS.HELLFIRE, Reference = "black midi"},
        {ID = mod.ITEMS.LOVERS_MASK, Reference = "The Legend of Zelda"},
        {ID = mod.ITEMS.STAR_SPAWN, Reference = "Dungeons and Dragons"},
        {ID = mod.ITEMS.LANKY_MUSHROOM, Reference = "Super Mario Maker"},
        {ID = mod.ITEMS.JUSTICE_AND_SPLENDOR, Reference = "ULTRAKILL"},
        {ID = mod.ITEMS.STRANGE_APPLE, Reference = "Snake"},
        {ID = mod.ITEMS.DEVILSKNIFE_ITEM, Reference = "Deltarune"},
        {ID = mod.ITEMS.GLITCHCITY, Reference = "Pokemon"},
        {ID = mod.ITEMS.BOOSTER_BOX, Reference = "Pokemon", Partial=true,},
        {ID = mod.ITEMS.TECH_MODULO, Reference = "Some Bunny's The Modular"},
        --{ID = mod.ITEMS.REGEN_RING, Reference = "Terraria"},
        {ID = mod.ITEMS.AIR_FRESHENER, Reference = "Terraria", Partial=true},
        {ID = mod.ITEMS.WICKED_RING, Reference = "Risk of Rain"},
        {ID = mod.ITEMS.GOLDEN_WATCH, Reference = "Enter the Gungeon", Partial=true},
        {ID = mod.ITEMS.YELLOW_SIGIL, Reference = "The King in Yellow"},
        {ID = mod.ITEMS.STAR_TREAT, Reference = "Bee Swarm Simulator"},
        {ID = mod.ITEMS.DARK_SHARD, Reference = "Terraria" },
        {ID = mod.ITEMS.LIGHT_SHARD, Reference = "Terraria"},

        --currently unused items
        {ID = mod.ITEMS.BOLTS_OF_LIGHT, Reference = "Bloons TD 6"},
        {ID = mod.ITEMS.GANYMEDE, Reference = "Planetside of Gunymede" },
        {ID = mod.ITEMS.SCREW_ATTACK, Reference = "Metroid" },
        {ID = mod.ITEMS.ACHERON, Reference = "Geometry Dash" },
        {ID = mod.ITEMS.BLOOD_HAIL, Reference = "black midi", Partial=true },
        {ID = mod.ITEMS.CALL_OF_THE_VOID, Reference = "MACHINEGIRL", Partial=true },
        {ID = mod.ITEMS.CURSE_MASK, Reference = "Ring of Pain" },
        {ID = mod.ITEMS.MS_GONORRHEA, Reference = "black midi"},
    },
    Trinkets = {
        {ID = mod.TRINKETS.CATS_EYE, Reference = "The Cat Empire"},
        {ID = mod.TRINKETS.GODLY_TOMATO, Reference = "Psychedellic Porn Crumpets"},
        {ID = mod.TRINKETS.OWL_FEATHER, Reference = "Chainsaw Man"},
        {ID = mod.TRINKETS.TREASURERS_KEY, Reference = "Super Mario Maker"},
        {ID = mod.TRINKETS.CURSED_KEY, Reference = "Super Mario Maker"},
        {ID = mod.TRINKETS.NIGHTMARE_FUEL, Reference = "Don't Starve"},

        --currently unused
        {ID = mod.TRINKETS.ZZZZZZ_MAGNET, Reference = "Spelunky", Partial=true},
        {ID = mod.TRINKETS.MR_SKITS, Reference = "Don't Starve"},
    },
}
return references