if GetResourceState('ox_core') ~= 'started' or not Ox then return end
Framework = 'ox'

function HasGroup(filter)
    return player.hasGroup(filter)
end