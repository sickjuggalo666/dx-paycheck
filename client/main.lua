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
	local model GetEntityModel(PlayerPedId())

	exports["fivem-target"]:AddTargetModel({
  		name = "payroll",
  		label = "Payroll",
  		icon = "fas fa-car",
  		model = GetHashKey('cs_bankman'),
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
end)

payCheck = function(targetName,optionName,vars,entityHit)
	if optionName == "paycheck" then
		OpenPaycheckMenu()
	end
end

Citizen.CreateThread(function()
	if Config.BlipActive then
		for k,v in ipairs(Config.BlipCoords) do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, Config.BlipID)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.5)
		SetBlipColour(blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.BlipName)
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
	local paycheckMenu = {
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
		exports['progbars']:StartProg(5000, 'Cashing Out...',disableControls)
		Citizen.Wait(5000)
		TriggerServerEvent('dx-paycheck:Payout')
end)

RegisterNetEvent('dx-paycheck:enterAmount')
AddEventHandler('dx-paycheck:enterAmount', function()
	local dialog = exports['zf_dialog']:DialogInput({
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
				exports['progbars']:StartProg(5000, 'Cashing Out...',disableControls)
				Citizen.Wait(5000)
				TriggerServerEvent('dx-paycheck:withdrawMoney', count)
		end
	end
end)