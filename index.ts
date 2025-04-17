// import {
//   http,
//   createPublicClient,
//   encodeAbiParameters,
//   hexToBytes,
//   keccak256,
//   toHex,
// } from 'viem';
// import { mainnet } from 'viem/chains';

// import { Trie } from '@ethereumjs/trie';

// import path from 'path';
// import {
//   Field,
//   FixedSizeArray,
//   U8,
//   U64,
//   generateToml,
//   toJSON,
// } from '@zkpersona/noir-helpers';
// import { namehash } from 'viem';

// const parseArray = (data: number[] | `0x${string}` | Uint8Array) => {
//   const arr = Array.isArray(data)
//     ? data
//     : // biome-ignore lint/nursery/noNestedTernary: <explanation>
//       data instanceof Uint8Array
//       ? Array.from(data)
//       : Array.from(hexToBytes(data));
//   return `[${arr.join(', ')}]`;
// };

// const leftPad = (
//   data: number[] | `0x${string}` | Uint8Array,
//   finalLength: number
// ) => {
//   const arr = Array.isArray(data)
//     ? data
//     : // biome-ignore lint/nursery/noNestedTernary: <explanation>
//       data instanceof Uint8Array
//       ? Array.from(data)
//       : Array.from(hexToBytes(data));
//   const zeroToAdd = finalLength - arr.length;
//   return [...new Array<number>(zeroToAdd).fill(0), ...arr];
// };

// const rightPad = (
//   data: number[] | `0x${string}` | Uint8Array,
//   finalLength: number
// ) => {
//   const arr = Array.isArray(data)
//     ? data
//     : // biome-ignore lint/nursery/noNestedTernary: <explanation>
//       data instanceof Uint8Array
//       ? Array.from(data)
//       : Array.from(hexToBytes(data));
//   const zeroToAdd = finalLength - arr.length;
//   return [...arr, ...new Array<number>(zeroToAdd).fill(0)];
// };

// const node = namehash('envoy1084.eth');

// // mapping(uint64 => mapping(bytes32 => mapping(uint256 => bytes))) versionable_addresses;

// // version => node => coinType => val
// // uint64 => bytes32 => uint256 => bytes

// // inner => version, slot

// // Main function
// function computeVersionableAddressSlot(
//   version: bigint,
//   node: `0x${string}`,
//   coinType = 60n,
//   slot = 2n
// ): `0x${string}` {
//   const inner = keccak256(
//     encodeAbiParameters(
//       [
//         {
//           name: 'version',
//           type: 'uint64',
//         },
//         {
//           name: 'slot',
//           type: 'uint256',
//         },
//       ],
//       [version, slot]
//     )
//   );

//   const mid = keccak256(
//     encodeAbiParameters(
//       [
//         {
//           name: 'node',
//           type: 'bytes32',
//         },
//         {
//           name: 'inner',
//           type: 'bytes32',
//         },
//       ],
//       [node, inner]
//     )
//   );

//   const finalSlot = keccak256(
//     encodeAbiParameters(
//       [
//         {
//           name: 'coinType',
//           type: 'uint256',
//         },
//         {
//           name: 'mid',
//           type: 'bytes32',
//         },
//       ],
//       [coinType, mid]
//     )
//   );

//   return finalSlot;
// }

// const slot = computeVersionableAddressSlot(0n, node);

// export const publicClient = createPublicClient({
//   chain: mainnet,
//   transport: http(),
// });

// const block = await publicClient.getBlock();
// // ENS Public
// block.const;
// address = '0x231b0ee14048e9dccd1d247744d114a4eb5e8e63';

// const p = await publicClient.getProof({
//   address,
//   storageKeys: [slot],
//   blockNumber: block.number,
// });

// const stateTrie = new Trie({ root: hexToBytes(block.stateRoot) });
// const addressHash = keccak256(hexToBytes(address), 'bytes');
// const accountProofBuffers = p.accountProof.map((p) => hexToBytes(p));

// const accountRlp = await stateTrie.verifyProof(
//   stateTrie.root(),
//   addressHash,
//   accountProofBuffers
// );

// const storageTrie = new Trie({ root: hexToBytes(p.storageHash) });
// const storageProofBuffers = (p.storageProof[0] ?? { proof: [] })?.proof.map(
//   (p) => hexToBytes(p)
// );

// const storageValueRlp = await storageTrie.verifyProof(
//   storageTrie.root(),
//   keccak256(slot, 'bytes'),
//   storageProofBuffers
// );

// const account = {
//   address: parseArray(p.address),
//   balance: toHex(p.balance),
//   codeHash: parseArray(p.codeHash),
//   nonce: toHex(p.nonce),
//   storageHash: parseArray(p.storageHash),
// };

// const leafNode = p.accountProof.at(-1) ?? '0x00';
// const nodes = p.accountProof.slice(0, -1);

// const storageLeafNode = p.storageProof.at(0)?.proof.at(-1) ?? '0x0';
// const storageNodes = p.storageProof.at(0)?.proof.slice(0, -1) ?? [];
// const storageKey = p.storageProof.at(0)?.key ?? '0x0';
// const storageValue = toHex(p.storageProof.at(0)?.value ?? 0n);

// const proof = {
//   nodes: nodes.map((val) => {
//     const parsed = parseArray(rightPad(val, 532));
//     return parsed;
//   }),
//   leaf: parseArray(rightPad(leafNode, 148)),
//   depth: p.accountProof.length,
// };

// const storageProof = {
//   nodes: storageNodes.map((val) => {
//     const parsed = parseArray(rightPad(val, 532));
//     return parsed;
//   }),
//   leaf: parseArray(rightPad(storageLeafNode, 69)),
//   depth: p.storageProof.at(0)?.proof.length ?? 0,
// };

// const accountProof = {
//   key: parseArray(leftPad(keccak256(p.address, 'bytes'), 66)),
//   value: parseArray(leftPad(accountRlp ?? [], 110)),
//   proof,
// };

// const storageProofInput = {
//   key: parseArray(leftPad(keccak256(storageKey), 66)),
//   value: parseArray(leftPad(storageValueRlp ?? [], 33)),
//   proof: storageProof,
// };

// const accountData = {
//   address: new FixedSizeArray(
//     20,
//     Array.from(hexToBytes(address)).map((x) => new U8(x))
//   ),
//   balance: new Field(account.balance),
//   code_hash: new FixedSizeArray(
//     32,
//     Array.from(hexToBytes(p.codeHash)).map((x) => new U8(x))
//   ),
//   storage_hash: new FixedSizeArray(
//     32,
//     Array.from(hexToBytes(p.storageHash)).map((x) => new U8(x))
//   ),
//   nonce: new U64(p.nonce),
// };

// const nodesData = nodes.map((val) => {
//   const items = rightPad(val, 532).map((x) => new U8(x));
//   return new FixedSizeArray(532, items);
// });

// const storageNodesData = storageNodes.map((val) => {
//   const items = rightPad(val, 532).map((x) => new U8(x));
//   return new FixedSizeArray(532, items);
// });

// while (nodesData.length !== 10) {
//   nodesData.push(new FixedSizeArray(532, new Array(532).fill(new U8(0))));
// }

// while (storageNodesData.length !== 6) {
//   storageNodesData.push(
//     new FixedSizeArray(532, new Array(532).fill(new U8(0)))
//   );
// }

// const proofData = {
//   key: new FixedSizeArray(
//     66,
//     leftPad(keccak256(p.address, 'bytes'), 66).map((x) => new U8(x))
//   ),
//   value: new FixedSizeArray(
//     110,
//     leftPad(accountRlp ?? [], 110).map((x) => new U8(x))
//   ),
//   proof: {
//     nodes: new FixedSizeArray(10, nodesData),
//     leaf: new FixedSizeArray(
//       148,
//       rightPad(leafNode, 148).map((x) => new U8(x))
//     ),
//     depth: new U64(p.accountProof.length),
//   },
// };

// const storageProofData = {
//   key: new FixedSizeArray(
//     66,
//     leftPad(keccak256(slot, 'bytes'), 66).map((x) => new U8(x))
//   ),
//   value: new FixedSizeArray(
//     33,
//     leftPad(storageValueRlp ?? [], 33).map((x) => new U8(x))
//   ),
//   proof: {
//     nodes: new FixedSizeArray(6, storageNodesData),
//     leaf: new FixedSizeArray(
//       69,
//       rightPad(storageLeafNode, 69).map((x) => new U8(x))
//     ),
//     depth: new U64(p.storageProof.at(0)?.proof.length ?? 0),
//   },
// };

// // const data = {
// //   account: accountData,
// //   account_proof: proofData,
// //   state_root: new FixedSizeArray(
// //     32,
// //     Array.from(hexToBytes(block.stateRoot)).map((x) => new U8(x))
// //   ),
// // };

// const data = {
//   storage_proof: storageProofData,
//   storage_root: new FixedSizeArray(
//     32,
//     Array.from(hexToBytes(p.storageHash)).map((x) => new U8(x))
//   ),
// };

// const inputs = toJSON(data);
// generateToml(inputs, path.join(__dirname, 'Prover.toml'));

// import { fromRlp } from 'viem';

// const arr = Uint8Array.from([
//   228, 130, 17, 35, 160, 96, 193, 223, 22, 218, 38, 132, 115, 174, 230, 176, 2,
//   202, 231, 156, 249, 16, 209, 250, 11, 200, 192, 102, 154, 250, 99, 27, 174,
//   208, 235, 111, 82,
// ]);

// console.log(fromRlp(arr, 'bytes'));
