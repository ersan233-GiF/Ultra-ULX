function ULib.redirect( ply, command, argv )
	local totalArgv = table.Add( ULib.explode( " ", command ), argv )
	RunConsoleCommand( "_u", unpack( totalArgv ) )
end