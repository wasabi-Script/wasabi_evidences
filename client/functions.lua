-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

function CreateEvidenceMarker(evidence, coords, time)
    if evidence == 'blood' then
        DrawMarker(3, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 235, 64, 52,
            100, true, true, 2, false, false, false, false)
    else
        DrawMarker(3, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 19, 223, 210,
            100, true, true, 2, false, false, false, false)
    end
end

function GetLocationInfo(coords)
    local streetA, streetB = 0, 0
    local streetA, streetB = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    street = {}
    if streetA ~= 0 then
        street[#street + 1] = GetStreetNameFromHashKey(streetA)
    end
    if streetB ~= 0 then
        street[#street + 1] = GetStreetNameFromHashKey(streetB)
    end
    street = table.concat(street, " & ")
    local zoneName = (Zones[GetNameOfZone(coords.x, coords.y, coords.z)] or nil)
    if zoneName then street = street..'('..zoneName..')' end
    return street
end

local weaponTypes = {
    [416676503] = Strings.handgun,
    [3337201093]  = Strings.submachine_gun,
    [860033945] = Strings.shotgun,
    [970310034] = Strings.assault_rifle,
    [1159398588] = Strings.lightmachine_gun,
    [3082541095] = Strings.heavyweapon
}

function GetWeaponType(hash)
    if weaponTypes[GetWeapontypeGroup(hash)] then
        return weaponTypes[GetWeapontypeGroup(hash)]
    end
end

function SpawnBloodSplat(coords)
    local ped = cache.ped
    local hash = `p_bloodsplat_s`
    lib.requestModel('p_bloodsplat_s', 100)
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-1.5))
    local obj = CreateObjectNoOffset(hash, x, y, z, true, false)
    PlaceObjectOnGroundProperly(obj)
    local objCoords = GetEntityCoords(obj)
    SetEntityCoords(obj, objCoords.x, objCoords.y, objCoords.z-0.25)
    SetEntityRotation(obj, -90.0, 0.0, 0.0, 2, false)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, true)
    SetModelAsNoLongerNeeded(hash)
end

function DeleteBloodSplat(coords)
    local hash = `p_bloodsplat_s`
    local closestBlood = GetClosestObjectOfType(coords, 3.0, hash, false)
    if not closestBlood then return end
    SetEntityAsMissionEntity(closestBlood, true, true)
    DeleteObject(closestBlood)
    if DoesEntityExist(closestBlood) then
        TriggerServerEvent('wasabi_evidence:cleanBlood', ObjToNet(closestBlood))
    end
end

function AddBlood(coords, interior, street)
    TriggerServerEvent('wasabi_evidence:add', 'blood', coords, interior, street)
end

function ScanForPrints()
    if not IsPolice then return end
    local ped = cache.ped
    local vehicle = cache.vehicle
    if not vehicle or not IsPedInAnyVehicle(cache.ped, false) then
        TriggerEvent('wasabi_evidence:notify', Strings.not_in_vehicle, Strings.not_in_vehicle_desc, 'error')
    elseif not PreviousDriver then
        TriggerEvent('wasabi_evidence:notify', Strings.no_prints_found, Strings.no_prints_found_desc, 'error')
    else
        if Config.MaxEvidence and #EvidenceInHand >= Config.MaxEvidence then
            TriggerEvent('wasabi_evidence:notify', Strings.max_evidence, Strings.max_evidence_desc, 'error')
            return
        end
        local data = lib.callback.await('wasabi_evidence:getPrintInfo', 100, PreviousDriver)
        data.coords = GetEntityCoords(cache.ped)
        data.street = GetLocationInfo(data.coords)
        data.plate = GetVehicleNumberPlateText(vehicle)
        EvidenceInHand[#EvidenceInHand + 1] = data
        if Config.VehicleFingerPrinting.removeOnUse then
            TriggerServerEvent('wasabi_evidence:usePrintTool')
        end
        TriggerEvent('wasabi_evidence:notify', Strings.prints_collected, (Strings.prints_collected_desc):format(#EvidenceInHand, Config.MaxEvidence), 'success')
    end
end

function PickupEvidence(data)
    if not data then return end
    local ped = cache.ped
    if IsPolice and #EvidenceInHand >= Config.MaxEvidence then
        TriggerEvent('wasabi_evidence:notify', Strings.max_evidence, Strings.max_evidence_desc, 'error')
        return true
    else
        DisableKeys(3000)
        lib.requestAnimDict('pickup_object', 100)
        TaskTurnPedToFaceCoord(ped, data.coords.x, data.coords.y, data.coords.z, 2000)
        TaskPlayAnim(ped, "pickup_object", "pickup_low", 8.0, 8.0, -1, 50, 0, false, false, false)
        Wait(1000)
        ClearPedTasks(ped)
        if IsPolice then
            if Config.BloodProps and data.evidence == 'blood' then
                DeleteBloodSplat(data.coords)
            end
            RemoveEvidence(data.id, data.coords)
            EvidenceInHand[#EvidenceInHand + 1] = data
            TriggerEvent('wasabi_evidence:notify', Strings.evidence_picked_up, (Strings.evidence_picked_up_desc):format(#EvidenceInHand, Config.MaxEvidence), 'success')
        elseif Config.CriminalsCanCleanEvidence.enabled then
            if data.evidence == 'blood' then
                local cleaned = lib.callback.await('wasabi_evidence:hasCleaner', 100)
                if cleaned then
                    RemoveEvidence(data.id, data.coords)
                    EvidenceInHand[#EvidenceInHand + 1] = data
                    TriggerEvent('wasabi_evidence:notify', Strings.evidence_destroyed, Strings.evidence_destroyed_desc, 'success')
                    if Config.BloodProps then DeleteBloodSplat(data.coords) end
                else
                    TriggerEvent('wasabi_evidence:notify', Strings.no_cleaner, Strings.no_cleaner_desc, 'error')
                end
            else
                RemoveEvidence(data.id, data.coords)
                EvidenceInHand[#EvidenceInHand + 1] = data
                TriggerEvent('wasabi_evidence:notify', Strings.evidence_destroyed, Strings.evidence_destroyed_desc, 'success')
            end
        end
        RemoveAnimDict('pickup_object')
        return true
    end
end

function OpenEvidenceAnalyzed(evidence)
    if not evidence and #evidence > 0 then return end
    local options = {}
    local e
    for i=1, #evidence do
        if evidence[i].evidence == 'blood' then e = 'blood' elseif evidence[i].evidence == 'print' then e = 'print' else e = 'bullet' end
        options[#options + 1] = {
            title = (Strings.evidence_report):format(evidence[i].id),
            description = Strings.evidence_type..' '..Strings[e],
            event = 'wasabi_evidence:openEvidenceHand',
            args = {evidence = evidence[i], data = evidence},
            icon = 'box-archive'
        }
    end
    lib.registerContext({
        id = 'evidence_analyzed',
        title = Strings.analyzed_evidence,
        options = options
    })
    lib.showContext('evidence_analyzed')
end

function AnalyzeEvidence()
    if #EvidenceInHand > 0 then
        local newData
        local data = {}
        if lib.progressCircle({
            duration = Config.AnalyzingTime,
            label = Strings.analyzing_time,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
            },
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer'
            },
        }) then
            for i=1, #EvidenceInHand do
                if EvidenceInHand[i] ~= nil then
                    local d = lib.callback.await('wasabi_evidence:saveEvidence', 100, EvidenceInHand[i])
                    if d then
                        data[#data + 1] = d
                    end
                end
            end
            if data and #data > 0 then
                newData = data
            end
            EvidenceInHand = {}
            TriggerEvent('wasabi_evidence:notify', Strings.analyzed, (Strings.analyzed_desc):format(#newData), 'success')
            OpenEvidenceAnalyzed(newData)
        else
            TriggerEvent('wasabi_evidence:notify', Strings.action_cancelled, Strings.action_cancelled_desc, 'error')
        end
    else
        TriggerEvent('wasabi_evidence:notify', Strings.no_evidence, Strings.no_evidence_desc, 'error')
    end
end

function AccessEvidenceStorage()
    local options = {}
    local evidence, fingerprints = lib.callback.await('wasabi_evidence:getEvidenceStorage', 100)
    if evidence and #evidence > 0 then
        if fingerprints then
            for k,v in pairs(evidence) do
                for b,_ in pairs(fingerprints) do
                    if v.identifier == b then
                        v.prints = true
                    end
                end
            end
        end
        local index = #evidence
        for i=1, #evidence do
            local e
            if evidence[i] ~= nil then
                if evidence[i].evidence == 'blood' then e = 'blood' elseif evidence[i].evidence == 'print' then e = 'print' else e = 'bullet' end
                options[index - 1] = {
                    title = (Strings.evidence_report):format(evidence[i].id),
                    description = Strings.evidence_type..' '..Strings[e],
                    event = 'wasabi_evidence:openEvidenceReport',
                    args = evidence[i],
                    icon = 'box-archive'
                }
                index = index - 1
            end
        end
    else
        options[#options + 1] = {
            title = Strings.no_evidence,
            icon = 'circle-exclamation'
        }
    end
    lib.registerContext({
        id = 'evidence_storage',
        title = Strings.evidence_storage,
        options = options
    })
    lib.showContext('evidence_storage')
end

function FingerprintNearbyPlayer(data)
    local options = {}
    if not data then
        local coords = GetEntityCoords(cache.ped)
        local closestPlayer = lib.getClosestPlayer(coords, 2.0, false)
        if not closestPlayer then
            TriggerEvent('wasabi_evidence:notify', Strings.no_one_nearby, Strings.no_one_nearby_desc, 'error')
            return
        end
        local closestPed = GetPlayerPed(closestPlayer)
        TaskTurnPedToFaceEntity(cache.ped, closestPed, 2000)
        TriggerServerEvent('wasabi_evidence:sv:setInteract', GetPlayerServerId(closestPlayer))
        Wait(2000)
        if lib.progressCircle({
            duration = 7500,
            position = 'bottom',
            label = Strings.obtaining_prints,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                scenario = 'WORLD_HUMAN_CLIPBOARD',
            },
        }) then
            local matchingPrints = lib.callback.await('wasabi_evidence:fingerprintPlayer', 250, GetPlayerServerId(closestPlayer))
            if not matchingPrints then
                options = {
                    {
                        title = Strings.not_in_system,
                        description = Strings.prints_not_found,
                        event = '',
                        icon = 'box-archive'
                    }
                }
            else
                for k,v in pairs(matchingPrints) do
                    options[#options + 1] = {
                        title = (Strings.evidence_report):format(v.id),
                        description = Strings.match_found,
                        event = 'wasabi_evidence:openPrintHands',
                        args = {evidence = v, data = matchingPrints},
                        icon = 'box-archive'
                    }
                end
            end
        else
            lib.hideContext()
            TriggerEvent('wasabi_evidence:notify', Strings.action_cancelled, Strings.action_cancelled_desc, 'error')
        end
    else
        for k,v in pairs(data) do
            options[#options + 1] = {
                title = (Strings.evidence_report):format(v.id),
                description = Strings.match_found,
                event = 'wasabi_evidence:openPrintHands',
                args = {evidence = v, data = data},
                icon = 'box-archive'
            }
        end
    end
    lib.registerContext({
        id = 'matched_prints',
        title = Strings.prints_found,
        options = options
    })
    lib.showContext('matched_prints')
end