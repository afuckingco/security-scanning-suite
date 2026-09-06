//! secradar — fast secret scanner.
//!
//! Detects API keys, tokens, passwords, private keys, and high-entropy strings
//! in source files and git history. 100% local, zero network calls.

pub mod cli;
pub mod entropy;
pub mod findings;
pub mod git_scanner;
pub mod reporter;
pub mod rules;
pub mod scanner;

pub use cli::{Cli, OutputFormat};
pub use findings::{Finding, Severity};
pub use rules::{Rule, RuleId, RULES};

/// Library version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");