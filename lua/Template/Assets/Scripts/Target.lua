-- Copyright (c) 2025 Matteo Grasso
-- 
--     https://github.com/matteogrs/templates.o3de.minimal.first-shooter
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local TimeDelay = require("Assets.Scripts.Utils.TimeDelay")

local Target =
{
	Properties =
	{
		MinHeight = 0.1,
		RespawnDelay = 2.0
	}	
}

function Target:OnActivate()
	self.initialTransform = TransformBus.Event.GetWorldTM(self.entityId)

	self.transformHandler = TransformNotificationBus.Connect(self, self.entityId)
end

function Target:OnTransformChanged(localTransform, worldTransform)
	if (worldTransform.translation.z < self.Properties.MinHeight) and (self.timer == nil) then
		self.timer = TimeDelay:Start(self.Properties.RespawnDelay, function() self:OnDelayEnd() end)
	end
end

function Target:OnDelayEnd()
	RigidBodyRequestBus.Event.DisablePhysics(self.entityId)

	RigidBodyRequestBus.Event.SetLinearVelocity(self.entityId, Vector3(0.0, 0.0, 0.0))
	RigidBodyRequestBus.Event.SetAngularVelocity(self.entityId, Vector3(0.0, 0.0, 0.0))	
	TransformBus.Event.SetWorldTM(self.entityId, self.initialTransform)

	RigidBodyRequestBus.Event.EnablePhysics(self.entityId)
	self.timer = nil
end

function Target:OnDeactivate()
	self.transformHandler:Disconnect()

	if self.timer ~= nil then
		self.timer:Stop()
		self.timer = nil
	end
end

return Target
