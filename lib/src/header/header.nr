use std::hash::keccak256;

use crate::helpers::arrays::sub_array_equals;
use crate::rlp::{decode::decode_list, list::RlpList};
use crate::types::{address::Address, bytes32::Bytes32, fragment::Fragment, hash::Hash};

use super::constants::{
    BLOCK_NUMBER_INDEX, MAX_HEADER_FIELDS_COUNT, RECEIPTS_ROOT_INDEX, STATE_ROOT_INDEX,
    TRANSACTIONS_ROOT_INDEX, WITHDRAWALS_ROOT_INDEX,
};
use super::{helpers::get_header_fields_count, types::BlockHeaderRlp};

pub struct BlockHeader {
    parent_hash: Hash,
    ommers_hash: Hash,
    beneficiary: Address,
    state_root: Hash,
    transactions_root: Hash,
    receipts_root: Hash,
    logs_bloom: [u8; 256],
    difficulty: u64,
    number: u64,
    gas_limit: u64,
    gas_used: u64,
    timestamp: u64,
    extra_data: Bytes32,
    mix_hash: Hash,
    nonce: u64,
    base_fee_per_gas: Bytes32,
    withdrawals_root: Option<Hash>, // Introduced in Shanghai Upgrade
    blob_gas_used: Option<u64>, // Introduced in EIP-4844
    excess_blob_gas: Option<u64>, // Introduced in EIP-4844
    parent_beacon_block_root: Option<Bytes32>, // Introduced in EIP-4788
}

// Partial block header, used for state, transaction and receipt verification
pub struct BlockHeaderPartial {
    number: u64,
    hash: Hash,
    state_root: Hash,
    transactions_root: Hash,
    receipts_root: Hash,
    withdrawals_root: Option<Hash>, // Introduced in Shanghai Upgrade
}

impl BlockHeader {
    pub fn new(
        parent_hash: Hash,
        ommers_hash: Hash,
        beneficiary: Address,
        state_root: Hash,
        transactions_root: Hash,
        receipts_root: Hash,
        logs_bloom: [u8; 256],
        difficulty: u64,
        number: u64,
        gas_limit: u64,
        gas_used: u64,
        timestamp: u64,
        extra_data: Bytes32,
        mix_hash: Hash,
        nonce: u64,
        base_fee_per_gas: Bytes32,
        withdrawals_root: Option<Hash>, // Introduced in Shanghai Upgrade
        blob_gas_used: Option<u64>, // Introduced in EIP-4844
        excess_blob_gas: Option<u64>, // Introduced in EIP-4844
        parent_beacon_block_root: Option<Bytes32>, // Introduced in EIP-4788
    ) -> Self {
        Self {
            parent_hash,
            ommers_hash,
            beneficiary,
            state_root,
            transactions_root,
            receipts_root,
            logs_bloom,
            difficulty,
            number,
            gas_limit,
            gas_used,
            timestamp,
            extra_data,
            mix_hash,
            nonce,
            base_fee_per_gas,
            withdrawals_root,
            blob_gas_used,
            excess_blob_gas,
            parent_beacon_block_root,
        }
    }

    pub fn parent_hash(self) -> Hash {
        self.parent_hash
    }

    pub fn ommers_hash(self) -> Hash {
        self.ommers_hash
    }

    pub fn beneficiary(self) -> Address {
        self.beneficiary
    }

    pub fn state_root(self) -> Hash {
        self.state_root
    }

    pub fn transactions_root(self) -> Hash {
        self.transactions_root
    }

    pub fn receipts_root(self) -> Hash {
        self.receipts_root
    }

    pub fn logs_bloom(self) -> [u8; 256] {
        self.logs_bloom
    }

    pub fn difficulty(self) -> u64 {
        self.difficulty
    }

    pub fn number(self) -> u64 {
        self.number
    }

    pub fn gas_limit(self) -> u64 {
        self.gas_limit
    }

    pub fn gas_used(self) -> u64 {
        self.gas_used
    }

    pub fn timestamp(self) -> u64 {
        self.timestamp
    }

    pub fn extra_data(self) -> Bytes32 {
        self.extra_data
    }

    pub fn mix_hash(self) -> Hash {
        self.mix_hash
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn base_fee_per_gas(self) -> Bytes32 {
        self.base_fee_per_gas
    }

    pub fn withdrawals_root(self) -> Option<Hash> {
        self.withdrawals_root
    }

    pub fn blob_gas_used(self) -> Option<u64> {
        self.blob_gas_used
    }

    pub fn excess_blob_gas(self) -> Option<u64> {
        self.excess_blob_gas
    }
}

impl BlockHeaderPartial {
    pub fn new(
        number: u64,
        hash: Hash,
        state_root: Hash,
        transactions_root: Hash,
        receipts_root: Hash,
        withdrawals_root: Option<Hash>, // Introduced in Shanghai Upgrade
    ) -> Self {
        Self { number, hash, state_root, transactions_root, receipts_root, withdrawals_root }
    }

    pub fn number(self) -> u64 {
        self.number
    }

    pub fn hash(self) -> Hash {
        self.hash
    }

    pub fn state_root(self) -> Hash {
        self.state_root
    }

    pub fn transactions_root(self) -> Hash {
        self.transactions_root
    }

    pub fn receipts_root(self) -> Hash {
        self.receipts_root
    }

    pub fn withdrawals_root(self) -> Option<Hash> {
        self.withdrawals_root
    }
}

pub fn verify_header(
    chain_id: u64,
    block_header_partial: BlockHeaderPartial,
    block_header_rlp: BlockHeaderRlp,
) {
    let block_header_rlp = Fragment::from_vec(block_header_rlp);
    let header_rlp_list: RlpList<MAX_HEADER_FIELDS_COUNT> = decode_list(block_header_rlp);

    let expected_header_fields_count =
        get_header_fields_count(chain_id, block_header_partial.number);
    let actual_header_fields_count = header_rlp_list.len() as u64;

    assert(
        expected_header_fields_count == actual_header_fields_count,
        f"Expected header fields count: {expected_header_fields_count}, got
        : {actual_header_fields_count}",
    );

    header_rlp_list.get(BLOCK_NUMBER_INDEX).assert_eq_u64(
        "Block number",
        block_header_rlp,
        block_header_partial.number,
    );
    header_rlp_list.get(STATE_ROOT_INDEX).assert_eq_bytes32(
        "State Root",
        block_header_rlp,
        block_header_partial.state_root,
    );
    header_rlp_list.get(TRANSACTIONS_ROOT_INDEX).assert_eq_bytes32(
        "Transactions Root",
        block_header_rlp,
        block_header_partial.transactions_root,
    );
    header_rlp_list.get(RECEIPTS_ROOT_INDEX).assert_eq_bytes32(
        "Receipts Root",
        block_header_rlp,
        block_header_partial.receipts_root,
    );

    // Only check withdrawals root if it is present in the block header partial
    if (block_header_partial.withdrawals_root.is_some()) {
        header_rlp_list.get(WITHDRAWALS_ROOT_INDEX).assert_eq_bytes32(
            "Withdrawals Root",
            block_header_rlp,
            block_header_partial.withdrawals_root().unwrap(),
        );
    }

    assert(
        sub_array_equals(
            keccak256(block_header_rlp.data(), block_header_rlp.len() as u32),
            block_header_partial.hash,
            0,
        ),
        "Block Hash does not Match",
    );
}

mod pre_london_tests {
    use crate::fixtures::header::{PRE_LONDON_BLOCK_HEADER_RLP, PRE_LONDON_PARTIAL_BLOCK_HEADER};
    use super::verify_header;

    #[test]
    fn test_verify_pre_london_block() {
        verify_header(
            1,
            PRE_LONDON_PARTIAL_BLOCK_HEADER,
            PRE_LONDON_BLOCK_HEADER_RLP,
        );
    }
}

mod post_london_tests {
    use crate::fixtures::header::{POST_LONDON_BLOCK_HEADER_RLP, POST_LONDON_PARTIAL_BLOCK_HEADER};
    use super::verify_header;

    #[test]
    fn test_verify_post_london_block() {
        verify_header(
            1,
            POST_LONDON_PARTIAL_BLOCK_HEADER,
            POST_LONDON_BLOCK_HEADER_RLP,
        );
    }
}

mod post_shanghai_tests {
    use crate::fixtures::header::{
        POST_SHANGHAI_BLOCK_HEADER_RLP, POST_SHANGHAI_PARTIAL_BLOCK_HEADER,
    };
    use super::verify_header;

    #[test]
    fn test_verify_post_shanghai_block() {
        verify_header(
            1,
            POST_SHANGHAI_PARTIAL_BLOCK_HEADER,
            POST_SHANGHAI_BLOCK_HEADER_RLP,
        );
    }
}

mod post_cancun_tests {
    use crate::fixtures::header::{POST_CANCUN_BLOCK_HEADER_RLP, POST_CANCUN_PARTIAL_BLOCK_HEADER};
    use super::verify_header;

    #[test]
    fn test_verify_post_cancun_block() {
        verify_header(
            1,
            POST_CANCUN_PARTIAL_BLOCK_HEADER,
            POST_CANCUN_BLOCK_HEADER_RLP,
        );
    }
}
