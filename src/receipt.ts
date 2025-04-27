import { Trie } from '@ethereumjs/trie';
import { FixedSizeArray, U8, U64 } from '@zkpersona/noir-helpers';
import {
  type Chain,
  type GetTransactionReceiptParameters,
  type Hex,
  type PublicClient,
  type PublicRpcSchema,
  type TransactionReceipt,
  type Transport,
  hexToNumber,
  toHex,
} from 'viem';

import {
  encodeIndex,
  leftPad,
  parseBytes32,
  parseTxReceiptPartial,
  rightPad,
  serializeReceipt,
  transactionTypeToHex,
} from './helpers';

interface GetBlockReceiptsParameters {
  blockNumber: bigint;
}

type ExtendedPublicRpcSchema = [
  ...PublicRpcSchema,
  {
    Method: 'eth_getBlockReceipts';
    Parameters: [blockNumber: Hex];
    ReturnType: TransactionReceipt<Hex, Hex, Hex, Hex>[];
  },
];

export type GetReceiptProofOpts = GetTransactionReceiptParameters & {
  maxDepthNoLeaf?: number;
  maxEncodedReceiptLength?: number;
  maxLeafLength?: number;
  getBlockReceipts?: (
    opts: GetBlockReceiptsParameters
  ) => Promise<TransactionReceipt<Hex, Hex, Hex, Hex>[]>;
};

export const getReceiptProof = async <T extends PublicClient>(
  publicClient: T,
  opts: GetReceiptProofOpts
) => {
  const extendedClient = publicClient.extend((client) => ({
    async getBlockReceipts(opts: GetBlockReceiptsParameters) {
      return await (
        client as PublicClient<
          Transport,
          Chain,
          undefined,
          ExtendedPublicRpcSchema
        >
      ).request({
        method: 'eth_getBlockReceipts',
        params: [toHex(opts.blockNumber)],
      });
    },
  }));
  const {
    maxDepthNoLeaf = 4,
    maxEncodedReceiptLength = 256,
    maxLeafLength = 256,
    getBlockReceipts,
    ...getTransactionReceiptOpts
  } = opts;

  const receipt = await publicClient.getTransactionReceipt(
    getTransactionReceiptOpts
  );

  if (!receipt.blockNumber) throw new Error('Transaction Receipt not found');

  const block = await publicClient.getBlock({
    blockNumber: receipt.blockNumber,
  });

  let blockReceipts: TransactionReceipt<Hex, Hex, Hex, Hex>[];

  if (getBlockReceipts) {
    blockReceipts = await getBlockReceipts({ blockNumber: block.number });
  } else {
    blockReceipts = await extendedClient.getBlockReceipts({
      blockNumber: block.number,
    });
  }

  const receiptsTrie = new Trie();

  const receipts = structuredClone(blockReceipts);

  const receiptKey = encodeIndex(receipt.transactionIndex);
  const requestedReceipt = receipts[receipt.transactionIndex];

  if (!requestedReceipt) {
    throw new Error('Requested Receipt not found.');
  }
  const receiptValue = serializeReceipt(requestedReceipt);

  if (receiptValue.length > maxEncodedReceiptLength) {
    throw new Error(
      `Receipt value length (${receiptValue.length}) exceeds max encoded receipt length (${maxEncodedReceiptLength})`
    );
  }

  for await (const item of receipts) {
    const key = encodeIndex(hexToNumber(item.transactionIndex));
    const value = serializeReceipt(item);
    await receiptsTrie.put(key, value);
  }

  if (block.receiptsRoot !== toHex(receiptsTrie.root())) {
    throw new Error('Receipts trie root does not match block receipts root');
  }

  const receiptProof = await receiptsTrie.createProof(receiptKey);
  const leafNode = receiptProof.at(-1) ?? '0x0';
  const nodes = receiptProof.slice(0, -1);

  if (maxLeafLength < leafNode.length) {
    throw new Error(
      `Leaf node length (${leafNode.length}) exceeds max leaf length (${maxLeafLength})`
    );
  }

  const nodesData = nodes.map((val) => {
    const items = rightPad(val, 532).map((x) => new U8(x));
    return new FixedSizeArray(532, items);
  });

  if (nodesData.length > maxDepthNoLeaf) {
    throw new Error(
      `Receipt Proof depth (${nodesData.length}) exceeds Max Depth provided (${maxDepthNoLeaf})`
    );
  }

  while (nodesData.length !== maxDepthNoLeaf) {
    nodesData.push(new FixedSizeArray(532, new Array(532).fill(new U8(0))));
  }

  const proof = {
    nodes: new FixedSizeArray(maxDepthNoLeaf, nodesData),
    leaf: new FixedSizeArray(
      maxLeafLength,
      rightPad(leafNode, maxLeafLength).map((x) => new U8(x))
    ),
    depth: new U64(receiptProof.length),
  };

  const receiptsRoot = parseBytes32(block.receiptsRoot);

  const key = new FixedSizeArray(
    8,
    leftPad(receiptKey, 8).map((x) => new U8(x))
  );
  const value = new FixedSizeArray(
    maxEncodedReceiptLength,
    leftPad(receiptValue, maxEncodedReceiptLength).map((x) => new U8(x))
  );

  const proofInput = {
    key,
    value,
    proof,
  };

  return {
    block_number: new U64(block.number),
    transaction_index: new U64(receipt.transactionIndex),
    transaction_type: new U8(transactionTypeToHex(receipt.type) ?? '0x0'),
    receipt: parseTxReceiptPartial(requestedReceipt),
    receipt_proof: proofInput,
    receipt_root: receiptsRoot,
  };
};
