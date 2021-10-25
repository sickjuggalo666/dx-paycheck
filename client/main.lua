local paycheckdata
ESX = nil



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
    ESXLoaded = true
end)

--- IF NOT USING BT-TARGET OR QTARGET HASH THIS SECTION and unhash the section after it!

--[[Citizen.CreateThread(function()
	local PedsTarget = {}
	for k,v in pairs (Config.NPCS) do
		PedsTarget = {v.model}
	end
	exports[Config.Target]:AddTargetModel(PedsTarget, {
		options = {
			{
				event = "dx-paycheck:Menu",
				icon = "fas fa-car",
				label = "Collect salary",
			},
			
		},
		job = {"all"},
		distance = 3.5
	})
end)]]

		--- FIVEM TARGET HERE!!!! Make sure to hash out this WHOLE section if you with to use Bt-target or Qtarget!

		Citizen.CreateThread(function()				

			for k,v in pairs(Config.NPCS) do												  
				exports["fivem-target"]:AddTargetModel({   
					name = "payroll",
					label = "Payroll",
					icon = "fas fa-car",
					model = GetHashKey(v.model),  --- currently only allows for the one model.. BUT i am working out ways to pull more than ONE hash!
					interactDist = 2.0,
					onInteract = payCheck,
					options = {
				{
					name = "paycheck",
					label = "PayCheck"
				}
				},
					vars = {}
				})
			end														   
		end)														  
																			 
		payCheck = function(targetname,optionName,vars,entityhit)	
			if optionName == "paycheck" then					   
				OpenPaycheckMenu() 								  
			end													 
		end													
				--]]
				
		RegisterNetEvent('dx-paycheck:Menu')
		AddEventHandler('dx-paycheck:Menu',function()
			OpenPaycheckMenu()
		end)
				
		Citizen.CreateThread(function()
			if Config.BlipActive then
				for k,v in ipairs(Config.BlipCoords) do
				local blip = AddBlipForCoord(v.x, v.y, v.z)
				SetBlipSprite(blip, v.BlipID)
				SetBlipDisplay(blip, 4)
				SetBlipScale(blip, v.BlipScale)
				SetBlipColour(blip, v.BlipColor)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.BlipName)
				EndTextCommandSetBlipName(blip)
				end
			end
		end)
				
		Citizen.CreateThread(function()
			Citizen.Wait(100)
			for k,v in pairs (Config.NPCS) do
			while not ESXLoaded do Wait(0) end
				if DoesEntityExist(ped) then
					DeletePed(ped)
				end
				Wait(250)
				ped = CreatingPed(v.model, v.coords, v.heading, v.animDict, v.animName)
			end
		end)
				
		function CreatingPed(hash, coords, heading, animDict, animName)
			RequestModel(GetHashKey(hash))
			while not HasModelLoaded(GetHashKey(hash)) do
				Wait(5)
			end
		
			local ped = CreatePed(5, hash, coords, false, false)
			SetEntityHeading(ped, heading)
			SetEntityAsMissionEntity(ped, true, true)
			SetPedHearingRange(ped, 0.0)
			SetPedSeeingRange(ped, 0.0)
			SetPedAlertness(ped, 0.0)
			SetPedFleeAttributes(ped, 0, 0)
			FreezeEntityPosition(ped, true) 
			SetEntityInvincible(ped, true) 
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetPedCombatAttributes(ped, 46, true)
			SetPedFleeAttributes(ped, 0, 0)
			while not TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, -1, 17, 0, 0, 0, 0) do
				Wait(1000)
			end
			return ped
		end
				
		function OpenPaycheckMenu()
					local paycheckMenu = {   -- ZF_Context Menus for a cleaner look!
						{
							id = 1,
							header = Config.Header,
							txt = Config.Text -- Testing this to see if it will work with ZF_ContextMenus!
						},
						{
							id = 2,
							header = Config.WithdrawAll,
							txt = Config.WithdrawText,
							params = {
								event = 'dx-paycheck:withdrawAll',
							}
						},
						{
							id = 3,
							header = Config.EnterAmount,
							txt = Config.AmountText,
							params = {
								event = 'dx-paycheck:enterAmount',
							}
						},
					}
					exports['zf_context']:openMenu(paycheckMenu)
		end
				
		RegisterNetEvent('dx-paycheck:withdrawAll')
		AddEventHandler('dx-paycheck:withdrawAll', function()
			local disableControls = {30,31,32,33,34,35,18}
				exports['progbars']:StartProg(5000, 'Cashing Out...',disableControls) -- progbars are a free ModFreakZ Script available at https://modit.store/products/mf-progress-bars?variant=31748599185485
				Citizen.Wait(5000)
				TriggerServerEvent('dx-paycheck:Payout')
		end)
				
		RegisterNetEvent('dx-paycheck:enterAmount')
		AddEventHandler('dx-paycheck:enterAmount', function()
			local dialog = exports['zf_dialog']:DialogInput({  -- ZF_Dialog for entering a said amount to withdraw!
				header = "City Hall", 
				rows = {
					{
						id = 0, 
						txt = "Enter Amount(#)",
					},
				}
			})
					
			if dialog ~= nil then
				if dialog[1].input == nil then
						ESX.ShowNotification('Invalid Entry Made.')
				else
					local count = tonumber(dialog[1].input)
					local disableControls = {30,31,32,33,34,35,18}
						exports['progbars']:StartProg(5000, 'Cashing Out...',disableControls) -- progbars are a free ModFreakZ Script available at https://modit.store/products/mf-progress-bars?variant=31748599185485
						Citizen.Wait(5000)
						TriggerServerEvent('dx-paycheck:withdrawMoney', count)
				end
			end
		end)
