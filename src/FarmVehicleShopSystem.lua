FarmVehicleShopSystem = {}
local FarmVehicleShopSystem_mt = Class(FarmVehicleShopSystem)

---
function FarmVehicleShopSystem.new(mission, modDirectory, modName)
    local self = setmetatable({}, FarmVehicleShopSystem_mt)
    self.mission = mission
    self.modDirectory = modDirectory
    self.modName = modName
    self.farmVehicleShops = {}

    return self
end

-- @param table farmVehicleShop
function FarmVehicleShopSystem:addFarmVehicleShop(farmVehicleShop)
    table.insert(self.farmVehicleShops, farmVehicleShop)
end

-- @param table farmVehicleShop
function FarmVehicleShopSystem:removeFarmVehicleShop(farmVehicleShop)
    table.removeElement(self.farmVehicleShops, farmVehicleShop)
end

-- @param farmId integer
function FarmVehicleShopSystem:getFarmVehicleShopByFarmId(farmId)
    for _, farmVehicleShop in ipairs(g_farmVehicleShopSystem.farmVehicleShops) do
        if farmVehicleShop.ownerFarmId == farmId then
            return farmVehicleShop
        end
    end

    return nil
end

-- @see shop/BuyVehicleData:buy
-- @param table storeItem
-- @param function? superFunc
-- @param table mapPlaces
function FarmVehicleShopSystem.onBuyVehicleEvent(storeItem, superFunc, mapPlaces, ...)
    local places = {}
    local farmVehicleShop = g_farmVehicleShopSystem:getFarmVehicleShopByFarmId(storeItem.ownerFarmId)

    if farmVehicleShop ~= nil then
        for _, place in ipairs(farmVehicleShop.vehicleSpawnPlaces) do
            table.insert(places, place)
        end
    end

    -- append map places for overflow
    for _, place in ipairs(mapPlaces) do
        table.insert(places, place)
    end

    return superFunc(storeItem, places, ...)
end

-- @see fs22/Vehicle:loadFinished, no longer visible in fs25 sdk!
-- @param table mission
function FarmVehicleShopSystem.getResetPlaces(mission, ...)
    local places = {}

    if g_localPlayer ~= nil then
        local farmVehicleShop = g_farmVehicleShopSystem:getFarmVehicleShopByFarmId(g_localPlayer.farmId)

        if farmVehicleShop ~= nil then
            for _, place in ipairs(farmVehicleShop.vehicleSpawnPlaces) do
                table.insert(places, place)
            end
        end
    end

    -- append map places for overflow
    for _, place in ipairs(mission.storeSpawnPlaces) do
        table.insert(places, place)
    end

    return places
end
