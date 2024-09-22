hook.Add(
    "PlayerCanSeePlayersChat",
    "MRPChat",
    function(text, teamOnly, listener, speaker)
        if string.sub(text, 1, 4) == "/ooc" then
            return true
        elseif string.sub(text, 1, 6) == "/radio" then
            return listener:MRPFaction()==speaker:MRPFaction()
        elseif string.sub(text, 1, 1) == "@" then
            return listener:IsAdmin() and speaker:IsAdmin()
        else
            local spkPos = speaker:GetPos()
            local lstnrPos = listener:GetPos()
            local distance = spkPos:Distance(lstnrPos)
            return distance < 500
        end
    end
)

