use crate::helpers::bytes::right_pad;
use crate::mpt::verify::verify_merkle_proof;
use crate::rlp::list::RlpList;
use crate::transaction::{helpers::assert_transaction_index_equals, types::TransactionType};
use crate::types::{address::Address, bytes32::Bytes32, fragment::Fragment, hash::Hash};

use super::constants::RECEIPT_FIELDS_COUNT;
use super::{helpers::assert_receipt_equals, types::{LogsBloom, ReceiptProof}};

pub struct Log<let MaxLogDataLen: u32, let MaxTopicsCount: u32> {
    address: Address,
    topics: BoundedVec<Bytes32, MaxTopicsCount>,
    data: BoundedVec<u8, MaxLogDataLen>,
}

impl<let MaxLogDataLen: u32, let MaxTopicsCount: u32> Log<MaxLogDataLen, MaxTopicsCount> {
    pub fn new(
        address: Address,
        topics: BoundedVec<Bytes32, MaxTopicsCount>,
        data: BoundedVec<u8, MaxLogDataLen>,
    ) -> Self {
        Self { address, topics, data }
    }

    pub fn address(self) -> Address {
        self.address
    }

    pub fn topics(self) -> BoundedVec<Bytes32, MaxTopicsCount> {
        self.topics
    }

    pub fn data(self) -> BoundedVec<u8, MaxLogDataLen> {
        self.data
    }
}

impl<let MaxLogDataLen: u32, let MaxTopicsCount: u32> Eq for Log<MaxLogDataLen, MaxTopicsCount> {
    fn eq(self, other: Self) -> bool {
        (self.address == other.address) & (self.topics == other.topics) & (self.data == other.data)
    }
}

pub struct TransactionReceiptPartial {
    state_root: Option<Hash>,
    status: Option<u1>,
    cumulative_gas_used: u64,
    logs_bloom: LogsBloom,
}

impl TransactionReceiptPartial {
    pub fn new(
        state_root: Option<Hash>,
        status: Option<u1>,
        cumulative_gas_used: u64,
        logs_bloom: LogsBloom,
    ) -> Self {
        Self { state_root, status, cumulative_gas_used, logs_bloom }
    }

    pub fn state_root(self) -> Option<Hash> {
        self.state_root
    }

    pub fn status(self) -> Option<u1> {
        self.status
    }

    pub fn cumulative_gas_used(self) -> u64 {
        self.cumulative_gas_used
    }

    pub fn logs_bloom(self) -> LogsBloom {
        self.logs_bloom
    }
}

impl Eq for TransactionReceiptPartial {
    fn eq(self, other: Self) -> bool {
        (self.state_root == other.state_root)
            & (self.status == other.status)
            & (self.cumulative_gas_used == other.cumulative_gas_used)
            & (self.logs_bloom == other.logs_bloom)
    }
}

pub fn verify_receipt_proof<let MaxEncodedLen: u32, let MaxDepthNoLeaf: u32, let MaxLeafLen: u32>(
    block_number: u64,
    transaction_index: u64,
    transaction_type: TransactionType,
    receipt: TransactionReceiptPartial,
    receipt_proof: ReceiptProof<MaxEncodedLen, MaxDepthNoLeaf, MaxLeafLen>,
    receipt_root: Hash,
) -> RlpList<RECEIPT_FIELDS_COUNT> {
    let key = Fragment::from_vec(right_pad(receipt_proof.key()));
    assert_transaction_index_equals(key, transaction_index);

    let value = right_pad(receipt_proof.value()).storage();
    let rlp_list: RlpList<RECEIPT_FIELDS_COUNT> = assert_receipt_equals(
        block_number,
        transaction_type,
        Fragment::from_array(value),
        receipt,
    );
    verify_merkle_proof(
        receipt_proof.key(),
        receipt_proof.value(),
        receipt_root,
        receipt_proof.proof(),
    );

    rlp_list
}
