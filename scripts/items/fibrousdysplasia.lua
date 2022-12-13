local this = {}
CollectibleType.SOMETHINGWICKED_FIBROUS_DYSPLASIA = Isaac.GetItemIdByName("Fibrous Dysplasia")

function this:PlayerUpdate(player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_FIBROUS_DYSPLASIA) then
        local p_data = player:GetData()
        local maxHearts = player:GetMaxHearts()
        p_data.somethingWicked_lastMaxHearts = p_data.somethingWicked_lastMaxHearts or maxHearts
        if p_data.somethingWicked_didBoneCheckLastFrame then
            p_data.somethingWicked_didBoneCheckLastFrame = false
            p_data.somethingWicked_lastMaxHearts = maxHearts
            return
        elseif p_data.somethingWicked_didBoneCheckLastFrame == nil then p_data.somethingWicked_didBoneCheckLastFrame = true end

        if p_data.somethingWicked_lastMaxHearts ~= maxHearts then
            local rHearts = player:GetHearts()
            if rHearts >= maxHearts
            and maxHearts > 0 then
                local heartDiff = maxHearts - p_data.somethingWicked_lastMaxHearts
                player:AddBoneHearts(heartDiff / 2)
                player:AddMaxHearts(-heartDiff)

                player:AddHearts(rHearts - player:GetHearts())
            end
            p_data.somethingWicked_lastMaxHearts = maxHearts
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, function (player)
    player:AddBoneHearts(1)
end, CollectibleType.SOMETHINGWICKED_FIBROUS_DYSPLASIA)

this.EIDEntries = {}
return this