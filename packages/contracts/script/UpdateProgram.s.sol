// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { console } from "forge-std/console.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { ProgramId } from "@dust/world/src/types/ProgramId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { IWorld } from "@dust/world/src/codegen/world/IWorld.sol";

import { Script } from "./Script.sol";

contract UpdateProgram is Script {
  using WorldResourceIdInstance for ResourceId;

  function run(EntityId entity, ProgramId program, bytes calldata extraData) external {
    address sender = startBroadcast();
    EntityId caller = EntityTypeLib.encodePlayer(sender);

    IWorld world = IWorld(StoreSwitch.getStoreAddress());
    world.updateProgram(caller, entity, program, extraData);

    vm.stopBroadcast();
  }
}
