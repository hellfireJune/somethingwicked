local mod = SomethingWicked
local game = Game()

function mod:WickedSoulOnPickup(player)
    local level = game:GetLevel()
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_WICKED_SOUL)
    local possibleCurses = {}
    for index, value in ipairs(mod.CONST.CursePool) do
        if level:GetCurses() & value == 0 then
            table.insert(possibleCurses, value)
        end
    end
    if #possibleCurses >= 1 then
        local curse = possibleCurses[rng:RandomInt(#possibleCurses) + 1]
        level:AddCurse(curse, false)
    end

    --when vfx, do here.
end

mod:AddCustomCBack(mod.ENUMS.CustomCallbacks.SWCB_PICKUP_ITEM, mod.WickedSoulOnPickup, CollectibleType.SOMETHINGWICKED_WICKED_SOUL)