import {
  http,
  createPublicClient,
  encodeAbiParameters,
  fromRlp,
  hexToBytes,
  keccak256,
  toHex,
} from 'viem';
import { mainnet } from 'viem/chains';

import { Trie } from '@ethereumjs/trie';

import { namehash } from 'viem';

const parseArray = (data: number[] | `0x${string}` | Uint8Array) => {
  const arr = Array.isArray(data)
    ? data
    : // biome-ignore lint/nursery/noNestedTernary: <explanation>
      data instanceof Uint8Array
      ? Array.from(data)
      : Array.from(hexToBytes(data));
  return `[${arr.join(', ')}]`;
};

const leftPad = (
  data: number[] | `0x${string}` | Uint8Array,
  finalLength: number
) => {
  const arr = Array.isArray(data)
    ? data
    : // biome-ignore lint/nursery/noNestedTernary: <explanation>
      data instanceof Uint8Array
      ? Array.from(data)
      : Array.from(hexToBytes(data));
  const zeroToAdd = finalLength - arr.length;
  return [...new Array<number>(zeroToAdd).fill(0), ...arr];
};

const rightPad = (
  data: number[] | `0x${string}` | Uint8Array,
  finalLength: number
) => {
  const arr = Array.isArray(data)
    ? data
    : // biome-ignore lint/nursery/noNestedTernary: <explanation>
      data instanceof Uint8Array
      ? Array.from(data)
      : Array.from(hexToBytes(data));
  const zeroToAdd = finalLength - arr.length;
  return [...arr, ...new Array<number>(zeroToAdd).fill(0)];
};

const node = namehash('envoy1084.eth');

// mapping(uint64 => mapping(bytes32 => mapping(uint256 => bytes))) versionable_addresses;

// version => node => coinType => val
// uint64 => bytes32 => uint256 => bytes

// inner => version, slot

// Main function
function computeVersionableAddressSlot(
  version: bigint,
  node: `0x${string}`,
  coinType = 60n,
  slot = 2n
): `0x${string}` {
  const inner = keccak256(
    encodeAbiParameters(
      [
        {
          name: 'version',
          type: 'uint64',
        },
        {
          name: 'slot',
          type: 'uint256',
        },
      ],
      [version, slot]
    )
  );

  const mid = keccak256(
    encodeAbiParameters(
      [
        {
          name: 'node',
          type: 'bytes32',
        },
        {
          name: 'inner',
          type: 'bytes32',
        },
      ],
      [node, inner]
    )
  );

  const finalSlot = keccak256(
    encodeAbiParameters(
      [
        {
          name: 'coinType',
          type: 'uint256',
        },
        {
          name: 'mid',
          type: 'bytes32',
        },
      ],
      [coinType, mid]
    )
  );

  return finalSlot;
}

const slot = computeVersionableAddressSlot(0n, node);

export const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(),
});

const block = await publicClient.getBlock();

// ENS Public
const address = '0x231b0ee14048e9dccd1d247744d114a4eb5e8e63';

const p = await publicClient.getProof({
  address,
  storageKeys: [slot],
  blockNumber: block.number,
});

const stateTrie = new Trie({ root: hexToBytes(block.stateRoot) });
const addressHash = keccak256(hexToBytes(address), 'bytes');
const accountProofBuffers = p.accountProof.map((p) => hexToBytes(p));

const accountRlp = await stateTrie.verifyProof(
  stateTrie.root(),
  addressHash,
  accountProofBuffers
);

const storageTrie = new Trie({ root: hexToBytes(p.storageHash) });
const storageProofBuffers = (p.storageProof[0] ?? { proof: [] })?.proof.map(
  (p) => hexToBytes(p)
);

await storageTrie.verifyProof(
  storageTrie.root(),
  keccak256(slot, 'bytes'),
  storageProofBuffers
);

const account = {
  address: parseArray(p.address),
  balance: toHex(p.balance),
  codeHash: parseArray(p.codeHash),
  nonce: toHex(p.nonce),
  storageHash: parseArray(p.storageHash),
};

const leafNode = p.accountProof.at(-1) ?? '0x00';
const nodes = p.accountProof.slice(0, -1);

const storageLeafNode = p.storageProof.at(0)?.proof.at(-1) ?? '0x0';
const storageNodes = p.storageProof.at(0)?.proof.slice(0, -1) ?? [];
const storageKey = p.storageProof.at(0)?.key ?? '0x0';
const storageValue = toHex(p.storageProof.at(0)?.value ?? 0n);

const proof = {
  nodes: nodes.map((val) => {
    const parsed = parseArray(rightPad(val, 532));
    return parsed;
  }),
  leaf: parseArray(rightPad(leafNode, 148)),
  depth: p.accountProof.length,
};

const storageProof = {
  nodes: storageNodes.map((val) => {
    const parsed = parseArray(rightPad(val, 532));
    return parsed;
  }),
  leaf: parseArray(rightPad(storageLeafNode, 69)),
  depth: p.storageProof.at(0)?.proof.length ?? 0,
};

const accountProof = {
  key: parseArray(leftPad(keccak256(p.address, 'bytes'), 66)),
  value: parseArray(leftPad(accountRlp ?? [], 110)),
  proof,
};

const storageProofInput = {
  key: parseArray(leftPad(keccak256(storageKey), 66)),
  value: parseArray(leftPad(storageValue, 32)),
  proof: storageProof,
};

// console.log({
//   account,
//   accountProof,
//   storageProof: storageProofInput,
//   storageHash: parseArray(p.storageHash),
//   stateRoot: parseArray(block.stateRoot),
// });

console.log('Storage Value: ', hexToBytes(storageValue));
const leaf = hexToBytes(storageLeafNode);

console.log('Leaf: ', leaf);
console.log('Leaf Decoded: ', fromRlp(leaf, 'bytes'));

const sliced = leaf.slice(34, 34 + 33);
console.log(sliced);
