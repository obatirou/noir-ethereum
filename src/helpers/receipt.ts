import { Bool, FixedSizeArray, U1, U8, U64 } from '@zkpersona/noir-helpers';
import {
  type Hex,
  type TransactionReceipt,
  type TransactionType,
  concatBytes,
  hexToBigInt,
  hexToBytes,
  toRlp,
} from 'viem';
import { parseByteArray } from './array';
import { parseBytes32 } from './bytes32';

const BYZANTIUM_BLOCK_NUMBER = 4_370_000;

const isPreByzantium = (blockNumber: bigint) => {
  return blockNumber < BYZANTIUM_BLOCK_NUMBER;
};

const serializeLogs = (
  logs: TransactionReceipt<Hex, Hex, Hex, Hex>['logs']
) => {
  return logs.map((log) => [
    hexToBytes(log.address),
    log.topics.map((topic) => hexToBytes(topic, { size: 32 })),
    hexToBytes(log.data),
  ]);
};

export const serializeReceipt = (
  receipt: TransactionReceipt<Hex, Hex, Hex, Hex>
) => {
  const {
    status,
    cumulativeGasUsed,
    logsBloom,
    logs,
    root: stateRoot,
    blockNumber,
    type,
  } = receipt;

  const blockNum = hexToBigInt(blockNumber);

  if (isPreByzantium(blockNum)) {
    if (!stateRoot) {
      throw new Error('Missing stateRoot for pre-Byzantium receipt');
    }
    const data = [
      hexToBytes(stateRoot),
      hexToBytes(cumulativeGasUsed),
      hexToBytes(logsBloom, { size: 256 }),
      serializeLogs(logs),
    ];

    return toRlp(data, 'bytes');
  }

  const data = [
    status === '0x1' ? hexToBytes('0x1') : new Uint8Array(0),
    hexToBytes(cumulativeGasUsed),
    hexToBytes(logsBloom),
    serializeLogs(logs),
  ];

  if (type === '0x0') {
    return toRlp(data, 'bytes');
  }

  return concatBytes([hexToBytes(type), toRlp(data, 'bytes')]);
};

export const transactionTypeToHex = (type: TransactionType) => {
  if (type.startsWith('0x')) return type as Hex;
  if (type === 'legacy') return '0x0';
  if (type === 'eip2930') return '0x1';
  if (type === 'eip1559') return '0x2';
  if (type === 'eip4844') return '0x3';
  if (type === 'eip7702') return '0x4';
};

export const parseTxReceiptPartial = (
  receipt: TransactionReceipt<Hex, Hex, Hex, Hex>
) => {
  return {
    state_root:
      isPreByzantium(hexToBigInt(receipt.blockNumber)) && receipt.root
        ? {
            _is_some: new Bool(true),
            _value: parseBytes32(receipt.root),
          }
        : {
            _is_some: new Bool(false),
            _value: new FixedSizeArray(32, new Array(32).fill(new U8(0))),
          },
    status: isPreByzantium(hexToBigInt(receipt.blockNumber))
      ? {
          _is_some: new Bool(false),
          _value: new U1(0),
        }
      : {
          _is_some: new Bool(true),
          _value: new U1(receipt.status),
        },
    cumulative_gas_used: new U64(receipt.cumulativeGasUsed),
    logs_bloom: new FixedSizeArray(256, parseByteArray(receipt.logsBloom)),
  };
};
