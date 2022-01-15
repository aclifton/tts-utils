local ComponentUtils = {}

function ComponentUtils.arrange(params)
    values = {
        items = {},
        origin = {0, 0, 0},
        alignment = "center",
        rotation = {0, 0, 0},
        padding = .1,
        rows = 0,
        cols = 0,
        positionSmooth = false,
        positionFast = false,
        reverseRowDirection = false,
    }
    for k,v in pairs(params) do values[k] = v end
    if #values.items == 0 then return end
    -- if values.cols == 0 and values.rows == 0 then
    --     local sqrtItems = math.ceil(math.sqrt(#values.items))
    --     values.rows = sqrtItems
    --     if values.rows == 0 then values.rows = 1 end
    --     values.cols = math.ceil(#values.items/values.rows)        
    -- end
    if type(values.padding) ~= "table" then
        values.padding = {values.padding, values.padding, values.padding}
    end
    local padding = Vector(values.padding)
    local position = Vector(values.origin)
    local max_item_bounds = Vector(0,0,0)
    local rows = values.rows
    local cols = values.cols    
    for _, item in ipairs(values.items) do
        item.setRotation(values.rotation)
        max_item_bounds = Vector.max(max_item_bounds, item.getBounds().size)
    end
    max_item_bounds.y = 0
    local first_position = position
    if values.alignment == "center" then
        local originOffset = Vector(
            -max_item_bounds[1]*(cols-1)/2 - padding[1]*(cols-1)/2,
            0,
            max_item_bounds[3]*(rows-1)/2 + padding[3]*(rows-1)/2
        )
        if values.reverseRowDirection then
            originOffset.z = -originOffset.z
        end
        first_position = first_position + originOffset
    elseif values.alignment == "left" then
    else
        error("Invalid arg alignment:"..values.alignment)
    end

    local positionOffsetX = Vector(max_item_bounds[1] + padding[1], 0, 0)
    local positionOffsetZ = -1 * Vector(0, 0, max_item_bounds[3] + padding[3])
    if values.reverseRowDirection then
        positionOffsetZ = -1 * positionOffsetZ
    end
    for i, item in ipairs(values.items) do
        local index = i - 1
        local r = math.floor(index/cols)
        local c = index - (r * cols)
        local current = first_position + positionOffsetX * (c) + positionOffsetZ * (r)
        item.setVelocity({0,0,0})
        item.setAngularVelocity({0,0,0})
        item.setRotation(values.rotation)
        if values.positionSmooth then
            item.setPositionSmooth(current, false, values.positionFast)
        else
            item.setPosition(current)
        end
    end    
end

return ComponentUtils