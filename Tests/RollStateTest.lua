local Helpers = dofile("Tests/TestHelpers.lua")
local RollState = dofile("RollState.lua")

local function testAllocatesTheFirstFreeSlot()
    -- Given
    local state = RollState.new(5)

    -- When
    local slot = state:add(101, 60000)

    -- Then
    Helpers.assertEqual(slot, 1, "first roll slot")
    Helpers.assertEqual(state:getSlot(1).rollID, 101, "first roll ID")
end

local function testQueuesRollsBeyondTheVisibleLimit()
    -- Given
    local state = RollState.new(2)
    state:add(101, 60000)
    state:add(102, 60000)

    -- When
    local slot = state:add(103, 60000)

    -- Then
    Helpers.assertEqual(slot, nil, "queued roll slot")
    Helpers.assertEqual(state:getQueueSize(), 1, "queue size")
end

local function testCancellationPromotesTheOldestQueuedRoll()
    -- Given
    local state = RollState.new(2)
    state:add(101, 60000)
    state:add(102, 60000)
    state:add(103, 50000)
    state:add(104, 40000)

    -- When
    local clearedSlot, promotedRoll = state:remove(101)

    -- Then
    Helpers.assertEqual(clearedSlot, 1, "cleared slot")
    Helpers.assertEqual(promotedRoll.rollID, 103, "promoted roll ID")
    Helpers.assertEqual(state:getSlot(1).rollID, 103, "replacement roll ID")
    Helpers.assertEqual(state:getQueueSize(), 1, "remaining queue size")
end

local function testQueuedRollCanBeCancelledBeforePromotion()
    -- Given
    local state = RollState.new(1)
    state:add(101, 60000)
    state:add(102, 50000)

    -- When
    local clearedSlot, promotedRoll = state:remove(102)

    -- Then
    Helpers.assertEqual(clearedSlot, nil, "queued cancellation slot")
    Helpers.assertEqual(promotedRoll, nil, "queued promotion")
    Helpers.assertEqual(state:getQueueSize(), 0, "queue after cancellation")
end

return {
    testAllocatesTheFirstFreeSlot,
    testQueuesRollsBeyondTheVisibleLimit,
    testCancellationPromotesTheOldestQueuedRoll,
    testQueuedRollCanBeCancelledBeforePromotion,
}
