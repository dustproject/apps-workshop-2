import { type Abi, decodeErrorResult, parseEventLogs } from "viem";
import { entryPoint07Abi } from "viem/account-abstraction";

export function decodeTransactionError(abi: Abi, response: unknown) {
  const receipt = response.receipt;
  const encodedReason = parseEventLogs({
    logs: receipt.receipt.logs,
    abi: entryPoint07Abi,
  });

  const revertReason = encodedReason.find(
    (log) => log.eventName === "UserOperationRevertReason"
  )?.args.revertReason;

  if (revertReason) {
    const decodedReason = decodeErrorResult({
      data: revertReason,
      abi,
    });

    return `${decodedReason.errorName}: ${decodedReason?.args?.join(", ")}`;
  }
  return null;
}
