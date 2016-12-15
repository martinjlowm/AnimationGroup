if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

local Curves = AG:New('Curves')

local Point = {}

function Point.Add(lhs, rhs)
    return Point:New(lhs.x + rhs.x, lhs.y + rhs.y)
end

function Point.Multiply(lhs, rhs)
    return Point:New(lhs * rhs.x, lhs * rhs.y)
end

local mt = {
    __add = Point.Add,
    __mul = Point.Multiply }

function Point:New(x, y)
    return setmetatable({x = x, y = y}, mt)
end

local function QuadraticBezier(p_0, p_1, p_2)
    return function(t)
        return
            (1 - t) * ((1 - t) * p_0 + t * p_1) +
            t * ((1 - t) * p_1 + t * p_2)
    end
end

local function CubicBezier(p_0, p_1, p_2, p_3)
    return function(t)
        return
            (1 - t) * QuadraticBezier(p_0, p_1, p_2)(t) +
            t * QuadraticBezier(p_1, p_2, p_3)(t)
    end
end

local CubicBezierEaseIn = function()
    local p_0 = Point:New(0, 0)
    local p_1 = Point:New(.5, 0)
    local p_2 = Point:New(1, 1)
    local p_3 = p_2

    return CubicBezier(p_0, p_1, p_2, p_3)
end

local CubicBezierEaseOut = function()
    local p_0 = Point:New(0, 0)
    local p_1 = p_0
    local p_2 = Point:New(.5, 1)
    local p_3 = Point:New(1, 1)

    return CubicBezier(p_0, p_1, p_2, p_3)
end

local CubicBezierEaseInOut = function()
    local p_0 = Point:New(0, 0)
    local p_1 = Point:New(.5, 0)
    local p_2 = Point:New(.5, 1)
    local p_3 = Point:New(1, 1)

    return CubicBezier(p_0, p_1, p_2, p_3)
end

local Linear = function(t)
    return {x = 0, y = t}
end

Curves.curves = {
    ['IN'] = CubicBezierEaseIn(),
    ['OUT'] = CubicBezierEaseOut(),
    ['INOUT'] = CubicBezierEaseInOut(),
    ['OUTIN'] = CubicBezierEaseInOut(),
    ['LINEAR'] = Linear
}

setmetatable(Curves, {__index = Curves.curves })
