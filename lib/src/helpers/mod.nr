/// Optimized conditional selection function circuits.
///
/// This function implements a branchless conditional selection that requires fewer constraints
/// than a traditional if-else statement in a circuit. Instead of branching, it uses arithmetic
/// operations to select between two values based on a boolean condition.
///
/// # Arguments
///
/// * `condition` - Boolean value determining which value to select
/// * `x` - First value to select from (chosen when condition is true)
/// * `y` - Second value to select from (chosen when condition is false)
///
/// # Returns
///
/// Returns `x` if condition is true, `y` if condition is false
pub fn if_else(condition: bool, x: Field, y: Field) -> Field {
    let condition_f = condition as Field;
    condition_f * x + (1 - condition_f) * y
}

pub mod bytes;
pub mod iterator;
pub mod arrays;
pub mod bounded_vec;
