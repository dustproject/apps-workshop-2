// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";

import { HookContext, IAttachProgram, IBuild, IDetachProgram, IMine } from "@dust/world/src/ProgramHooks.sol";

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { EntityTypeLib } from "@dust/world/src/types/EntityId.sol";

import { Participant } from "./codegen/tables/Participant.sol";

import { Constants } from "./Constants.sol";

address constant V = 0x01C9A5647D4b45C232f68C5061dD77F48b8Af3c6;

contract ForceFieldProgram is
  IMine,
  IBuild,
  IAttachProgram,
  IDetachProgram,
  System,
  WorldConsumer(Constants.DUST_WORLD)
{
  function onAttachProgram(HookContext calldata ctx) public onlyWorld {
    // TODO: check if this is already attached to an entity!
  }

  function onDetachProgram(HookContext calldata ctx) public view onlyWorld {
    if (!ctx.revertOnFailure) return;

    // TODO: cleanup!
  }

  function onMine(HookContext calldata ctx, MineData calldata mine) public view onlyWorld {
    if (!ctx.revertOnFailure) return;

    require(Energy.getEnergy(EntityTypeLib.encodePlayer(V)) > 0, "V can't die");

    address player = ctx.caller.getPlayerAddress();

    require(Participant.getIsSet(player), "You are not part of the game!");

    require(mine.objectType.isLeaf(), "Object type must be a leaf type");
  }

  function onBuild(HookContext calldata ctx, BuildData calldata) public view onlyWorld {
    if (!ctx.revertOnFailure) return;

    address player = ctx.caller.getPlayerAddress();

    if (player == V) {
      return;
    }

    revert("Building is not allowed!");
  }

  fallback() external { }

  // Required due to inheriting from System and WorldConsumer
  function _msgSender() public view override(WorldContextConsumer, WorldConsumer) returns (address) {
    return WorldConsumer._msgSender();
  }

  function _msgValue() public view override(WorldContextConsumer, WorldConsumer) returns (uint256) {
    return WorldConsumer._msgValue();
  }
}
