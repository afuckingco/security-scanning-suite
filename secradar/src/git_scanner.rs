//! Git history scanner — finds secrets committed in past commits.

use crate::findings::Finding;
use crate::rules::scan_line;
use crate::scanner::ScanOptions;
use anyhow::{Context, Result};
use git2::Repository;
use std::path::Path;

pub fn scan_history(opts: &ScanOptions, max_commits: usize) -> Result<Vec<Finding>> {
    let repo = Repository::discover(&opts.paths[0])
        .context("not a git repository")?;

    let mut walker = repo.revwalk()?;
    walker.push_head()?;
    let mut findings = Vec::new();
    let mut count = 0;

    for oid in walker {
        if count >= max_commits { break; }
        let oid = oid?;
        let commit = repo.find_commit(oid)?;
        let tree = commit.tree()?;

        tree.walk(git2::TreeWalkMode::PreOrder, |_root, entry| {
            let Ok(obj) = entry.to_object(&repo) else { return git2::TreeWalkResult::Ok; };
            let Ok(blob) = obj.into_blob() else { return git2::TreeWalkResult::Ok; };
            let Ok(text) = std::str::from_utf8(blob.content()) else { return git2::TreeWalkResult::Ok; };
            let path = entry.name().unwrap_or("?");
            for (line_idx, line) in text.lines().enumerate() {
                for rule_match in scan_line(line) {
                    findings.push(Finding {
                        rule_id: rule_match.rule.id.to_string(),
                        rule_name: rule_match.rule.name.to_string(),
                        severity: rule_match.rule.severity,
                        file: Path::new(path).to_path_buf(),
                        line: line_idx + 1,
                        column: rule_match.column,
                        match_text: Finding::redact(&rule_match.matched_text),
                        context: Finding::redact(line.trim()),
                        commit: Some(oid.to_string()),
                    });
                }
            }
            git2::TreeWalkResult::Ok
        })?;

        count += 1;
    }

    // Filter by rules/severity same as file scanner
    findings.retain(|f| {
        if !opts.skip_rules.is_empty() && opts.skip_rules.contains(&f.rule_id) {
            return false;
        }
        if !opts.only_rules.is_empty() && !opts.only_rules.contains(&f.rule_id) {
            return false;
        }
        if let Some(min) = opts.min_severity {
            if f.severity < min {
                return false;
            }
        }
        true
    });

    Ok(findings)
}
