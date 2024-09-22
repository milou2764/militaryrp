local nColor = Color(255,255,255)

hook.Add("OnPlayerChat", "MRPChatClient", function(ply, text, teamChat, isDead)
    if IsValid(ply) then
        if string.sub(text, 1, 4) == "/ooc" then
            text = string.sub(text, 5, #text)
            chat.AddText(
                Color(255,0,255), "(OOC) ",
                nColor, ply:MRPName(), ": ",
                text
            )

            return true
        elseif string.sub(text, 1, 6) == "/radio" then
            text = string.sub(text, 8, #text)
            chat.AddText(
                Color(255,0,0), "(RADIO) ",
                nColor, ply:MRPName(), ": ",
                text
            )

            return true
        elseif string.sub(text, 1, 1) == "@" then
            text =  string.sub(text, 2, #text)
            chat.AddText(
                Color(255,255,0), "(STAFF) ",
                nColor, ply:Nick(), ": ",
                text
            )

            return true

        else
            chat.AddText(
                nColor, ply:MRPName(), ": ",
                text
            )
            return true
        end
    end
end)
