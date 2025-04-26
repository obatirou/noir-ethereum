use crate::mpt::proof::ProofInput;
use super::constants::{BLOOM_FILTER_LENGTH, MAX_PREFIXED_KEY_NIBBLE_LEN};

pub type LogsBloom = [u8; BLOOM_FILTER_LENGTH];

pub type ReceiptProof<let MaxEncodedLen: u32, let MaxDepthNoLeaf: u32, let MaxLeafLen: u32> = ProofInput<MAX_PREFIXED_KEY_NIBBLE_LEN, MaxEncodedLen, MaxDepthNoLeaf, MaxLeafLen>;
