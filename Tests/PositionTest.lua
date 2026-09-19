local Helpers = dofile("Tests/TestHelpers.lua")
local Position = dofile("Position.lua")

local function testUsesDefaultPositionWithoutSavedData()
    -- Given
    local savedPosition = nil

    -- When
    local position = Position.restore(savedPosition)

    -- Then
    Helpers.assertSame(position, {
        point = "TOP",
        relativePoint = "TOP",
        x = 0,
        y = -200,
    }, "default position")
end

local function testRestoresValidSavedPosition()
    -- Given
    local savedPosition = {
        point = "CENTER",
        relativePoint = "CENTER",
        x = 120,
        y = -45,
    }

    -- When
    local position = Position.restore(savedPosition)

    -- Then
    Helpers.assertSame(position, savedPosition, "restored position")
end

local function testMalformedSavedPositionFallsBackToDefault()
    -- Given
    local savedPosition = {
        point = "INVALID",
        relativePoint = "CENTER",
        x = "far",
        y = -45,
    }

    -- When
    local position = Position.restore(savedPosition)

    -- Then
    Helpers.assertSame(position, {
        point = "TOP",
        relativePoint = "TOP",
        x = 0,
        y = -200,
    }, "fallback position")
end

local function testCreatesSavedPositionFromDragCoordinates()
    -- Given
    local point = "BOTTOMLEFT"
    local relativePoint = "BOTTOMLEFT"
    local x = 321.5
    local y = 222.25

    -- When
    local position = Position.update(point, relativePoint, x, y)

    -- Then
    Helpers.assertSame(position, {
        point = "BOTTOMLEFT",
        relativePoint = "BOTTOMLEFT",
        x = 321.5,
        y = 222.25,
    }, "updated position")
end

return {
    testUsesDefaultPositionWithoutSavedData,
    testRestoresValidSavedPosition,
    testMalformedSavedPositionFallsBackToDefault,
    testCreatesSavedPositionFromDragCoordinates,
}
