//! Ethereum Transaction Receipt Structures and Verification
//!
//! This module provides structures and functions for working with Ethereum transaction receipts.

use crate::helpers::bytes::right_pad;
use crate::mpt::verify::verify_merkle_proof;
use crate::rlp::list::RlpList;
use crate::transaction::{helpers::assert_transaction_index_equals, types::TransactionType};
use crate::types::{address::Address, bytes32::Bytes32, fragment::Fragment, hash::Hash};

use super::constants::RECEIPT_FIELDS_COUNT;
use super::{helpers::assert_receipt_equals, types::{LogsBloom, ReceiptProof}};

/// Represents a log entry in an Ethereum transaction receipt.
///
/// A log entry contains:
/// - The address of the contract that emitted the event
/// - A list of topics (indexed parameters)
/// - The event data
///
/// # Generics
///
/// * `MaxLogDataLen` - Maximum length of the log data field
/// * `MaxTopicsCount` - Maximum number of topics allowed
pub struct Log<let MaxLogDataLen: u32, let MaxTopicsCount: u32> {
    /// The address of the contract that emitted the event
    address: Address,
    /// The indexed parameters of the event
    topics: BoundedVec<Bytes32, MaxTopicsCount>,
    /// The event data
    data: BoundedVec<u8, MaxLogDataLen>,
}

impl<let MaxLogDataLen: u32, let MaxTopicsCount: u32> Log<MaxLogDataLen, MaxTopicsCount> {
    /// Creates a new log entry.
    ///
    /// # Arguments
    ///
    /// * `address` - The contract address that emitted the event
    /// * `topics` - The indexed parameters of the event
    /// * `data` - The event data
    ///
    /// # Returns
    ///
    /// A new Log instance
    pub fn new(
        address: Address,
        topics: BoundedVec<Bytes32, MaxTopicsCount>,
        data: BoundedVec<u8, MaxLogDataLen>,
    ) -> Self {
        Self { address, topics, data }
    }

    /// Gets the contract address that emitted the event.
    ///
    /// # Returns
    ///
    /// The 20-byte contract address
    pub fn address(self) -> Address {
        self.address
    }

    /// Gets the indexed parameters of the event.
    ///
    /// # Returns
    ///
    /// A bounded vector of 32-byte topic values
    pub fn topics(self) -> BoundedVec<Bytes32, MaxTopicsCount> {
        self.topics
    }

    /// Gets the event data.
    ///
    /// # Returns
    ///
    /// A bounded vector of event data bytes
    pub fn data(self) -> BoundedVec<u8, MaxLogDataLen> {
        self.data
    }
}

impl<let MaxLogDataLen: u32, let MaxTopicsCount: u32> Eq for Log<MaxLogDataLen, MaxTopicsCount> {
    /// Compares two log entries for equality.
    ///
    /// Two log entries are equal if they have:
    /// - The same contract address
    /// - The same topics in the same order
    /// - The same event data
    ///
    /// # Arguments
    ///
    /// * `other` - The log entry to compare with
    ///
    /// # Returns
    ///
    /// `true` if the log entries are equal, `false` otherwise
    fn eq(self, other: Self) -> bool {
        (self.address == other.address) & (self.topics == other.topics) & (self.data == other.data)
    }
}

/// Represents a partial transaction receipt for verification purposes.
///
/// This structure contains only the essential fields needed for receipt
/// verification, handling both pre and post Byzantium hard fork receipts.
///
/// # Fields
///
/// * `state_root` - The state root (pre-Byzantium) or None
/// * `status` - The transaction status (post-Byzantium) or None
/// * `cumulative_gas_used` - The total gas used by the transaction
/// * `logs_bloom` - The bloom filter of log entries
pub struct TransactionReceiptPartial {
    /// The state root for pre-Byzantium receipts
    state_root: Option<Hash>,
    /// The transaction status for post-Byzantium receipts
    status: Option<u8>,
    /// The total gas used by the transaction
    cumulative_gas_used: u64,
    /// The bloom filter of log entries
    logs_bloom: LogsBloom,
}

impl TransactionReceiptPartial {
    /// Creates a new partial transaction receipt.
    ///
    /// # Arguments
    ///
    /// * `state_root` - The state root (pre-Byzantium) or None
    /// * `status` - The transaction status (post-Byzantium) or None
    /// * `cumulative_gas_used` - The total gas used by the transaction
    /// * `logs_bloom` - The bloom filter of log entries
    ///
    /// # Returns
    ///
    /// A new TransactionReceiptPartial instance
    pub fn new(
        state_root: Option<Hash>,
        status: Option<u8>,
        cumulative_gas_used: u64,
        logs_bloom: LogsBloom,
    ) -> Self {
        Self { state_root, status, cumulative_gas_used, logs_bloom }
    }

    /// Gets the state root for pre-Byzantium receipts.
    ///
    /// # Returns
    ///
    /// The state root hash or None for post-Byzantium receipts
    pub fn state_root(self) -> Option<Hash> {
        self.state_root
    }

    /// Gets the transaction status for post-Byzantium receipts.
    ///
    /// # Returns
    ///
    /// The transaction status (0 for failure, 1 for success) or None for pre-Byzantium receipts
    pub fn status(self) -> Option<u8> {
        self.status
    }

    /// Gets the total gas used by the transaction.
    ///
    /// # Returns
    ///
    /// The cumulative gas used value
    pub fn cumulative_gas_used(self) -> u64 {
        self.cumulative_gas_used
    }

    /// Gets the bloom filter of log entries.
    ///
    /// # Returns
    ///
    /// The logs bloom filter
    pub fn logs_bloom(self) -> LogsBloom {
        self.logs_bloom
    }
}

impl Eq for TransactionReceiptPartial {
    /// Compares two partial transaction receipts for equality.
    ///
    /// Two receipts are equal if they have:
    /// - The same state root/status
    /// - The same cumulative gas used
    /// - The same logs bloom filter
    ///
    /// # Arguments
    ///
    /// * `other` - The receipt to compare with
    ///
    /// # Returns
    ///
    /// `true` if the receipts are equal, `false` otherwise
    fn eq(self, other: Self) -> bool {
        (self.state_root == other.state_root)
            & (self.status == other.status)
            & (self.cumulative_gas_used == other.cumulative_gas_used)
            & (self.logs_bloom == other.logs_bloom)
    }
}

/// Verifies a transaction receipt proof against a receipt root.
///
/// This function:
/// 1. Verifies the transaction index matches
/// 2. Verifies the receipt RLP encoding
/// 3. Verifies the Merkle proof against the receipt root
///
/// # Arguments
///
/// * `block_number` - The block number for Byzantium check
/// * `transaction_index` - The index of the transaction
/// * `transaction_type` - The type of the transaction
/// * `receipt` - The partial receipt to verify
/// * `receipt_proof` - The Merkle proof of the receipt
/// * `receipt_root` - The root hash of the receipts trie
///
/// # Generics
///
/// * `MaxEncodedLen` - Maximum length of the encoded receipt
/// * `MaxDepthNoLeaf` - Maximum depth of the Merkle proof
/// * `MaxLeafLen` - Maximum length of the leaf data
///
/// # Returns
///
/// The decoded RLP list if verification succeeds
///
/// # Panics
///
/// Panics if:
/// - The transaction index doesn't match
/// - The receipt RLP encoding is invalid
/// - The Merkle proof is invalid
pub fn verify_receipt_proof<let MaxEncodedLen: u32, let MaxDepthNoLeaf: u32, let MaxLeafLen: u32>(
    block_number: u64,
    transaction_index: u64,
    transaction_type: TransactionType,
    receipt: TransactionReceiptPartial,
    receipt_proof: ReceiptProof<MaxEncodedLen, MaxDepthNoLeaf, MaxLeafLen>,
    receipt_root: Hash,
) -> RlpList<RECEIPT_FIELDS_COUNT> {
    // Verify the transaction index matches
    let key = Fragment::from_vec(right_pad(receipt_proof.key()));
    assert_transaction_index_equals(key, transaction_index);

    // Verify the receipt RLP encoding
    let value = right_pad(receipt_proof.value()).storage();
    let rlp_list: RlpList<RECEIPT_FIELDS_COUNT> = assert_receipt_equals(
        block_number,
        transaction_type,
        Fragment::from_array(value),
        receipt,
    );

    // Verify the Merkle proof against the receipt root
    verify_merkle_proof(
        receipt_proof.key(),
        receipt_proof.value(),
        receipt_root,
        receipt_proof.proof(),
    );

    rlp_list
}

mod post_byzantium_tests {
    use crate::fixtures::receipt::post_byzantium::{
        block_number, receipt, receipt_proof, receipt_root, transaction_index, transaction_type,
    };
    use super::verify_receipt_proof;

    #[test]
    fn test_verify_post_byzantium_receipt_proof() {
        let _ = verify_receipt_proof(
            block_number,
            transaction_index,
            transaction_type,
            receipt,
            receipt_proof,
            receipt_root,
        );
    }
}

mod pre_byzantium_tests {
    use crate::fixtures::receipt::pre_byzantium::{
        block_number, receipt, receipt_proof, receipt_root, transaction_index, transaction_type,
    };
    use super::verify_receipt_proof;

    #[test]
    fn test_verify_pre_byzantium_receipt_proof() {
        let _ = verify_receipt_proof(
            block_number,
            transaction_index,
            transaction_type,
            receipt,
            receipt_proof,
            receipt_root,
        );
    }
}
