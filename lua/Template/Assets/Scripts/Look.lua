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

local InputMultiHandler = require("Scripts.Utils.Components.InputUtils")

local Look =
{
	Properties =
	{
		Speed = 10.0
	}
}

function Look:OnActivate()
	self.rotationAngle = Vector2(0.0, 0.0)
	self.input = Vector2(0.0, 0.0)

	self.inputHandlers = InputMultiHandler.ConnectMultiHandlers
	{
		[InputEventNotificationId("HorizontalLook")] =
		{
			OnPressed = function(value) self:OnHorizontalLookChanged(value) end,
			OnHeld = function(value) self:OnHorizontalLookChanged(value) end,
			OnReleased = function(value) self:OnHorizontalLookChanged(0.0) end
		},
		[InputEventNotificationId("VerticalLook")] =
		{
			OnPressed = function(value) self:OnVerticalLookChanged(value) end,
			OnHeld = function(value) self:OnVerticalLookChanged(value) end,
			OnReleased = function(value) self:OnVerticalLookChanged(0.0) end
		}
	}

	self.tickHandler = TickBus.Connect(self)
end

function Look:OnHorizontalLookChanged(value)
	self.input.x = value
end

function Look:OnVerticalLookChanged(value)
	self.input.y = value
end

function Look:OnTick(deltaTime, time)
	self.rotationAngle = self.rotationAngle + (self.input * (Math.DegToRad(self.Properties.Speed) * deltaTime))

	local horizontalRotation = Quaternion.CreateRotationZ(self.rotationAngle.x)
	TransformBus.Event.SetLocalRotationQuaternion(self.entityId, horizontalRotation)

	local transform = TransformBus.Event.GetLocalTM(self.entityId)
	local rightAxis = transform:GetBasisX()
	local verticalRotation = Quaternion.CreateFromAxisAngle(rightAxis, -self.rotationAngle.y)

	local rotation = verticalRotation * horizontalRotation
	TransformBus.Event.SetLocalRotationQuaternion(self.entityId, rotation)
end

function Look:OnDeactivate()
	self.inputHandlers:Disconnect()
	self.tickHandler:Disconnect()
end

return Look
