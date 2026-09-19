local RollView = {}

local BIND_TEXT = {
    [1] = "BoP",
    [2] = "BoE",
    [3] = "BoU",
    [4] = "Quest",
}

function RollView.build(item)
    local isBindOnPickup = item.bindType == 1

    return {
        bindColor = isBindOnPickup and { 1, 0.3, 0.1 }
            or { 0.3, 1, 0.3 },
        bindText = BIND_TEXT[item.bindType] or "",
        buttons = {
            need = item.canNeed == true,
            greed = item.canGreed == true and item.canTransmog ~= true,
            disenchant = item.canDisenchant == true,
            transmog = item.canTransmog == true,
            pass = true,
        },
        itemLevelText = item.showItemLevel
            and tostring(item.itemLevel or "") or "",
        qualityColor = item.qualityColor or { 1, 1, 1 },
        stackText = (item.count or 1) > 1 and tostring(item.count) or "",
    }
end

BetterLootRollView = RollView

return RollView
