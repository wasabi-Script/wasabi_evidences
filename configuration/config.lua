-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local minutes, seconds = 60000, 1000
Config = {}

----------------------
-- General Settings --
----------------------
Config.PoliceJobs = { -- Police jobs/grades able to use evidence system
    ['police'] = 0, -- ['JOB_NAME'] = GRADE_LEVEL
--  ['sheriff'] = 2 -- Example
}
Config.CriminalsCanCleanEvidence = {
    enabled = false, -- Criminals are able to clean up bullets/blood when enabled
    requiredBloodCleanItem = 'bleachwipes', -- Item name required in inventory for criminals to wipe blood evidence
    removeBloodCleanItemOnUse = true, -- Remove item when clean blood
}
Config.MaxEvidence = 5 -- Max evidence that can be collected at once prior to going to evidence lab for analyzing
Config.FlashlightRange = 15 -- Default: 15 / Distance one can see evidence with flashlight (MUST BE ABOVE 2)
Config.AutoDestroy = 5 * minutes -- Auto destory evidence after so long (Default 5 * minutes / Set to false if no destroy)
Config.BloodProps = true -- Have prop on ground for blood splatter
Config.BossCanDeleteStorage = true -- Boss ranks can delete storage from storage(If enabled)

-----------------------
-- Evidence Settings --
-----------------------
Config.AnalyzingTime = 6 * seconds -- Time it takes to analyze evidence at the crime lab

Config.VehicleFingerPrinting = {
    enabled = true, -- Enable finger printing vehicle steering wheel?
    requiredItem = 'uvlight',
    removeOnUse = false -- Remove the finger printing device on use
}

Config.Gloves = {
    enabled = false, -- Enable ability for defined gloves to conceal identity of player for all evidence except blood
    hands = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,112,114}, -- Define all ids that are hands, or set to false and set all gloves(must be set to false to set gloves)
    gloves = {} -- if hands above is set to false, script will check this table for if wearing gloves
}

Config.BlacklistedWeapons = {
--  [`WEAPON_SHOTGUN`] = true, -- example
    [`WEAPON_STUNGUN`] = true, -- Add additional weapons in same syntax
}

Config.EvidenceReportData = { -- Data it provides in evidence reports
    -- Add custom parameters if desired and accomodate them in `client/cl_customize.lua` under OpenEvidenceReport()
    -- You can remove/add any of these OR re-order them to display to your likings!
    blood = { -- Will be displayed in evidence report in order they are placed in index
        {
            parameter = 'name', -- Argument for OpenEvidenceReport() function
            label = 'Name' -- Label to describe on form
        },

        {
            parameter = 'location', -- Street name(s) and zone names(defined in the Zones table of config.lua)
            label = 'Location'
        },

        {
            parameter = 'date', -- Server date of evidence drop
            label = 'Date'
        },

        {
            parameter = 'time', -- Server time of evidence drop
            label = 'Time'
        },

        {
            parameter = 'lab', -- Crime lab that processed evidence
            label = 'Crime Lab'
        },

--      {
--          parameter = 'bloodtype', -- Example of a custom parameter named 'bloodtype'
--          label = 'Blood Type' -- Using custom logic labeled in `client/cl_customize.lua` under GetBloodTypeFromCitizenId(citizenid) function (Works out of box if uncommented AND running QBCore)
--      },

--      {
--          parameter = 'custom', -- Example of a custom parameter named 'custom'
--          label = 'License #' -- Using logic from the 'data' table in `client/cl_customize.lua` under OpenEvidenceReport() function of identifier/citizenid
--      },


    },

    bullet = { -- Will be displayed in evidence report in order they are placed in index
        {-- Now only shows name if they have had their prints scanned at finger print station previously
            parameter = 'name', -- Argument for OpenEvidenceReport() function
            label = 'Name:' -- Label to describe on form
        },
        {
            parameter = 'guntype',
            label = 'Bullet Type'
        },
        {
            parameter = 'location',
            label = 'Location'
        },
        {
            parameter = 'date',
            label = 'Date'
        },
        
        {
            parameter = 'time',
            label = 'Time'
        },

        {
            parameter = 'lab', -- Crime lab that processed evidence
            label = 'Crime Lab'
        },

--      {
--          parameter = 'custom', -- Example of a custom parameter named 'custom'
--          label = 'License #' -- Using logic from the 'data' table in `client/cl_customize.lua` under OpenEvidenceReport() function of identifier/citizenid
--      },
    },
    print = { -- Evidence related to finger prints
        {-- Now only shows name if they have had their prints scanned at finger print station previously
            parameter = 'name', -- Argument for OpenEvidenceReport() function
            label = 'Name:' -- Label to describe on form
        },
        {
            parameter = 'plate',
            label = 'License Plate'
        },
        {
            parameter = 'location',
            label = 'Location'
        },
        {
            parameter = 'date',
            label = 'Date'
        },
        
        {
            parameter = 'time',
            label = 'Time'
        },

        {
            parameter = 'lab', -- Crime lab that processed evidence
            label = 'Crime Lab'
        },

--      {
--          parameter = 'custom', -- Example of a custom parameter named 'custom'
--          label = 'License #' -- Using logic from the 'data' table in `client/cl_customize.lua` under OpenEvidenceReport() function of identifier/citizenid
--      },
    },

}

---------------
-- Locations --
---------------
Config.EvidenceLabs = { -- Locations where Config.PoliceJobs can analyze evidence

-- Copy starting here to add new location
    LSPD = {

        label = 'LSPD', -- Label to display during certain situations/notifications

        analyze = {
            coords = vec3(483.63, -987.9, 30.68), -- Coords for location(If target is not enabled)
            range = 1.8, -- Range to show TextUI (If target is not enabled)
            label = '[E] - Analyze Evidence', -- TextUI string(If target is not enabled)
            target = {
                enabled = false, -- Enable Target? (Can be customized in cl_customize.lua the target system)
                label = 'Analyze Evidence',
                coords = vec3(483.63, -987.9, 30.68),
                heading = 181.42,
                width = 2.0,
                length = 1.0,
                minZ = 30.68-0.9,
                maxZ = 30.68+0.9
            }
        },

        fingerprinting = {
            enabled = true, -- Enable a finger printing station. By default this will be used to reveal any 'unknown' fingerprints that are ran through the system.
            coords = vec3(473.24, -1007.58, 26.26), -- Coords for location(If target is not enabled)
            range = 1.8, -- Range to show TextUI (If target is not enabled)
            label = '[E] - Take Suspect\'s Fingerprints', -- TextUI string(If target is not enabled)
            target = {
                enabled = false, -- Enable Target? (Can be customized in cl_customize.lua the target system)
                label = 'Take Suspect\'s Fingerprints',
                coords = vec3(473.24, -1007.58, 26.26),
                heading = 357.17,
                width = 2.0,
                length = 1.0,
                minZ = 26.26-0.9,
                maxZ = 26.26+0.9
            }
        },

        storage = {
            enabled = true, -- Enable archive access in-game via storage location?
            coords = vec3(480.84, -984.55, 30.68), -- Coords for location(If target is not enabled)
            range = 1.8, -- Range to show TextUI (If target is not enabled)
            label = '[E] - Access Evidence Storage', -- TextUI string(If target is not enabled)
            target = {
                enabled = false, -- Enable Target? (Can be customized in cl_customize.lua the target system)
                label = 'Access Evidence Storage',
                coords = vec3(480.84, -984.55, 30.68),
                heading = 87.87,
                width = 2.0,
                length = 1.0,
                minZ = 30.68-0.9,
                maxZ = 30.68+0.9
            }
        },
                         ---------------------------------------------------------------------------------------------------------------------
        jobLock = false, -- Put job here if want this specific crime lab locked to only one job (Must be job listed in 'Config.PoliceJobs', --
                         -- leave as false if all Config.PoliceJobs can access)                                                             --
                         -- Can be string (ex. 'police' or table ex. {'police', 'sheriff'})                                                 --
                         ---------------------------------------------------------------------------------------------------------------------
    },
-- Stop copying here and paste below, and rename LSPD to something else and re-configure for additional locations


}   

-----------------------------------------------------------------
-- Don't Touch Anthing Under This (Except maybe to translate?) --
-----------------------------------------------------------------

Zones = {
    ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo",
    ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon",
    ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge",
    ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills",
    ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis",
    ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert",
    ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights",
    ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society",
    ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack",
    ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir",
    ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta",
    ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo",
    ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean",
    ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands",
    ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach",
    ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track",
    ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row",
    ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal",
    ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci",
    ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", 
    ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz"
}
