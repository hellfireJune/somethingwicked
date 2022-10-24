local this = {}
CollectibleType.SOMETHINGWICKED_PRISMATIC_MUSHROOM = Isaac.GetItemIdByName("Prismatic Mushroom")

this.PossibleEffects = {
    function (ent)
        SomethingWicked:UtilAddCurse(ent, 15)
    end,
    function (ent)
        SomethingWicked:UtilAddDread(ent, 3)
    end,
    function (ent, player)
        ent:AddConfusion(EntityRef(player), 300, false)

        local e_data = ent:GetData()
        e_data.somethingWicked_electroStun = true
        e_data.somethingWicked_electroStunParent = player
    end,
    function (ent, player)
        SomethingWicked:UtilAddBitter(ent, 5, player)
    end
}

function this:UseItem(_, rng, player, flags)
    local allEnemies = Isaac.FindInRadius(Vector.Zero, 80000, 8)
    for _, ent in pairs(allEnemies) do
        local effect = SomethingWicked:GetRandomElement(this.PossibleEffects, rng)
        effect(ent, player)
    end

    SomethingWicked.sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0)
    return true
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem)
this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PRISMATIC_MUSHROOM] = {
        desc = ""
    }
}
return this