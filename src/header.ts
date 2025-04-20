import {
  Bool,
  BoundedVec,
  FixedSizeArray,
  U8,
  U64,
} from '@zkpersona/noir-helpers';

import {
  type ByteArray,
  type GetBlockParameters,
  type PublicClient,
  hexToBytes,
  toBytes,
  toRlp,
} from 'viem';
import { parseByteArray, parseBytes32 } from './helpers';

export type GetBlockHeaderOpts = GetBlockParameters;

export const getBlockHeader = async <T extends PublicClient>(
  publicClient: T,
  opts: GetBlockHeaderOpts
) => {
  const chainId = new U64(publicClient.chain?.id ?? 1);
  const block = await publicClient.getBlock(opts);

  const headerData: ByteArray[] = [
    hexToBytes(block.parentHash),
    hexToBytes(block.sha3Uncles),
    hexToBytes(block.miner),
    hexToBytes(block.stateRoot),
    hexToBytes(block.transactionsRoot),
    hexToBytes(block.receiptsRoot),
    hexToBytes(block.logsBloom ?? '0x0'),
    block.difficulty === 0n ? new Uint8Array(0) : toBytes(block.difficulty),
    toBytes(block.number ?? 0n),
    toBytes(block.gasLimit),
    toBytes(block.gasUsed),
    toBytes(block.timestamp),
    hexToBytes(block.extraData),
    hexToBytes(block.mixHash),
    hexToBytes(block.nonce ?? '0x0'),
    block.baseFeePerGas ? toBytes(block.baseFeePerGas) : undefined,
    block.withdrawalsRoot ? hexToBytes(block.withdrawalsRoot) : undefined,
    block.blobGasUsed ? toBytes(block.blobGasUsed) : undefined,
    block.excessBlobGas ? toBytes(block.excessBlobGas) : undefined,
    block.parentBeaconBlockRoot
      ? hexToBytes(block.parentBeaconBlockRoot)
      : undefined,
  ].filter((x) => x !== undefined);

  const headerRlp = toRlp(headerData);

  const header = {
    number: new U64(block.number ?? 0n),
    hash: parseBytes32(block.hash ?? '0x0'),
    state_root: parseBytes32(block.stateRoot),
    transactions_root: parseBytes32(block.transactionsRoot),
    receipts_root: parseBytes32(block.receiptsRoot),
    withdrawals_root: block.withdrawalsRoot
      ? {
          _is_some: new Bool(true),
          _value: parseBytes32(block.withdrawalsRoot),
        }
      : { _is_some: new Bool(false), _value: new FixedSizeArray(0, []) },
  };

  return {
    chain_id: chainId,
    block_header_partial: header,
    block_header_rlp: new BoundedVec(709, new U8(0), parseByteArray(headerRlp)),
  };
};
