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
        max_item_bounds = Vector.max(max_item_bounds, item.getBounds().size)
    end
    max_item_bounds.y = 0
    local first_position = position
    local padding_initial_offset = Vector(padding[1]*(cols-1)/2, 0, padding[3]*(rows-1)/2)
    if values.alignment == "center" then
        first_position = first_position - Vector(
            max_item_bounds[1]*(cols-1)/2 + padding[1]*(cols-1)/2,
            0,
            max_item_bounds[3]*(rows-1)/2 + padding[3]*(rows-1)/2
        )
    elseif values.alignment == "left" then
    else
        error("Invalid arg alignment:"..values.alignment)
    end

    local positionOffsetX = Vector(max_item_bounds[1] + padding[1], 0, 0)
    local positionOffsetZ = Vector(0, 0, max_item_bounds[3] + padding[3])
    for i, item in ipairs(values.items) do
        local index = i - 1
        local r = math.floor(index/cols)
        local c = index - (r * cols)
        local current = first_position + positionOffsetX * (c) + positionOffsetZ * (r)
        item.setVelocity({0,0,0})
        item.setAngularVelocity({0,0,0})
        item.setPosition(current)
        item.setRotation(values.rotation)
    end    
end

return ComponentUtils