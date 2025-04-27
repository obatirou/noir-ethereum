export type RecursiveArray<T> = T | readonly RecursiveArray<T>[];

import {
  type AccessList,
  type AuthorizationList,
  type ByteArray,
  InvalidAddressError,
  InvalidLegacyVError,
  InvalidStorageKeySizeError,
  type Signature,
  type Transaction,
  type TransactionEIP1559,
  type TransactionEIP2930,
  type TransactionEIP4844,
  type TransactionEIP7702,
  type TransactionLegacy,
  type TransactionSerializableGeneric,
  assertTransactionEIP1559,
  assertTransactionEIP2930,
  concatBytes,
  hexToBytes,
  isAddress,
  toBytes,
  toRlp,
  trim,
} from 'viem';

export const serializeTransaction = (tx: Transaction): Uint8Array => {
  if (tx.type === 'legacy') {
    return serializeLegacyTransaction(tx);
  }
  if (tx.type === 'eip1559') {
    return serializeEIP1559Transaction(tx);
  }
  if (tx.type === 'eip2930') {
    return serializeEIP2930Transaction(tx);
  }

  if (tx.type === 'eip4844') {
    return serializeEIP4844Transaction(tx);
  }

  return serializeEIP7702Transaction(tx);
};

export const serializeLegacyTransaction = (tx: TransactionLegacy) => {
  // { nonce, gasPrice, gasLimit, to, value, data, v, r, s }
  const { nonce, gasPrice, gas, to, value, input: data, chainId = 0 } = tx;

  const signature = {
    v: tx.v,
    r: tx.r,
    s: tx.s,
  };

  let serializedTransaction = [
    nonce ? toBytes(nonce) : hexToBytes('0x'),
    gasPrice ? toBytes(gasPrice) : hexToBytes('0x'),
    gas ? toBytes(gas) : hexToBytes('0x'),
    to ? hexToBytes(to) : hexToBytes('0x'),
    value ? toBytes(value) : hexToBytes('0x'),
    data ? hexToBytes(data) : hexToBytes('0x'),
  ];

  const v = (() => {
    // EIP-155 (inferred chainId)
    if (signature.v >= 35n) {
      const inferredChainId = (signature.v - 35n) / 2n;
      if (inferredChainId > 0) return signature.v;
      return 27n + (signature.v === 35n ? 0n : 1n);
    }

    // EIP-155 (explicit chainId)
    if (chainId > 0)
      return BigInt(chainId * 2) + BigInt(35n + signature.v - 27n);

    // Pre-EIP-155 (no chainId)
    const v = 27n + (signature.v === 27n ? 0n : 1n);
    if (signature.v !== v) throw new InvalidLegacyVError({ v: signature.v });
    return v;
  })();

  const r = trim(signature.r);
  const s = trim(signature.s);

  serializedTransaction = [
    ...serializedTransaction,
    v ? toBytes(v) : hexToBytes('0x'),
    r === '0x00' ? hexToBytes('0x') : hexToBytes(r),
    s === '0x00' ? hexToBytes('0x') : hexToBytes(s),
  ];

  return toRlp(serializedTransaction, 'bytes');
};

export const serializeEIP1559Transaction = (tx: TransactionEIP1559) => {
  // { chainId, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to, value, data, accessList, v, r, s }
  const {
    chainId,
    gas,
    nonce,
    to,
    value,
    maxFeePerGas,
    maxPriorityFeePerGas,
    accessList,
    input: data,
  } = tx;

  assertTransactionEIP1559(tx);

  const serializedAccessList = serializeAccessList(accessList);

  const serializedTransaction = [
    toBytes(chainId),
    nonce ? toBytes(nonce) : hexToBytes('0x'),
    maxPriorityFeePerGas ? toBytes(maxPriorityFeePerGas) : hexToBytes('0x'),
    maxFeePerGas ? toBytes(maxFeePerGas) : hexToBytes('0x'),
    gas ? toBytes(gas) : hexToBytes('0x'),
    to ? hexToBytes(to) : hexToBytes('0x'),
    value ? toBytes(value) : hexToBytes('0x'),
    data ? hexToBytes(data) : hexToBytes('0x'),
    serializedAccessList,
    ...toYParitySignatureArray(tx),
  ];

  return concatBytes([
    new Uint8Array([0x02]),
    toRlp(serializedTransaction, 'bytes'),
  ]);
};

export const serializeEIP2930Transaction = (tx: TransactionEIP2930) => {
  // { chainId, nonce, gasPrice, gasLimit, to, value, data, accessList, v, r, s }
  const {
    chainId,
    gas,
    input: data,
    nonce,
    to,
    value,
    accessList,
    gasPrice,
  } = tx;

  assertTransactionEIP2930(tx);

  const serializedAccessList = serializeAccessList(accessList);

  const serializedTransaction = [
    toBytes(chainId),
    nonce ? toBytes(nonce) : hexToBytes('0x'),
    gasPrice ? toBytes(gasPrice) : hexToBytes('0x'),
    gas ? toBytes(gas) : hexToBytes('0x'),
    to ? hexToBytes(to) : hexToBytes('0x'),
    value ? toBytes(value) : hexToBytes('0x'),
    data ? hexToBytes(data) : hexToBytes('0x'),
    serializedAccessList,
    ...toYParitySignatureArray(tx),
  ];

  return concatBytes([
    new Uint8Array([0x01]),
    toRlp(serializedTransaction, 'bytes'),
  ]);
};

export const serializeEIP4844Transaction = (tx: TransactionEIP4844) => {
  // {chain_id, nonce, max_priority_fee_per_gas, max_fee_per_gas, gas_limit, to, value, data, access_list, max_fee_per_blob_gas, blob_versioned_hashes, y_parity, r, s}
  const {
    chainId,
    gas,
    nonce,
    to,
    value,
    maxFeePerBlobGas,
    maxFeePerGas,
    maxPriorityFeePerGas,
    accessList,
    input: data,
  } = tx;

  const blobVersionedHashes: ByteArray[] | undefined = tx.blobVersionedHashes
    ? tx.blobVersionedHashes.map((x) => hexToBytes(x))
    : undefined;

  const serializedAccessList = serializeAccessList(accessList);

  const serializedTransaction = [
    toBytes(chainId),
    nonce ? toBytes(nonce) : hexToBytes('0x'),
    maxPriorityFeePerGas ? toBytes(maxPriorityFeePerGas) : hexToBytes('0x'),
    maxFeePerGas ? toBytes(maxFeePerGas) : hexToBytes('0x'),
    gas ? toBytes(gas) : hexToBytes('0x'),
    to ? hexToBytes(to) : hexToBytes('0x'),
    value ? toBytes(value) : hexToBytes('0x'),
    data ? hexToBytes(data) : hexToBytes('0x'),
    serializedAccessList,
    maxFeePerBlobGas ? toBytes(maxFeePerBlobGas) : hexToBytes('0x'),
    blobVersionedHashes ?? [],
    ...toYParitySignatureArray(tx),
  ] as const;

  return concatBytes([
    new Uint8Array([0x03]),
    toRlp(serializedTransaction, 'bytes'),
  ]);
};

export const serializeEIP7702Transaction = (tx: TransactionEIP7702) => {
  // { chainId, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to, value, data, accessList, v, r, s }
  const {
    authorizationList,
    chainId,
    gas,
    nonce,
    to,
    value,
    maxFeePerGas,
    maxPriorityFeePerGas,
    accessList,
    input: data,
  } = tx;

  const serializedAccessList = serializeAccessList(accessList);
  const serializedAuthorizationList =
    serializeAuthorizationList(authorizationList);

  return concatBytes([
    new Uint8Array([0x04]),
    toRlp(
      [
        toBytes(chainId),
        nonce ? toBytes(nonce) : hexToBytes('0x'),
        maxPriorityFeePerGas ? toBytes(maxPriorityFeePerGas) : hexToBytes('0x'),
        maxFeePerGas ? toBytes(maxFeePerGas) : hexToBytes('0x'),
        gas ? toBytes(gas) : hexToBytes('0x'),
        to ? hexToBytes(to) : hexToBytes('0x'),
        value ? toBytes(value) : hexToBytes('0x'),
        data ? hexToBytes(data) : hexToBytes('0x'),
        serializedAccessList,
        serializedAuthorizationList,
        ...toYParitySignatureArray(tx),
      ],
      'bytes'
    ),
  ]);
};

export function serializeAccessList(
  accessList?: AccessList | undefined
): RecursiveArray<Uint8Array> {
  if (!accessList || accessList.length === 0) return [];

  const serializedAccessList = [];
  for (let i = 0; i < accessList.length; i++) {
    // biome-ignore lint/style/noNonNullAssertion: <explanation>
    const { address, storageKeys } = accessList[i]!;

    // biome-ignore lint/style/useForOf: <explanation>
    for (let j = 0; j < storageKeys.length; j++) {
      // biome-ignore lint/style/noNonNullAssertion: <explanation>
      const key = storageKeys[j]!;
      if (key.length - 2 !== 64) {
        throw new InvalidStorageKeySizeError({ storageKey: key });
      }
    }

    if (!isAddress(address, { strict: false })) {
      throw new InvalidAddressError({ address });
    }

    serializedAccessList.push([
      hexToBytes(address),
      storageKeys.map((x) => hexToBytes(x)),
    ]);
  }
  return serializedAccessList;
}

export function toYParitySignatureArray(
  transaction: TransactionSerializableGeneric,
  signature_?: Signature | undefined
) {
  const signature = signature_ ?? transaction;
  const { v, yParity } = signature;

  if (typeof signature.r === 'undefined') return [];
  if (typeof signature.s === 'undefined') return [];
  if (typeof v === 'undefined' && typeof yParity === 'undefined') return [];

  const r = trim(signature.r);
  const s = trim(signature.s);

  const yParity_ = (() => {
    if (typeof yParity === 'number')
      return yParity ? toBytes(1) : hexToBytes('0x');
    if (v === 0n) return hexToBytes('0x');
    if (v === 1n) return toBytes(1);

    return v === 27n ? hexToBytes('0x') : toBytes(1);
  })();

  return [
    yParity_,
    r === '0x00' ? hexToBytes('0x') : hexToBytes(r),
    s === '0x00' ? hexToBytes('0x') : hexToBytes(s),
  ];
}

export function serializeAuthorizationList(
  authorizationList?: AuthorizationList<number, true> | undefined
) {
  if (!authorizationList || authorizationList.length === 0) return [];

  const serializedAuthorizationList = [];
  for (const authorization of authorizationList) {
    const { chainId, nonce, ...signature } = authorization;
    const contractAddress = authorization.address;
    serializedAuthorizationList.push([
      chainId ? toBytes(chainId) : hexToBytes('0x'),
      hexToBytes(contractAddress),
      nonce ? toBytes(nonce) : hexToBytes('0x'),
      ...toYParitySignatureArray({}, signature),
    ]);
  }

  return serializedAuthorizationList;
}

export const encodeIndex = (index: number) => {
  return index === 0 ? hexToBytes('0x80') : toRlp(toBytes(index), 'bytes');
};
