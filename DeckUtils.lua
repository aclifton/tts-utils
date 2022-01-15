local DeckUtils = {}

function DeckUtils.getDeckOrCardFromZone(zone_guid)
    local zone = getObjectFromGUID(zone_guid)
    if zone == nil then return nil end
    for _, obj in ipairs(zone.getObjects()) do
        if obj.type == "Deck" then
            return obj
        end
    end
    for _, obj in ipairs(zone.getObjects()) do
        if obj.type == "Card" then
            return obj
        end
    end
    return nil
end

return DeckUtils