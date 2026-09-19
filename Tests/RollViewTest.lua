local Helpers = dofile("Tests/TestHelpers.lua")
local RollView = dofile("RollView.lua")

local function testMapsAvailableRollChoices()
    -- Given
    local item = {
        canNeed = true,
        canGreed = true,
        canDisenchant = false,
        canTransmog = true,
    }

    -- When
    local view = RollView.build(item)

    -- Then
    Helpers.assertSame(view.buttons, {
        need = true,
        greed = false,
        disenchant = false,
        transmog = true,
        pass = true,
    }, "roll buttons")
end

local function testMapsItemPresentation()
    -- Given
    local item = {
        count = 3,
        itemLevel = 639,
        bindType = 1,
        quality = 4,
        qualityColor = { 0.64, 0.21, 0.93 },
        showItemLevel = true,
    }

    -- When
    local view = RollView.build(item)

    -- Then
    Helpers.assertEqual(view.stackText, "3", "stack text")
    Helpers.assertEqual(view.itemLevelText, "639", "item level text")
    Helpers.assertEqual(view.bindText, "BoP", "bind text")
    Helpers.assertEqual(view.bindColor[1], 1, "bind red")
    Helpers.assertEqual(view.qualityColor[3], 0.93, "quality blue")
end

return {
    testMapsAvailableRollChoices,
    testMapsItemPresentation,
}
