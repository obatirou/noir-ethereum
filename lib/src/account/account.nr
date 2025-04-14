use crate::{
    mpt::{proof::ProofInput, verify::verify_merkle_proof},
    types::{address::Address, bytes32::Bytes32, hash::Hash},
};

use super::{
    constants::{
        MAX_ACCOUNT_DEPTH, MAX_ACCOUNT_LEAF_LENGTH, MAX_ACCOUNT_STATE_LENGTH, MAX_KEY_LENGTH,
    },
    helpers::{assert_account_equals, assert_address_equals},
};

pub struct Account {
    address: Address,
    balance: Field,
    code_hash: Bytes32,
    nonce: u64,
    storage_hash: Bytes32,
}

impl Account {
    pub fn new(
        address: Address,
        nonce: u64,
        balance: Field,
        storage_hash: Bytes32,
        code_hash: Bytes32,
    ) -> Self {
        Self { address, nonce, balance, storage_hash, code_hash }
    }

    pub fn address(self) -> Address {
        self.address
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn balance(self) -> Field {
        self.balance
    }

    pub fn storage_hash(self) -> Bytes32 {
        self.storage_hash
    }

    pub fn code_hash(self) -> Bytes32 {
        self.code_hash
    }
}

impl Eq for Account {
    fn eq(self, other: Self) -> bool {
        (self.address == other.address)
            & (self.nonce == other.nonce)
            & (self.balance == other.balance)
            & (self.storage_hash == other.storage_hash)
            & (self.code_hash == other.code_hash)
    }
}

pub fn verify_account<let MaxDepth: u32>(
    account: Account,
    state_proof_input: ProofInput<MAX_KEY_LENGTH, MAX_ACCOUNT_STATE_LENGTH, MAX_ACCOUNT_DEPTH, MAX_ACCOUNT_LEAF_LENGTH>,
    state_root: Hash,
) -> bool {
    assert_address_equals(state_proof_input.key(), account.address());
    assert_account_equals(state_proof_input.value(), account);
    verify_merkle_proof(
        state_proof_input.key(),
        state_proof_input.value(),
        state_root,
        state_proof_input.proof(),
    )
}
