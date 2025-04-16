use crate::account::account::Account;
use crate::account::types::AccountProof;
use crate::account::verify_account;
use crate::types::hash::Hash;

#[export]
fn benchmark_verify_account(account: Account, account_proof: AccountProof, state_root: Hash) {
    verify_account(account, account_proof, state_root);
}
