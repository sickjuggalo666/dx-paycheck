Config = {}
Config.ReceiveInCash = true -- If its in true, you'll recieve it on cash (wallet), false it will become on bank.
Config.UseEsExtendedType = true -- IF true, enable the trigger so you can place it in your es_extended, false it will disable it
Config.WithdrawQuantity = true
Config.Timeout = 5000 -- Timeout for the citizen, briefly, 5 secs.
Config.Target = 'qtarget' -- Config your exports target (bt-target or qtarget) -- suppors FiveM-Target as well!! Check Client.lua for more info!

Config.Header = "City Hall"
Config.WithdrawAll = "Withdraw All?"
Config.WithdrawText = "Collect all the paycheck"
Config.EnterAmount = "Withdraw Amount?"
Config.AmountText = "Enter a Select amount"

Config.Discord_url = ""  --- I spaced out adding this config option for webhooks!! my mistake

Config.NPCS =  {
    {
        model = "cs_bankman",
        coords = vector3(-552.90313720703,-192.07667541504,37.219646453857),  
        heading = 209.4,
        animDict = "amb@world_human_cop_idles@male@idle_b",
        animName = "idle_e"
    },
    -- {
    --      model = "cs_bankman", -- https://wiki.rage.mp/index.php?title=Peds
    --      coords = vector3(0,0,0),  -- coords
    --      heading = 0.0 -- heading
    --      animDict = "", -- https://pastebin.com/6mrYTdQv
    --      animName = "" -- https://alexguirre.github.io/animations-list/
    -- }
}

Config.BlipActive = true

Config.BlipCoords = { -- fixed the blips FOR SURE this time lol
    {BlipName = "Paycheck PickUp", BlipID = 525, BlipScale = 0.5, x = -552.86126708984, y = -191.00524902344, z = 37.219673156738, BlipColor = 5}, -- messed up blip. fixed now i apologize
}

--	Your Notification System
RegisterNetEvent('dx-paycheck:notification')
AddEventHandler('dx-paycheck:notification', function(msg,type)
--	Types used: (error | success)
	--exports['mythic_notify']:DoHudText(type,msg)
    -- ESX.ShowNotification(msg)
    -- exports['dopeNotify3']:Alert("City Hall", msg, 5000, type)
    exports.brinnNotify:SendNotification({                    
        text = '<b><i class="fas fa-bell"></i> NOTIFICACIÓN</span></b></br><span style="color: #a9a29f;">'..msg..'',
        type = type,
        timeout = 3000,
        layout = "centerRight"
    })
end)
