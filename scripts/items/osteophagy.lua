local this = {}
CollectibleType.SOMETHINGWICKED_OSTEOPHAGY = Isaac.GetItemIdByName("Osteophagy")

function this:UseItem(_, _, player, flags)
    local returnArray = {
        Discharge = false,
        ShowAnim = false
    }
    if flags & 1 << 5 ~= 0 then
        return returnArray
    end

    if player:GetBoneHearts() > 0 
    and (player.SubType ~= PlayerType.PLAYER_KEEPER or player.SubType ~= PlayerType.PLAYER_KEEPER_B) then
        local hearts = player:GetHearts()
        player:AddBoneHearts(-1)
        player:AddMaxHearts(2, true)
        player:AddHearts(hearts - player:GetHearts())
        SomethingWicked.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
        return true
    else
        return returnArray
    end
end


--TY to the Rep+ team for the GetSprite method of getting it to only run once 
function this:PickupInit(pickup)
    if (pickup:GetSprite():IsPlaying("Appear") or pickup:GetSprite():IsPlaying("AppearFast")) 
    and pickup:GetSprite():GetFrame() == 0 then
        if SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_OSTEOPHAGY) then
            local procChance = pickup:GetDropRNG():RandomFloat()
            if (pickup.SubType == HeartSubType.HEART_FULL and procChance <= 0.08)
            or (pickup.SubType == HeartSubType.HEART_HALF and procChance <= 0.03) then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, true)
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_OSTEOPHAGY)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.PickupInit, PickupVariant.PICKUP_HEART)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_OSTEOPHAGY] = {
        desc = "!!! Convert: # 1 Bone heart to 1 heart container #↑ Red hearts have a 8% chance (3% for half hearts) to be replaced by bone hearts",
        Hide = true,--[[,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Converts one bone heart to heart containers on use", "Red hearts have an 8% chance (3% chance for half hearts) to be replacedd by bone hearts"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SECRET
        }]]
    }
}
return this