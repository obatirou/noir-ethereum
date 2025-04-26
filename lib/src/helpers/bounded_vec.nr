use super::iterator::Iterator;

pub fn bounded_vec_map<U, T, Env, let N: u32>(
    bounded_vec: BoundedVec<T, N>,
    f: fn[Env](T) -> U,
) -> BoundedVec<U, N> {
    let result: &mut BoundedVec<U, N> = &mut BoundedVec::new();
    bounded_vec.each(|x, _| result.push(f(x)));

    *result
}

impl<T, let N: u32> Iterator<T> for BoundedVec<T, N> {
    fn each<Env>(self, f: fn[Env](T, u64) -> ()) {
        for i in 0..N {
            if i < self.len() {
                f(self.get(i), i as u64);
            }
        }
    }
}
