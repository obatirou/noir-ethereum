import { Field } from '@zkpersona/noir-helpers';

export const toU128 = (value: bigint) => {
  const mask64 = (1n << 64n) - 1n; // Mask to extract lower 64 bits
  const lo = value & mask64; // Lower 64 bits
  const hi = value >> 64n; // Higher 64 bits
  return { lo: new Field(lo), hi: new Field(hi) };
};
