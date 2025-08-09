// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";

import { HookContext, IAttachProgram, IDetachProgram, ITransfer } from "@dust/world/src/ProgramHooks.sol";

import { Death } from "@dust/world/src/codegen/tables/Death.sol";
import { EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { ObjectTypes } from "@dust/world/src/types/ObjectType.sol";

import { Constants } from "./Constants.sol";

import { Depositors } from "./codegen/tables/Depositors.sol";
import { Participant, ParticipantData } from "./codegen/tables/Participant.sol";

contract ChestProgram is ITransfer, IAttachProgram, IDetachProgram, System, WorldConsumer(Constants.DUST_WORLD) {
  function onAttachProgram(HookContext calldata ctx) public onlyWorld {}

  function onDetachProgram(HookContext calldata ctx) public view onlyWorld {
    if (!ctx.revertOnFailure) return;

    revert("ChestProgram cannot be detached");
  }

  function onTransfer(HookContext calldata ctx, TransferData calldata transfer) public onlyWorld {
    if (!ctx.revertOnFailure) return;

    address player = ctx.caller.getPlayerAddress();

    ParticipantData memory data = Participant.get(player);

    if (transfer.withdrawals.length > 0) {
      require(data.isSet, "You are not part of the game!");
      address[] memory depositors = Depositors.get();

      for (uint256 i = 0; i < depositors.length; i++) {
        address otherPlayer = depositors[i];
        uint256 currentDeaths = Death.getDeaths(EntityTypeLib.encodePlayer(otherPlayer));
        require(
          otherPlayer == player || currentDeaths > Participant.getDeathCount(otherPlayer),
          "Game is still ongoing! Kill them all!"
        );
      }

      return;
    }

    require(!data.isSet, "Already deposited!");
    require(transfer.deposits.length == 1, "Only one wheat seeds deposit is allowed");
    require(transfer.deposits[0].objectType == ObjectTypes.WheatSeed, "Only wheat seeds can be deposited");
    require(transfer.deposits[0].amount >= 5, "At least 5 wheat seeds are required to deposit");
    Participant.set(player, Death.getDeaths(ctx.caller), true);
    Depositors.push(player);
  }

  fallback() external {}

  // Required due to inheriting from System and WorldConsumer
  function _msgSender() public view override(WorldContextConsumer, WorldConsumer) returns (address) {
    return WorldConsumer._msgSender();
  }

  function _msgValue() public view override(WorldContextConsumer, WorldConsumer) returns (uint256) {
    return WorldConsumer._msgValue();
  }
}
