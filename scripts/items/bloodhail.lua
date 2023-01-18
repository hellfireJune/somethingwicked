local this = {}
CollectibleType.SOMETHINGWICKED_BLOOD_HAIL = Isaac.GetItemIdByName("Blood Hail")

SomethingWicked.TearFlagCore:AddNewFlagData(SomethingWicked.CustomTearFlags.FLAG_RAIN_HELLFIRE, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_BLOOD_HAIL)
        and ((tear.Parent and tear.Parent.Type == 1) or tear.Type ~= EntityType.ENTITY_TEAR) then
            return true
        end
    end,
    EnemyHitEffect = function (_, tear, pos, enemy)
        this:HitEnemy(tear, enemy, pos)
    end
})

function this:HitEnemy(tear, enemy, pos)
    
end

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BLOOD_HAIL] = {
        desc = "rain ):"
    }
}
return this