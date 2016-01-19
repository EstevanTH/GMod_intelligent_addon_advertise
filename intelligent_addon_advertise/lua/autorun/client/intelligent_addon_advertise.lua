local addons_list = {
}
local advertise_delay = 300
local color_msg = Color( 255,64,0 )
local color_command = Color( 255,160,128 )
local collection_url = "http://steamcommunity.com/sharedfiles/filedetails/?id=561712523"

do
	local function SVN_subscribed_or_server_Workshop( vehiclescript )
		if file.Exists( vehiclescript, "GAME" ) then
			return true
		end
		return false
	end
	local id, vehiclescript, subscribed
	for i,v in ipairs( addons_list ) do
		id = v[1]
		vehiclescript = v[2]
		subscribed = ( id and string.len( id )!=0 and steamworks.IsSubscribed( id ) )
		subscribed = ( subscribed or ( vehiclescript and string.len( vehiclescript )!=0 and SVN_subscribed_or_server_Workshop( vehiclescript ) ) )
		if !subscribed then
			local function advertise()
				chat.AddText( color_msg, "You have missing addons. Type ", color_command, "!workshop", color_msg, " in chat and install them!" )
			end
			timer.Create( "intelligent_addon_advertise", advertise_delay, 0, advertise ) -- advertise every advertise_delay seconds
			hook.Add( "PostRenderVGUI", "intelligent_addon_advertise", function()
				advertise() -- advertise when the game is just loaded
				hook.Remove( "PostRenderVGUI", "intelligent_addon_advertise" )
			end )
			break
		end
	end
end

function intelligent_addon_advertise()
	gui.OpenURL( collection_url )
end

concommand.Add( "intelligent_addon_advertise", function( ply )
	if IsValid( ply ) then
		if ply:IsSuperAdmin() then
			ply:PrintMessage( HUD_PRINTCONSOLE, "Put the following lines in the addons_list table and fill the 1st string with the Workshop ID (if it exists).\n" )
			ply:PrintMessage( HUD_PRINTCONSOLE, "These lines only contain vehicles. You can put other kinds of addons by using an empty second string.\n" )
			local vehiclescript
			local lines = {}
			local category
			local clipboard = ""
			local function PrintAndClip( text )
				clipboard = clipboard..text
				ply:PrintMessage( HUD_PRINTCONSOLE, text )
			end
			for _,V in pairs( list.GetForEdit( "Vehicles" ) ) do
				category = ( V.Category or "Other" )
				if !lines[category] then
					lines[category] = {}
				end
				if V.KeyValues and V.KeyValues.vehiclescript then
					vehiclescript = V.KeyValues.vehiclescript
				else
					vehiclescript = ""
				end
				table.insert( lines[category], '\t{ "", "'..vehiclescript..'" }, -- '..( V.Name or "Unknown" )..'\n' )
			end
			for category,cat_list in pairs( lines ) do
				PrintAndClip( "\t-- "..category.."\n" )
				for _,line in ipairs( cat_list ) do
					PrintAndClip( line )
				end
			end
			SetClipboardText( clipboard )
			ply:PrintMessage( HUD_PRINTCONSOLE, "The lines have been copied to the clipboard. Use Ctrl+V in your text editor!\n" )
		end
	end
end )
