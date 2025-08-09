import { usePlayerStatus } from "./common/usePlayerStatus";
import { useSyncStatus } from "./mud/useSyncStatus";
import { usePlayerPositionQuery } from "./common/usePlayerPositionQuery";
import { AccountName } from "./common/AccountName";
import { useDustClient } from "./common/useDustClient";
import IWorldAbi from "@dust/world/out/IWorld.sol/IWorld.abi";
// import { stash, tables } from "./mud/stash";
// import { useRecord } from "@latticexyz/stash/react";
import { useMutation } from "@tanstack/react-query";
import { encodePlayer } from "@dust/world/internal";
import { decodeTransactionError } from "./common/decodeTransactionError";
// import { resourceToHex } from "@latticexyz/common";
// import IWorldAbi from "dustkit/out/IWorld.sol/IWorld.abi";
// import mudConfig from "contracts/mud.config";
// import CounterAbi from "contracts/out/CounterSystem.sol/CounterSystem.abi.json";

const CHEST_ENTITY_ID =
  "0x030000025a00000093fffffab700000000000000000000000000000000000000";

const TRANSFER_SYSTEM_ID =
  "0x737900000000000000000000000000005472616e7366657253797374656d0000";

const WHEAT_SEED_OBJECT_TYPE = 134;

export default function App() {
  const { data: dustClient } = useDustClient();
  const userAddress = dustClient?.appContext.userAddress;
  const chestEntityId = dustClient?.appContext.via?.entity;
  const userEntityId = userAddress ? encodePlayer(userAddress) : null;

  const syncStatus = useSyncStatus();
  const playerStatus = usePlayerStatus();
  const playerPosition = usePlayerPositionQuery();

  const isDesktopApp = !dustClient?.appContext.via;
  const isChestApp = !!dustClient?.appContext.via;

  const joinGame = useMutation({
    mutationFn: async () => {
      if (!dustClient) throw new Error("Dust client not connected");
      if (!userEntityId) throw new Error("User not found");

      const userSlots = await dustClient.provider.request({
        method: "getSlots",
        params: {
          entity: userEntityId,
          objectType: WHEAT_SEED_OBJECT_TYPE,
          amount: 5,
          operationType: "withdraw",
        },
      });

      const result = await dustClient.provider.request({
        method: "systemCall",
        params: [
          {
            systemId: TRANSFER_SYSTEM_ID,
            abi: IWorldAbi,
            functionName: "transferAmounts",
            args: [
              userEntityId,
              userEntityId,
              chestEntityId,
              userSlots.slots,
              "0x",
            ],
          },
        ],
      });

      const errorMessage = decodeTransactionError(IWorldAbi, result);
      if (errorMessage) {
        throw new Error(errorMessage);
      }
      return result;
    },
  });

  if (!dustClient) {
    const url = `https://alpha.dustproject.org?debug-app=${window.location.origin}/dust-app.json`;
    return (
      <div className="flex flex-col h-screen items-center justify-center">
        <a href={url} className="text-center text-blue-500 underline">
          Open this page in DUST to connect to DustKit
        </a>
      </div>
    );
  }

  if (!syncStatus.isLive || !playerStatus) {
    return (
      <div className="flex flex-col h-screen items-center justify-center">
        <p className="text-center">Syncing ({syncStatus.percentage}%)...</p>
      </div>
    );
  }

  return (
    <div className="space-y-2 p-4">
      <p>
        Hello, <AccountName address={dustClient.appContext.userAddress} />!
      </p>
      {playerPosition.data && (
        <p>Your position: {JSON.stringify(playerPosition.data, null, " ")}</p>
      )}

      {isDesktopApp && (
        <p>
          Come to{" "}
          <span
            className="cursor-pointer text-blue-500 underline"
            onClick={async () => {
              if (!dustClient) throw new Error("Dust client not connected");

              await dustClient.provider.request({
                method: "setWaypoint",
                params: {
                  entity: CHEST_ENTITY_ID,
                  label: "Spleef Game",
                },
              });
            }}
          >
            (602, 148, -1353)
          </span>{" "}
          to play the spleef game!
        </p>
      )}

      {isChestApp && (
        <>
          <button
            className="bg-blue-500 text-white p-2 rounded-md"
            onClick={() => joinGame.mutate()}
            disabled={joinGame.isPending}
          >
            {joinGame.isPending ? "Joining..." : "Join Game"}
          </button>

          {joinGame.error && (
            <p className="text-red-500">{joinGame.error.message}</p>
          )}
          {joinGame.isSuccess && <p className="text-green-500">Joined game</p>}
        </>
      )}
    </div>
  );
}
