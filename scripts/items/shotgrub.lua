local this = {}
CollectibleType.SOMETHINGWICKED_SHOTGRUB = Isaac.GetItemIdByName("Parasite 2")

function this:FireGrubbyTear(tear)
    if tear.FrameCount > 1 then
        return
    end

    local p = SomethingWicked:UtilGetPlayerFromTear(tear)
    local t_data = tear:GetData()
    if p:HasCollectible(CollectibleType.SOMETHINGWICKED_SHOTGRUB)then
        if not t_data.somethinWicked_isShotgrubTear then
            tear:AddTearFlags(TearFlags.TEAR_WIGGLE)
        else
            local p_rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SHOTGRUB)
            local chance = p.Luck * 0.05
            if p_rng:RandomFloat() < 0.2 + chance then
                tear:AddTearFlags(TearFlags.TEAR_POISON)
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.FireGrubbyTear)

this.EIDEntries = {}
return this