//! Ethereum Transaction Receipt Constants
//!
//! This module defines constants used for working with Ethereum transaction receipts.

/// Block number where the Byzantium hard fork was activated
///
/// The Byzantium hard fork introduced:
/// - Status field in transaction receipts
/// - REVERT opcode
/// - Static call opcode
/// - Other EIPs
pub global BYZANTIUM_BLOCK_NUMBER: u32 = 4_370_000;

/// Number of fields in a transaction receipt
///
/// A transaction receipt contains:
/// 1. Status (success/failure)
/// 2. Cumulative gas used
/// 3. Logs bloom
/// 4. Logs
pub global RECEIPT_FIELDS_COUNT: u32 = 4;

/// Index of the state root in the RLP-encoded receipt
///
/// The state root represents the root hash of the state trie
/// after the transaction has been executed
pub global STATE_ROOT_INDEX: u32 = 0;

/// Index of the status field in the RLP-encoded receipt
///
/// The status field indicates whether the transaction was successful (1)
/// or failed (0). Introduced in the Byzantium hard fork.
pub global STATUS_INDEX: u32 = 0;

/// Index of the cumulative gas used field in the RLP-encoded receipt
///
/// This field represents the total amount of gas used by all transactions
/// in the block up to and including this transaction
pub global CUMULATIVE_GAS_USED_INDEX: u32 = 1;

/// Index of the logs bloom field in the RLP-encoded receipt
///
/// The logs bloom is a 256-byte array used for efficient log filtering.
/// It contains a compressed representation of all log entries in the block.
pub global LOGS_BLOOM_INDEX: u32 = 2;

/// Index of the logs field in the RLP-encoded receipt
///
/// The logs field contains an array of log entries generated during
/// the transaction's execution
pub global LOGS_INDEX: u32 = 3;

/// Length of the bloom filter in bytes
///
/// The bloom filter is a 256-byte array used for efficient log filtering.
/// Each byte represents 8 bits, allowing for 2048 bits total.
pub global BLOOM_FILTER_LENGTH: u32 = 256;

/// Number of fields in a log entry
///
/// A log entry contains:
/// 1. Address of the contract that generated the log
/// 2. Topics (indexed parameters)
/// 3. Data (non-indexed parameters)
pub global LOG_FIELDS_COUNT: u32 = 3;

/// Index of the contract address in a log entry
///
/// The address field identifies which contract generated the log entry
pub global LOG_ADDRESS_INDEX: u32 = 0;

/// Index of the topics array in a log entry
///
/// Topics are indexed parameters that can be efficiently searched.
/// The first topic is always the event signature hash.
pub global LOG_TOPICS_INDEX: u32 = 1;

/// Index of the data field in a log entry
///
/// The data field contains non-indexed parameters of the event.
/// These parameters are not searchable but are included in the log.
pub global LOG_DATA_INDEX: u32 = 2;

/// Maximum length of an MPT key in bytes
///
/// This constant defines the maximum length of a key in the Merkle Patricia Trie.
/// Keys are used to store and retrieve values in the trie.
pub global MAX_KEY_LENGTH: u32 = 3;

/// Maximum length of a prefixed key in nibbles
///
/// A prefixed key includes a prefix byte that indicates whether the key
/// is of odd or even length. The length is in nibbles (half bytes).
/// Calculation: (MAX_KEY_LENGTH + 1) * 2
pub global MAX_PREFIXED_KEY_NIBBLE_LEN: u32 = 8;
