FarmVehicleShopSystem = {}
local FarmVehicleShopSystem_mt = Class(FarmVehicleShopSystem)
source(g_currentModDirectory .. "src/FarmVehicleResetEvent.lua")

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

function FarmVehicleShopSystem:setActiveFarmVehicleShop(farmId)
    local shop = g_farmVehicleShopSystem:getFarmVehicleShopByFarmId(farmId)
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

    if mission.farmVehicleShop ~= nil then
        local farmVehicleShop = g_farmVehicleShopSystem:getFarmVehicleShopByFarmId(mission.farmVehicleShop or 0)

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

    -- Reset farmId
    g_client:getServerConnection():sendEvent(FarmVehicleResetEvent.new(0))

    return places
end

function FarmVehicleShopSystem.onYesNoReset(self, yes)
    if yes then
        if self.currentHotspot ~= nil then
            local vehicle = InGameMenuMapUtil.getHotspotVehicle(self.currentHotspot)

            if vehicle ~= nil then
                g_client:getServerConnection():sendEvent(FarmVehicleResetEvent.new(vehicle.ownerFarmId))
            end
        end
    end
end
