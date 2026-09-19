local Helpers = dofile("Tests/TestHelpers.lua")
local RollController = dofile("RollController.lua")

local function createRenderer()
    return {
        hidden = {},
        shown = {},
        hide = function(self, slot)
            table.insert(self.hidden, slot)
        end,
        show = function(self, slot, roll)
            table.insert(self.shown, { slot = slot, roll = roll })
        end,
    }
end

local function testStartShowsAnAllocatedRoll()
    -- Given
    local renderer = createRenderer()
    local controller = RollController.new(2, renderer)

    -- When
    controller:start(101, 60000)

    -- Then
    Helpers.assertEqual(renderer.shown[1].slot, 1, "shown slot")
    Helpers.assertEqual(renderer.shown[1].roll.rollID, 101, "shown roll")
end

local function testCancelHidesAndReplacesAQueuedRoll()
    -- Given
    local renderer = createRenderer()
    local controller = RollController.new(1, renderer)
    controller:start(101, 60000)
    controller:start(102, 50000)

    -- When
    controller:cancel(101)

    -- Then
    Helpers.assertEqual(renderer.hidden[1], 1, "hidden slot")
    Helpers.assertEqual(renderer.shown[2].slot, 1, "replacement slot")
    Helpers.assertEqual(renderer.shown[2].roll.rollID, 102, "replacement roll")
end

local function testCancelAllHidesEveryVisibleRoll()
    -- Given
    local renderer = createRenderer()
    local controller = RollController.new(2, renderer)
    controller:start(101, 60000)
    controller:start(102, 50000)

    -- When
    controller:cancelAll()

    -- Then
    Helpers.assertEqual(#renderer.hidden, 2, "hidden roll count")
    Helpers.assertEqual(controller.state:getQueueSize(), 0, "cleared queue")
end

return {
    testStartShowsAnAllocatedRoll,
    testCancelHidesAndReplacesAQueuedRoll,
    testCancelAllHidesEveryVisibleRoll,
}
