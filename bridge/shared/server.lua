RegisterCallback('wasabi_evidence:getIdentifier', function(source, target, cb)
    cb(GetIdentifier(target))
end)

RegisterCallback('wasabi_evidence:isPlayerBoss', function(source, cb)
    cb(IsPlayerBoss(source))
end)

--[[if Config.UseMetaData.enabled then
    if Config.UseMetaData.inventory == 'custom' then
        -- Insert Custom functions here
    elseif Config.UseMetaData.inventory == 'qs' then
        if Framework == 'qb' then Config.UseMetaData.inventory = 'qb' end
        TriggerEvent('qs-core:getSharedObject', function(library) QS = library end)

        function AddMetaDataItem(source, item, count, slot, metadata)
            local Player = QS.GetPlayerFromId(source)
            Player.Functions.AddItem(item, count, slot, metadata)
            TriggerEvent('qs-inventory:addItem', source, Config.UseMetaData.item, 1, false, metadata)
        end

        function GetEvidenceBagData(source)

        end

        functon RemoveMetaDataItem(source, item, count, slot, metadata)
            xPlayer.Functions.GetItemByName(fromItemData.name:lower())]] -- COMING SOON