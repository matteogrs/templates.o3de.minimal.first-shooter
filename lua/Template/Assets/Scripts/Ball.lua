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

local Ball =
{
	Properties =
	{
		Lifetime = 2.0
	}
}

function Ball:OnActivate()
	self.timer = TimeDelay:Start(self.Properties.Lifetime, function() self:OnDelayEnd() end)
end

function Ball:OnDelayEnd()
	local containerId = TransformBus.Event.GetParentId(self.entityId)
	GameEntityContextRequestBus.Broadcast.DestroyGameEntityAndDescendants(containerId)
end

function Ball:OnDeactivate()
	self.timer:Stop()
end

return Ball
