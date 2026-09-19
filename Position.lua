local Position = {}

local DEFAULT_POSITION = {
    point = "TOP",
    relativePoint = "TOP",
    x = 0,
    y = -200,
}

local VALID_POINTS = {
    BOTTOM = true,
    BOTTOMLEFT = true,
    BOTTOMRIGHT = true,
    CENTER = true,
    LEFT = true,
    RIGHT = true,
    TOP = true,
    TOPLEFT = true,
    TOPRIGHT = true,
}

local function copy(position)
    return {
        point = position.point,
        relativePoint = position.relativePoint,
        x = position.x,
        y = position.y,
    }
end

local function isValid(position)
    return type(position) == "table"
        and VALID_POINTS[position.point] == true
        and VALID_POINTS[position.relativePoint] == true
        and type(position.x) == "number"
        and type(position.y) == "number"
end

function Position.restore(savedPosition)
    if isValid(savedPosition) then
        return copy(savedPosition)
    end

    return copy(DEFAULT_POSITION)
end

function Position.update(point, relativePoint, x, y)
    local position = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }

    return Position.restore(position)
end

BetterLootPosition = Position

return Position
