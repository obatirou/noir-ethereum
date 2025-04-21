use crate::{
    helpers::bytes::right_pad,
    mpt::verify::verify_merkle_proof,
    types::{address::Address, bytes32::Bytes32, fragment::Fragment, hash::Hash},
};

use super::helpers::{
    assert_transaction_index_equals, assert_tx_rlp_equals, split_into_tx_type_and_rlp,
};
use super::types::TransactionProof;
use super::types::TransactionType;

pub struct LegacyTransaction<let MaxDataLen: u32> {
    nonce: u64,
    gas_price: u64,
    gas_limit: u64,
    to: Option<Address>,
    value: U128,
    data: BoundedVec<u8, MaxDataLen>,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

impl<let MaxDataLen: u32> LegacyTransaction<MaxDataLen> {
    pub fn new(
        nonce: u64,
        gas_price: u64,
        gas_limit: u64,
        to: Option<Address>,
        value: U128,
        data: BoundedVec<u8, MaxDataLen>,
        v: u8,
        r: Bytes32,
        s: Bytes32,
    ) -> Self {
        Self { nonce, gas_price, gas_limit, to, value, data, v, r, s }
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn gas_price(self) -> u64 {
        self.gas_price
    }

    pub fn gas_limit(self) -> u64 {
        self.gas_limit
    }

    pub fn to(self) -> Option<Address> {
        self.to
    }

    pub fn value(self) -> U128 {
        self.value
    }

    pub fn data(self) -> BoundedVec<u8, MaxDataLen> {
        self.data
    }

    pub fn v(self) -> u8 {
        self.v
    }

    pub fn r(self) -> Bytes32 {
        self.r
    }

    pub fn s(self) -> Bytes32 {
        self.s
    }
}

impl<let MaxDataLen: u32> Eq for LegacyTransaction<MaxDataLen> {
    fn eq(self, other: Self) -> bool {
        (self.nonce == other.nonce)
            & (self.gas_price == other.gas_price)
            & (self.gas_limit == other.gas_limit)
            & (self.to == other.to)
            & (self.value == other.value)
            & (self.data == other.data)
            & (self.v == other.v)
            & (self.r == other.r)
            & (self.s == other.s)
    }
}

pub struct EIP2930Transaction<let MaxDataLen: u32, let MaxAccessListLen: u32> {
    chain_id: u64,
    nonce: u64,
    gas_price: u64,
    gas_limit: u64,
    to: Option<Address>,
    value: U128,
    data: BoundedVec<u8, MaxDataLen>,
    access_lists: BoundedVec<u8, MaxAccessListLen>,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> EIP2930Transaction<MaxDataLen, MaxAccessListLen> {
    pub fn new(
        chain_id: u64,
        nonce: u64,
        gas_price: u64,
        gas_limit: u64,
        to: Option<Address>,
        value: U128,
        data: BoundedVec<u8, MaxDataLen>,
        access_lists: BoundedVec<u8, MaxAccessListLen>,
        v: u8,
        r: Bytes32,
        s: Bytes32,
    ) -> Self {
        Self { chain_id, nonce, gas_price, gas_limit, to, value, data, access_lists, v, r, s }
    }

    pub fn chain_id(self) -> u64 {
        self.chain_id
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn gas_price(self) -> u64 {
        self.gas_price
    }

    pub fn gas_limit(self) -> u64 {
        self.gas_limit
    }

    pub fn to(self) -> Option<Address> {
        self.to
    }

    pub fn value(self) -> U128 {
        self.value
    }

    pub fn data(self) -> BoundedVec<u8, MaxDataLen> {
        self.data
    }

    pub fn access_lists(self) -> BoundedVec<u8, MaxAccessListLen> {
        self.access_lists
    }

    pub fn v(self) -> u8 {
        self.v
    }

    pub fn r(self) -> Bytes32 {
        self.r
    }

    pub fn s(self) -> Bytes32 {
        self.s
    }
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> Eq for EIP2930Transaction<MaxDataLen, MaxAccessListLen> {
    fn eq(self, other: Self) -> bool {
        (self.chain_id == other.chain_id)
            & (self.nonce == other.nonce)
            & (self.gas_price == other.gas_price)
            & (self.gas_limit == other.gas_limit)
            & (self.to == other.to)
            & (self.value == other.value)
            & (self.data == other.data)
            & (self.access_lists == other.access_lists)
            & (self.v == other.v)
            & (self.r == other.r)
            & (self.s == other.s)
    }
}

pub struct EIP1559Transaction<let MaxDataLen: u32, let MaxAccessListLen: u32> {
    chain_id: u64,
    nonce: u64,
    max_priority_fee_per_gas: u64,
    max_fee_per_gas: u64,
    gas_limit: u64,
    to: Option<Address>,
    value: U128,
    data: BoundedVec<u8, MaxDataLen>,
    access_lists: BoundedVec<u8, MaxAccessListLen>,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> EIP1559Transaction<MaxDataLen, MaxAccessListLen> {
    pub fn new(
        chain_id: u64,
        nonce: u64,
        max_priority_fee_per_gas: u64,
        max_fee_per_gas: u64,
        gas_limit: u64,
        to: Option<Address>,
        value: U128,
        data: BoundedVec<u8, MaxDataLen>,
        access_lists: BoundedVec<u8, MaxAccessListLen>,
        v: u8,
        r: Bytes32,
        s: Bytes32,
    ) -> Self {
        Self {
            chain_id,
            nonce,
            max_priority_fee_per_gas,
            max_fee_per_gas,
            gas_limit,
            to,
            value,
            data,
            access_lists,
            v,
            r,
            s,
        }
    }

    pub fn chain_id(self) -> u64 {
        self.chain_id
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn max_priority_fee_per_gas(self) -> u64 {
        self.max_priority_fee_per_gas
    }

    pub fn max_fee_per_gas(self) -> u64 {
        self.max_fee_per_gas
    }

    pub fn gas_limit(self) -> u64 {
        self.gas_limit
    }

    pub fn to(self) -> Option<Address> {
        self.to
    }

    pub fn value(self) -> U128 {
        self.value
    }

    pub fn data(self) -> BoundedVec<u8, MaxDataLen> {
        self.data
    }

    pub fn access_lists(self) -> BoundedVec<u8, MaxAccessListLen> {
        self.access_lists
    }

    pub fn v(self) -> u8 {
        self.v
    }

    pub fn r(self) -> Bytes32 {
        self.r
    }

    pub fn s(self) -> Bytes32 {
        self.s
    }
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> Eq for EIP1559Transaction<MaxDataLen, MaxAccessListLen> {
    fn eq(self, other: Self) -> bool {
        (self.chain_id == other.chain_id)
            & (self.nonce == other.nonce)
            & (self.max_priority_fee_per_gas == other.max_priority_fee_per_gas)
            & (self.max_fee_per_gas == other.max_fee_per_gas)
            & (self.gas_limit == other.gas_limit)
            & (self.to == other.to)
            & (self.value == other.value)
            & (self.data == other.data)
            & (self.access_lists == other.access_lists)
            & (self.v == other.v)
            & (self.r == other.r)
            & (self.s == other.s)
    }
}

pub struct EIP4844Transaction<let MaxDataLen: u32, let MaxAccessListLen: u32> {
    chain_id: u64,
    nonce: u64,
    max_priority_fee_per_gas: u64,
    max_fee_per_gas: u64,
    gas_limit: u64,
    to: Option<Address>,
    value: U128,
    data: BoundedVec<u8, MaxDataLen>,
    access_lists: BoundedVec<u8, MaxAccessListLen>,
    max_fee_per_blob_gas: u64,
    blob_versioned_hashes: BoundedVec<Hash, 6>,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> EIP4844Transaction<MaxDataLen, MaxAccessListLen> {
    pub fn new(
        chain_id: u64,
        nonce: u64,
        max_priority_fee_per_gas: u64,
        max_fee_per_gas: u64,
        gas_limit: u64,
        to: Option<Address>,
        value: U128,
        data: BoundedVec<u8, MaxDataLen>,
        access_lists: BoundedVec<u8, MaxAccessListLen>,
        max_fee_per_blob_gas: u64,
        blob_versioned_hashes: BoundedVec<Hash, 6>,
        v: u8,
        r: Bytes32,
        s: Bytes32,
    ) -> Self {
        Self {
            chain_id,
            nonce,
            max_priority_fee_per_gas,
            max_fee_per_gas,
            gas_limit,
            to,
            value,
            data,
            access_lists,
            max_fee_per_blob_gas,
            blob_versioned_hashes,
            v,
            r,
            s,
        }
    }

    pub fn chain_id(self) -> u64 {
        self.chain_id
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn max_priority_fee_per_gas(self) -> u64 {
        self.max_priority_fee_per_gas
    }

    pub fn max_fee_per_gas(self) -> u64 {
        self.max_fee_per_gas
    }

    pub fn gas_limit(self) -> u64 {
        self.gas_limit
    }

    pub fn to(self) -> Option<Address> {
        self.to
    }

    pub fn value(self) -> U128 {
        self.value
    }

    pub fn data(self) -> BoundedVec<u8, MaxDataLen> {
        self.data
    }

    pub fn access_lists(self) -> BoundedVec<u8, MaxAccessListLen> {
        self.access_lists
    }

    pub fn max_fee_per_blob_gas(self) -> u64 {
        self.max_fee_per_blob_gas
    }

    pub fn blob_versioned_hashes(self) -> BoundedVec<Hash, 6> {
        self.blob_versioned_hashes
    }

    pub fn v(self) -> u8 {
        self.v
    }

    pub fn r(self) -> Bytes32 {
        self.r
    }

    pub fn s(self) -> Bytes32 {
        self.s
    }
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> Eq for EIP4844Transaction<MaxDataLen, MaxAccessListLen> {
    fn eq(self, other: Self) -> bool {
        (self.chain_id == other.chain_id)
            & (self.nonce == other.nonce)
            & (self.max_priority_fee_per_gas == other.max_priority_fee_per_gas)
            & (self.max_fee_per_gas == other.max_fee_per_gas)
            & (self.gas_limit == other.gas_limit)
            & (self.to == other.to)
            & (self.value == other.value)
            & (self.data == other.data)
            & (self.access_lists == other.access_lists)
            & (self.max_fee_per_blob_gas == other.max_fee_per_blob_gas)
            & (self.blob_versioned_hashes == other.blob_versioned_hashes)
            & (self.v == other.v)
            & (self.r == other.r)
            & (self.s == other.s)
    }
}

pub struct AuthorizationEntry {
    chain_id: u64,
    address: Address,
    nonce: u64,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

pub struct EIP7702Transaction<let MaxDataLen: u32, let MaxAccessListLen: u32, let MaxAuthorizationListLen: u32> {
    chain_id: u64,
    nonce: u64,
    max_priority_fee_per_gas: u64,
    max_fee_per_gas: u64,
    gas_limit: u64,
    to: Option<Address>,
    value: U128,
    data: BoundedVec<u8, MaxDataLen>,
    access_lists: BoundedVec<u8, MaxAccessListLen>,
    authorization_lists: BoundedVec<AuthorizationEntry, MaxAuthorizationListLen>,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

pub struct TransactionPartial<let MaxDataLen: u32> {
    nonce: u64,
    gas_limit: u64,
    to: Option<Address>,
    value: U128,
    data: BoundedVec<u8, MaxDataLen>,
    v: u8,
    r: Bytes32,
    s: Bytes32,
}

impl<let MaxDataLen: u32> TransactionPartial<MaxDataLen> {
    pub fn new(
        nonce: u64,
        gas_limit: u64,
        to: Option<Address>,
        value: U128,
        data: BoundedVec<u8, MaxDataLen>,
        v: u8,
        r: Bytes32,
        s: Bytes32,
    ) -> Self {
        Self { nonce, gas_limit, to, value, data, v, r, s }
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn gas_limit(self) -> u64 {
        self.gas_limit
    }

    pub fn to(self) -> Option<Address> {
        self.to
    }

    pub fn value(self) -> U128 {
        self.value
    }

    pub fn data(self) -> BoundedVec<u8, MaxDataLen> {
        self.data
    }

    pub fn v(self) -> u8 {
        self.v
    }

    pub fn r(self) -> Bytes32 {
        self.r
    }

    pub fn s(self) -> Bytes32 {
        self.s
    }
}

impl<let MaxDataLen: u32> Eq for TransactionPartial<MaxDataLen> {
    fn eq(self, other: Self) -> bool {
        (self.nonce == other.nonce)
            & (self.gas_limit == other.gas_limit)
            & (self.to == other.to)
            & (self.value == other.value)
            & (self.data == other.data)
            & (self.v == other.v)
            & (self.r == other.r)
            & (self.s == other.s)
    }
}

impl<let MaxDataLen: u32> From<LegacyTransaction<MaxDataLen>> for TransactionPartial<MaxDataLen> {
    fn from(legacy: LegacyTransaction<MaxDataLen>) -> Self {
        Self {
            nonce: legacy.nonce,
            gas_limit: legacy.gas_limit,
            to: legacy.to,
            value: legacy.value,
            data: legacy.data,
            v: legacy.v,
            r: legacy.r,
            s: legacy.s,
        }
    }
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> From<EIP2930Transaction<MaxDataLen, MaxAccessListLen>> for TransactionPartial<MaxDataLen> {
    fn from(eip2930: EIP2930Transaction<MaxDataLen, MaxAccessListLen>) -> Self {
        Self {
            nonce: eip2930.nonce,
            gas_limit: eip2930.gas_limit,
            to: eip2930.to,
            value: eip2930.value,
            data: eip2930.data,
            v: eip2930.v,
            r: eip2930.r,
            s: eip2930.s,
        }
    }
}

impl<let MaxDataLen: u32, let MaxAccessListLen: u32> From<EIP1559Transaction<MaxDataLen, MaxAccessListLen>> for TransactionPartial<MaxDataLen> {
    fn from(eip1559: EIP1559Transaction<MaxDataLen, MaxAccessListLen>) -> Self {
        Self {
            nonce: eip1559.nonce,
            gas_limit: eip1559.gas_limit,
            to: eip1559.to,
            value: eip1559.value,
            data: eip1559.data,
            v: eip1559.v,
            r: eip1559.r,
            s: eip1559.s,
        }
    }
}

pub struct TransactionPartialFieldLayout {
    field_count: u32,
    nonce_index: u32,
    gas_limit_index: u32,
    to_index: u32,
    value_index: u32,
    data_index: u32,
    signature_index: u32,
}

impl TransactionPartialFieldLayout {
    pub fn new(
        field_count: u32,
        nonce_index: u32,
        gas_limit_index: u32,
        to_index: u32,
        value_index: u32,
        data_index: u32,
        signature_index: u32,
    ) -> Self {
        Self {
            field_count,
            nonce_index,
            gas_limit_index,
            to_index,
            value_index,
            data_index,
            signature_index,
        }
    }
    pub fn field_count(self) -> u32 {
        self.field_count
    }

    pub fn nonce_index(self) -> u32 {
        self.nonce_index
    }

    pub fn gas_limit_index(self) -> u32 {
        self.gas_limit_index
    }

    pub fn to_index(self) -> u32 {
        self.to_index
    }

    pub fn value_index(self) -> u32 {
        self.value_index
    }

    pub fn data_index(self) -> u32 {
        self.data_index
    }

    pub fn signature_index(self) -> u32 {
        self.signature_index
    }
}

pub fn assert_transaction_equals<let MaxDataLen: u32, let MaxEncodedDataLen: u32>(
    tx_type: TransactionType,
    encoded_tx: Fragment<u8, MaxEncodedDataLen>,
    tx: TransactionPartial<MaxDataLen>,
) {
    let is_legacy = tx_type == 0;
    let (actual_tx_type, tx_rlp) = split_into_tx_type_and_rlp(is_legacy, encoded_tx);

    assert(actual_tx_type == tx_type, "Invalid Transaction Type type");
    assert_tx_rlp_equals(tx_rlp, tx_type, tx);
}

pub fn verify_transaction_proof<let MaxDataLen: u32, let MaxEncodedDataLen: u32, let MaxLeafLen: u32, let MaxEncodedTxLen: u32>(
    transaction_index: u64,
    transaction_type: TransactionType,
    transaction: TransactionPartial<MaxDataLen>,
    transaction_proof: TransactionProof<MaxLeafLen, MaxEncodedTxLen>,
    transaction_root: Hash,
) {
    let key = Fragment::from_vec(right_pad(transaction_proof.key()));
    assert_transaction_index_equals(key, transaction_index);

    let value = right_pad(transaction_proof.value()).storage();
    assert_transaction_equals(transaction_type, Fragment::from_array(value), transaction);
    verify_merkle_proof(
        transaction_proof.key(),
        transaction_proof.value(),
        transaction_root,
        transaction_proof.proof(),
    )
}

mod test_legacy_transaction {
    use crate::fixtures::transaction::legacy::{
        transaction, transaction_index, transaction_proof, transaction_root, transaction_type,
    };
    use super::verify_transaction_proof;

    #[test]
    fn test_legacy_transaction() {
        verify_transaction_proof(
            transaction_index,
            transaction_type,
            transaction,
            transaction_proof,
            transaction_root,
        )
    }
}

mod test_eip1559_transaction {
    use crate::fixtures::transaction::eip1559::{
        transaction, transaction_index, transaction_proof, transaction_root, transaction_type,
    };
    use super::verify_transaction_proof;

    #[test]
    fn test_eip1559_transaction() {
        verify_transaction_proof(
            transaction_index,
            transaction_type,
            transaction,
            transaction_proof,
            transaction_root,
        )
    }
}

mod test_eip4844_transaction {
    use crate::fixtures::transaction::eip4844::{
        transaction, transaction_index, transaction_proof, transaction_root, transaction_type,
    };
    use super::verify_transaction_proof;

    #[test]
    fn test_eip4844_transaction() {
        verify_transaction_proof(
            transaction_index,
            transaction_type,
            transaction,
            transaction_proof,
            transaction_root,
        )
    }
}

mod test_eip7702_transaction {
    use crate::fixtures::transaction::eip7702::{
        transaction, transaction_index, transaction_proof, transaction_root, transaction_type,
    };
    use super::verify_transaction_proof;

    #[test]
    fn test_eip7702_transaction() {
        verify_transaction_proof(
            transaction_index,
            transaction_type,
            transaction,
            transaction_proof,
            transaction_root,
        )
    }
}
