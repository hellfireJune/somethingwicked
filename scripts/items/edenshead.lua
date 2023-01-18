local this = {}
CollectibleType.SOMETHINGWICKED_EDENS_HEAD = Isaac.GetItemIdByName("Eden's Head")
this.throwables = {
    CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD,
    CollectibleType.COLLECTIBLE_CANDLE,
    CollectibleType.COLLECTIBLE_RED_CANDLE,
    CollectibleType.COLLECTIBLE_BOOMERANG,
    CollectibleType.COLLECTIBLE_GLASS_CANNON,
    CollectibleType.COLLECTIBLE_DOCTORS_REMOTE
}

function this:UseHead(_, rng, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        return
    end

    local throwable = SomethingWicked:GetRandomElement(this.throwables, rng)
    player:UseActiveItem(throwable)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseHead, CollectibleType.SOMETHINGWICKED_EDENS_HEAD)


this.moddedThrowables = {
    "Cursed Candle",
    "Balrog's Head",
    --"Ice Wand",
    "Boline",
    --"Facestabber",

    --fOLIO
    "D2",
    "Sanguine Hook",
    "Grappling Hook",
}

this.hasInitModdedThrowables = false
function this:RunStart()
    if not this.hasInitModdedThrowables then
        this.hasInitModdedThrowables = true
        this:InitModdedThrowables()
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.RunStart)

function this:InitModdedThrowables()
    for _, cardHud in ipairs(this.moddedThrowables) do
        local card = Isaac.GetItemIdByName(cardHud)
        if card ~= -1 then
            table.insert(this.throwables, card)
        end
    end
end
if SomethingWicked.game:GetFrameCount() > 0 then
    this:InitModdedThrowables()
end

this.EIDEntries = {}
return this