//! Ethereum Account Structure and Verification
//!
//! This module defines the Account structure and verification methods used in Ethereum's
//! state trie. An Account represents an Ethereum account's state, including its balance,
//! nonce, code hash, and storage hash. The module also provides methods to verify
//! account proofs against the state root using Merkle Patricia Tree verification.

use crate::{
    mpt::verify::verify_merkle_proof,
    types::{address::Address, bytes32::Bytes32, hash::Hash},
};

use super::helpers::{assert_account_equals, assert_address_equals};
use super::types::AccountProof;

/// Represents an Ethereum account's state.
///
/// An Account contains all the essential information about an Ethereum account:
/// - Address: The account's unique identifier
/// - Nonce: The number of transactions sent from this account
/// - Balance: The account's ETH balance in wei
/// - Storage Hash: The root hash of the account's storage trie
/// - Code Hash: The hash of the account's contract code (if it's a contract)
pub struct Account {
    address: Address,
    balance: Field,
    code_hash: Bytes32,
    nonce: u64,
    storage_hash: Bytes32,
}

impl Account {
    /// Creates a new Account instance.
    ///
    /// # Arguments
    ///
    /// * `address` - The account's Ethereum address
    /// * `nonce` - The account's transaction count
    /// * `balance` - The account's ETH balance in wei
    /// * `storage_hash` - The root hash of the account's storage trie
    /// * `code_hash` - The hash of the account's contract code
    ///
    /// # Returns
    ///
    /// A new Account instance with the specified fields
    pub fn new(
        address: Address,
        nonce: u64,
        balance: Field,
        storage_hash: Bytes32,
        code_hash: Bytes32,
    ) -> Self {
        Self { address, nonce, balance, storage_hash, code_hash }
    }

    /// Gets the account's Ethereum address.
    ///
    /// # Returns
    ///
    /// The account's 20-byte address
    pub fn address(self) -> Address {
        self.address
    }

    /// Gets the account's nonce (transaction count).
    ///
    /// # Returns
    ///
    /// The number of transactions sent from this account
    pub fn nonce(self) -> u64 {
        self.nonce
    }

    /// Gets the account's ETH balance.
    ///
    /// # Returns
    ///
    /// The account's balance in wei
    pub fn balance(self) -> Field {
        self.balance
    }

    /// Gets the account's storage trie root hash.
    ///
    /// # Returns
    ///
    /// The 32-byte hash of the account's storage trie root
    pub fn storage_hash(self) -> Bytes32 {
        self.storage_hash
    }

    /// Gets the account's contract code hash.
    ///
    /// # Returns
    ///
    /// The 32-byte hash of the account's contract code
    pub fn code_hash(self) -> Bytes32 {
        self.code_hash
    }
}

impl Eq for Account {
    /// Compares two Account instances for equality.
    ///
    /// Two accounts are considered equal if all their fields match:
    /// - Address
    /// - Nonce
    /// - Balance
    /// - Storage Hash
    /// - Code Hash
    ///
    /// # Arguments
    ///
    /// * `other` - The Account to compare against
    ///
    /// # Returns
    ///
    /// `true` if all fields match, `false` otherwise
    fn eq(self, other: Self) -> bool {
        (self.address == other.address)
            & (self.nonce == other.nonce)
            & (self.balance == other.balance)
            & (self.storage_hash == other.storage_hash)
            & (self.code_hash == other.code_hash)
    }
}

/// Verifies an account's state using a Merkle Patricia Tree proof.
///
/// This function performs three verification steps:
/// 1. Verifies that the proof's key matches the account's address
/// 2. Verifies that the proof's value matches the account's state
/// 3. Verifies the Merkle proof against the state root
///
/// # Arguments
///
/// * `account` - The Account to verify
/// * `account_proof` - The Merkle proof for the account
/// * `state_root` - The root hash of the state trie
///
/// # Panics
///
/// Panics if:
/// - The proof's key doesn't match the account's address
/// - The proof's value doesn't match the account's state
/// - The Merkle proof is invalid
pub fn verify_account(account: Account, account_proof: AccountProof, state_root: Hash) {
    // Verify the proof's key matches the account's address
    assert_address_equals(account_proof.key(), account.address());

    // Verify the proof's value matches the account's state
    assert_account_equals(account_proof.value(), account);

    // Verify the Merkle proof against the state root
    verify_merkle_proof(
        account_proof.key(),
        account_proof.value(),
        state_root,
        account_proof.proof(),
    )
}

mod verify_account_tests {
    use crate::fixtures::account::account_without_storage::{account, account_proof, state_root};
    use super::verify_account;

    #[test]
    fn test_verify_account() {
        verify_account(account, account_proof, state_root);
    }
}

// 10k
// 23k
// 42k
// 1052k

