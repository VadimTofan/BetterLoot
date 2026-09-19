local RollState = {}
RollState.__index = RollState

function RollState.new(maxVisible)
    local state = {
        maxVisible = maxVisible,
        queue = {},
        slots = {},
    }

    return setmetatable(state, RollState)
end

function RollState:getSlot(index)
    return self.slots[index]
end

function RollState:getQueueSize()
    return #self.queue
end

function RollState:add(rollID, rollTime)
    local roll = {
        rollID = rollID,
        rollTime = rollTime,
    }

    for index = 1, self.maxVisible do
        if not self.slots[index] then
            self.slots[index] = roll

            return index
        end
    end

    table.insert(self.queue, roll)

    return nil
end

function RollState:remove(rollID)
    for index = 1, self.maxVisible do
        local roll = self.slots[index]

        if roll and roll.rollID == rollID then
            local promotedRoll = table.remove(self.queue, 1)
            self.slots[index] = promotedRoll

            return index, promotedRoll
        end
    end

    for index, roll in ipairs(self.queue) do
        if roll.rollID == rollID then
            table.remove(self.queue, index)

            return nil, nil
        end
    end

    return nil, nil
end

BetterLootRollState = RollState

return RollState
