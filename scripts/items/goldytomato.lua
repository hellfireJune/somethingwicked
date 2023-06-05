local this = {}
TrinketType.SOMETHINGWICKED_GODLY_TOMATO = Isaac.GetTrinketIdByName("Godly Tomato")

function this:OnFireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if tear.FrameCount == 0 
    and player
    and player:HasTrinket(TrinketType.SOMETHINGWICKED_GODLY_TOMATO) then
        local myRNG = RNG()
        myRNG:SetSeed(Random() + 1, 1)
        if myRNG:RandomInt(8 - player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_GODLY_TOMATO) + 1) == 1 then 
            tear:AddTearFlags(TearFlags.TEAR_GLOW)
            tear:Update()
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.OnFireTear)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_GODLY_TOMATO] = {
        isTrinket = true,
        desc = "↑ Chance to give a fired tear a {{Collectible331}} Godhead aura",
        metadataFunction = function (item)
            EID:addGoldenTrinketMetadata(item, {"↑ +2% chance", "↑ +4% chance"} )
        end,
    }
}
return this