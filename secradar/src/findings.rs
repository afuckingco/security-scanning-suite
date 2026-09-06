//! Finding — represents a single secret detection result.

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Severity {
    Info,
    Low,
    Medium,
    High,
    Critical,
}

impl Severity {
    pub fn label(&self) -> &'static str {
        match self {
            Severity::Info => "INFO",
            Severity::Low => "LOW",
            Severity::Medium => "MEDIUM",
            Severity::High => "HIGH",
            Severity::Critical => "CRITICAL",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Finding {
    pub rule_id: String,
    pub rule_name: String,
    pub severity: Severity,
    pub file: PathBuf,
    pub line: usize,
    pub column: usize,
    pub match_text: String,    // redacted version
    pub context: String,        // surrounding line (redacted)
    pub commit: Option<String>,  // if found in git history
}

impl Finding {
    pub fn redact(s: &str) -> String {
        // Show first 4 and last 2 chars only: AKIA****XY
        if s.len() <= 8 {
            return "*".repeat(s.len());
        }
        let prefix = &s[..4];
        let suffix = &s[s.len() - 2..];
        format!("{}{}{}",
            prefix,
            "*".repeat(s.len().saturating_sub(6).min(20)),
            suffix)
    }
}