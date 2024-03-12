local sfx = SFXManager()
local game = Game()

local function UseItem(_, _, player)
    player:AddBlackHearts(2)
    --perpetually spinning moon thing vfx would be cool
    return true
end