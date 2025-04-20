import { Trie } from '@ethereumjs/trie';
import { FixedSizeArray, U8, U64 } from '@zkpersona/noir-helpers';
import {
  type GetBlockParameters,
  type Hex,
  type PublicClient,
  hexToBytes,
  keccak256,
} from 'viem';
import { leftPad, parseBytes32, rightPad } from './helpers';

export type GetStorageProofOpts = {
  address: Hex;
  slot: Hex;
} & GetBlockParameters;

export const getStorageProof = async <T extends PublicClient>(
  publicClient: T,
  opts: GetStorageProofOpts
) => {
  const { address, slot, ...getBlockOpts } = opts;
  const block = await publicClient.getBlock(getBlockOpts);

  const res = await publicClient.getProof({
    address,
    storageKeys: [slot],
    blockNumber: block.number ?? undefined,
  });

  const storageProof = res.storageProof[0]?.proof;

  if (!storageProof) {
    throw new Error('Storage Proof not found.');
  }

  const storageTrie = new Trie({ root: hexToBytes(res.storageHash) });
  const storageProofBuffers = storageProof.map((p) => hexToBytes(p));
  const storageValueRlp = await storageTrie.verifyProof(
    storageTrie.root(),
    keccak256(slot, 'bytes'),
    storageProofBuffers
  );

  if (!storageValueRlp) {
    throw new Error('Storage Proof verification failed');
  }

  const leafNode = storageProof.at(-1) ?? '0x0';
  const nodes = storageProof.slice(0, -1);

  const nodesData = nodes.map((val) => {
    const items = rightPad(val, 532).map((x) => new U8(x));
    return new FixedSizeArray(532, items);
  });

  if (nodesData.length > 6) {
    throw new Error(
      'Storage Proof can have at most 6 nodes excluding the leaf node'
    );
  }

  while (nodesData.length !== 6) {
    nodesData.push(new FixedSizeArray(532, new Array(532).fill(new U8(0))));
  }

  const proof = {
    nodes: new FixedSizeArray(6, nodesData),
    leaf: new FixedSizeArray(
      69,
      rightPad(leafNode, 69).map((x) => new U8(x))
    ),
    depth: new U64(storageProof.length),
  };

  const storageRoot = parseBytes32(res.storageHash);
  const key = new FixedSizeArray(
    66,
    leftPad(keccak256(slot, 'bytes'), 66).map((x) => new U8(x))
  );
  const value = new FixedSizeArray(
    33,
    leftPad(storageValueRlp, 33).map((x) => new U8(x))
  );

  const proofInput = {
    key,
    value,
    proof,
  };

  return {
    storage_proof: proofInput,
    storage_root: storageRoot,
  };
};
