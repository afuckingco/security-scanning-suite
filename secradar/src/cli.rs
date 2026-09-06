//! CLI definition using clap.

use clap::{Parser, ValueEnum};
use std::path::PathBuf;

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
pub enum OutputFormat {
    Pretty,
    Json,
    Sarif,
    Compact,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
pub enum SeverityFilter {
    Critical,
    High,
    Medium,
    Low,
    Info,
}

#[derive(Parser, Debug)]
#[command(
    name = "secradar",
    version,
    author,
    about = "Fast secret scanner — finds API keys, tokens, and high-entropy secrets in source code",
    long_about = "secradar scans files (and optionally git history) for hardcoded secrets: API keys, \
                  tokens, passwords, private keys, and high-entropy strings. Runs locally, zero \
                  network calls, suitable for CI/pre-commit hooks."
)]
pub struct Cli {
    /// Paths to scan (files or directories). Defaults to current directory.
    #[arg(default_value = ".")]
    pub paths: Vec<PathBuf>,

    /// Output format
    #[arg(short, long, value_enum, default_value_t = OutputFormat::Pretty)]
    pub format: OutputFormat,

    /// Minimum severity to report
    #[arg(long, value_enum)]
    pub min_severity: Option<SeverityFilter>,

    /// Rules to skip (by ID, comma-separated: SR001,SR010)
    #[arg(long, value_delimiter = ',')]
    pub skip_rule: Vec<String>,

    /// Only run these rules (comma-separated)
    #[arg(long, value_delimiter = ',')]
    pub only_rule: Vec<String>,

    /// Scan git history (commits) instead of working tree
    #[arg(long)]
    pub git_history: bool,

    /// Maximum number of commits to scan when --git-history is set
    #[arg(long, default_value_t = 500)]
    pub max_commits: usize,

    /// Path to config file (default: .secradar.toml in current dir)
    #[arg(short, long)]
    pub config: Option<PathBuf>,

    /// Disable .gitignore respect (scan everything)
    #[arg(long)]
    pub no_gitignore: bool,

    /// Follow symbolic links
    #[arg(long)]
    pub follow_symlinks: bool,

    /// Maximum file size in bytes (default 1 MB)
    #[arg(long, default_value_t = 1_048_576)]
    pub max_file_size: u64,

    /// Number of threads (default: auto)
    #[arg(short = 'j', long)]
    pub threads: Option<usize>,

    /// Exit with code 0 even if secrets found (useful for reporting)
    #[arg(long)]
    pub no_fail: bool,

    /// Suppress progress output
    #[arg(short, long)]
    pub quiet: bool,

    /// Show rule IDs in output
    #[arg(long)]
    pub show_ids: bool,

    /// Additional exclude patterns (glob, can be repeated)
    #[arg(long, value_delimiter = ',')]
    pub exclude: Vec<String>,
}