-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

IsPolice, EvidenceInHand, PreviousDriver, Gloves, Hands = false, {}, nil, nil, nil
local nearbyEvidence

-- Events
RegisterNetEvent('wasabi_evidence:deleteEvidence', function(id)
    local alert = lib.alertDialog({
        header = Strings.delete_evidence_confirm,
        content = (Strings.delete_evidence_confirm_desc):format(id),
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        if lib.callback.await('wasabi_evidence:deleteEvidence', 100, id) then
            TriggerEvent('wasabi_evidence:notify', Strings.evidence_deleted, (Strings.evidence_deleted_desc):format(id), 'success')
        else
            TriggerEvent('wasabi_evidence:notify', Strings.error, (Strings.evidence_not_deleted_desc):format(id), 'error')
        end
    end
end)

RegisterNetEvent('wasabi_evidence:fingerprintVehicle', function()
    ScanForPrints()
end)

RegisterNetEvent('wasabi_evidence:cleanBloodSpot', function(net)
    local obj = NetToObj(net)
    if not DoesEntityExist(obj) then return end
    SetEntityAsMissionEntity(obj, true, true)
    DeleteObject(obj)
end)

RegisterNetEvent('wasabi_evidence:cl:setInteract', function(target)
    local player = GetPlayerFromServerId(target)
    local ped = GetPlayerPed(player)
    TaskTurnPedToFaceEntity(cache.ped, ped, 2000)
    Wait(2000)
    ClearPedTasks(cache.ped)
end)

AddEventHandler('wasabi_evidence:openEvidenceReport', function(data)
    if not IsPolice then return end
    OpenEvidenceReport(data, true)
end)

AddEventHandler('wasabi_evidence:analyzeEvidence', function()
    if not IsPolice then return end
    AnalyzeEvidence()
end)

AddEventHandler('wasabi_evidence:accessEvidenceHand', function(data)
    OpenEvidenceAnalyzed(data)
end)

AddEventHandler('wasabi_evidence:openPrintHands', function(data)
    if not IsPolice then return end
    OpenEvidenceReport(data.evidence, false, data.data, true)
end)

AddEventHandler('wasabi_evidence:openEvidenceHand', function(data)
    if not IsPolice then return end
    OpenEvidenceReport(data.evidence, false, data.data)
end)

AddEventHandler('wasabi_evidence:accessEvidenceStorage', function()
    if not IsPolice then return end
    AccessEvidenceStorage()
end)

AddEventHandler('wasabi_evidence:fingerprintNearbyPlayer', function(data)
    if not IsPolice then return end
    local data = data
    if data and data?.noData then data = false end
    FingerprintNearbyPlayer(data)
end)

-- Main Thread
CreateThread(function()
    while not PlayerData?.job do Wait(1000) end -- Wait for PlayerData to fully load
    for k,v in pairs(Config.PoliceJobs) do
        local hasJob, hasGrade = HasGroup(k)
        if hasJob and hasGrade >= Config.PoliceJobs[hasJob] then IsPolice = true break end
    end
    if Config.Gloves.enabled then
        if Config.Gloves.hands then
            Hands = Config.Gloves.hands
        else
            Gloves = Config.Gloves.gloves
        end
    end
    -- Evidence creation thread
    CreateThread(function()
        while true do
            local sleep = 2000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            if HasEntityBeenDamagedByAnyPed(ped) then
                local street = GetLocationInfo(coords)
                AddBlood(coords, GetInteriorFromEntity(ped), street)
                ClearEntityLastDamageEntity(ped)
                if Config.BloodProps then SpawnBloodSplat(coords) end
            end
            local currentHand = GetPedDrawableVariation(ped, 3)
            local track = true
            if Hands then
                for i=1, #Hands do
                    if Hands[i] == currentHand then
                        track = true
                        break
                    else
                        track = false
                    end
                end
            elseif Gloves then
                for i=1, #Gloves do
                    if Gloves[i] == currentHand then
                        track = false
                        break
                    end
                end
            end
            if Config.BlacklistedWeapons[GetSelectedPedWeapon(ped)] then
                track = false
            end
            if IsPedArmed(ped, 4) then
                sleep = 0
                if IsPedShooting(ped) and track then
                    sleep = 500
                    local street = GetLocationInfo(coords)
                    AddBullet(GetWeaponType(GetSelectedPedWeapon(ped)), coords, GetInteriorFromEntity(ped), street)
                end
            end
            Wait(sleep)
        end
    end)
    -- Evidence Collection thread
    CreateThread(function()
        local sync = true
        local textUI
        while true do
            local sleep = 1500
            local ped = cache.ped
            local coords = GetEntityCoords(ped)
            local authorized = false
            if not Config.CriminalsCanCleanEvidence.enabled then
                for k,v in pairs(Config.PoliceJobs) do
                    local job, grade = HasGroup(k)
                    if job and grade and grade >= v then authorized = true break end
                end
            else
                authorized = true
            end
            if authorized and IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(ped) == `WEAPON_FLASHLIGHT` then
                if sync then
                    nearbyEvidence = lib.callback.await('wasabi_evidence:getNearbyEvidence', 100, coords, GetInteriorFromEntity(ped))
                    sync = false
                end
                if nearbyEvidence and #nearbyEvidence > 0 then
                    for k,v in pairs(nearbyEvidence) do
                        if v and v?.coords then
                            local dist = #(v.coords - coords)
                            if dist <= Config.FlashlightRange then
                                sleep = 0
                                if v.evidence == 'blood' then
                                    CreateEvidenceMarker(v.evidence, vec3(v.coords.x, v.coords.y, v.coords.z-0.75))
                                else
                                    sleep = 0
                                    CreateEvidenceMarker(v.evidence, vec3(v.coords.x, v.coords.y, v.coords.z-0.75))
                                end
                                if dist <= 1.0 then
                                    if not textUI then textUI = {} end
                                    if not textUI[k] then
                                        textUI[k] = true
                                        ShowTextUI(Strings.txtui_pickup_evidence)
                                    end
                                    if IsControlJustReleased(0,38) then
                                        PickupEvidence(nearbyEvidence[k])
                                        sleep = 2000
                                        HideTextUI()
                                        textUI = {}
                                        sync = true
                                    end
                                elseif dist >= 1.1 and textUI?[k] then
                                    HideTextUI()
                                    textUI = nil
                                end
                            elseif textUI?[k] then
                                textUI = nil
                                HideTextUI()
                            end
                        end
                    end
                end
            elseif authorized and not IsPlayerFreeAiming(PlayerId()) then
                if textUI then textUI = nil HideTextUI() end
                sync = true
            end
            Wait(sleep)
        end
    end)
    -- Evidence Labs Thread
    CreateThread(function()
        for k,v in pairs(Config.EvidenceLabs) do
            if v.analyze.target.enabled then
                local job = v.jobLock
                if not job then
                    job = {}
                    for k,v in pairs(Config.PoliceJobs) do
                        job[#job + 1] = k
                    end
                end
                local data = {
                    targetType = 'AddBoxZone',
                    identifier = k..'_analyze',
                    coords = v.analyze.target.coords,
                    heading = v.analyze.target.heading,
                    width = v.analyze.target.width,
                    length = v.analyze.target.length,
                    minZ = v.analyze.target.minZ,
                    maxZ = v.analyze.target.maxZ,
                    job = job,
                    distance = 2.0,
                    options = {
                        {
                            event = 'wasabi_evidence:analyzeEvidence',
                            icon = 'fa-solid fa-microscope',
                            label = v.analyze.target.label
                        }
                    }
                }
                TriggerEvent('wasabi_evidence:addTarget', data)
            end
            if v.fingerprinting.enabled and v.fingerprinting.target.enabled then
                local job = v.jobLock
                if not job then
                    job = {}
                    for k,v in pairs(Config.PoliceJobs) do
                        job[#job + 1] = k
                    end
                end
                local data = {
                    targetType = 'AddBoxZone',
                    identifier = k..'_fingerprinting',
                    coords = v.fingerprinting.target.coords,
                    heading = v.fingerprinting.target.heading,
                    width = v.fingerprinting.target.width,
                    length = v.fingerprinting.target.length,
                    minZ = v.fingerprinting.target.minZ,
                    maxZ = v.fingerprinting.target.maxZ,
                    job = job,
                    distance = 2.0,
                    options = {
                        {
                            event = 'wasabi_evidence:fingerprintNearbyPlayer',
                            icon = 'fa-solid fa-fingerprint',
                            label = v.fingerprinting.target.label,
                            noData = true,
                        }
                    }
                }
                TriggerEvent('wasabi_evidence:addTarget', data)
            end
            if v.storage.enabled and v.storage.target.enabled then
                local job = v.jobLock
                if not job then
                    job = {}
                    for k,v in pairs(Config.PoliceJobs) do
                        job[#job + 1] = k
                    end
                end
                local data = {
                    targetType = 'AddBoxZone',
                    identifier = k..'_evidstorage',
                    coords = v.storage.target.coords,
                    heading = v.storage.target.heading,
                    width = v.storage.target.width,
                    length = v.storage.target.length,
                    minZ = v.storage.target.minZ,
                    maxZ = v.storage.target.maxZ,
                    job = job,
                    distance = 2.0,
                    options = {
                        {
                            event = 'wasabi_evidence:accessEvidenceStorage',
                            icon = 'fa-solid fa-box-archive',
                            label = v.storage.target.label
                        }
                    }
                }
                TriggerEvent('wasabi_evidence:addTarget', data)
            end
        end
        local textUI = {}
        while true do
            local sleep = 1500
            local ped = cache.ped
            local coords = GetEntityCoords(ped)
            if IsPolice then
                for k,v in pairs(Config.EvidenceLabs) do
                    local authorized = false
                    if v.jobLock and HasGroup(v.jobLock) then authorized = true elseif not v.jobLock then authorized = true end
                    if authorized then
                        local dist1, dist2, dist3
                        if not v.analyze.target.enabled then
                            dist1 = #(coords - v.analyze.coords)
                        end
                        if v.storage.enabled and not v.storage.target.enabled then
                            dist2 = #(coords - v.storage.coords)
                        end
                        if v.fingerprinting.enabled and not v.fingerprinting.target.enabled then
                            dist3 = #(coords - v.fingerprinting.coords)
                        end
                        if dist1 and dist1 <= v.analyze.range then
                            if not textUI[k] then textUI[k] = {} end
                            if not textUI[k].analyze then
                                ShowTextUI(v.analyze.label)
                                textUI[k].analyze = true
                            end
                            sleep = 0
                            if IsControlJustReleased(0, 38) then
                                AnalyzeEvidence(k)
                            end
                        elseif textUI?[k]?.analyze then
                            HideTextUI()
                            textUI = {}
                        end
                        if dist2 and dist2 <= v.storage.range then
                            if not textUI[k] then textUI[k] = {} end
                            if not textUI[k].storage then
                                ShowTextUI(v.storage.label)
                                textUI[k].storage = true
                            end
                            sleep = 0
                            if IsControlJustReleased(0, 38) then
                                AccessEvidenceStorage()
                            end
                        elseif textUI?[k]?.storage then
                            HideTextUI()
                            textUI = {}
                        end
                        if dist3 and dist3 <= v.fingerprinting.range then
                            if not textUI[k] then textUI[k] = {} end
                            if not textUI[k].fingerprinting then
                                ShowTextUI(v.fingerprinting.label)
                                textUI[k].fingerprinting = true
                            end
                            sleep = 0
                            if IsControlJustReleased(0, 38) then
                                FingerprintNearbyPlayer()
                            end
                        elseif textUI?[k]?.fingerprinting then
                            HideTextUI()
                            textUI = {}
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end)
end)

lib.onCache('vehicle', function(vehicle)
    local track, found
    local currentHand = GetPedDrawableVariation(PlayerPedId(), 3)
    if Hands then
        for i=1, #Hands do
            if Hands[i] == currentHand then
                track = true
                break
            end
        end
    elseif Gloves then
        for i=1, #Gloves do
            if Gloves[i] == currentHand then
                track = false
                break
            end
        end
    end
    if vehicle then
        PreviousDriver = lib.callback.await('wasabi_evidence:checkLastDriver', 100, VehToNet(vehicle), (track or false))
    else
        PreviousDriver = nil
    end
end)