local mod = SomethingWicked
mod.save.runData.pickupData = mod.save.runData.pickupData or {}
local game = Game()

local rIdex = nil
local pickupDataToSave = {}
--ran on new floor to clear all pickup data, since pickups cant transfer across floors
function mod:clearPickupData(bool)
    if bool then
        mod.save.runData.pickupData = {}
    end

    rIdex = nil
    pickupDataToSave = {}
end

--call whenever pickupdata is modified
function mod:savePickupData()
    local rdict = {}
    for index, value in ipairs(pickupDataToSave) do
        local idict = rdict[""..value.InitSeed] or {}
        local pickupData = value:GetData().sw_pickupData
        if pickupData then
            idict[pickupData.tracker] = {
                pickupData = pickupData,
                variant = value.Variant,
                subtype = value.SubType,
                positionX = math.floor(value.Position.X),
                positionY = math.floor(value.Position.Y)
            }
        end

        rdict[""..value.InitSeed] = idict
    end
    mod.save.runData.pickupData[rIdex] = rdict
end

function mod:loadPickupData(pickup)
    if rIdex == nil then
        local level = game:GetLevel()
        rIdex = level:GetCurrentRoomIndex() 
    end

    if not mod.save.runData.pickupData[""..rIdex] then
        mod.save.runData.pickupData[""..rIdex] = {}
    end
    local dict = mod.save.runData.pickupData[""..rIdex]
    if not dict[""..pickup.InitSeed] then
        dict[""..pickup.InitSeed] = {}
    end
    local iDict = dict[""..pickup.InitSeed]

    --loop around, if there's an exact match select that one, otherwise pick the first one with the same variant and subtype and move it to the end so that its less likely to be picked again
    local candidate = nil
    local dontMove = false
    for index, value in ipairs(iDict) do
        if value.variant == pickup.Variant and value.subtype == pickup.SubType then
            if not candidate then
                candidate = index
            end

            if value.positionX == math.floor(pickup.Position.X)
            and value.positionY == math.floor(pickup.Position.Y) then
                dontMove = true
                candidate = index
                break
            end
        end
    end
    local data
    if candidate == nil then
        data = {
            pickupData = {
                tracker = #iDict+1,
                randomSignature = math.random(20, 10000)
            },
            variant = pickup.Variant,
            subtype = pickup.SubType,
            positionX = math.floor(pickup.Position.X),
            positionY = math.floor(pickup.Position.Y),
        }
        table.insert(iDict, data)
    else
        data = iDict[candidate]
        if not dontMove then
            table.remove(iDict, candidate)
            table.insert(iDict, data)
            local newData = {
                pickupData = data.pickupData,
                variant = pickup.Variant,
                subtype = pickup.SubType,
                positionX = math.floor(pickup.Position.X),
                positionY = math.floor(pickup.Position.Y)
                
            }
            newData.pickupData.tracker = #iDict+1
            table.insert(iDict, newData)
            data = newData
        end
    end

    return data.pickupData
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.EARLY, function (_, pickup)

    local level = game:GetLevel()
    local n_rIdex = level:GetCurrentRoomIndex() 
    if n_rIdex ~= rIdex then
        mod:clearPickupData(false)
    end 
    table.insert(pickupDataToSave, pickup)
    for index, value in ipairs(pickupDataToSave) do
        local p_data = value:GetData()
        p_data.sw_pickupData = mod:loadPickupData(value)
    end
    local p_data = pickup:GetData()
    print(p_data.sw_pickupData.randomSignature)
    mod:savePickupData()
end)