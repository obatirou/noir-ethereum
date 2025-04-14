import { Trie } from '@ethereumjs/trie';
import { toBytes } from '@ethereumjs/util';
import { http, createPublicClient, fromRlp, keccak256, toHex } from 'viem';
import { mainnet } from 'viem/chains';

export const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(),
});

const block = await publicClient.getBlock();
const stateRoot = block.stateRoot;

const p = await publicClient.getProof({
  address: '0x4200000000000000000000000000000000000016',
  storageKeys: [
    '0x4a932049252365b3eedbc5190e18949f2ec11f39d3bef2d259764799a1b27d99',
  ],
  blockNumber: block.number,
});

console.log(p);
console.log('\n\n');

const proof = {
  accountProof: p.accountProof.map((x) => toBytes(x)),
};

// Initialize the state trie with the stateRoot
const stateTrie = await Trie.createFromProof(proof.accountProof);

// Convert the account address to a buffer
const addressHash = toBytes(keccak256(p.address));

// Verify the account proof
const accountValue = await stateTrie.verifyProof(
  stateTrie.root(),
  addressHash,
  proof.accountProof
);

if (!accountValue) {
  throw new Error('Account value not found');
}

const accountRlp = toHex(accountValue);

const extractedStorageRoot = fromRlp(accountRlp, 'hex')[2];

console.log('Extracted Storage Root: ', extractedStorageRoot);
console.log('Expected Storage Root: ', p.storageHash);
