package main

import (
	"bytes"
	"encoding/json"
	"io"
	"os"
	"regexp"
	"testing"
)

func TestCalculateEntropy(t *testing.T) {
	tests := []struct {
		input string
		min   float64
		max   float64
	}{
		{"aaaa", 0.0, 0.1},
		{"abcd", 1.9, 2.1},
		{"AKIA12345678EXAMPLE", 3.7, 4.0},
		{"OhbVrpoi6gR1IfLBc7Wn3GMSJmXAPC5zUayEZwQk", 5.2, 5.5},
	}
	for _, tt := range tests {
		got := CalculateEntropy(tt.input)
		if got < tt.min || got > tt.max {
			t.Errorf("CalculateEntropy(%q) = %f, want between %f and %f", tt.input, got, tt.min, tt.max)
		}
	}
}

func TestEntropyDetection(t *testing.T) {
	if !IsLikelySecret("OhbVrpoi6gR1IfLBc7Wn3GMSJmXAPC5zUayEZwQk") {
		t.Error("Expected high-entropy string to be detected as secret")
	}

	jwt := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
	if IsLikelySecret(jwt) {
		t.Error("Expected JWT to be filtered out (false positive)")
	}

	if IsLikelySecret("123e4567-e89b-12d3-a456-426614174000") {
		t.Error("Expected UUID to be filtered out")
	}

	if IsLikelySecret("123E4567-E89B-12D3-A456-426614174000") {
		t.Error("Expected Uppercase UUID to be filtered out")
	}
}

func TestDefaultRulesMatch(t *testing.T) {
	rules := LoadDefaultRules()

	testCases := []struct {
		ruleID string
		input  string
		should bool
	}{
		{"S001", "AKIAIOSFODNN7EXAMPLE123", true},
		{"S001", "AKIAIOSFODNN7EXAMPL", false},
		{"S002", "api_key = 'abcd1234567890abcd1234'", true},
		{"S003", "-----BEGIN RSA PRIVATE KEY-----", true},
		{"D001", "USER root", true},
		{"D002", "FROM python:latest", true},
		{"D002", "FROM python:3.9", false},
	}

	ruleMap := make(map[string]*regexp.Regexp)
	for _, r := range rules {
		ruleMap[r.ID] = r.Regex
	}

	for _, tc := range testCases {
		re, ok := ruleMap[tc.ruleID]
		if !ok {
			t.Fatalf("Rule %s not found", tc.ruleID)
		}

		matches := re.MatchString(tc.input)
		if matches != tc.should {
			t.Errorf("Rule %s: input %q, expected %v but got %v", tc.ruleID, tc.input, tc.should, matches)
		}
	}
}

func TestScanFile(t *testing.T) {
	content := []byte(`var awsKey = "AKIAIOSFODNN7EXAMPLE123"`)
	tmpfile, err := os.CreateTemp("", "sift_test_scan_*.go")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpfile.Name())

	if _, err := tmpfile.Write(content); err != nil {
		t.Fatal(err)
	}
	if err := tmpfile.Close(); err != nil {
		t.Fatal(err)
	}

	rules := LoadDefaultRules()
	findings := scanFile(tmpfile.Name(), rules)

	if len(findings) == 0 {
		t.Error("Expected to find AWS key, got 0 findings")
	}

	found := false
	for _, f := range findings {
		if f.RuleID == "S001" {
			found = true
			break
		}
	}
	if !found {
		t.Error("Expected to find rule S001 (AWS Key)")
	}
}

func TestCustomRulesParsing(t *testing.T) {
	tmpfile, err := os.CreateTemp("", "sift_test_rules_*.txt")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpfile.Name())

	content := "CUST01|HIGH|(?i)password\\s*=|Password leak\n"
	if _, err := tmpfile.WriteString(content); err != nil {
		t.Fatal(err)
	}
	tmpfile.Close()

	rules, err := LoadCustomRules(tmpfile.Name())
	if err != nil {
		t.Fatalf("LoadCustomRules failed: %v", err)
	}
	if len(rules) != 1 {
		t.Errorf("Expected 1 rule, got %d", len(rules))
	}
	if rules[0].ID != "CUST01" {
		t.Errorf("Expected ID CUST01, got %s", rules[0].ID)
	}
}

func TestCustomRulesCompileError(t *testing.T) {
	tmpfile, err := os.CreateTemp("", "sift_test_rules_bad_*.txt")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpfile.Name())

	content := "BADRULE|HIGH|[invalid(regex|Bad rule\n"
	if _, err := tmpfile.WriteString(content); err != nil {
		t.Fatal(err)
	}
	tmpfile.Close()

	rules, err := LoadCustomRules(tmpfile.Name())

	if err != nil {
		t.Errorf("Expected LoadCustomRules to handle invalid regex gracefully, got error: %v", err)
	}
	if len(rules) != 0 {
		t.Errorf("Expected invalid regex to be skipped (0 rules), got %d rules", len(rules))
	}
}

func TestJSONOutput(t *testing.T) {
	findings := []Finding{{
		RuleID: "S001", Severity: "CRITICAL",
		Desc: "AWS Key", File: "test.go", Line: 5,
		Snippet: "var key = AKIA...",
	}}

	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	PrintJSON(findings)

	w.Close()
	os.Stdout = oldStdout

	var buf bytes.Buffer
	io.Copy(&buf, r)

	var parsed []Finding
	if err := json.Unmarshal(buf.Bytes(), &parsed); err != nil {
		t.Errorf("PrintJSON output is not valid JSON: %v", err)
	}
	if len(parsed) != 1 || parsed[0].RuleID != "S001" {
		t.Errorf("JSON output mismatch")
	}
}
