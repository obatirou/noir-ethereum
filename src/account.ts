import { Trie } from '@ethereumjs/trie';
import { Field, FixedSizeArray, U8, U64 } from '@zkpersona/noir-helpers';
import {
  type GetBlockParameters,
  type Hex,
  type PublicClient,
  hexToBytes,
  keccak256,
} from 'viem';
import { leftPad, parseAddress, parseBytes32, rightPad } from './helpers';

export type GetAccountProofOpts = {
  address: Hex;
} & GetBlockParameters;

export const getAccountProof = async <T extends PublicClient>(
  publicClient: T,
  opts: GetAccountProofOpts
) => {
  const { address, ...getBlockOpts } = opts;
  const block = await publicClient.getBlock(getBlockOpts);

  const res = await publicClient.getProof({
    address,
    storageKeys: [],
    blockNumber: block.number ?? undefined,
  });

  const stateTrie = new Trie({ root: hexToBytes(block.stateRoot) });
  const addressHash = keccak256(address, 'bytes');

  const accountProofBuffers = res.accountProof.map((p) => hexToBytes(p));

  const accountRlp = await stateTrie.verifyProof(
    stateTrie.root(),
    addressHash,
    accountProofBuffers
  );

  if (!accountRlp) {
    throw new Error('Account Proof verification failed');
  }

  const account = {
    address: parseAddress(address),
    balance: new Field(res.balance),
    code_hash: parseBytes32(res.codeHash),
    nonce: new U64(res.nonce),
    storage_hash: parseBytes32(res.storageHash),
  };

  const leafNode = res.accountProof.at(-1) ?? '0x0';
  const nodes = res.accountProof.slice(0, -1);

  const nodesData = nodes.map((val) => {
    const items = rightPad(val, 532).map((x) => new U8(x));
    return new FixedSizeArray(532, items);
  });

  if (nodesData.length > 8) {
    throw new Error(
      'Account Proof can have at most 8 nodes excluding the leaf node'
    );
  }

  while (nodesData.length !== 8) {
    nodesData.push(new FixedSizeArray(532, new Array(532).fill(new U8(0))));
  }

  const proof = {
    nodes: new FixedSizeArray(8, nodesData),
    leaf: new FixedSizeArray(
      148,
      rightPad(leafNode, 148).map((x) => new U8(x))
    ),
    depth: new U64(res.accountProof.length),
  };

  const stateRoot = parseBytes32(block.stateRoot);
  const key = new FixedSizeArray(
    66,
    leftPad(addressHash, 66).map((x) => new U8(x))
  );
  const value = new FixedSizeArray(
    110,
    leftPad(accountRlp, 110).map((x) => new U8(x))
  );

  const proofInput = {
    key,
    value,
    proof,
  };

  return {
    account,
    account_proof: proofInput,
    state_root: stateRoot,
  };
};
