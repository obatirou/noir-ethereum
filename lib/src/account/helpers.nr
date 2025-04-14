use std::hash::keccak256;

use crate::helpers::bytes::right_pad;

use crate::rlp::{decode::decode_list_of_small_strings, list::RlpList};
use crate::types::{address::{Address, ADDRESS_LENGTH}, fragment::Fragment, hash::HASH_LENGTH};

use super::account::Account;
use super::constants::{
    ACCOUNT_FIELDS_COUNT, BALANCE_INDEX, CODE_HASH_INDEX, MAX_ACCOUNT_STATE_LENGTH, MAX_KEY_LENGTH,
    NONCE_INDEX, STORAGE_HASH_INDEX,
};

pub fn assert_account_equals(
    account_rlp_left_padded: [u8; MAX_ACCOUNT_STATE_LENGTH],
    account: Account,
) {
    let account_rlp_right_padded = right_pad(account_rlp_left_padded).storage();
    let account_rlp_list: RlpList<ACCOUNT_FIELDS_COUNT> =
        decode_list_of_small_strings(Fragment::from_array(account_rlp_right_padded));

    assert(
        account_rlp_list.len() == ACCOUNT_FIELDS_COUNT,
        "Invalid number of fields in account RLP",
    );

    let account_rlp = Fragment::from_array(account_rlp_right_padded);

    account_rlp_list.get(NONCE_INDEX).assert_eq_u64("Nonce", account_rlp, account.nonce() as u64);

    account_rlp_list.get(BALANCE_INDEX).assert_eq_u128(
        "Balance",
        account_rlp,
        U128::from_integer(account.balance()),
    );

    account_rlp_list.get(STORAGE_HASH_INDEX).assert_eq_bytes32(
        "Storage Hash",
        account_rlp,
        account.storage_hash(),
    );
    account_rlp_list.get(CODE_HASH_INDEX).assert_eq_bytes32(
        "Code Hash",
        account_rlp,
        account.code_hash(),
    );
}

pub fn assert_address_equals(address_hash: [u8; MAX_KEY_LENGTH], address: Address) {
    let address_hash_fragment = Fragment::new(
        (MAX_KEY_LENGTH - HASH_LENGTH) as u64,
        HASH_LENGTH as u64,
        address_hash,
    );

    let other_address_hash_fragment =
        Fragment::from_array(keccak256(address, ADDRESS_LENGTH as u32));

    assert(address_hash_fragment.eq(other_address_hash_fragment), "Address mismatch");
}
