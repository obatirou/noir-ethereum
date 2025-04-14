import {
  http,
  createPublicClient,
  hexToBytes,
  keccak256,
  toHex,
  toRlp,
} from 'viem';
import { mainnet } from 'viem/chains';

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

export const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(),
});

const block = await publicClient.getBlock();
console.log(block);

const address = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';

const p = await publicClient.getProof({
  address,
  storageKeys: [],
  blockNumber: block.number,
});

const account = {
  address: parseArray(p.address),
  balance: toHex(p.balance),
  codeHash: parseArray(p.codeHash),
  nonce: toHex(p.nonce),
  storageHash: parseArray(p.storageHash),
};

const leafNode = p.accountProof.at(-1) ?? '0x00';
const nodes = p.accountProof.slice(0, -1);

const proof = {
  nodes: nodes.map((val) => {
    const parsed = parseArray(rightPad(val, 532));
    return parsed;
  }),
  leaf: parseArray(rightPad(leafNode, 148)),
  depth: p.accountProof.length,
};

const accountProof = {
  key: parseArray(leftPad(keccak256(p.address, 'bytes'), 66)),
  value: parseArray(
    leftPad(
      toRlp([toHex(p.nonce), toHex(p.balance), p.storageHash, p.codeHash]),
      110
    )
  ),
  proof,
};

// console.log({
//   account,
//   accountProof,
//   stateRoot: parseArray(block.stateRoot),
// });
