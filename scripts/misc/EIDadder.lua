if EID then

    local icon = Sprite()
    icon:Load("gfx/ui/eid_icon.anm2", true)

    EID:addIcon("SomethingWicked", "Idle", 0, 32, 32, 6, 4, icon)

    EID:setModIndicatorName("Something Wicked")
    EID:setModIndicatorIcon("SomethingWicked")
end