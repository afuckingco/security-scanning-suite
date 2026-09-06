package main

import (
	"math"
	"regexp"
	"strings"
)

var (
	quoteRegex = regexp.MustCompile(`["']([^"']{16,})["']`)
	uuidRx     = regexp.MustCompile(`(?i)^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$`)
	base64Part = regexp.MustCompile(`^[A-Za-z0-9_-]+$`)
)

func CalculateEntropy(str string) float64 {
	if str == "" {
		return 0.0
	}
	freq := make(map[rune]float64)
	for _, char := range str {
		freq[char]++
	}

	entropy := 0.0
	length := float64(len(str))
	for _, count := range freq {
		p := count / length
		entropy -= p * math.Log2(p)
	}
	return entropy
}

func isBase64URLPart(s string) bool {
	return base64Part.MatchString(s)
}

func IsLikelySecret(str string) bool {
	ent := CalculateEntropy(str)

	if ent < 5.2 {
		return false
	}

	if strings.Count(str, ".") == 2 {
		parts := strings.Split(str, ".")
		if len(parts) == 3 && isBase64URLPart(parts[0]) && isBase64URLPart(parts[1]) && isBase64URLPart(parts[2]) {
			return false
		}
	}

	if uuidRx.MatchString(str) {
		return false
	}

	hasLower := strings.ContainsAny(str, "abcdefghijklmnopqrstuvwxyz")
	hasUpper := strings.ContainsAny(str, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	hasDigit := strings.ContainsAny(str, "0123456789")

	if hasLower && hasUpper && hasDigit {
		return true
	}

	if ent > 5.8 {
		return true
	}

	return false
}
