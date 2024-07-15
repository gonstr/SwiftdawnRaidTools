local WA_SRT_HELPER = "!WA:2!9rvZUTTrx0OQfTHOniwaXa9NfeQag2O2QoUnP4lazHPbvSlK)PK0)uuuWmKZLItd1meZmuXkfDJqx01Etx1nADxPhHUORje(Ec8JqEc6DiTeCDRkbK4mdpZ5EUN5o3gDBnOfTf9xwxkk0zmoip(0GEhCK7msHovipoxZeCL1mvkHkE93ECsIc0FY9Ms4X4NprW46O9CpkW1l3MYu5zKrbWL6WeHCarhMhQzdGBM1i)HXfkTyGbXP5uIg8GHaxFngmbcGfFoJQtD2fNkjXvH(PEknrQTIsyCMk1YbFPx7kQiSMRxgv)(YgkwIDpwKVUiYwNcClB8jtetYS3ngCnbY(5ZrSE75RT1x0z72BubU6pKLfWxqJ5HuijHaFyNknRqU(XFAXhNVLN5oicORFhSBSax4l(U27Y1mpcJgiezQWZ3nCFilhKH9eekqB)9iZAzbuThGtTm)SwWOpo9qqPi9beysbVYNwVkqBA3PtNnMNg3vW)xzZZUfTO34fy0L7z4jB7nTVl3leL1yTK1Vpivpyn5nd)th9OCOCLRvfrvB0VijHD50W921pi0pa5U8(r7dKmD6cmNibeJN)jU965uGNWrMkjqwUsUCrkg(pvcMLq9b7ZTBJk(Otp09OWGdo01R9sY3BNOljXQ1K66)oHECYaqz5fNcXVQ8(tRR7cnz7uSgvdfvL0Jv5qw2buL1ekeH5EacqUVBVt6EAVRk43ytw5RyQWhcb1ZpuqHF)E5Tx(LObcAOedWlZxB5GYG(K4rHjzcHm9kcNzUwj4pT8d6(harb(AjW7RtF3Yh5WfCygf9fdIQ8qQGybNQgBGA0D5wodimE3YnXnuUvzNYpVCB89dU7kojcUo)HDLS3y)nfekskXoiycEa7b9nxK)OvlF0mCAej(v9X2nCQtgwWF2vfkiKJoUmnstYqJFvVbfzAg60zeLA1Y)NLd6PX1dyVbmdgBINpo5dJuIczmeXgKlK6BAuDrDJQMtKvb3KkoA0Tg)AHKEUKKp(8BgCLcYsQ7J5CCqWXhoX4aS62E5F6YD6CjeZuiSM5F2YrrhHvnS4qDQeuPIm6i5OAT1qE58b)awjXsg50ZTBWeTig9cdXV3Vv2MrN57fyx3HWE4JJq1LW6BnnrIvJ4Pj6ZnFBD34UMLmPAK)EEUUhL)X)R6QEGNrE0Dky0P7CXo9(QKHVq29lFl6dGKtYoRwc)QxSiti)6M4Z0ARDVQfA0OrZj4vwGw1Y(NF)PmEnX4USMERa)oTurpPZJFsNTBn8)FXF9d"

function SwiftdawnRaidTools:WeakAurasIsInstalled()
    return WeakAuras ~= nil
end

function SwiftdawnRaidTools:WeakaurasIsHelperInstalled()
    if not self:WeakAurasIsInstalled() then
        return false    
    end 

    if not WeakAurasSaved then
        return false
    end

    for _, wa in pairs(WeakAurasSaved.displays) do
        if wa.id == "SRT Helper v1" then
            return true
        end
    end

    return false
end

function SwiftdawnRaidTools:WeakAurasInstallHelper(callback)
    if WeakAuras then
        WeakAuras.Import(WA_ANTI_RAID_TOOLS_HELPER, nil, callback)
    end
end
