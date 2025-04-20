import { FixedSizeArray, U8 } from '@zkpersona/noir-helpers';
import { type Hex, hexToBytes } from 'viem';

export const parseAddress = (address: Hex) => {
  const buffer = Array.from(hexToBytes(address));
  if (buffer.length !== 20) {
    throw new Error('Address must be 20 bytes');
  }
  const arr = buffer.map((x) => new U8(x));
  return new FixedSizeArray(20, arr);
};
