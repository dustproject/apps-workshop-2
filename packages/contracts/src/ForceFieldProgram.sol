// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";

import { HookContext, IAttachProgram, IBuild, IDetachProgram, IMine } from "@dust/world/src/ProgramHooks.sol";

import { Constants } from "./Constants.sol";

contract ForceFieldProgram is
  IMine,
  IBuild,
  IAttachProgram,
  IDetachProgram,
  System,
  WorldConsumer(Constants.DUST_WORLD)
{
  function onAttachProgram(HookContext calldata ctx) public onlyWorld { }

  function onDetachProgram(HookContext calldata ctx) public view onlyWorld { }

  function onMine(HookContext calldata ctx, MineData calldata mine) public view onlyWorld { }

  function onBuild(HookContext calldata ctx, BuildData calldata build) public view onlyWorld { }

  fallback() external { }

  // Required due to inheriting from System and WorldConsumer
  function _msgSender() public view override(WorldContextConsumer, WorldConsumer) returns (address) {
    return WorldConsumer._msgSender();
  }

  function _msgValue() public view override(WorldContextConsumer, WorldConsumer) returns (uint256) {
    return WorldConsumer._msgValue();
  }
}
