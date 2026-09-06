//! secradar CLI entry point.

use anyhow::Result;
use clap::Parser;
use secradar::{
    cli::{Cli, OutputFormat, SeverityFilter},
    findings::Severity,
    git_scanner::scan_history,
    reporter::report,
    scanner::{scan, ScanOptions},
};

fn main() -> Result<()> {
    let cli = Cli::parse();

    // Setup logging
    let log_level = if cli.quiet { "error" } else { "warn" };
    std::env::set_var("RUST_LOG", log_level);
    let _ = env_logger::try_init();

    // Threading
    if let Some(threads) = cli.threads {
        rayon::ThreadPoolBuilder::new()
            .num_threads(threads)
            .build_global()
            .ok();
    }

    let opts = ScanOptions {
        paths: if cli.paths.is_empty() {
            vec![std::path::PathBuf::from(".")]
        } else {
            cli.paths.clone()
        },
        respect_gitignore: !cli.no_gitignore,
        follow_symlinks: cli.follow_symlinks,
        max_file_size: cli.max_file_size,
        skip_rules: cli.skip_rule.clone(),
        only_rules: cli.only_rule.clone(),
        min_severity: cli.min_severity.map(severity_from_filter),
        exclude: cli.exclude.clone(),
    };

    let findings = if cli.git_history {
        scan_history(&opts, cli.max_commits)?
    } else {
        let (findings, _stats) = scan(&opts)?;
        findings
    };

    let stdout = std::io::stdout();
    let mut handle = stdout.lock();
    report(&findings, cli.format, &mut handle)?;

    if !cli.no_fail && !findings.is_empty() {
        std::process::exit(1);
    }
    Ok(())
}

fn severity_from_filter(s: SeverityFilter) -> Severity {
    match s {
        SeverityFilter::Critical => Severity::Critical,
        SeverityFilter::High => Severity::High,
        SeverityFilter::Medium => Severity::Medium,
        SeverityFilter::Low => Severity::Low,
        SeverityFilter::Info => Severity::Info,
    }
}