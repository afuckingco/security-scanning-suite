package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

type Rule struct {
	ID       string
	Desc     string
	Pattern  string
	Severity string
	Regex    *regexp.Regexp
}

var validSeverities = map[string]bool{
	"CRITICAL": true,
	"HIGH":     true,
	"MEDIUM":   true,
	"LOW":      true,
}

func LoadDefaultRules() []Rule {
	defaults := []Rule{
		{ID: "S001", Desc: "AWS Access Key", Pattern: `(?i)(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}`, Severity: "CRITICAL"},
		{ID: "S002", Desc: "Generic Secret/Token", Pattern: `(?i)(api_key|apikey|token|secret|password|passwd)\s*[:=]\s*['"]?[a-zA-Z0-9_\-]{20,}['"]?`, Severity: "HIGH"},
		{ID: "S003", Desc: "Private Key Block", Pattern: `-----BEGIN (RSA|EC|DSA|OPENSSH) PRIVATE KEY-----`, Severity: "CRITICAL"},
		{ID: "D001", Desc: "Docker USER root", Pattern: `(?m)^USER\s+root`, Severity: "MEDIUM"},
		{ID: "D002", Desc: "Docker :latest tag", Pattern: `(?m)^FROM\s+[a-zA-Z0-9_.-]+:latest`, Severity: "LOW"},
	}

	for i := range defaults {
		re, err := regexp.Compile(defaults[i].Pattern)
		if err != nil {
			fmt.Fprintf(os.Stderr, "❌ FATAL: Default rule %s has invalid pattern: %v\n", defaults[i].ID, err)
			os.Exit(1)
		}
		defaults[i].Regex = re
	}
	return defaults
}

func LoadCustomRules(filePath string) ([]Rule, error) {
	file, err := os.Open(filePath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}
	defer file.Close()

	var customRules []Rule
	scanner := bufio.NewScanner(file)
	lineNum := 0

	for scanner.Scan() {
		lineNum++
		line := strings.TrimSpace(scanner.Text())

		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.Split(line, "|")
		if len(parts) != 4 {
			fmt.Fprintf(os.Stderr, "⚠️  Warning: Invalid format at %s line %d (skipped)\n", filePath, lineNum)
			continue
		}

		id := strings.TrimSpace(parts[0])
		severity := strings.TrimSpace(parts[1])
		pattern := strings.TrimSpace(parts[2])
		desc := strings.TrimSpace(parts[3])

		if !validSeverities[severity] {
			fmt.Fprintf(os.Stderr, "⚠️  Invalid severity '%s' at %s line %d (use: CRITICAL, HIGH, MEDIUM, LOW)\n",
				severity, filePath, lineNum)
			continue
		}

		if len(pattern) > 500 {
			fmt.Fprintf(os.Stderr, "⚠️  Warning: Regex too long at %s line %d (skipped)\n", filePath, lineNum)
			continue
		}

		compiled, err := regexp.Compile(pattern)
		if err != nil {
			fmt.Fprintf(os.Stderr, "⚠️  Warning: Invalid regex at %s line %d: %v\n", filePath, lineNum, err)
			continue
		}

		customRules = append(customRules, Rule{
			ID: id, Desc: desc, Pattern: pattern, Severity: severity, Regex: compiled,
		})
	}
	return customRules, nil
}
