-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

-----------------------------
-- Customize Notifications --
-----------------------------
RegisterNetEvent('wasabi_evidence:notify', function(title, desc, style, icon) -- Edit notifications here with custom notification system
    if icon then
        lib.notify({
            title = title,
            description = desc,
            duration = 3500,
            icon = icon,
            type = style
        })
    else
        lib.notify({
            title = title,
            description = desc,
            duration = 3500,
            type = style
        })
    end
end)

-----------------------
-- Customize Text UI --
-----------------------
function ShowTextUI(msg)
    lib.showTextUI(msg) -- Replace this with your custom text UI function/event?
end

function HideTextUI()
    lib.hideTextUI() -- Replace this with your custom text UI function/event?
end

----------------------
-- Customize Target --
----------------------
AddEventHandler('wasabi_evidence:addTarget', function(d)
    if d.targetType == 'AddBoxZone' then
        exports.qtarget:AddBoxZone(d.identifier, d.coords, d.width, d.length, {
            name=d.identifier,
            heading=d.heading,
            debugPoly=false,
            minZ=d.minZ,
            maxZ=d.maxZ,
            useZ = true,
        }, {
            options = d.options,
            job = (d.job or false),
            distance = d.distance,
        })
    elseif d.targetType == 'Player' then
        exports.qtarget:Player({
            options = d.options,
            job = (d.job or false),
            distance = d.distance,
        })
    elseif d.targetType == 'Vehicle' then
        exports.qtarget:Vehicle({
            options = d.options,
            job = (d.job or false),
            distance = d.distance
        })
    elseif d.targetType == 'Model' then
        exports.qtarget:AddTargetModel(d.models, {
            options = d.options,
            job = (d.job or false),
            distance = d.distance,
        })
    end
end)


-------------------------------------------------------------------------------------------------
-- Function for the blood type example in custom parameters for evidence (QBCore Only Example) --
-------------------------------------------------------------------------------------------------
local function GetBloodTypeFromCitizenId(citizenid)
    local bloodtype = lib.callback.await('wasabi_evidence:getBloodType', 100)
    if not bloodtype then return false else return bloodtype end
end

--------------------------------------------------------------------------------
-- Add additional parameters for more information provided in evidence report --
--------------------------------------------------------------------------------
function OpenEvidenceReport(data, openStorage, openHand, printScan) -- Add additional parameters in config to pull here:
    local date, time = lib.callback.await('wasabi_evidence:getDateAndTime', 100, data.time)
    local reportData = Config.EvidenceReportData
    local options, d = {}, nil
    if openStorage then
        options[#options + 1] = {
            title = Strings.go_back,
            event = 'wasabi_evidence:accessEvidenceStorage'
        }
    elseif printScan then
        options[#options + 1] = {
            title = Strings.go_back,
            event = 'wasabi_evidence:fingerprintNearbyPlayer',
            args = openHand
        }
    elseif openHand then
        options[#options + 1] = {
            title = Strings.go_back,
            event = 'wasabi_evidence:accessEvidenceHand',
            args = openHand
        }
    end
    if data.evidence == 'blood' then d = 'blood' elseif data.evidence == 'print' then d = 'print' else d = 'bullet' end
    for i=1, #reportData[d] do
        local e = reportData[d][i]
        if e.parameter == 'name' then
            if d ~= 'blood' then
                if data.prints then
                    options[#options + 1] = {
                        title = e.label,
                        description = data.owner,
                        event = ''
                    }
                else
                    options[#options + 1] = {
                        title = e.label,
                        description = Strings.not_in_system,
                        event = ''
                    }
                end
            else
                options[#options + 1] = {
                    title = e.label,
                    description = data.owner,
                    event = ''
                }
            end
        elseif e.parameter == 'location' then
            options[#options + 1] = {
                title = e.label,
                description = data.street,
                event = ''
            }
        elseif e.parameter == 'date' then
            options[#options + 1] = {
                title = e.label,
                description = date,
                event = ''
            }
        elseif e.parameter == 'time' then
            options[#options + 1] = {
                title = e.label,
                description = time,
                event = ''
            }
        elseif e.parameter == 'plate' then
            options[#options + 1] = {
                title = e.label,
                description = data.plate,
                event = ''
            }
        elseif e.parameter == 'guntype' then
            options[#options + 1] = {
                title = e.label,
                description = data.evidence,
                event = ''
            }
        elseif e.parameter == 'bloodtype' then -- Example of a custom parameter
            -- Example of a custom parameter (Works out of box for QBCore)
            local bloodType = GetBloodTypeFromCitizenId(data.identifier)
            if not bloodType then return end
            options[#options + 1] = { -- This will be the option field shown in context that will be created for parameter
                title = e.label, -- d.label = the label option you defined with your parameter
                description = bloodType,
                event = ''
            }
        elseif e.parameter == 'custom' then -- Example of a custom parameter
            -- Can add some logic here for obtaining information needed
            -- Information in data table:
            --      * 'identifier' (Citizen ID for QBCore / Identifier for ESX)
            --      * 'evidence' (Will return 'blood' for blood evidence or the weapon type of bullet from `configuration/strings.lua`)
            --      * 'coords' (Vector3 of coords where evidence was found)
            --      * 'interior' (Interior ID or 0/nil/false if outside)
            --      * 'time' (os time of server when evidence dropped)
            --      * 'owner' (Character first / last name of who dropped evidence)
            --      * 'street' (Location info of where evidence dropped, street names & area name / see Zones table in `configuration/config.lua`)
            options[#options + 1] = { -- This will be the option field shown in context that will be created for parameter
                title = e.label, -- d.label = the label option you defined with your parameter
                description = data.identifier, -- Example of utilizing the 'data' table
                event = ''
            }
        end
    end
    if Config.BossCanDeleteStorage then
        if IsPlayerBoss() then
            options[#options + 1] = {
                title = Strings.delete_evidence,
                description = (Strings.delete_evidence_desc):format(data.id),
                event = 'wasabi_evidence:deleteEvidence',
                args = data.id
            }
        end
    end
    lib.registerContext({
        id = 'evidence_report',
        title = (Strings.evidence_report):format(data.id),
        options = options
    })
    lib.showContext('evidence_report')

end