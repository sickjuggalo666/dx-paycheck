ESX	= nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


if Config.UseEsExtendedType then
	RegisterNetEvent('dx-paycheck:AddMoneyEs_Extended')
	AddEventHandler('dx-paycheck:AddMoneyEs_Extended',function(xPlayer, value)
		if xPlayer ~= nil then
			MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
				['@identifier'] = xPlayer.identifier
			}, function(result)
				local paycheckbd = {}
				if result[1].paycheck ~= nil then
					paycheckbd = json.decode(result[1].paycheck)
				end
			MySQL.Async.fetchAll("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
				['@identifier'] = xPlayer.identifier,
				['@paycheck'] = paycheckbd + (value)
			})
			end)
		else 
			print(('Someone is trying to do something shady. [DX-PAYCHECK]'):format(xPlayer.identifier))
		end
	end)
end


RegisterNetEvent('dx-paycheck:AddMoney')
AddEventHandler('dx-paycheck:AddMoney',function(source, value)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			local paycheckbd = {}
			if result[1].paycheck ~= nil then
				paycheckbd = json.decode(result[1].paycheck)
			end
		MySQL.Async.fetchAll("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
			['@identifier'] = xPlayer.identifier,
			['@paycheck'] = paycheckbd + (value)
		})
		end)
	else 
		print(('Someone is trying to do something shady. [DX-PAYCHECK]'):format(xPlayer.identifier))
	end
end)


RegisterNetEvent('dx-paycheck:withdrawMoney')
AddEventHandler('dx-paycheck:withdrawMoney', function(value)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			if result[1] then
				local paycheckbd = {}
				if result[1].paycheck ~= nil then
					paycheckbd = json.decode(result[1].paycheck)
				end
				print(value)
				if paycheckbd >= value then
					MySQL.Async.execute("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
						['@identifier'] = xPlayer.identifier,
						['@paycheck'] = paycheckbd - value
					})
					if Config.ReceiveInCash == true then
						xPlayer.addMoney(value)
					else
						xPlayer.addAccountMoney('bank', value)
					end
					local msg1 = 'You collected '..value..'$'
					local type = 'success'
					TriggerClientEvent('dx-paycheck:notification',_source,msg1,type)
					sendCollectDiscord(_source,name,msg1,type)  -- will show in discord the (msg1) from above in discord E.X.("You collected $1000")
				else
					local msg2 = 'You dont have enough money to withdraw $'..value..': You Have $'..paycheckbd..'!'
					local type2 = 'error'
					TriggerClientEvent('dx-paycheck:notification',_source,msg2,type2)
					sendCollectDiscord(_source,name,msg2,type2)  -- will show in discord the (msg2) from above in discord E.X.("You dont have enough money to withdraw $10000: You Have $4000!")
				end
			end
		end)
	else
		print(('Someone is trying to do something shady. [DX-PAYCHECK]'):format(xPlayer.identifier))
	end
end)

ESX.RegisterServerCallback('dx-paycheck:server:GetDataMoney', function(source,cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll("SELECT `paycheck` FROM users WHERE identifier = @identifier", {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			if result[1] ~= nil then
				local paycheckdata = {}
				if result[1].paycheck ~= nil then
					paycheckdata = json.decode(result[1].paycheck)
				end
				cb(paycheckdata)
			end	
		end)
	end
end)

RegisterNetEvent("dx-paycheck:Payout")
AddEventHandler("dx-paycheck:Payout", function()
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
				local paycheckbd = {}
				if result[1].paycheck ~= nil then
					paycheckbd = json.decode(result[1].paycheck)
				end
				if paycheckbd > 0 then
					MySQL.Async.execute("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
						['@identifier'] = xPlayer.identifier,
						['@paycheck'] = 0
					})
					if Config.ReceiveInCash == true then
						xPlayer.addMoney(paycheckbd)
					else
						xPlayer.addAccountMoney('bank', paycheckbd)
					end
					local msg3 = 'Your paycheck Totaled: $'..paycheckbd..'!'
					local type3 = 'success'
					TriggerClientEvent('dx-paycheck:notification',_source,msg3,type3)
					sendCollectDiscord(_source,name,msg3,type3)
				else
					local msg4 = 'You don\'t have anything to collect.'
					local type4 = 'error'
					TriggerClientEvent('dx-paycheck:notification',_source,msg4,type4)
				end
		end)
	else
		print(('Someone is trying to do something shady. [DX-PAYCHECK]'):format(xPlayer.identifier))
	end
end)

sendCollectDiscord = function(color, name, message, footer)			--Added webhooks to track the collection or (lack of collection) in discord for easier monitoring for Admins
	local embed = {
		  {
			  ["color"] = 3085967,
			  ["title"] = "**".. name .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
			  ["author"] = {
				["name"] = 'Made by | SickJuggalo666',
				['icon_url'] = 'https://i.imgur.com/arJnggZ.png'
			  }
		  }
	  }
  
	PerformHttpRequest(Config.Discord_url, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end