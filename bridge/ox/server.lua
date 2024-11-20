if GetResourceState('ox_core') ~= 'started' or not Ox then return end
Framework = 'ox'

function GetPlayer(source)
    return Ox.GetPlayer(source)
end

function HasGroup(source, filter)
    local player = GetPlayer(source)
    ---@diagnostic disable-next-line: missing-parameter
    return player.hasGroup(filter)
end

function RegisterUsableItem(item, cb)
    ---@diagnostic disable-next-line: redefined-local
    exports(item, function(event, item, inventory, slot, data)
        if event ~= 'usedItem' then return end
        cb(item, inventory, slot, data)
    end)
end

function AddItem(source, item, count, slot, metadata)
    return exports.ox_inventory:AddItem(source, item, count, metadata, slot)
end

function RemoveItem(source, item, count, slot, metadata)
    return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
end

function AddMoney(source, type, amount)
    if type == 'money' then
        return exports.pefcl:addCash(source, amount)
    end

    exports.pefcl:addBankBalance(source, { amount = amount })
end

function RemoveMoney(source, type, amount)
    if type == 'money' then
        return exports.pefcl:removeCash(source, amount)
    end

    exports.pefcl:removeBankBalance(source, { amount = amount })
end