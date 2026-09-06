//! Built-in detection rules.
//!
//! Each rule matches a specific kind of secret (AWS keys, GitHub tokens, etc.).
//! Rules can be disabled via config or `--skip-rule` flag.

use crate::entropy::shannon_entropy;
use crate::findings::{Finding, Severity};
use once_cell::sync::Lazy;
use regex::Regex;
use std::path::Path;

#[derive(Debug, Clone)]
pub struct Rule {
    pub id: &'static str,
    pub name: &'static str,
    pub description: &'static str,
    pub severity: Severity,
    pub regex: &'static Lazy<Regex>,
    /// Minimum entropy of the matched string (0.0 = ignore entropy).
    pub min_entropy: f64,
}

/// All built-in rules.
pub static RULES: &[Rule] = &[
    // ---- Cloud providers ----
    Rule {
        id: "SR001",
        name: "AWS Access Key ID",
        description: "Amazon Web Services access key identifier",
        severity: Severity::Critical,
        regex: &AWS_ACCESS_KEY,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR002",
        name: "AWS Secret Access Key",
        description: "Amazon Web Services secret access key",
        severity: Severity::Critical,
        regex: &AWS_SECRET_KEY,
        min_entropy: 3.5,
    },
    Rule {
        id: "SR003",
        name: "Google API Key",
        description: "Google Cloud API key",
        severity: Severity::Critical,
        regex: &GOOGLE_API_KEY,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR004",
        name: "Azure Subscription Key",
        description: "Microsoft Azure subscription / API key",
        severity: Severity::High,
        regex: &AZURE_KEY,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR005",
        name: "DigitalOcean PAT",
        description: "DigitalOcean personal access token",
        severity: Severity::High,
        regex: &DO_TOKEN,
        min_entropy: 0.0,
    },

    // ---- Source control ----
    Rule {
        id: "SR010",
        name: "GitHub Personal Access Token",
        description: "GitHub personal access token (classic)",
        severity: Severity::Critical,
        regex: &GITHUB_PAT,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR011",
        name: "GitHub Fine-grained PAT",
        description: "GitHub fine-grained personal access token",
        severity: Severity::Critical,
        regex: &GITHUB_FG_PAT,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR012",
        name: "GitHub OAuth Token",
        description: "GitHub OAuth access token",
        severity: Severity::Critical,
        regex: &GITHUB_OAUTH,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR013",
        name: "GitLab Personal Access Token",
        description: "GitLab personal access token",
        severity: Severity::Critical,
        regex: &GITLAB_PAT,
        min_entropy: 0.0,
    },

    // ---- Communication ----
    Rule {
        id: "SR020",
        name: "Slack Bot Token",
        description: "Slack bot user OAuth token",
        severity: Severity::High,
        regex: &SLACK_TOKEN,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR021",
        name: "Slack Webhook URL",
        description: "Slack incoming webhook URL",
        severity: Severity::Medium,
        regex: &SLACK_WEBHOOK,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR022",
        name: "Discord Webhook URL",
        description: "Discord webhook URL",
        severity: Severity::Medium,
        regex: &DISCORD_WEBHOOK,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR023",
        name: "Telegram Bot Token",
        description: "Telegram bot API token",
        severity: Severity::High,
        regex: &TELEGRAM_TOKEN,
        min_entropy: 0.0,
    },

    // ---- Payment ----
    Rule {
        id: "SR030",
        name: "Stripe Live Key",
        description: "Stripe live secret API key",
        severity: Severity::Critical,
        regex: &STRIPE_LIVE,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR031",
        name: "Stripe Test Key",
        description: "Stripe test secret API key (less critical but should not be committed)",
        severity: Severity::Low,
        regex: &STRIPE_TEST,
        min_entropy: 0.0,
    },

    // ---- Auth tokens ----
    Rule {
        id: "SR040",
        name: "JWT Token",
        description: "JSON Web Token (3-part base64)",
        severity: Severity::Medium,
        regex: &JWT,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR041",
        name: "Heroku API Key",
        description: "Heroku API key",
        severity: Severity::High,
        regex: &HEROKU,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR042",
        name: "npm Auth Token",
        description: "npm registry authentication token",
        severity: Severity::High,
        regex: &NPM_TOKEN,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR043",
        name: "PyPI Token",
        description: "PyPI upload token",
        severity: Severity::High,
        regex: &PYPI_TOKEN,
        min_entropy: 0.0,
    },

    // ---- Private keys ----
    Rule {
        id: "SR050",
        name: "RSA Private Key",
        description: "PEM-encoded RSA private key",
        severity: Severity::Critical,
        regex: &RSA_PRIVATE_KEY,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR051",
        name: "OpenSSH Private Key",
        description: "OpenSSH private key",
        severity: Severity::Critical,
        regex: &OPENSSH_PRIVATE_KEY,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR052",
        name: "PGP Private Key",
        description: "PGP private key block",
        severity: Severity::Critical,
        regex: &PGP_PRIVATE_KEY,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR053",
        name: "EC Private Key",
        description: "Elliptic curve private key (PEM)",
        severity: Severity::Critical,
        regex: &EC_PRIVATE_KEY,
        min_entropy: 0.0,
    },

    // ---- Generic / contextual ----
    Rule {
        id: "SR060",
        name: "Generic API Key Assignment",
        description: "Variable name suggests API key + assigned value",
        severity: Severity::Medium,
        regex: &GENERIC_API_KEY,
        min_entropy: 3.5,
    },
    Rule {
        id: "SR061",
        name: "Generic Password Assignment",
        description: "Variable name suggests password + assigned value",
        severity: Severity::High,
        regex: &GENERIC_PASSWORD,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR062",
        name: "Generic Secret Assignment",
        description: "Variable name suggests secret + assigned value",
        severity: Severity::High,
        regex: &GENERIC_SECRET,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR063",
        name: "Connection String with Credentials",
        description: "Database connection string containing username/password",
        severity: Severity::Critical,
        regex: &CONNECTION_STRING,
        min_entropy: 0.0,
    },
    Rule {
        id: "SR064",
        name: "Basic Auth in URL",
        description: "HTTP URL with embedded credentials",
        severity: Severity::High,
        regex: &BASIC_AUTH_URL,
        min_entropy: 0.0,
    },
];

// =====================================================================
// REGEX DEFINITIONS
// =====================================================================

// Cloud
static AWS_ACCESS_KEY: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\b((?:AKIA|ASIA)[A-Z0-9]{16})\b").unwrap());
static AWS_SECRET_KEY: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r#"(?i)aws(.{0,20})?(secret|private)?(.{0,20})?['"][A-Za-z0-9/+=]{40}['"]"#).unwrap()
});
static GOOGLE_API_KEY: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bAIza[0-9A-Za-z\-_]{35}\b").unwrap());
static AZURE_KEY: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r#"(?i)azure(.{0,20})?(key|secret|token)(.{0,20})?['"][A-Za-z0-9/+]{40,}['"]"#).unwrap()
});
static DO_TOKEN: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bdop_v1_[a-f0-9]{64}\b").unwrap());

// Source control
static GITHUB_PAT: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bghp_[A-Za-z0-9]{36}\b").unwrap());
static GITHUB_FG_PAT: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bgithub_pat_[A-Za-z0-9_]{82}\b").unwrap());
static GITHUB_OAUTH: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bgho_[A-Za-z0-9]{36}\b").unwrap());
static GITLAB_PAT: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bglpat-[A-Za-z0-9_\-]{20,}\b").unwrap());

// Communication
static SLACK_TOKEN: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bxox[abpr]-[A-Za-z0-9-]{10,}\b").unwrap());
static SLACK_WEBHOOK: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"https://hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]+").unwrap());
static DISCORD_WEBHOOK: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"https://(?:ptb\.|canary\.)?discord(?:app)?\.com/api/webhooks/\d+/[A-Za-z0-9_\-]+")
        .unwrap()
});
static TELEGRAM_TOKEN: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\b\d{8,10}:[A-Za-z0-9_\-]{35}\b").unwrap());

// Payment
static STRIPE_LIVE: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bsk_live_[A-Za-z0-9]{24,}\b").unwrap());
static STRIPE_TEST: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bsk_test_[A-Za-z0-9]{24,}\b").unwrap());

// Auth
static JWT: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"\beyJ[A-Za-z0-9_\-]+\.eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+").unwrap()
});
static HEROKU: Lazy<Regex> =
    Lazy::new(|| Regex::new(r#"(?i)heroku(.{0,20})?['"][0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}['"]"#).unwrap());
static NPM_TOKEN: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"\bnpm_[A-Za-z0-9]{36}\b").unwrap());
static PYPI_TOKEN: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"\bpypi-AgEIcHlwaS5vcmc[A-Za-z0-9_\-]{50,}\b").unwrap()
});

// Private keys
static RSA_PRIVATE_KEY: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"-----BEGIN RSA PRIVATE KEY-----").unwrap());
static OPENSSH_PRIVATE_KEY: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"-----BEGIN OPENSSH PRIVATE KEY-----").unwrap());
static PGP_PRIVATE_KEY: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"-----BEGIN PGP PRIVATE KEY BLOCK-----").unwrap());
static EC_PRIVATE_KEY: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"-----BEGIN EC PRIVATE KEY-----").unwrap());

// Generic (require context)
static GENERIC_API_KEY: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r#"(?i)(api[_-]?key|apikey)\s*[:=]\s*['"]?([A-Za-z0-9_\-]{20,})['"]?"#).unwrap()
});
static GENERIC_PASSWORD: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r#"(?i)(password|passwd|pwd)\s*[:=]\s*['"]?([^\s'"]{6,})['"]?"#).unwrap()
});
static GENERIC_SECRET: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r#"(?i)(secret|client[_-]?secret)\s*[:=]\s*['"]?([A-Za-z0-9_\-]{16,})['"]?"#).unwrap()
});
static CONNECTION_STRING: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r#"(?i)(mongodb|postgres|postgresql|mysql|redis|amqp):\/\/[^:\/\s]+:[^@\/\s]+@[^:\/\s]+"#)
        .unwrap()
});
static BASIC_AUTH_URL: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"https?:\/\/[A-Za-z0-9_\-~]+:[^@\/\s]+@[^\s]+").unwrap());

// =====================================================================
// MATCHING
// =====================================================================

/// A match produced by a rule on a single line.
#[derive(Debug, Clone)]
pub struct RuleMatch {
    pub rule: &'static Rule,
    pub matched_text: String,
    pub column: usize,
}

pub type RuleId = &'static str;

/// Scan a single line of content and return all rule matches.
pub fn scan_line(line: &str) -> Vec<RuleMatch> {
    let mut matches = Vec::new();
    for rule in RULES {
        for m in rule.regex.find_iter(line) {
            let matched = m.as_str().to_string();
            // Skip if entropy check fails
            if rule.min_entropy > 0.0 {
                let e = shannon_entropy(&matched);
                if e < rule.min_entropy {
                    continue;
                }
            }
            matches.push(RuleMatch {
                rule,
                matched_text: matched,
                column: m.start() + 1,
            });
        }
    }
    matches
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_aws_access_key() {
        let m = scan_line("AKIAIOSFODNN7EXAMPLE");
        assert_eq!(m.len(), 1);
        assert_eq!(m[0].rule.id, "SR001");
    }

    #[test]
    fn test_github_pat() {
        let m = scan_line("token = ghp_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        assert!(m.iter().any(|m| m.rule.id == "SR010"));
    }

    #[test]
    fn test_google_api_key() {
        let m = scan_line("GOOGLE_KEY=AIzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        assert!(m.iter().any(|m| m.rule.id == "SR003"));
    }

    #[test]
    fn test_no_false_positive_in_normal_text() {
        let m = scan_line("The quick brown fox jumps over the lazy dog.");
        assert!(m.is_empty());
    }

    #[test]
    fn test_private_key_header() {
        let m = scan_line("-----BEGIN RSA PRIVATE KEY-----");
        assert!(m.iter().any(|m| m.rule.id == "SR050"));
    }

    #[test]
    fn test_jwt() {
        let m = scan_line("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c");
        assert!(m.iter().any(|m| m.rule.id == "SR040"));
    }

    #[test]
    fn test_stripe_live() {
        // Build the key at runtime so the literal "sk_live_" prefix
        // doesn't appear in source code (and trip secret scanners)
        let key = format!("{}{}", "sk_live_", "a".repeat(30));
        let m = scan_line(&key);
        assert!(m.iter().any(|m| m.rule.id == "SR030"));
    }
}