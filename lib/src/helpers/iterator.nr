/// A trait that provides iteration capabilities over a collection of elements.
///
/// This trait allows for generic iteration over any type T, providing a way to
/// execute a function on each element along with its index.
///
/// # Generics
///
/// * `T` - The type of elements being iterated over
///
/// # Methods
///
/// * `each` - Executes a function on each element with its index
///   * `f` - A function that takes an element of type T and its index (u64)
///   * `Env` - The environment type for the function closure
pub trait Iterator<T> {
    fn each<Env>(self, f: fn[Env](T, u64) -> ());
}
