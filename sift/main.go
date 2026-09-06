package main

import (
	"flag"
	"fmt"
	"os"
	"time"
)

const SiftVersion = "1.0.0"

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Sift v%s — Fast zero-dependency secret scanner\n\n", SiftVersion)
		fmt.Fprintf(os.Stderr, "Usage:\n  sift [flags] [directory]\n\nFlags:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  sift .                                 # Scan current directory\n")
		fmt.Fprintf(os.Stderr, "  sift --git-diff .                      # Only changed files\n")
		fmt.Fprintf(os.Stderr, "  sift --json . > report.json            # JSON output for CI/CD\n")
		fmt.Fprintf(os.Stderr, "  sift --rules .siftrules .              # Custom rules\n")
	}

	useJSON := flag.Bool("json", false, "Output in JSON format (for CI/CD machines)")
	useGitDiff := flag.Bool("git-diff", false, "Scan only changed files (incremental mode)")
	customRulesPath := flag.String("rules", ".siftrules", "Path to custom rules file")
	useVersion := flag.Bool("version", false, "Show version and exit")
	flag.Parse()

	if *useVersion {
		fmt.Printf("Sift v%s\n", SiftVersion)
		os.Exit(0)
	}

	targetDir := "."
	if flag.NArg() > 0 {
		targetDir = flag.Arg(0)
	}

	info, err := os.Stat(targetDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "❌ Error: %v\n", err)
		os.Exit(1)
	}
	if !info.IsDir() {
		fmt.Fprintf(os.Stderr, "❌ Error: %s is not a directory\n", targetDir)
		os.Exit(1)
	}

	if !*useJSON {
		fmt.Printf("%s%s🔍 Sift v%s: Smart & Extensible Security Scanner%s\n\n", CBold, CCyan, SiftVersion, CReset)
	}

	defaultRules := LoadDefaultRules()
	rules := defaultRules

	customRules, err := LoadCustomRules(*customRulesPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "❌ Error loading custom rules: %v\n", err)
		os.Exit(1)
	}

	if len(customRules) > 0 {
		rules = append(rules, customRules...)
		if !*useJSON {
			fmt.Printf("✅ Loaded %d default rules + %d custom rules.\n\n", len(defaultRules), len(customRules))
		}
	} else {
		if !*useJSON {
			fmt.Printf("✅ Loaded %d default rules.\n\n", len(defaultRules))
		}
	}

	start := time.Now()
	findings := Scan(targetDir, rules, *useGitDiff)
	duration := time.Since(start)

	if *useJSON {
		PrintJSON(findings)
	} else {
		PrintTerminal(findings, duration)
	}

	for _, f := range findings {
		if f.Severity == "CRITICAL" || f.Severity == "HIGH" {
			os.Exit(1)
		}
	}
}
