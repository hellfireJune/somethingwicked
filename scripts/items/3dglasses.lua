local this = {}
CollectibleType.SOMETHINGWICKED_3D_GLASSES = Isaac.GetItemIdByName("3D Glasses")
this.procChance = 0.25
this.damageMult = 0.5
this.angle = 10
this.Colors = {
    [-this.angle] = Color(0.5, 0, 0, 0.75),
    [this.angle] = Color(0, 0, 0.5, 0.75)
}

function this:SplitTearsSometimes(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player
    and player:HasCollectible(CollectibleType.SOMETHINGWICKED_3D_GLASSES)
    and tear.FrameCount == 1 then
        local t_data = tear:GetData()
        if t_data.somethingwicked_3DglassesChecked == nil then
            local rng = tear:GetDropRNG()
            local proc = rng:RandomFloat()
            if proc < this.procChance then
                for i = -this.angle, this.angle, this.angle * 2 do
                    local newAngle = tear.Velocity:Rotated(i)
                    local new = player:FireTear(tear.Position - tear.Velocity, newAngle, false, false, false, nil, this.damageMult)
                    new.Color = this.Colors[i]

                    local n_data = new:GetData()
                    n_data.somethingwicked_3DglassesChecked = true
                end
            end
            t_data.somethingwicked_3DglassesChecked = true
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.SplitTearsSometimes)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_3D_GLASSES] = {
        desc = "↑ 25% chance to shoot out 2 more tears that deal "..this.damageMult.." of your damage upon fire",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"25% chance to shoot out 2 more tears that deal "..this.damageMult.." of your damage upon tear fire"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        }
    }
}
return this
