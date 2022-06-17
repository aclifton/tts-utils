local ComponentUtils = {}

function ComponentUtils.getObjectSizeHack(obj)
    if obj.type == "Tile" then
        return obj.getScale():scale(Vector(2,1,2))
    else
        return obj.getBounds().size
    end
end

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
    if values.cols == 0 and values.rows == 0 then
        values.rows = math.ceil(math.sqrt(#values.items))
    end
    if values.cols == 0 then
        values.cols = math.ceil(#values.items/values.rows)
    elseif values.rows == 0 then
        values.rows = math.ceil(#values.items/values.cols)
    end

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
        max_item_bounds = Vector.max(max_item_bounds, ComponentUtils.getObjectSizeHack(item))
    end
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

function ComponentUtils.getObjectsAboveRectangularObject(params)
    local values = {
        height = 1,
        debug = false,
    }
    for k,v in pairs(params) do values[k] = v end
    local obj = getObjectFromGUID(values.obj)
    if obj == nil then error("obj cannot be nil") end
    local position = obj.getPosition()
    local objSize = obj.getBoundsNormalized().size
    local rotation = obj.getRotation()
    local hits = Physics.cast({
        origin       = position,
        direction    = {0, 1, 0},
        type         = 3,-- int (1: Ray, 2: Sphere, 3: Box),
        size         = objSize,
        orientation  = rotation,
        max_distance = values.height,
        debug        = values.debug,
    }) -- returns {{Vector point, Vector normal, float distance, Object hit_object}, ...}
    local uniqueObjects = {}
    for _, hit in ipairs(hits) do
        local hitObject = hit.hit_object
        if hitObject.getGUID() ~= nil and hitObject.getGUID() ~= params.obj then
            uniqueObjects[hitObject.getGUID()] = hitObject
        end
    end
    local objects = {}
    for _, object in pairs(uniqueObjects) do table.insert(objects, object) end
    return objects
end

function ComponentUtils.getObjectsAboveRegualarHexagonalObject(params)
    local values = {
        height = 1,
        debug = false,
    }
    for k,v in pairs(params) do values[k] = v end
    local obj = getObjectFromGUID(values.obj)
    if obj == nil then error("obj cannot be nil") end
    local position = obj.getPosition()
    local objSize = obj.getBoundsNormalized().size
    local rotation = obj.getRotation()    
    local uniqueObjects = {}

    for r=30,180,60 do
        local rotation = obj.getRotation()
        rotation.y = rotation.y + r
        local hits = Physics.cast({
            origin = obj.getPosition(),
            type = 3,
            direction = {0,1,0},
            max_distance = values.height,
            size = {objSize.x * math.sqrt(3)/2, objSize.y, objSize.x/2},
            orientation = rotation,
            debug = values.debug,
        })
        for _, hit in ipairs(hits) do
            local hitObject = hit.hit_object
            if hitObject.getGUID() ~= nil and hitObject.getGUID() ~= params.obj then
                uniqueObjects[hitObject.getGUID()] = hitObject
            end
        end
    end

    local objects = {}
    for _, object in pairs(uniqueObjects) do table.insert(objects, object) end
    return objects
end

return ComponentUtils