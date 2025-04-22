import { Trie } from '@ethereumjs/trie';
import {
  Bool,
  BoundedVec,
  FixedSizeArray,
  U8,
  U64,
} from '@zkpersona/noir-helpers';
import { type GetTransactionParameters, type PublicClient, toHex } from 'viem';
import {
  encodeTransactionIndex,
  leftPad,
  parseAddress,
  parseByteArray,
  parseBytes32,
  rightPad,
  serializeTransaction,
  toU128,
} from './helpers';

export type GetTransactionProofOpts = GetTransactionParameters & {
  maxLeafLength?: number;
  maxDataLength?: number;
  maxEncodedTransactionLength?: number;
  maxDepthNoLeaf?: number;
};

export const getTransactionProof = async <T extends PublicClient>(
  publicClient: T,
  opts: GetTransactionProofOpts
) => {
  const {
    maxLeafLength = 256,
    maxDataLength = 256,
    maxEncodedTransactionLength = 525,
    maxDepthNoLeaf = 4,
    ...getTransactionOpts
  } = opts;

  const tx = await publicClient.getTransaction(getTransactionOpts);
  if (!tx.blockNumber) throw new Error('Transaction not found');

  const txKey = encodeTransactionIndex(tx.transactionIndex ?? 0);
  const txData = parseByteArray(tx.input);
  const encodedTx = serializeTransaction(tx);

  if (maxEncodedTransactionLength < encodedTx.length) {
    throw new Error(
      'Encoded Transaction length exceeds max encoded transaction length'
    );
  }

  if (maxDataLength < txData.length) {
    throw new Error('Transaction data length exceeds max data length');
  }

  const block = await publicClient.getBlock({
    blockNumber: tx.blockNumber,
    includeTransactions: true,
  });

  const transactionsTrie = new Trie();

  const transactions = structuredClone(block.transactions);

  for await (const [index, item] of transactions.entries()) {
    const key = encodeTransactionIndex(index);
    const value = serializeTransaction(item);
    await transactionsTrie.put(key, value);
  }

  if (block.transactionsRoot !== toHex(transactionsTrie.root())) {
    throw new Error(
      'Transactions trie root does not match block transactions root'
    );
  }

  const transactionProof = await transactionsTrie.createProof(txKey);
  const leafNode = transactionProof.at(-1) ?? '0x0';
  const nodes = transactionProof.slice(0, -1);

  if (maxLeafLength < leafNode.length) {
    throw new Error('Leaf node length exceeds max leaf length');
  }

  const nodesData = nodes.map((val) => {
    const items = rightPad(val, 532).map((x) => new U8(x));
    return new FixedSizeArray(532, items);
  });

  if (nodesData.length > maxDepthNoLeaf) {
    throw new Error('Transaction Proof length exceeds Max Depth provided');
  }

  while (nodesData.length !== maxDepthNoLeaf) {
    nodesData.push(new FixedSizeArray(532, new Array(532).fill(new U8(0))));
  }

  const proof = {
    nodes: new FixedSizeArray(6, nodesData),
    leaf: new FixedSizeArray(
      maxLeafLength,
      rightPad(leafNode, maxLeafLength).map((x) => new U8(x))
    ),
    depth: new U64(transactionProof.length),
  };

  const transactionRoot = parseBytes32(block.transactionsRoot);

  const key = new FixedSizeArray(
    8,
    leftPad(txKey, 8).map((x) => new U8(x))
  );
  const value = new FixedSizeArray(
    maxEncodedTransactionLength,
    leftPad(encodedTx, maxEncodedTransactionLength).map((x) => new U8(x))
  );

  const proofInput = {
    key,
    value,
    proof,
  };

  return {
    transaction_index: new U64(tx.transactionIndex ?? 0),
    transaction_type: new U8(tx.typeHex ?? '0x0'),
    transaction_proof: proofInput,
    transaction_root: transactionRoot,
    transaction: {
      nonce: new U64(tx.nonce),
      gas_limit: new U64(tx.gas),
      to: tx.to
        ? {
            _is_some: new Bool(true),
            _value: parseAddress(tx.to),
          }
        : { _is_some: new Bool(false), _value: new FixedSizeArray(0, []) },
      value: toU128(tx.value),
      data: new BoundedVec(maxDataLength, new U8(0), txData),
      v: new U8(tx.v),
      r: new FixedSizeArray(32, parseByteArray(tx.r)),
      s: new FixedSizeArray(32, parseByteArray(tx.s)),
    },
  };
};
