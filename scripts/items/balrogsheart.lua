local this = {}
CollectibleType.SOMETHINGWICKED_BALROGS_HEART = Isaac.GetItemIdByName("Balrog's Heart")
TearVariant.SOMETHINGWICKED_BALROG_CLUSTER = Isaac.GetEntityVariantByName("Balrog Tear")

function this:TearUpdate(tear)
    local t_data = tear:GetData()
    if not t_data.somethingWicked_isBalrogsHeart then
        return
    end

    local fCount = tear.FrameCount
    if fCount % 5 == 1 then
        local thefloatingfire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, tear.Position, Vector.Zero, tear):ToEffect()
        thefloatingfire.CollisionDamage = tear.CollisionDamage / 11
        thefloatingfire.SpriteScale = Vector(1/2, 1/2)
        thefloatingfire:SetTimeout(35)
    end
end

function this:FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player and player:HasCollectible(CollectibleType.SOMETHINGWICKED_BALROGS_HEART) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BALROGS_HEART)
        local f = c_rng:RandomFloat()
        if f < 0.15 then
            local t_data = tear:GetData()
            t_data.somethingWicked_isBalrogsHeart = true
            tear:ChangeVariant(TearVariant.SOMETHINGWICKED_BALROG_CLUSTER)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.TearUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BALROGS_HEART] = {
        desc = ""
    }
}
return this