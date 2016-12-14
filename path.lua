if not LibAG then return end

local Path = LibAG:New('Path', LibAG.Animation)
Path.curve_type = nil
Path.control_points = {}

-- Adds a new path control point.
function Path:CreateControlPoint(name, template, order)
    local control_point = { name = name,
                            template = template,
                            order = order }
    table.insert(self.control_points, control_points)
end

-- Returns an arg list of current path control points.
function Path:GetControlPoints()
    return unpack(self.control_points)
end

-- Returns the path 'curveType'.
function Path:GetCurve()
    return self.curve_type
end

-- Returns highest 'orderId' currently set for any of the control points .
function Path:GetMaxOrder()
    local highest_order = 0

    for _, point in next, self.control_points do
        if point.order > highest_order then
            highest_order = point.order
        end
    end

    return highest_order
end

-- Sets the path 'curveType'.
function Path:SetCurve(curve_type)
    self.curve_type = curve_type
end
