import { encodeAbiParameters, keccak256 } from 'viem';
import { namehash, normalize } from 'viem/ens';

export const getENSNameStorageSlot = (name: string) => {
  const normalized = normalize(name);
  const node = namehash(normalized);

  // Contract: ENSPublicResolver (0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63)
  // mapping(uint64 => mapping(bytes32 => mapping(uint256 => bytes))) versionable_addresses;
  // Slot 2

  const version = 0n;
  const slot = 2n;
  const coinType = 60n; // ETH

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
};
