print("loaded smokeshop stuff!")
local this = {}
this.minvariant = 13000 this.maxvariant = 13001

this.roomData = {}
function this:GameStart()
    SomethingWicked.RedKeyRoomHelpers:InitializeRoomData("supersecret", this.minvariant, this.maxvariant, this.roomData) 
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.GameStart)

return this