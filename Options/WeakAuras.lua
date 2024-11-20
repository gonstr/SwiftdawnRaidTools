local WA_SRT_HELPER = "!WA:2!9rvZUTTrq4O6dPHOTWvaXa9NdeQagoOPcjUjPabniv0GQ2fY)us6F6jMLChkUnK7sS7sfRu0lc9qpRl9uVOZ9KEe6HCMWOpb(ripbDwszbx3QUasCMDNDMV5BMDA1VDEBAB6VULuuQZyCqE4Xbd27ax55hMKOaDl54fcZj84uH8ibJRJ2X9GaxVcBktvKrghaNRdteYCIoSiuZYHfATkwpUuPf5gloUGs0Ghmc46ljL4Uenl(ugvN60dvLKyntWvpXtPjsTLdJZ0BoLkcB8XlIA(EERVMLypGf5RlJS1Pa3YgxzIysMDVyW1ea7NDLfB15Q9(IVS7d6CVAJR)d9YsZx6gZIukjHaFu3ASQqF9t)8YdV6kp1npcOBDdBBCpWPwMFwlp1hv3hukYqaDxsjVox3Q(s33UB3U37kiDZG))HSNEn3UvhFVGWt7f6EcwD6CF7B67fGkkb5vvQ1eTKnCiivFWMYfIVXrpUaQw)svzu9T9ltsyNppCNE(bH(b98cQUt0UajtNU0MJKaAJN)rUdg4uILSitlbiBovDjIOdoEF3dcd2BFxVjQcilBpQYAEt1m0eY5yfxdLnniXPq8lRUJhNKdkRQ1lKlPRW)DwHmg0uWFMDN)zS6ScU76K2kiPzuicZ9aeBYDDhCu)JhmTKVGMSk(qtR6iiOrFFbf(JBv0z1VgYf0qjMBVOyZvBugmKepomjtiKPtELqspvskMC6cbNebxxSEFj712FFjHI(JyhemdRdEWqZdNpEJQ7EbQgrIF5q8fnN6Kji0tMwQGqoMPY0injdt4n8YlZ0mlV4mIsTr1JSCW6sCJa71GryIjE(OYhfPeLYyiILxiK6luPeQ4vN1mxyTzY6GBykhnMutjCM5HTG)KQ3VF1DD4co8Narb(AjWhQtV9fuSsySOU2lvqSGtvtm2yCt1ZDYjmoE3QNx9n3UQxLt1oOy7BUZcK8dni5tV1mSpeO1du(L3R4ZwntxiHyMcbWAfF(QTIog7azXH6ujOsfz0XZVMXVZf4imCG4Hf1dTSK)i2oZsg7mWTFWmTigPBtiE3FVQdJEb(20Exidtx7rpC7sgD(2NT9GVkz03k7)O5jsSxh5hSKU2BBg023SLHoI83XZ19GIp5)ePncEgatJqEmHn06T4iAqYjzN0aHFZlwKjKF3A4AEdNTt9gTA1ATzgYN1KdZz8g)HAwtvqwsZ4ENddcoC)2QOh39HpU7dAp6Vo7V)d"


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
        WeakAuras.Import(WA_SRT_HELPER, nil, callback)
    end
end
