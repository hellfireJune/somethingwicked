local this = {}
CollectibleType.SOMETHINGWICKED_EYE_OF_PROVIDENCE = Isaac.GetItemIdByName("Eye of Providence")

SomethingWicked.TearFlagCore:AddNewFlagData(SomethingWicked.CustomTearFlags.FLAG_PROVIDENCE, {
    EnemyHitEffect = function (_, tear, pos, enemy)
        this:HitEnemy(tear, pos, enemy)
    end
})

function this:HitEnemy(tear, pos, enemy)
    
end

function this:CacheEval(player, flags)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_EYE_OF_PROVIDENCE) then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_SPIRAL
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheEval, CacheFlag.CACHE_TEARFLAG)

this.EIDEntries = {}
return this