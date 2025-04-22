use crate::mpt::proof::ProofInput;
use super::constants::MAX_PREFIXED_KEY_NIBBLE_LENGTH;

/// The type of a transaction.
///
/// 0: Legacy transaction
/// 1: EIP-2930 transaction
/// 2: EIP-1559 transaction
/// 3: EIP-4844 transaction
/// 4: EIP-7702 transaction
pub type TransactionType = u8;

pub type TransactionProof<let MaxLeafLen: u32, let MaxEncodedTxLen: u32, let MaxDepthNoLeaf: u32> = ProofInput<MAX_PREFIXED_KEY_NIBBLE_LENGTH, MaxEncodedTxLen, MaxDepthNoLeaf, MaxLeafLen>;
