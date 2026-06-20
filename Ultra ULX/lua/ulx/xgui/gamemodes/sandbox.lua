local Tsb = ULib.ulx_lang.T
xgui.prepareDataType( "sboxlimits" )
local sbox_settings = xlib.makepanel{ parent=xgui.null }
local sidepanel = xlib.makescrollpanel{ x=5, y=5, w=160, h=322, spacing=4, parent=sbox_settings }
sbox_settings.sideLabels = {}
local function addSbCheckbox( key, convar, repconvar, marginTop )
	local cb = xlib.makecheckbox{ dock=TOP, dockmargin={0,marginTop or 0,0,0}, label=Tsb(key), convar=convar, repconvar=repconvar, parent=sidepanel }
	table.insert( sbox_settings.sideLabels, { panel=cb, key=key } )
	return cb
end
local function addSbLabel( key, marginTop, opts )
	opts = opts or {}
	local lbl = xlib.makelabel{ dock=TOP, dockmargin={0,marginTop or 5,0,0}, label=Tsb(key), parent=sidepanel, w=opts.w, wordwrap=opts.wordwrap }
	table.insert( sbox_settings.sideLabels, { panel=lbl, key=key } )
	return lbl
end
addSbCheckbox("sb_weapons_spawn", xlib.ifListenHost("sbox_weapons"), xlib.ifNotListenHost("rep_sbox_weapons"))
addSbCheckbox("sb_godmode", xlib.ifListenHost("sbox_godmode"), xlib.ifNotListenHost("rep_sbox_godmode"), 5)
addSbCheckbox("sb_pvp", xlib.ifListenHost("sbox_playershurtplayers"), xlib.ifNotListenHost("rep_sbox_playershurtplayers"), 20)
addSbCheckbox("sb_noclip", xlib.ifListenHost("sbox_noclip"), xlib.ifNotListenHost("rep_sbox_noclip"), 5)
addSbCheckbox("sb_bonemanip_npc", xlib.ifListenHost("sbox_bonemanip_npc"), xlib.ifNotListenHost("rep_sbox_bonemanip_npc"), 5)
addSbCheckbox("sb_bonemanip_player", xlib.ifListenHost("sbox_bonemanip_player"), xlib.ifNotListenHost("rep_sbox_bonemanip_player"), 5)
addSbCheckbox("sb_bonemanip_all", xlib.ifListenHost("sbox_bonemanip_misc"), xlib.ifNotListenHost("rep_sbox_bonemanip_misc"), 5)
addSbCheckbox("sb_physgun_limited", xlib.ifListenHost("physgun_limited"), xlib.ifNotListenHost("rep_physgun_limited"), 20)
addSbLabel("sb_max_range")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=128, max=8192, convar=xlib.ifListenHost("physgun_maxrange"), repconvar=xlib.ifNotListenHost("rep_physgun_maxrange"), parent=sidepanel, fixclip=true }
addSbLabel("sb_teleport_dist")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=10000, convar=xlib.ifListenHost("physgun_teleportDistance"), repconvar=xlib.ifNotListenHost("rep_physgun_teleportDistance"), parent=sidepanel, fixclip=true }
addSbLabel("sb_max_speed")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=10000, convar=xlib.ifListenHost("physgun_maxSpeed"), repconvar=xlib.ifNotListenHost("rep_physgun_maxSpeed"), parent=sidepanel, fixclip=true }
addSbLabel("sb_max_angular")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=10000, convar=xlib.ifListenHost("physgun_maxAngular"), repconvar=xlib.ifNotListenHost("rep_physgun_maxAngular"), parent=sidepanel, fixclip=true }
addSbLabel("sb_arrive_time")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=2, decimal=2, convar=xlib.ifListenHost("physgun_timeToArrive"), repconvar=xlib.ifNotListenHost("rep_physgun_timeToArrive"), parent=sidepanel, fixclip=true }
addSbLabel("sb_arrive_ragdoll")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=2, decimal=2, convar=xlib.ifListenHost("physgun_timeToArriveRagdoll"), repconvar=xlib.ifNotListenHost("rep_physgun_timeToArriveRagdoll"), parent=sidepanel, fixclip=true }
addSbLabel("sb_persist_file", 20, { w=138 })
xlib.maketextbox{ h=25, dock=TOP, dockmargin={0,5,5,0}, label=Tsb("sb_persist_props"), convar=xlib.ifListenHost("sbox_persist"), repconvar=xlib.ifNotListenHost("rep_sbox_persist"), parent=sidepanel }
addSbLabel("sb_note", 20, { w=138, wordwrap=true })
sbox_settings.plist = xlib.makelistlayout{ x=170, y=5, h=322, w=410, spacing=1, padding=2, parent=sbox_settings }
function sbox_settings.processLimits()
	sbox_settings.plist:Clear()
	for g, limits in ipairs( xgui.data.sboxlimits ) do
		if #limits > 0 then
			local panel = xlib.makepanel{ dockpadding={ 0,0,0,5 } }
			local i=0
			for _, cvar in ipairs( limits ) do
				local cvardata = cvar:Explode( " " )
				xgui.queueFunctionCall( xlib.makelabel, "sboxlimits", { x=10+(i%2*195), y=5+math.floor(i/2)*40, w=185, label="最大 " .. cvardata[1]:sub(9), parent=panel } )
				xgui.queueFunctionCall( xlib.makeslider, "sboxlimits", { x=10+(i%2*195), y=20+math.floor(i/2)*40, w=185, label="<--->", min=0, max=cvardata[2], convar=xlib.ifListenHost(cvardata[1]), repconvar=xlib.ifNotListenHost("rep_"..cvardata[1]), parent=panel, fixclip=true } )
				i = i + 1
			end
			sbox_settings.plist:Add( xlib.makecat{ label=limits.title .. " (" .. #limits .. " 限制)", contents=panel, expanded=( g==1 ) } )
		end
	end
end
sbox_settings.processLimits()
xgui.hookEvent( "sboxlimits", "process", sbox_settings.processLimits, "sandboxProcessLimits" )
xgui.registerRefresh( "sandbox", function()
	xgui.refreshLabels( sbox_settings.sideLabels )
end )
xgui.addSettingModule( "sandbox", sbox_settings, "icon16/brick.png" )
