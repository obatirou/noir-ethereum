import { Trie } from '@ethereumjs/trie';
import { MapDB, utf8ToBytes } from '@ethereumjs/util';

import { toHex } from 'viem';
const trie = await Trie.create({ db: new MapDB() });

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

const key1 = utf8ToBytes('a');
const key2 = utf8ToBytes('b');

const value1 = utf8ToBytes('value1');
const value2 = utf8ToBytes('value2');

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

const walk = trie.walkTrieIterable(trie.root());

for await (const { node, currentKey } of walk) {
  console.log({ node, currentKey });
}
