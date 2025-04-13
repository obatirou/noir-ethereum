import { Trie } from '@ethereumjs/trie';
import { toHex } from 'viem';
const trie = new Trie();

const leftPad = (arr: number[], finalLength: number) => {
  const padded = new Array(finalLength - arr.length).fill(0);
  return [...padded, ...arr];
};

const rightPad = (arr: number[], finalLength: number) => {
  const padded = new Array(finalLength - arr.length).fill(0);
  return [...arr, ...padded];
};

const joinArray = (arr: string[]) => {
  return `[${arr.join(', ')}]`;
};

const key1 = Buffer.from('abcd'); // Shared prefix: 'ab'
const key2 = Buffer.from('abef'); // Shared prefix: 'ab'

const value1 = Buffer.from('value1');
const value2 = Buffer.from('value2');

console.log(key1.toString('utf-8'));

// Insert key-value pairs into the trie
await trie.put(key1, value1);
await trie.put(key2, value2);

const proof = await trie.createProof(key1);

const root = Array.from(trie.root()).map((x) => toHex(x));
const k = leftPad(Array.from(key1), (key1.length + 1) * 2).map((x) => toHex(x));
const v = Array.from(value1).map((x) => toHex(x));
const depth = proof.length;
const l = proof.splice(proof.length - 1, 1)[0];
const leaf = Array.from(l ?? []).map((x) => toHex(x));

console.log('Depth: ', depth);
console.log('Root: ', joinArray(root));
console.log('Key: ', joinArray(k));
console.log('Value: ', joinArray(v));
console.log('Leaf: ', joinArray(leaf));

for (let i = 0; i < proof.length; i++) {
  const p = proof[i]!;
  const node = rightPad(Array.from(p ?? []), 532).map((x) => toHex(x));
  console.log(`Node ${i}: `, joinArray(node));
}
