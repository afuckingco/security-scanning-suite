//! Output formatters — pretty, JSON, SARIF, compact.

use crate::cli::OutputFormat;
use crate::findings::{Finding, Severity};
use colored::*;
use std::io::Write;
use std::path::PathBuf;

pub fn report(findings: &[Finding], format: OutputFormat, writer: &mut dyn Write) -> anyhow::Result<()> {
    match format {
        OutputFormat::Pretty => report_pretty(findings, writer),
        OutputFormat::Json => report_json(findings, writer),
        OutputFormat::Sarif => report_sarif(findings, writer),
        OutputFormat::Compact => report_compact(findings, writer),
    }
}

fn severity_color(s: Severity) -> Color {
    match s {
        Severity::Critical => Color::BrightRed,
        Severity::High => Color::Red,
        Severity::Medium => Color::Yellow,
        Severity::Low => Color::Cyan,
        Severity::Info => Color::Blue,
    }
}

fn report_pretty(findings: &[Finding], w: &mut dyn Write) -> anyhow::Result<()> {
    if findings.is_empty() {
        writeln!(w, "{}", "  ✓ No secrets found.".green())?;
        return Ok(());
    }

    writeln!(w)?;
    writeln!(w, "  {} potential secret(s) detected:", findings.len().to_string().red().bold())?;
    writeln!(w, "  {}", "─".repeat(60).dimmed())?;

    // Group by file
    let mut by_file: std::collections::BTreeMap<&PathBuf, Vec<&Finding>> = std::collections::BTreeMap::new();
    for f in findings {
        by_file.entry(&f.file).or_default().push(f);
    }

    for (file, finds) in by_file {
        writeln!(w, "\n  {} {}", "▸".bright_blue(), file.display().to_string().bold())?;
        for f in finds {
            let sev_str = format!("{:8}", f.severity.label())
                .color(severity_color(f.severity))
                .bold();
            writeln!(
                w,
                "    {} [{}] {}",
                sev_str,
                f.rule_id.dimmed(),
                f.rule_name
            )?;
            writeln!(w, "      {}:{}", f.line, f.column.to_string().dimmed())?;
            writeln!(w, "      match:  {}", f.match_text.yellow())?;
            if !f.context.is_empty() && f.context != f.match_text {
                writeln!(w, "      context: {}", f.context.dimmed())?;
            }
            if let Some(c) = &f.commit {
                writeln!(w, "      commit: {}", c.dimmed())?;
            }
        }
    }

    writeln!(w)?;
    writeln!(w, "  {}", "─".repeat(60).dimmed())?;
    let by_sev = count_by_severity(findings);
    let mut parts = Vec::new();
    for (sev, n) in by_sev {
        parts.push(format!("{} {}", n.to_string().color(severity_color(sev)).bold(), sev.label().to_lowercase()));
    }
    writeln!(w, "  Total: {}", parts.join(", "))?;
    writeln!(w)?;
    Ok(())
}

fn report_json(findings: &[Finding], w: &mut dyn Write) -> anyhow::Result<()> {
    #[derive(serde::Serialize)]
    struct Output<'a> {
        tool: &'a str,
        version: &'a str,
        count: usize,
        findings: &'a [Finding],
        summary: std::collections::BTreeMap<String, usize>,
    }
    let summary = count_by_severity(findings)
        .into_iter()
        .map(|(k, v)| (k.label().to_string(), v))
        .collect();

    let output = Output {
        tool: "secradar",
        version: env!("CARGO_PKG_VERSION"),
        count: findings.len(),
        findings,
        summary,
    };
    writeln!(w, "{}", serde_json::to_string_pretty(&output)?)?;
    Ok(())
}

fn report_sarif(findings: &[Finding], w: &mut dyn Write) -> anyhow::Result<()> {
    // SARIF 2.1.0 format for GitHub code scanning compatibility
    let sarif = serde_json::json!({
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "version": "2.1.0",
        "runs": [{
            "tool": {
                "driver": {
                    "name": "secradar",
                    "version": env!("CARGO_PKG_VERSION"),
                    "informationUri": "https://github.com/afiqandico13/secradar",
                    "rules": build_sarif_rules(),
                }
            },
            "results": findings.iter().map(|f| {
                serde_json::json!({
                    "ruleId": f.rule_id,
                    "ruleIndex": rule_index(&f.rule_id),
                    "level": sarif_level(f.severity),
                    "message": {"text": format!("{}: {}", f.rule_name, f.match_text)},
                    "locations": [{
                        "physicalLocation": {
                            "artifactLocation": {"uri": f.file.display().to_string()},
                            "region": {
                                "startLine": f.line,
                                "startColumn": f.column,
                                "snippet": {"text": f.context},
                            }
                        }
                    }]
                })
            }).collect::<Vec<_>>()
        }]
    });
    writeln!(w, "{}", serde_json::to_string_pretty(&sarif)?)?;
    Ok(())
}

fn report_compact(findings: &[Finding], w: &mut dyn Write) -> anyhow::Result<()> {
    for f in findings {
        writeln!(
            w,
            "{}:{}:{} [{}] {}: {}",
            f.file.display(),
            f.line,
            f.column,
            f.rule_id,
            f.severity.label(),
            f.match_text
        )?;
    }
    Ok(())
}

fn count_by_severity(findings: &[Finding]) -> Vec<(Severity, usize)> {
    use std::collections::BTreeMap;
    let mut counts: BTreeMap<Severity, usize> = BTreeMap::new();
    for f in findings {
        *counts.entry(f.severity).or_insert(0) += 1;
    }
    counts.into_iter().collect()
}

fn build_sarif_rules() -> serde_json::Value {
    use crate::rules::RULES;
    serde_json::json!(RULES.iter().enumerate().map(|(i, r)| {
        serde_json::json!({
            "id": r.id,
            "name": r.id,
            "shortDescription": {"text": r.name},
            "fullDescription": {"text": r.description},
            "defaultConfiguration": {"level": sarif_level(r.severity)},
            "helpUri": "https://github.com/afiqandico13/secradar",
        })
    }).collect::<Vec<_>>())
}

fn rule_index(id: &str) -> usize {
    use crate::rules::RULES;
    RULES.iter().position(|r| r.id == id).unwrap_or(0)
}

fn sarif_level(s: Severity) -> &'static str {
    match s {
        Severity::Critical | Severity::High => "error",
        Severity::Medium => "warning",
        Severity::Low | Severity::Info => "note",
    }
}