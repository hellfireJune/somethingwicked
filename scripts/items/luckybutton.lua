local this = {}
TrinketType.SOMETHINGWICKED_LUCKY_BUTTON = Isaac.GetTrinketIdByName("Lucky Button")
this.ValidSlots = {
    [SomethingWicked.MachineVariant.MACHINE_SLOT] = function (position)
        
    end,
    [SomethingWicked.MachineVariant.MACHINE_FORTUNE] = function (position)
        
    end,
}

function this:PostUpdate()
    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_LUCKY_BUTTON) then
        local machines = Isaac.FindByType(EntityType.ENTITY_SLOT)
        for key, slot in pairs(machines) do
            if this.ValidSlots[slot.Variant] then
                local e_data = slot:GetData()
                local sprite = slot:GetSprite()
                if sprite:IsPlaying("Prize") and sprite:GetFrame() == 4 then
                    if not e_data.somethingWicked_luckyButtonCheck then
                    
                        --stolen from folio
                        for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
                            if pickup and pickup.FrameCount <= 0 then
                                local func = this.ValidSlots[slot.Variant]
                                func(slot.Position)

                                e_data.somethingWicked_luckyButtonCheck = true
                                break
                            end
                        end
                    end
                else
                    e_data.somethingWicked_luckyButtonCheck = false
                end
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.PostUpdate)

this.EIDEntries = {}
return this