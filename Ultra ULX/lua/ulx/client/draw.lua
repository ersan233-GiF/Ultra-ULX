	Title: Draw
	Our client-side draw functions
]]
	Function: csayDraw
	Draws a csay text on the screen.
	Parameters:
		msg - The message to draw.
		color - *(Optional, defaults to 255, 255, 255, 255)* The color of the text
		duration - *(Optional, defaults to 5)* The length of the text
		fade - *(Optional, defaults to 0.5)* The length of fade time
	Revisions:
		v2.10 - Added fade parameter
]]
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
	state.color.a = alpha
	draw.DrawText(state.msg, "TargetID", ScrW() * 0.5, ScrH() * 0.25, state.color, TEXT_ALIGN_CENTER)
end
function ULib.csayDraw( msg, color, duration, fade )
	csayState.msg = msg
	csayState.color = color or Color(255, 255, 255, 255)
	csayState.duration = duration or 5
	csayState.fade = fade or 0.5
	csayState.start = CurTime()
	hook.Add("HUDPaint", "CSayHelperDraw", csayDrawToScreen)
end
