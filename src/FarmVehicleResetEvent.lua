FarmVehicleResetEvent = {}
local FarmVehicleResetEvent_mt = Class(FarmVehicleResetEvent, Event)
InitEventClass(FarmVehicleResetEvent, "FarmVehicleResetEvent")

function FarmVehicleResetEvent.emptyNew()
    return Event.new(FarmVehicleResetEvent_mt)
end

function FarmVehicleResetEvent.new(farmId)
    local self = FarmVehicleResetEvent.emptyNew()
    self.farmId = farmId

    return self
end

function FarmVehicleResetEvent:writeStream(streamId, connection)
    streamWriteUIntN(streamId, self.farmId, FarmManager.FARM_ID_SEND_NUM_BITS)
end

function FarmVehicleResetEvent:readStream(streamId, connection)
    self.farmId = streamReadUIntN(streamId, FarmManager.FARM_ID_SEND_NUM_BITS)
    self:run(connection)
end

function FarmVehicleResetEvent:run(connection)
    g_messageCenter:publish(FarmVehicleResetEvent, self.farmId)
    g_currentMission.farmVehicleShop = self.farmId

    if not connection:getIsServer() then
        g_server:broadcastEvent(FarmVehicleResetEvent.new(self.farmId))
    end
end
