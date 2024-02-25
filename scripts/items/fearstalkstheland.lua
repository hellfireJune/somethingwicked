local this = {}
this.DreadStatusColor = Color(1, 1, 1, 1, 0.4)

function this:UseItem(_, _, player)
    return true
end

function this:OnDread(ent)
    if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) ~= true then
        SomethingWicked:UtilAddDread(ent, 3)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, mod.ITEMS.FEAR_STALKS_THE_LAND)

this.EIDEntries = {
    [mod.ITEMS.FEAR_STALKS_THE_LAND] = {
        desc = "Radiohead",
        Hide = true,
    }
}
return this