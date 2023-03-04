local this = {}
CollectibleType.SOMETHINGWICKED_BALROGS_HEART = Isaac.GetItemIdByName("Balrog's Heart")
TearVariant.SOMETHINGWICKED_BALROG_CLUSTER = Isaac.GetEntityVariantByName("Balrog Tear")

SomethingWicked.TFCore:AddNewFlagData(SomethingWicked.CustomTearFlags.FLAG_BALROG_HEART, {
    TearVariant = TearVariant.SOMETHINGWICKED_BALROG_CLUSTER,
    OverrideTearUpdate = function (_, tear)
        this:TearUpdate(tear)
    end ,
    ApplyLogic = function (_, player, tear)
        return this:FireTear(player, tear)
    end,
})

function this:TearUpdate(tear)
    local fCount = tear.FrameCount
    if fCount % 5 == 1 then
        local thefloatingfire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, tear.Position, Vector.Zero, tear):ToEffect()
        thefloatingfire.CollisionDamage = tear.CollisionDamage / 11
        thefloatingfire.SpriteScale = Vector(1/2, 1/2)
        thefloatingfire:SetTimeout(35)
    end
end

function this:FireTear(player, tear)
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_BALROGS_HEART) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BALROGS_HEART)
        local f = c_rng:RandomFloat()
        if f < 0.15 then
            return true
        end
    end
end

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BALROGS_HEART] = {
        desc = "",
        Hide = true,
    }
}
return this