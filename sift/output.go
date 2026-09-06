package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"
)

const (
	CReset  = "\033[0m"
	CRed    = "\033[31m"
	CGreen  = "\033[32m"
	CYellow = "\033[33m"
	CCyan   = "\033[36m"
	CBold   = "\033[1m"
)

var severityColors = map[string]string{
	"CRITICAL": CRed + CBold,
	"HIGH":     CRed,
	"MEDIUM":   CYellow,
	"LOW":      CCyan,
}

func PrintTerminal(findings []Finding, duration time.Duration) {
	if len(findings) == 0 {
		fmt.Printf("%s%s✅ Clean! No secrets or bad practices found.%s\n", CBold, CGreen, CReset)
		fmt.Printf("⏱️  Scanned in %v\n", duration)
		return
	}

	fmt.Printf("%s⚠️  Found %d issues in %v:%s\n\n", CYellow, len(findings), duration, CReset)

	for _, f := range findings {
		color, ok := severityColors[f.Severity]
		if !ok {
			color = CYellow
		}

		fmt.Printf("%s[%s]%s %s (%s)\n", color, f.Severity, CReset, f.Desc, f.RuleID)
		fmt.Printf("  %s:%d\n", f.File, f.Line)
		fmt.Printf("  %s| %s%s\n\n", CCyan, f.Snippet, CReset)
	}
}

func PrintJSON(findings []Finding) {
	jsonOut, err := json.MarshalIndent(findings, "", "  ")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error marshalling JSON")
		return
	}
	fmt.Println(string(jsonOut))
}
