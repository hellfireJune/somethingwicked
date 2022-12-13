SomethingWicked.CardWeightReplacerCore = {}

function SomethingWicked.CardWeightReplacerCore:DebugGetCardOdds(maxRuns)
    local c = {}
    for i = 1, maxRuns, 1 do
        local card = SomethingWicked.game:GetItemPool():GetCard(Random() + 1, true, true, false)
        if SomethingWicked:UtilTableHasValue(SomethingWicked.addedCards, card) then
            c[card] = (c[card] or 0) + 1
        end
    end
    for key, value in pairs(c) do
        print(key..": "..(value/(maxRuns/100)).."% chance of appearance")
    end
end