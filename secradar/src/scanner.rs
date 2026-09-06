//! File scanner — traverses directories and scans files for secrets.

use crate::findings::{Finding, Severity};
use crate::rules::{scan_line, Rule};
use anyhow::{Context, Result};
use ignore::{DirEntry, WalkBuilder};
use rayon::prelude::*;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

#[derive(Debug, Clone)]
pub struct ScanOptions {
    pub paths: Vec<PathBuf>,
    pub respect_gitignore: bool,
    pub follow_symlinks: bool,
    pub max_file_size: u64,
    pub skip_rules: Vec<String>,
    pub only_rules: Vec<String>,
    pub min_severity: Option<Severity>,
    pub exclude: Vec<String>,
}

impl Default for ScanOptions {
    fn default() -> Self {
        Self {
            paths: vec![PathBuf::from(".")],
            respect_gitignore: true,
            follow_symlinks: false,
            max_file_size: 1_048_576,
            skip_rules: vec![],
            only_rules: vec![],
            min_severity: None,
            exclude: vec![],
        }
    }
}

pub struct ScanStats {
    pub files_scanned: usize,
    pub bytes_scanned: usize,
    pub findings: usize,
}

/// Scan files matching the options. Returns all findings.
pub fn scan(opts: &ScanOptions) -> Result<(Vec<Finding>, ScanStats)> {
    let files = collect_files(opts)?;
    let files_count = files.len();
    let counter = Arc::new(AtomicUsize::new(0));

    let findings: Vec<Finding> = files
        .par_iter()
        .filter_map(|path| {
            counter.fetch_add(1, Ordering::Relaxed);
            match scan_file(path, opts) {
                Ok(finds) if !finds.is_empty() => Some(finds),
                _ => None,
            }
        })
        .flatten()
        .collect();

    let bytes_scanned: usize = files
        .iter()
        .filter_map(|p| fs::metadata(p).ok())
        .map(|m| m.len() as usize)
        .sum();

    let stats = ScanStats {
        files_scanned: files_count,
        bytes_scanned,
        findings: findings.len(),
    };

    Ok((findings, stats))
}

fn collect_files(opts: &ScanOptions) -> Result<Vec<PathBuf>> {
    let mut builder = WalkBuilder::new(&opts.paths[0]);
    for path in &opts.paths[1..] {
        builder.add(path);
    }
    builder
        .git_ignore(opts.respect_gitignore)
        .git_exclude(opts.respect_gitignore)
        .follow_links(opts.follow_symlinks)
        .max_filesize(Some(opts.max_file_size));

    // Add custom excludes
    let mut override_builder = ignore::overrides::OverrideBuilder::new(".");
    for pat in &opts.exclude {
        let _ = override_builder.add(&format!("!{}", pat));
    }
    if let Ok(ov) = override_builder.build() {
        builder.overrides(ov);
    }

    let walker = builder.build();
    let files: Vec<PathBuf> = walker
        .filter_map(|e| e.ok())
        .filter(is_scannable)
        .map(|e| e.into_path())
        .collect();
    Ok(files)
}

fn is_scannable(entry: &DirEntry) -> bool {
    let path = entry.path();
    if !entry.file_type().map(|t| t.is_file()).unwrap_or(false) {
        return false;
    }
    // Skip common binary / build artefacts
    let skip_dirs = [
        "node_modules", ".git", "target", "dist", "build", "vendor",
        "__pycache__", ".venv", "venv", ".idea", ".vscode", ".gradle",
    ];
    let path_str = path.to_string_lossy();
    if skip_dirs.iter().any(|d| path_str.contains(&format!("{}{}{}", std::path::MAIN_SEPARATOR, d, std::path::MAIN_SEPARATOR))) {
        return false;
    }
    // Skip obvious binary extensions by name
    let skip_exts = [
        "png", "jpg", "jpeg", "gif", "webp", "svg", "ico", "bmp",
        "pdf", "zip", "tar", "gz", "tgz", "7z", "rar", "exe", "dll",
        "so", "dylib", "class", "jar", "war", "pyc", "o", "a",
        "mp4", "mov", "mp3", "wav", "ogg", "flac",
    ];
    if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
        if skip_exts.contains(&ext.to_lowercase().as_str()) {
            return false;
        }
    }
    true
}

fn scan_file(path: &Path, opts: &ScanOptions) -> Result<Vec<Finding>> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("reading {}", path.display()))?;

    let mut findings = Vec::new();
    for (line_idx, line) in content.lines().enumerate() {
        for rule_match in scan_line(line) {
            // Filter by rules
            if !opts.skip_rules.is_empty() && opts.skip_rules.iter().any(|s| s == rule_match.rule.id) {
                continue;
            }
            if !opts.only_rules.is_empty() && !opts.only_rules.iter().any(|s| s == rule_match.rule.id) {
                continue;
            }
            // Filter by severity
            if let Some(min) = opts.min_severity {
                if rule_match.rule.severity < min {
                    continue;
                }
            }

            findings.push(Finding {
                rule_id: rule_match.rule.id.to_string(),
                rule_name: rule_match.rule.name.to_string(),
                severity: rule_match.rule.severity,
                file: path.to_path_buf(),
                line: line_idx + 1,
                column: rule_match.column,
                match_text: Finding::redact(&rule_match.matched_text),
                context: Finding::redact(line.trim()),
                commit: None,
            });
        }
    }
    Ok(findings)
}