local ADDON_NAME = ...

local MAX_VISIBLE_ROLLS = 5
local BAR_WIDTH = 325
local BAR_HEIGHT = 30
local BAR_SPACING = 4
local BUTTON_SIZE = 20
local TIMER_UPDATE_INTERVAL = 0.1

local ROLL_BUTTONS = {
    {
        key = "pass",
        rollType = 0,
        texture = [[Interface\Buttons\UI-GroupLoot-Pass-Up]],
        tooltip = PASS,
    },
    {
        key = "disenchant",
        rollType = 3,
        texture = [[Interface\Buttons\UI-GroupLoot-DE-Up]],
        tooltip = ROLL_DISENCHANT,
    },
    {
        key = "transmog",
        rollType = 4,
        texture = [[Interface\MINIMAP\TRACKING\Transmogrifier]],
        tooltip = TRANSMOGRIFY,
    },
    {
        key = "greed",
        rollType = 2,
        texture = [[Interface\Buttons\UI-GroupLoot-Coin-Up]],
        tooltip = GREED,
    },
    {
        key = "need",
        rollType = 1,
        texture = [[Interface\Buttons\UI-GroupLoot-Dice-Up]],
        tooltip = NEED,
    },
}

local function setTooltip(button)
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:AddLine(button.tooltip)

    if not button:IsEnabled() then
        GameTooltip:AddLine(CANT_ROLL or "Can't Roll", 1, 0.2, 0.2)
    end

    GameTooltip:Show()
end

local function setItemTooltip(button, event)
    if not button.rollID or button.rollID < 0 then
        return
    end

    if event == "MODIFIER_STATE_CHANGED" and not button:IsMouseOver() then
        return
    end

    GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
    GameTooltip:SetLootRollItem(button.rollID)

    if IsShiftKeyDown() then
        GameTooltip_ShowCompareItem()
    end
end

local function clickItem(button)
    if IsModifiedClick() and button.itemLink then
        HandleModifiedItemClick(button.itemLink)
    end
end

local function clickRoll(button)
    if button.owner.rollID and not button.owner.isPreview then
        RollOnLoot(button.owner.rollID, button.rollType)
    end
end

local function createRollButton(owner, definition)
    local button = CreateFrame("Button", nil, owner)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetNormalTexture(definition.texture)
    button:SetPushedTexture(definition.texture)
    button:SetDisabledTexture(definition.texture)
    button:SetHighlightTexture(definition.texture)
    button:SetMotionScriptsWhileDisabled(true)
    button:SetHitRectInsets(3, 3, 3, 3)
    button:SetScript("OnClick", clickRoll)
    button:SetScript("OnEnter", setTooltip)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button.owner = owner
    button.rollType = definition.rollType
    button.tooltip = definition.tooltip

    local disabledTexture = button:GetDisabledTexture()
    disabledTexture:SetDesaturated(true)
    disabledTexture:SetAlpha(0.25)

    return button
end


local Renderer = {}
Renderer.__index = Renderer

function Renderer.new(holder, onExpired)
    local renderer = {
        bars = {},
        holder = holder,
        onExpired = onExpired,
    }

    return setmetatable(renderer, Renderer)
end


function Renderer:createBar(slot)
    local bar = CreateFrame("Frame", ADDON_NAME .. "RollFrame" .. slot, self.holder)
    bar:SetSize(BAR_WIDTH, BAR_HEIGHT)
    bar:SetPoint("TOP", self.holder, "TOP", 0, -(slot - 1)
        * (BAR_HEIGHT + BAR_SPACING))
    bar:Hide()

    local background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.04, 0.04, 0.04, 0.9)

    local timer = CreateFrame("StatusBar", nil, bar)
    timer:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
    timer:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    timer:SetHeight(BAR_HEIGHT / 3)
    timer:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    bar.timer = timer

    local timerBackground = timer:CreateTexture(nil, "BACKGROUND")
    timerBackground:SetAllPoints()
    timerBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    local itemButton = CreateFrame("Button", nil, bar)
    itemButton:SetPoint("RIGHT", bar, "LEFT", -2, 0)
    itemButton:SetSize(BAR_HEIGHT, BAR_HEIGHT)
    itemButton:SetScript("OnClick", clickItem)
    itemButton:SetScript("OnEnter", setItemTooltip)
    itemButton:SetScript("OnLeave", GameTooltip_Hide)
    itemButton:SetScript("OnEvent", setItemTooltip)
    itemButton:RegisterEvent("MODIFIER_STATE_CHANGED")
    bar.itemButton = itemButton

    local itemBackground = itemButton:CreateTexture(nil, "BACKGROUND")
    itemBackground:SetPoint("TOPLEFT", -1, 1)
    itemBackground:SetPoint("BOTTOMRIGHT", 1, -1)
    itemBackground:SetColorTexture(0, 0, 0, 1)

    local icon = itemButton:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    bar.icon = icon

    local stack = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    stack:SetPoint("BOTTOMRIGHT", -1, 1)
    bar.stack = stack

    local itemLevel = itemButton:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )
    itemLevel:SetPoint("BOTTOM", itemButton, "BOTTOM", 0, 1)
    bar.itemLevel = itemLevel

    local bind = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bind:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 3, 12)
    bar.bind = bind

    local name = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    name:SetPoint("LEFT", bind, "RIGHT", 3, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    bar.name = name

    local previousButton

    for _, definition in ipairs(ROLL_BUTTONS) do
        local button = createRollButton(bar, definition)

        if previousButton then
            button:SetPoint("RIGHT", previousButton, "LEFT", -3, 0)
        else
            button:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -3, 10)
        end

        bar[definition.key] = button
        previousButton = button
    end

    name:SetPoint("RIGHT", previousButton, "LEFT", -3, 0)

    timer:SetScript("OnUpdate", function(_, elapsed)
        bar.elapsed = (bar.elapsed or 0) + elapsed

        if bar.elapsed < TIMER_UPDATE_INTERVAL or not bar.rollID then
            return
        end

        bar.elapsed = 0

        if bar.isPreview then
            bar.previewTimeLeft = math.max(0, bar.previewTimeLeft - elapsed)
            timer:SetValue(bar.previewTimeLeft)

            if bar.previewTimeLeft <= 0 then
                bar:Hide()
                bar.rollID = nil
            end

            return
        end

        local timeLeft = GetLootRollTimeLeft(bar.rollID)

        if timeLeft <= 0 then
            self.onExpired(bar.rollID)
        else
            timer:SetValue(timeLeft)
        end
    end)

    self.bars[slot] = bar

    return bar
end


function Renderer:getBar(slot)
    return self.bars[slot] or self:createBar(slot)
end


function Renderer:hide(slot)
    local bar = self:getBar(slot)
    bar.rollID = nil
    bar.itemButton.rollID = nil
    bar.isPreview = nil
    bar:Hide()
end


local function getQualityColor(quality)
    local color = ITEM_QUALITY_COLORS[quality]

    if not color then
        return { 1, 1, 1 }
    end

    return { color.r, color.g, color.b }
end


local function shouldShowItemLevel(itemClassID, itemEquipLoc, quality)
    local isEquipment = itemClassID == Enum.ItemClass.Weapon
        or itemClassID == Enum.ItemClass.Armor

    return isEquipment and itemEquipLoc ~= "" and quality >= 2
end


function Renderer:readRoll(rollID)
    local texture, name, count, quality, _, canNeed, canGreed,
        canDisenchant, _, _, _, _, canTransmog = GetLootRollItemInfo(rollID)

    if not name then
        return nil
    end

    local itemLink = GetLootRollItemLink(rollID)
    local _, _, _, itemLevel, _, _, _, _, itemEquipLoc, _, _, itemClassID,
        _, bindType = C_Item.GetItemInfo(itemLink)

    return {
        bindType = bindType,
        canDisenchant = canDisenchant,
        canGreed = canGreed,
        canNeed = canNeed,
        canTransmog = canTransmog,
        count = count,
        itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel,
        itemLink = itemLink,
        name = name,
        quality = quality,
        qualityColor = getQualityColor(quality),
        showItemLevel = shouldShowItemLevel(itemClassID, itemEquipLoc, quality),
        texture = texture,
    }
end


function Renderer:populate(bar, rollID, rollTime, item)
    local view = BetterLootRollView.build(item)
    local red, green, blue = unpack(view.qualityColor)

    bar.rollID = rollID
    bar.elapsed = TIMER_UPDATE_INTERVAL
    bar.icon:SetTexture(item.texture)
    bar.itemButton.itemLink = item.itemLink
    bar.itemButton.rollID = rollID
    bar.stack:SetText(view.stackText)
    bar.itemLevel:SetText(view.itemLevelText)
    bar.bind:SetText(view.bindText)
    bar.bind:SetTextColor(unpack(view.bindColor))
    bar.name:SetText(item.name)
    bar.name:SetTextColor(1, 1, 1)
    bar.timer:SetStatusBarColor(red, green, blue, 0.7)
    bar.timer:SetMinMaxValues(0, rollTime)
    bar.timer:SetValue(rollTime)

    for key, enabled in pairs(view.buttons) do
        bar[key]:SetEnabled(enabled)
    end

    bar:Show()
end


function Renderer:show(slot, roll)
    local item = self:readRoll(roll.rollID)

    if not item then
        self.onExpired(roll.rollID)

        return
    end

    self:populate(self:getBar(slot), roll.rollID, roll.rollTime, item)
end


function Renderer:showPreview()
    local previewItems = {
        {
            name = "Mythic Test Blade",
            texture = 135274,
            quality = 4,
            qualityColor = getQualityColor(4),
            count = 1,
            itemLevel = 639,
            bindType = 1,
            showItemLevel = true,
            canNeed = true,
            canGreed = true,
            canDisenchant = true,
            canTransmog = false,
        },
        {
            name = "Veteran Test Mantle",
            texture = 135061,
            quality = 3,
            qualityColor = getQualityColor(3),
            count = 2,
            itemLevel = 626,
            bindType = 2,
            showItemLevel = true,
            canNeed = false,
            canGreed = true,
            canDisenchant = false,
            canTransmog = true,
        },
    }

    for slot, item in ipairs(previewItems) do
        local bar = self:getBar(slot)
        self:populate(bar, -slot, 30, item)
        bar.isPreview = true
        bar.previewTimeLeft = 30
    end
end


BetterLootDB = type(BetterLootDB) == "table" and BetterLootDB or {}

local savedPosition = BetterLootPosition.restore(BetterLootDB.position)
BetterLootDB.position = savedPosition

local holder = CreateFrame("Frame", ADDON_NAME .. "Holder", UIParent)
holder:SetPoint(
    savedPosition.point,
    UIParent,
    savedPosition.relativePoint,
    savedPosition.x,
    savedPosition.y
)
holder:SetSize(BAR_WIDTH, BAR_HEIGHT)
holder:SetClampedToScreen(true)
holder:SetMovable(true)
holder:RegisterForDrag("LeftButton")

local moverBackground = holder:CreateTexture(nil, "OVERLAY")
moverBackground:SetAllPoints()
moverBackground:SetColorTexture(0.1, 0.7, 0.9, 0.45)
moverBackground:Hide()

local moverText = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
moverText:SetPoint("CENTER")
moverText:SetText("BetterLoot - drag to move")
moverText:Hide()

local function saveHolderPosition()
    local point, _, relativePoint, x, y = holder:GetPoint(1)
    BetterLootDB.position = BetterLootPosition.update(
        point,
        relativePoint,
        x,
        y
    )
end

local function lockHolder()
    holder:StopMovingOrSizing()
    holder:EnableMouse(false)
    moverBackground:Hide()
    moverText:Hide()
    saveHolderPosition()
end

local function unlockHolder()
    if InCombatLockdown() then
        print("BetterLoot: the mover cannot be unlocked during combat.")

        return
    end

    holder:EnableMouse(true)
    moverBackground:Show()
    moverText:Show()
end

local function resetHolder()
    if InCombatLockdown() then
        print("BetterLoot: the position cannot be reset during combat.")

        return
    end

    local position = BetterLootPosition.restore(nil)
    holder:ClearAllPoints()
    holder:SetPoint(
        position.point,
        UIParent,
        position.relativePoint,
        position.x,
        position.y
    )
    BetterLootDB.position = position
end

holder:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    end
end)
holder:SetScript("OnDragStop", function()
    holder:StopMovingOrSizing()
    saveHolderPosition()
end)

local controller
local renderer = Renderer.new(holder, function(rollID)
    controller:cancel(rollID)
end)
controller = BetterLootRollController.new(MAX_VISIBLE_ROLLS, renderer)

local events = CreateFrame("Frame")
events:RegisterEvent("START_LOOT_ROLL")
events:RegisterEvent("CANCEL_LOOT_ROLL")
events:RegisterEvent("CANCEL_ALL_LOOT_ROLLS")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event, rollID, rollTime)
    if event == "START_LOOT_ROLL" then
        controller:start(rollID, rollTime)
    elseif event == "CANCEL_LOOT_ROLL" then
        controller:cancel(rollID)
    elseif event == "CANCEL_ALL_LOOT_ROLLS" then
        controller:cancelAll()
    else
        lockHolder()
    end
end)

if UnregisterInternalEvent then
    UnregisterInternalEvent("START_LOOT_ROLL")
    UnregisterInternalEvent("CANCEL_LOOT_ROLL")
else
    UIParent:UnregisterEvent("START_LOOT_ROLL")
    UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

SLASH_BETTERLOOT1 = "/betterloot"
SlashCmdList.BETTERLOOT = function(command)
    local action = strlower(strtrim(command or ""))

    if action == "test" then
        renderer:showPreview()

        return
    elseif action == "unlock" then
        unlockHolder()

        return
    elseif action == "lock" then
        lockHolder()

        return
    elseif action == "reset" then
        resetHolder()

        return
    end

    print("BetterLoot: /betterloot test, unlock, lock, or reset")
end
