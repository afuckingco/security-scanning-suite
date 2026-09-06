package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

type Finding struct {
	RuleID   string `json:"rule_id"`
	Severity string `json:"severity"`
	Desc     string `json:"description"`
	File     string `json:"file"`
	Line     int    `json:"line"`
	Snippet  string `json:"snippet"`
}

func Scan(targetDir string, rules []Rule, useGitDiff bool) []Finding {
	var filesToScan []string

	if useGitDiff {
		filesToScan = getGitDiffFiles(targetDir)
	} else {
		filesToScan = getAllFiles(targetDir)
	}

	var findings []Finding
	var mu sync.Mutex
	var wg sync.WaitGroup

	fileChan := make(chan string, 100)

	for i := 0; i < 4; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for path := range fileChan {
				res := scanFile(path, rules)
				if len(res) > 0 {
					mu.Lock()
					findings = append(findings, res...)
					mu.Unlock()
				}
			}
		}()
	}

	for _, f := range filesToScan {
		fileChan <- f
	}
	close(fileChan)
	wg.Wait()

	return findings
}

func getAllFiles(root string) []string {
	var files []string
	filepath.WalkDir(root, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return nil
		}

		if d.Type()&os.ModeSymlink != 0 {
			return nil
		}

		if d.IsDir() {
			name := d.Name()
			if strings.HasPrefix(name, ".") || name == "node_modules" || name == "vendor" || name == "target" {
				return filepath.SkipDir
			}
			return nil
		}

		info, _ := d.Info()
		if info != nil && info.Size() < 2*1024*1024 {
			files = append(files, path)
		}
		return nil
	})
	return files
}

func getGitDiffFiles(dir string) []string {
	if _, err := os.Stat(filepath.Join(dir, ".git")); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "⚠️  Not a git repo, scanning all files\n")
		return getAllFiles(dir)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "git", "-C", dir, "diff", "--name-only", "HEAD~1..HEAD")
	out, err := cmd.Output()

	if err != nil {
		if ctx.Err() == context.DeadlineExceeded {
			fmt.Fprintf(os.Stderr, "⚠️  Git command timed out, scanning all files\n")
			return getAllFiles(dir)
		}

		ctx2, cancel2 := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel2()
		cmd = exec.CommandContext(ctx2, "git", "-C", dir, "diff", "--name-only", "--cached")
		out, err = cmd.Output()

		if err != nil {
			fmt.Fprintf(os.Stderr, "⚠️  Could not determine changed files via git, scanning all files\n")
			return getAllFiles(dir)
		}
	}

	var files []string
	for _, f := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		f = strings.TrimSpace(f)
		if f != "" {
			fullPath := filepath.Join(dir, f)
			if info, err := os.Stat(fullPath); err == nil && !info.IsDir() {
				files = append(files, fullPath)
			}
		}
	}

	if len(files) == 0 {
		fmt.Fprintf(os.Stderr, "⚠️  No changed files found in git, scanning all files\n")
		return getAllFiles(dir)
	}

	return files
}

func scanFile(path string, rules []Rule) []Finding {
	var res []Finding
	file, err := os.Open(path)
	if err != nil {
		return nil
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024)
	lineNum := 0

	for scanner.Scan() {
		lineNum++
		line := scanner.Text()

		for _, rule := range rules {
			if rule.Regex.MatchString(line) {
				res = append(res, createFinding(rule, path, lineNum, line))
			}
		}

		matches := quoteRegex.FindAllStringSubmatch(line, -1)
		for _, match := range matches {
			if len(match) > 1 && IsLikelySecret(match[1]) {
				res = append(res, Finding{
					RuleID: "ENT01", Severity: "HIGH", Desc: "High-entropy string detected (Potential Zero-Day Secret)",
					File: path, Line: lineNum, Snippet: truncate(line),
				})
				break
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "⚠️  Error scanning %s: %v\n", path, err)
	}

	return res
}

func createFinding(r Rule, path string, lineNum int, line string) Finding {
	return Finding{
		RuleID: r.ID, Severity: r.Severity, Desc: r.Desc,
		File: path, Line: lineNum, Snippet: truncate(line),
	}
}

func truncate(s string) string {
	s = strings.TrimSpace(s)
	if len(s) > 60 {
		return s[:57] + "..."
	}
	return s
}
