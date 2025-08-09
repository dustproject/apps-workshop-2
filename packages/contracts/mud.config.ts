import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  codegen: {
    generateSystemLibraries: true,
  },
  userTypes: {
    ObjectType: {
      filePath: "@dust/world/src/types/ObjectType.sol",
      type: "uint16",
    },
    EntityId: {
      filePath: "@dust/world/src/types/EntityId.sol",
      type: "bytes32",
    },
    ProgramId: {
      filePath: "@dust/world/src/types/ProgramId.sol",
      type: "bytes32",
    },
    ResourceId: {
      filePath: "@latticexyz/store/src/ResourceId.sol",
      type: "bytes32",
    },
  },
  namespace: "workshop_1",
  systems: {
    ChestProgram: {
      openAccess: false,
      deploy: {
        registerWorldFunctions: false,
      },
    },
    ForceFieldProgram: {
      openAccess: false,
      deploy: {
        registerWorldFunctions: false,
      },
    },
  },
  tables: {
    Participant: {
      schema: {
        player: "address",
        deathCount: "uint256",
        isSet: "bool",
      },
      key: ["player"],
    },
    Depositors: {
      schema: {
        depositors: "address[]",
      },
      key: [],
    },
  },
});
