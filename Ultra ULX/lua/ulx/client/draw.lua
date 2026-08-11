local csayState = {}
local function csayDrawToScreen()
	local state = csayState
	if not state.msg then
		hook.Remove("HUDPaint", "CSayHelperDraw")
		return
	end
	local alpha = 255
	local dtime = CurTime() - state.start
	if dtime > state.duration then
		state.msg = nil
		hook.Remove("HUDPaint", "CSayHelperDraw")
		return
	end
	if state.fade - dtime > 0 then
		alpha = (state.fade - dtime) / state.fade
		alpha = (1 - alpha) * 255
	end
	if state.duration - dtime < state.fade then
		alpha = (state.duration - dtime) / state.fade * 255
	end
	local c = state.color
	local drawColor = Color(c.r, c.g, c.b, math.Clamp(math.floor(alpha), 0, 255))
	draw.DrawText(state.msg, "TargetID", ScrW() * 0.5, ScrH() * 0.25, drawColor, TEXT_ALIGN_CENTER)
end
function ULib.csayDraw( msg, color, duration, fade )
	csayState.msg = msg
	csayState.color = color or Color(255, 255, 255, 255)
	csayState.duration = duration or 5
	csayState.fade = fade or 0.5
	csayState.start = CurTime()
	hook.Add("HUDPaint", "CSayHelperDraw", csayDrawToScreen)
end