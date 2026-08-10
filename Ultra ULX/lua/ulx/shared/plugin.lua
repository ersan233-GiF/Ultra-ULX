ULib.plugins = {}
function ULib.registerPlugin( pluginData )
	local name = pluginData.Name
	if not ULib.plugins[ name ] then
		ULib.plugins[ name ] = pluginData
	else
		table.Merge( ULib.plugins[ name ], pluginData )
		pluginData = ULib.plugins[ name ]
	end
	if pluginData.WorkshopID then
		local addons = engine.GetAddons()
		for i=1, #addons do
			local addon = addons[i]
			if addon.mounted and addon.file:find(tostring(pluginData.WorkshopID)) then
				pluginData.WorkshopMounted = true
			end
		end
	end
	if SERVER then
		ULib.clientRPC( nil, "ULib.registerPlugin", pluginData )
	end
end
if SERVER then
	local function sendRegisteredPlugins( ply )
		for name, pluginData in pairs (ULib.plugins) do
			ULib.clientRPC( ply, "ULib.registerPlugin", pluginData )
		end
	end
	hook.Add( "PlayerInitialSpawn", "ULibSendRegisteredPlugins", sendRegisteredPlugins )
end
local ulibBuildNumURL = ULib.RELEASE and "https://teamulysses.github.io/ulib/ulib.build" or "https://raw.githubusercontent.com/TeamUlysses/ulib/master/ulib.build"
ULib.registerPlugin{
	Name          = "ULib",
	Version       = string.format( "%.2f", ULib.VERSION ),
	IsRelease     = ULib.RELEASE,
	Author        = "Team Ulysses",
	URL           = "https://ulyssesmod.net",
	WorkshopID    = 557962238,
	BuildNumLocal = tonumber(ULib.fileRead( "ulib.build" )),
	BuildNumRemoteURL = ulibBuildNumURL,
}
function ULib.pluginVersionStr( name )
	local dat = ULib.plugins[ name ]
	if not dat then return nil end
	if dat.WorkshopMounted then
		return string.format( "v%sw", dat.Version )
	elseif dat.IsRelease then
		return string.format( "v%s", dat.Version )
	elseif dat.BuildNumLocal and not dat.BuildHidden then
		local build = dat.BuildNumLocal
		if build > 1400000000 and build < 5000000000 then
			build = os.date( "%x", build )
		end
		return string.format( "v%sd (%s)", dat.Version, build )
	else
		return string.format( "v%sd", dat.Version )
	end
end
local function receiverFor( plugin )
	local function receiver( body, len, headers, httpCode )
		local buildOnline = tonumber( body )
		if not buildOnline then return end
		plugin.BuildNumRemote = buildOnline
		if plugin.BuildNumRemoteReceivedCallback then
			plugin.BuildNumRemoteReceivedCallback( plugin.BuildNumLocal, buildOnline )
		end
	end
	return receiver
end
function ULib.updateCheck( name, url )
	local plugin = ULib.plugins[ name ]
	if not plugin then return nil end
	if plugin.BuildNumRemote then return nil end
	http.Fetch( url, receiverFor( plugin ) )
	return true
end
local function httpCheck( body, len, headers, httpCode )
	if httpCode < 200 or httpCode > 299 then
		return
	end
	hook.Remove( "PlayerConnect", "ULibPluginUpdateChecker" )
	for name, plugin in pairs (ULib.plugins) do
		if plugin.BuildNumRemoteURL then
			ULib.updateCheck( name, plugin.BuildNumRemoteURL )
		end
	end
end
local function httpErr()
	hook.Remove( "PlayerConnect", "ULibPluginUpdateChecker" )
end
local function downloadForUlibUpdateCheck()
	http.Fetch( "http://connectivity-check.ubuntu.com/", httpCheck, httpErr )
end
if ULib.AUTOMATIC_UPDATE_CHECKS then
	hook.Add( "PlayerConnect", "ULibPluginUpdateChecker", downloadForUlibUpdateCheck )
end