-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local timeouts = {}

function SetTimeout(msec, cb)
    timeouts[#timeouts + 1] = {
        time = GetGameTimer() + msec,
        cb = cb
    }
    return #timeouts
end

function ClearTimeout(i)
    timeouts[i] = nil
end

function GetIdentifier(target)
    ServerCallback('wasabi_evidence:getIdentifier', function(identifier)
        return identifier
    end)
end

function IsPlayerBoss()
    local isBoss = ''
    ServerCallback('wasabi_evidence:isPlayerBoss', function(boss)
        isBoss = boss
    end)
    while isBoss == '' do Wait() end
    return isBoss
end
