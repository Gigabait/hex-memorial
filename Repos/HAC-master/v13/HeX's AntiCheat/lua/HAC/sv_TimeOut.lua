
HAC.TOut = {
	ThisPong 	= HAC.RandomString( #HAC_MAP ),
	Mee 		= NULL,
	GotPong		= {},
}


//Always
--[[
function HAC.TOut.IsTimingOut(self)
	if not self:Logged() then return end
	
	self:WriteLog("# IsTimingOut()", nil, true)
end
hook.Add("IsTimingOut", "HAC.TOut.IsTimingOut", HAC.TOut.IsTimingOut)
]]

//Start
function HAC.TOut.Start(self)
	self.HAC_LastTimeOut = CurTime()
	
	if self:Logged() then
		self:WriteLog("^ Timeout started", nil,true)
	else
		HAC.COLCON(HAC.BLUE2, "[HAC] Timeout started: "..tostring(self) )
	end
end
hook.Add("TimeOutStart", "HAC.TOut.Start", HAC.TOut.Start)

//Stop
function HAC.TOut.End(self)
	local Time = self.HAC_LastTimeOut - CurTime()
	Time = math.Round( -Time )
	
	if self:Logged() then
		self:WriteLog("^ Timeout ended, after "..Time, nil,true)
	else
		HAC.COLCON(HAC.BLUE2, "[HAC] Timeout ended: "..tostring(self).." after "..Time)
	end
end
hook.Add("TimeOutEnd", "HAC.TOut.End", HAC.TOut.End)



//Toggle
function HAC.TOut.ToggleHook()
	for k,v in pairs( player.GetHumans() ) do
		local Chan = v:GetNetChannel()
		if not Chan then continue end
		
		if Chan:IsTimingOut() then
			//Always
			hook.Run("IsTimingOut", v)
			
			//Start
			if not v.HAC_TOut_One then
				v.HAC_TOut_One = true
				v.HAC_TOut_Two = false
				
				v.HAC_TOutDidStart = true
				hook.Run("TimeOutStart", v)
			end
		else
			//Stop
			if not v.HAC_TOut_Two then
				v.HAC_TOut_Two = true
				v.HAC_TOut_One = false
				
				if v.HAC_TOutDidStart then
					hook.Run("TimeOutEnd", v)
				end
			end
		end
	end
end
timer.Create("HAC.TOut.ToggleHook", 3, 0, HAC.TOut.ToggleHook)






//Get pong
function HAC.TOut.GetPong(self,cmd,args)
	HAC.TOut.Mee:print("[HAC] Pong <-- "..tostring(self) )
	HAC.TOut.GotPong[ self ] = "Done"
end
concommand.Add(HAC.TOut.ThisPong, HAC.TOut.GetPong)


//Send pong
local function Send(self,Him)
	self:print("[HAC] Ping --> "..tostring(Him) )
	
	HAC.TOut.GotPong[ Him ] = "Waiting"
	
	Him:HACPEX(HAC.TOut.ThisPong)
	
	timer.Simple(5, function()
		for k,v in pairs( player.GetHumans() ) do
			local Tab = HAC.TOut.GotPong[ Him ]
			if Tab and Tab != "Done" then
				self:print("[HAC] Ping TIMEOUT: "..tostring(Him) )
			end
			HAC.TOut.GotPong[ Him ] = nil
		end
	end)
end

function HAC.TOut.SendPing(self,cmd,args)
	HAC.TOut.Mee 		= self
	HAC.TOut.GotPong 	= {}
	
	//All
	if #args == 0 then
		//Send
		for k,v in pairs( player.GetHumans() ) do
			Send(self, v)
		end
		
		return
	end
	
	
	//Him
	local Him = tonumber( args[1] )
	if not Him or Him < 1 then
		self:print("[HAC] Invalid index!")
		return
	end
	
	Him = Player(Him)
	if IsValid(Him) then
		Send(self, Him)
	else
		self:print("[HAC] Invalid userid!")
	end
end
concommand.Add("pong", HAC.TOut.SendPing)












