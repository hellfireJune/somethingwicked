local this = {}
this.AmountToSpawn = 2

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, mod.CARDS.THOTH_THE_MAGUS)


this.EIDEntries = {
    [mod.CARDS.THOTH_THE_MAGUS] = {
        desc = "Spawns ".. this.AmountToSpawn .. " batteries."
    }
}
return this