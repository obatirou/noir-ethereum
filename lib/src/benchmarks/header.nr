use crate::header::{header::{BlockHeaderPartial, verify_header}, types::BlockHeaderRlp};

#[export]
pub fn benchmark_verify_header(
    chain_id: u64,
    block_header_partial: BlockHeaderPartial,
    block_header_rlp: BlockHeaderRlp,
) {
    verify_header(chain_id, block_header_partial, block_header_rlp);
}
