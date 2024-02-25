local this = {}

function this:CardUse(_, player)
    --local tempEffects = player:GetEffects()
    --tempEffects:AddCollectibleEffect(mod.ITEMS.TOYBOX, true, 1)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.CardUse, mod.CARDS.STONE_OF_THE_PIT)
--[[this.EIDEntries = { 
    [mod.CARDS.STONE_OF_THE_PIT] = {
        desc = "Smelts one random trinket onto you."
    }
--}
--return this--]]