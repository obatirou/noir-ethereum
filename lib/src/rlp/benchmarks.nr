use crate::rlp::decode::{decode_list, decode_string};
use crate::types::fragment::Fragment;
use super::{decode::decode_to_rlp_header, fragment::RlpFragment, header::RlpHeader};

#[export]
pub fn benchmark_decode_single_byte() -> RlpHeader {
    let data = Fragment::from_array([0x42]);
    decode_to_rlp_header(data)
}

#[export]
pub fn benchmark_decode_string() -> RlpFragment {
    // Test case: Short string "hello" (5 bytes)
    let data = Fragment::from_array([0x85, 0x68, 0x65, 0x6c, 0x6c, 0x6f]);
    decode_string(data)
}

#[export]
pub fn benchmark_decode_short_list() -> BoundedVec<RlpFragment, 3> {
    // Test case: Short list [1, 2, 3]
    let data = Fragment::from_array([0xc3, 0x01, 0x02, 0x03]);
    let list: BoundedVec<RlpFragment, 3> = decode_list(data);
    list
}

#[export]
pub fn benchmark_decode_long_list() -> BoundedVec<RlpFragment, 255> {
    let mut data: [u8; 255 + 2] = [0x42; 0xff + 2];
    data[0] = 0xf8;
    data[1] = 0xff;
    let data = Fragment::from_array(data);
    let list: BoundedVec<RlpFragment, 255> = decode_list(data);
    list
}
