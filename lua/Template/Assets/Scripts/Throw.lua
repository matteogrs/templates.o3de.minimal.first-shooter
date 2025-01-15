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

local Throw =
{
	Properties =
	{
		BallPrefab = SpawnableScriptAssetRef(),
		Strength = 7.5
	}
}

function Throw:OnActivate()
	self.spawnSystem = SpawnableScriptMediator()
	self.spawnTicket = self.spawnSystem:CreateSpawnTicket(self.Properties.BallPrefab)
	self.spawnHandler = SpawnableScriptNotificationsBus.Connect(self, self.spawnTicket:GetId())

	self.inputHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("Throw"))
end

function Throw:OnPressed(value)
	local transform = TransformBus.Event.GetLocalTM(self.entityId)
	
	local forwardAxis = transform:GetBasisY()
	local spawnPosition = transform.translation + forwardAxis

	local parentId = TransformBus.Event.GetParentId(self.entityId)
	self.spawnSystem:SpawnAndParentAndTransform(self.spawnTicket, parentId, spawnPosition, Vector3(0.0, 0.0, 0.0), 1.0)
end

function Throw:OnSpawn(spawnTicket, spawnedEntityIds)
	local ballId = spawnedEntityIds[2]
	self.physicsHandler = RigidBodyNotificationBus.Connect(self, ballId)
end

function Throw:OnPhysicsEnabled(ballId)
	local transform = TransformBus.Event.GetLocalTM(self.entityId)
	
	local forwardAxis = transform:GetBasisY()
	local velocity = forwardAxis * self.Properties.Strength

	RigidBodyRequestBus.Event.ApplyLinearImpulse(ballId, velocity)
end

function Throw:OnDeactivate()
	self.inputHandler:Disconnect()
	self.spawnHandler:Disconnect()

	if self.physicsHandler ~= nil then
		self.physicsHandler:Disconnect()
		self.physicsHandler = nil
	end
end

return Throw
