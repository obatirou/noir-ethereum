/// Maximum length (in bytes) of a key in the account state trie.
/// This value is set to 32 bytes to accommodate the keccak256 hash of an Ethereum address,
/// which is the standard key format for account lookups in the state trie.
pub global MAX_KEY_LENGTH: u32 = 32;

/// Maximum length (in nibbles) of a prefixed key in the account state trie.
/// This value is derived from MAX_KEY_LENGTH plus a prefix byte, converted to nibbles.
/// Formula: (32 bytes + 1 prefix byte) * 2 nibbles per byte = 66 nibbles
pub global MAX_PREFIXED_KEY_NIBBLE_LENGTH: u32 = 66; // (32 + 1) * 2

/// Maximum depth of the account state trie proof.
/// This value represents the maximum number of nodes that can be present in a proof path
/// from the root to a leaf node in the account state trie.
/// Set to 10 to accommodate the maximum possible trie depth for account lookups.
pub global MAX_ACCOUNT_DEPTH: u32 = 10;

/// Maximum length (in bytes) of an account state value in RLP encoding.
/// This value accounts for the RLP-encoded representation of an account's state,
/// which includes nonce, balance, storage hash, and code hash.
/// The value 110 bytes is derived from the maximum possible RLP encoding of these fields.
pub global MAX_ACCOUNT_STATE_LENGTH: u32 = 110;

/// Maximum length (in bytes) of a leaf node in the account state trie.
/// This value represents the maximum size of a leaf node containing an account state.
/// The value 148 bytes accounts for the RLP encoding of the leaf node structure
/// (prefix + key + value) in the Merkle Patricia Trie.
pub global MAX_ACCOUNT_LEAF_LENGTH: u32 = 148;

/// Number of fields in an account state.
/// An account state consists of 4 fields: nonce, balance, storage hash, and code hash.
pub global ACCOUNT_FIELDS_COUNT: u32 = 4;

/// Index of the nonce field in the account state RLP list.
/// The nonce represents the number of transactions sent from this account.
pub global NONCE_INDEX: u32 = 0;

/// Index of the balance field in the account state RLP list.
/// The balance represents the amount of Wei (native currency) owned by this account.
pub global BALANCE_INDEX: u32 = 1;

/// Index of the storage hash field in the account state RLP list.
/// The storage hash is the root hash of the account's storage trie.
pub global STORAGE_HASH_INDEX: u32 = 2;

/// Index of the code hash field in the account state RLP list.
/// The code hash is the hash of the account's contract code (if it's a contract account).
pub global CODE_HASH_INDEX: u32 = 3;
