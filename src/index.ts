import { U8 } from '@zkpersona/noir-helpers';

class FixedSizedArray<T, N extends number> {
  readonly data: T[];

  constructor(length: N, data: T[]) {
    if (data.length !== length) {
      throw new Error(
        `Expected array of length ${length}, but got ${data.length}`
      );
    }
    this.data = data;
  }

  get(index: number): T | undefined {
    return this.data[index];
  }

  toArray(): T[] {
    return [...this.data];
  }
}

const data = Array.from({ length: 32 }, () => new U8(1));

const arr = new FixedSizedArray<U8, 32>(32, data);
