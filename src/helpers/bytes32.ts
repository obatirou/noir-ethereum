import { FixedSizeArray, U8 } from '@zkpersona/noir-helpers';
import { type Hex, hexToBytes } from 'viem';

export const parseBytes32 = (data: Hex) => {
  const buffer = Array.from(hexToBytes(data));
  if (buffer.length !== 32) {
    throw new Error('data must be 32 bytes');
  }
  const arr = buffer.map((x) => new U8(x));
  return new FixedSizeArray(32, arr);
};
