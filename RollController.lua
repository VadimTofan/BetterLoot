local RollState = BetterLootRollState or dofile("RollState.lua")

local RollController = {}
RollController.__index = RollController

function RollController.new(maxVisible, renderer)
    local controller = {
        renderer = renderer,
        state = RollState.new(maxVisible),
    }

    return setmetatable(controller, RollController)
end

function RollController:start(rollID, rollTime)
    local slot = self.state:add(rollID, rollTime)

    if slot then
        self.renderer:show(slot, self.state:getSlot(slot))
    end
end

function RollController:cancel(rollID)
    local slot, promotedRoll = self.state:remove(rollID)

    if not slot then
        return
    end

    self.renderer:hide(slot)

    if promotedRoll then
        self.renderer:show(slot, promotedRoll)
    end
end

function RollController:cancelAll()
    for slot = 1, self.state.maxVisible do
        if self.state:getSlot(slot) then
            self.renderer:hide(slot)
        end
    end

    self.state = RollState.new(self.state.maxVisible)
end

BetterLootRollController = RollController

return RollController
