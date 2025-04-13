use crate::helpers::iterator::Iterator;
use crate::types::fragment::Fragment;

pub fn byte_to_nibbles(byte: u8) -> (u8, u8) {
    let upper = byte / 16;
    let lower = byte - 16 * upper;

    (upper, lower)
}

pub fn bytes_to_nibbles<let MaxLen: u32>(bytes: Fragment<u8, MaxLen>) -> Fragment<u8, MaxLen> {
    assert(
        (MaxLen as u64) >= 2 * bytes.len(),
        "Bytes implicit data length must be at least 2 times larger than bytes explicit length",
    );

    let nibbles = &mut Fragment::from_array_with_len(2 * bytes.len(), [0; MaxLen]);

    bytes.each(|byte, i| {
        let (hi, lo) = byte_to_nibbles(byte);
        nibbles.set(2 * i, hi);
        nibbles.set(2 * i + 1, lo);
    });

    *nibbles
}

pub fn nibbles_to_byte(upper: u8, lower: u8) -> u8 {
    assert(upper < 16, "Nibble value must be less than 16");
    assert(lower < 16, "Nibble value must be less than 16");

    upper * 16 + lower
}

pub fn nibbles_to_bytes<let BytesLen: u32, let NibblesLen: u32>(
    nibbles: [u8; NibblesLen],
) -> [u8; BytesLen] {
    assert(NibblesLen == 2 * BytesLen, "Generic arguments don't match");

    let mut bytes = [0; BytesLen];

    for i in 0..NibblesLen / 2 {
        let byte = nibbles_to_byte(nibbles[2 * i], nibbles[2 * i + 1]);
        bytes[i] = byte;
    }

    bytes
}

pub fn left_byte_shift<let N: u32>(input: [u8; N], n: u64) -> [u8; N] {
    let mut out: [u8; N] = [0; N];

    for i in 0..N {
        let index_ind = (((i.into() + n) as u32) < (N as u32)) as u64;
        out[i] = (index_ind as u8) * input[index_ind * (i.into() + n)];
    }

    out
}

pub fn byte_value<let N: u32>(in_value: [u8; N]) -> BoundedVec<u8, N> {
    let mut value_length = 0;

    for i in 0..N {
        let num_bytes_index = (value_length == 0) as u32;
        let byte_index = (in_value[i] != 0) as u32;
        value_length =
            num_bytes_index * byte_index * (N - i) + (1 - num_bytes_index) * value_length;
    }

    let value: [u8; N] = left_byte_shift(in_value, (N - value_length) as u64);

    BoundedVec { storage: value, len: value_length }
}

pub fn right_pad<let N: u32>(arr: [u8; N]) -> BoundedVec<u8, N> {
    byte_value(arr)
}
