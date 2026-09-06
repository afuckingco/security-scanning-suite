//! Shannon entropy calculation — used to detect high-entropy strings
//! that may be secrets even when not matching a known pattern.

/// Compute Shannon entropy of a string.
/// Returns bits per character. Higher = more random = more likely a secret.
/// - "aaaaaaaa" = 0.0 (no entropy)
/// - "hello world" = ~3.0
/// - Random base64 = ~5.5-6.0
/// - Random hex = ~3.5-4.0
pub fn shannon_entropy(s: &str) -> f64 {
    if s.is_empty() {
        return 0.0;
    }
    let mut counts = [0usize; 256];
    let mut total = 0usize;
    for b in s.bytes() {
        counts[b as usize] += 1;
        total += 1;
    }
    let mut entropy = 0.0;
    for &count in counts.iter() {
        if count > 0 {
            let p = count as f64 / total as f64;
            entropy -= p * p.log2();
        }
    }
    entropy
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_entropy_low_for_repeated() {
        assert_eq!(shannon_entropy("aaaaaaaa"), 0.0);
        assert_eq!(shannon_entropy(""), 0.0);
    }

    #[test]
    fn test_entropy_medium_for_text() {
        let e = shannon_entropy("hello world");
        assert!(e > 2.0 && e < 4.0, "got {}", e);
    }

    #[test]
    fn test_entropy_high_for_random() {
        let e = shannon_entropy("aZ39KQ8mXp2vN7LcR4jF6wY0uT1sB5hD");
        assert!(e > 4.5, "got {}", e);
    }
}