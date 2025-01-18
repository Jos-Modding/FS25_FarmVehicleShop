source(g_currentModDirectory .. "src/FarmVehicleShopSystem.lua")

local environment = nil

local function load(mission)
    assert(g_farmVehicleShop == nil)

    environment = FarmVehicleShopSystem:new(mission, g_currentModDirectory, g_currentModName)
    getfenv(0)["g_farmVehicleShopSystem"] = environment
end

local function unload()
    environment = nil
    getfenv(0)["g_farmVehicleShopSystem"] = nil
end

local function init()
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)
    Mission00.load = Utils.prependedFunction(Mission00.load, load)
    BuyVehicleData.buy = Utils.overwrittenFunction(BuyVehicleData.buy, FarmVehicleShopSystem.onBuyVehicleEvent)
    BaseMission.getResetPlaces = Utils.overwrittenFunction(BaseMission.getResetPlaces, FarmVehicleShopSystem.getResetPlaces)
end

init()
