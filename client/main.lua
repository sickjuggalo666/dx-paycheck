local paycheckdata
ESX = nil



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
    ESXLoaded = true
end)

Citizen.CreateThread(function()
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


RegisterNetEvent('dx-paycheck:Menu')
AddEventHandler('dx-paycheck:Menu',function()
	OpenPaycheckMenu()
end)

function OpenPaycheckMenu()
		local OpenPaycheckMenu = {
			{
            	id = 1,
            	header = Config.Header,
            	txt = Config.Text
        	},
			{
				id = 2,
				header = Config.WithdrawAll,
				txt = Config.WithdrawText,
				params = {
					event = 'JD_Evidence:confirmorcancel',
					args = {
						selection = "confirm",
						inventory = inventoryID
					}
				}
			},
			{
				id = 3,
				header = Config.EnterAmount,
				txt = Config.AmountText,
				params = {
					event = 'JD_Evidence:confirmorcancel',
					args = {
						selection = "cancel"
					}
				}
			}
		}

		exports['zf_context']:openMenu(OpenPaycheckMenu)

end
