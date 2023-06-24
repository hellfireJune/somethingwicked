local this = {}
this.wispsCap = 5

function this:OnEnemyKill(entity)
    if entity == nil then
        return
    end
    
    if entity:IsEnemy() then
        for _, player in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_NIGHTSHADE)) do--[[and entity:GetDropRNG():RandomFloat() <= 0.33]] 
            
                local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_NIGHTSHADE)
                if #wisps <= this.wispsCap then
                    local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_NIGHTSHADE, player.Position, Vector.Zero, player)
                    wisp.Parent = player
                end
        end
    end
end

function this:RemoveWisps()
    local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_NIGHTSHADE)
    if wisps ~= nil and #wisps > 0 then
        for _, wisp in ipairs(wisps) do
            wisp:Remove()
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnEnemyKill)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.RemoveWisps)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_NIGHTSHADE] = {
        desc = "Spawns wisps with homing tears upon killing an enemy#These wisps are removed upon entering a new room",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns wisps with homing tears upon killing an enemy","These wisps are removed upon entering a new room, and there is an upper limit of 6 wisps at a time"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME,
        }
    }
}
return this