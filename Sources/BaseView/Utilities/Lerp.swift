func lerp<T: FloatingPoint>(from start: T, to end: T, progress: T) -> T {
    start + (end - start) * progress
}
