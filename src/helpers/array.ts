import { U8 } from '@zkpersona/noir-helpers';
import { type Hex, hexToBytes } from 'viem';

export const parseByteArray = (data: Hex) => {
  const buffer = Array.from(hexToBytes(data));
  return buffer.map((x) => new U8(x));
};

export const leftPad = (
  data: number[] | Hex | Uint8Array,
  finalLength: number
) => {
  const arr = Array.isArray(data)
    ? data
    : // biome-ignore lint/nursery/noNestedTernary: <explanation>
      data instanceof Uint8Array
      ? Array.from(data)
      : Array.from(hexToBytes(data));
  const zerosToAdd = finalLength - arr.length;
  if (zerosToAdd < 0) {
    throw new Error('Final length is less than the data length');
  }
  return [...new Array<number>(zerosToAdd).fill(0), ...arr];
};

export const rightPad = (
  data: number[] | Hex | Uint8Array,
  finalLength: number
) => {
  const arr = Array.isArray(data)
    ? data
    : // biome-ignore lint/nursery/noNestedTernary: <explanation>
      data instanceof Uint8Array
      ? Array.from(data)
      : Array.from(hexToBytes(data));
  const zerosToAdd = finalLength - arr.length;
  if (zerosToAdd < 0) {
    throw new Error('Final length is less than the data length');
  }
  return [...arr, ...new Array<number>(zerosToAdd).fill(0)];
};
