# Paycheck System
Paycheck System script for ESX made by Dessaux

# Discord
Join here to report bugs or ask for help
https://discord.gg/tbZEuU2Zmm

# Features: 
* Configurable Model for the NPC and Animation
* Added multiples NPC's and multiples Blips for the paycheck system
* Added an option to get the paycheck on cash or bank
* Added an option for multiples notification systems, configurable in the config.lua
* Adding an option to withdraw all or not
* Showing the money in the interface


# Trigger
The trigger used for adding the quantity its:
* Server Side
"TriggerEvent('dx-paycheck:AddMoney',source, salary)"
* Client Side
"TriggerClientEvent('dx-paycheck:AddMoney', salary)"

If you want to make it for the es_extended you have to make some adjustments for the trigger
To make it simple you can go to my discord and write me there if you want to do it.

# Video preview:
https://streamable.com/5bsib9

# Download link:

https://forum.cfx.re/t/release-free-esx-multi-paychecks-with-qtarget-and-rprogress/4238490/


## 10/25/2021 ##
__SickJuggalo666__

Added ZF Context and Dialog! Config options for the text to set anyway you want easily! 
FiveM-Target support look in client.lua for more info on how to use or how to use BT-Target or QTarget!
added `exports['dx-paycheck']:OpenPaycheckMenu()` to add to any script where you would like people to be able to open their checks! think PD or EMS

## For ES EXTENDED Paychecks! ##



ESX.StartPayCheck = function()
	function payCheck()
		local xPlayers = ESX.GetPlayers()

		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			local job     = xPlayer.job.grade_name
			local salary  = xPlayer.job.grade_salary
			
			if salary > 0 then
				if job == 'unemployed' then -- unemployed
					--xPlayer.addAccountMoney('bank', salary)                                         -- this will remove the Direct Deposit to bank!
					TriggerEvent('dx-paycheck:AddMoneyEs_Extended',xPlayer, salary)                   -- this will send the money to the paycheck 
					TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_MAZE', 9)
				elseif Config.EnableSocietyPayouts then -- possibly a society
					TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
						if society ~= nil then -- verified society
							TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
								if account.money >= salary then -- does the society money to pay its employees?
									--xPlayer.addAccountMoney('bank', salary)                          -- this will remove the Direct Deposit to bank!
									TriggerEvent('dx-paycheck:AddMoneyEs_Extended',xPlayer, salary)    -- this will send the money to the paycheck 
									account.removeMoney(salary)

									TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary, 'CHAR_BANK_MAZE', 9)

								else
									TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
								end
							end)
						else -- not a society
							--xPlayer.addAccountMoney('bank', salary)                                   -- this will remove the Direct Deposit to bank!
							TriggerEvent('dx-paycheck:AddMoneyEs_Extended',xPlayer, salary)             -- this will send the money to the paycheck 
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_MAZE', 9)
						end
					end)
				else -- generic job
					--xPlayer.addAccountMoney('bank', salary)                                           -- this will remove the Direct Deposit to bank!
					TriggerEvent('dx-paycheck:AddMoneyEs_Extended',xPlayer, salary)                     -- this will send the money to the paycheck 
					TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_MAZE', 9)
				end
			end

		end

		SetTimeout(Config.PaycheckInterval, payCheck)
	end

	SetTimeout(Config.PaycheckInterval, payCheck)
end