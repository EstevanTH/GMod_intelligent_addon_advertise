local workshop_command = "!workshop"

hook.Add( "PlayerSay", "intelligent_addon_advertise", function( sender, text )
	if text == workshop_command then
		sender:SendLua( "intelligent_addon_advertise()" )
		return ""
	end
end )
