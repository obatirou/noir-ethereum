use ethereum::account::{Account, verify_account};
use ethereum::account::types::AccountProof;
use ethereum::types::hash::Hash;

fn main(account: Account, account_proof: AccountProof, state_root: Hash) {
    verify_account(account, account_proof, state_root)
}
