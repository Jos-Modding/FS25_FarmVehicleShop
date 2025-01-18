local modName = g_currentModName

PlaceableVehicleSpawner = {
    DEBUG = true,
    SPEC_TABLE_NAME = "spec_" .. modName .. ".vehicleSpawner",
}

function PlaceableVehicleSpawner.prerequisitesPresent(...)
    return true
end

function PlaceableVehicleSpawner.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", PlaceableVehicleSpawner)
    SpecializationUtil.registerEventListener(vehicleType, "onPostFinalizePlacement", PlaceableVehicleSpawner)
end

function PlaceableVehicleSpawner.registerXMLPaths(schema, basePath)
    schema:setXMLSpecializationType("VehicleSpawner")
    schema:register(XMLValueType.NODE_INDEX, basePath .. ".vehicleSpawnAreas#shopTriggerNode", "Start node")
    schema:register(XMLValueType.NODE_INDEX, basePath .. ".vehicleSpawnAreas.vehicleSpawnArea(?)#startNode", "Start node")
    schema:register(XMLValueType.NODE_INDEX, basePath .. ".vehicleSpawnAreas.vehicleSpawnArea(?)#endNode", "End node")
    schema:setXMLSpecializationType()
end

function PlaceableVehicleSpawner:onDelete()
    if self[PlaceableVehicleSpawner.SPEC_TABLE_NAME] ~= nil then
        self[PlaceableVehicleSpawner.SPEC_TABLE_NAME] = nil
    end

    if self.shopTrigger ~= nil then
        self.shopTrigger:delete()
    end

    g_farmVehicleShopSystem:removeFarmVehicleShop(self)
end

function PlaceableVehicleSpawner:onPostFinalizePlacement()
    self.vehicleSpawnPlaces = {}

    if not self.xmlFile:hasProperty("placeable.vehicleSpawnAreas") then
        Logging.xmlWarning(self.xmlFile, "Missing vehicle spawn areas")
        return
    end

    self.xmlFile:iterate("placeable.vehicleSpawnAreas.vehicleSpawnArea", function (_, key)
        local startNode = self.xmlFile:getValue(key .. "#startNode", nil, self.components, self.i3dMappings)
        local endNode = self.xmlFile:getValue(key .. "#endNode", nil, self.components, self.i3dMappings)
        local place = PlacementUtil.loadPlaceFromNode(startNode, endNode)
        table.insert(self.vehicleSpawnPlaces, place)
    end)

    self.shopTriggerNode = self.xmlFile:getValue("placeable.vehicleSpawnAreas#shopTriggerNode", nil, self.components, self.i3dMappings)
    if self.shopTriggerNode ~= nil then
        self.shopTrigger = ShopTrigger.new(self.shopTriggerNode)
    end

    g_farmVehicleShopSystem:addFarmVehicleShop(self)
end
