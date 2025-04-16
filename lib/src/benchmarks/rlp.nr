use crate::mpt::types::Node;
use crate::rlp::decode::decode_list_of_small_strings;
use crate::rlp::list::RlpList;
use crate::types::fragment::Fragment;

#[export]
pub fn benchmark_decode_node(node: Node) -> RlpList<17> {
    let rlp_list: RlpList<17> = decode_list_of_small_strings(Fragment::from_array(node));

    rlp_list
}
