local this = {}
CollectibleType.SOMETHINGWICKED_POSSUMS_EAR = Isaac.GetItemIdByName("Possum's Ear")

function this:UseItem(_, _, player, flags)
    local returnArray = {
        Discharge = false,
        ShowAnim = false,
        Remove = false
    }
    if flags & 1 << 5 ~= 0 then
        return returnArray
    end

    if player:GetMaxHearts() > 0 
    and (player.SubType ~= PlayerType.PLAYER_KEEPER or player.SubType ~= PlayerType.PLAYER_KEEPER_B) then
        local hearts = player:GetHearts()
        player:AddMaxHearts(-2, true)
        player:AddBoneHearts(1)
        player:AddHearts(hearts - player:GetHearts())
        SomethingWicked.sfx:Play(SoundEffect.SOUND_BONE_HEART, 1, 0)
        return true
    else
        return returnArray
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_POSSUMS_EAR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_POSSUMS_EAR] = {
        desc = "!!! Convert: # 1 heart container to 1 bone heart",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_RED_CHEST,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Converts 1 heart container to one bone heart on use"})
    }
}
return this