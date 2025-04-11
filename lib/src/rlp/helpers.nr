use crate::types::fragment::Fragment;

global MAX_LEN_IN_BYTES: u64 = 2;

pub fn read_u64_be<let N: u32>(data: Fragment<u8, N>, lenlen: u64) -> u64 {
    assert(lenlen <= MAX_LEN_IN_BYTES, "Byte Length exceeds the maximum length");
    let mut result: u64 = 0;

    for i in 0..MAX_LEN_IN_BYTES {
        if (i < lenlen & i < data.len()) {
            result = data.at(i) as u64 + result * 256;
        }
    }
    result
}
