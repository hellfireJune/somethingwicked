if EID then
    local this = {}

    local icon = Sprite()
    icon:Load("gfx/ui/eid_icon.anm2", true)

    EID:addIcon("SomethingWicked", "Idle", 0, 32, 32, 6, 4, icon)

    EID:setModIndicatorName("Something Wicked")
    EID:setModIndicatorIcon("SomethingWicked")

    --abyss
    EID.descriptions["en_us"].abyssSynergies[CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM] = "Purple cursing locust"

    --bov
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_CURSED_MUSHROOM] = "Curses nearby enemies on destruction"
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_TRINKET_SMASHER] = "Spawns two wisps on destroyed trinket, spawns bonus wisps if the trinket was worth more (eg. Golden Trinkets)"
    EID.descriptions["en_us"].bookOfVirtuesWisps[CollectibleType.SOMETHINGWICKED_FETUS_IN_FETU] = "Do nothing by themselves, will destroy self and spawn a blue spider if the item is used again"
end