"""Tests for output reporters."""
import json
import unittest
from dockguard.parser import parse
from dockguard.rules import lint, Config, Finding
from dockguard.reporter import report_pretty, report_json, report_github


class TestReporter(unittest.TestCase):
    def setUp(self):
        self.findings = [
            Finding(rule_id="DG003", severity="error", message="Secret leaked",
                    line_number=5, suggestion="Use docker secrets"),
            Finding(rule_id="DG001", severity="warning", message="Running as root",
                    line_number=1, suggestion="Add USER"),
            Finding(rule_id="DG007", severity="info", message="No healthcheck",
                    line_number=10, suggestion="Add HEALTHCHECK"),
        ]

    def test_json_format(self):
        result = report_json(self.findings, "Dockerfile")
        data = json.loads(result)
        self.assertEqual(data["tool"], "dockguard")
        self.assertEqual(data["file"], "Dockerfile")
        self.assertEqual(len(data["findings"]), 3)
        self.assertEqual(data["summary"]["error"], 1)
        self.assertEqual(data["summary"]["warning"], 1)
        self.assertEqual(data["summary"]["info"], 1)

    def test_github_format(self):
        result = report_github(self.findings, "Dockerfile")
        self.assertIn("::error file=Dockerfile,line=5::DG003", result)
        self.assertIn("::warning file=Dockerfile,line=1::DG001", result)
        self.assertIn("::notice file=Dockerfile,line=10::DG007", result)

    def test_pretty_format(self):
        result = report_pretty(self.findings, "Dockerfile", color=False)
        self.assertIn("Dockerfile", result)
        self.assertIn("DG003", result)
        self.assertIn("ERROR", result)
        self.assertIn("WARNING", result)
        self.assertIn("INFO", result)
        # No ANSI codes when color=False
        self.assertNotIn("\033", result)

    def test_pretty_format_with_color(self):
        result = report_pretty(self.findings, "Dockerfile", color=True)
        # Should contain ANSI escape codes
        self.assertIn("\033[", result)

    def test_pretty_empty(self):
        result = report_pretty([], "Dockerfile", color=False)
        self.assertIn("No issues", result)


class TestEndToEnd(unittest.TestCase):
    """Full pipeline: dockerfile string → parse → lint → report."""

    def test_vulnerable_dockerfile(self):
        dockerfile = """FROM node:latest
WORKDIR /app
COPY package*.json ./
RUN apt-get install -y curl
RUN curl https://get.example.com | sh
ENV API_KEY=***3000
CMD node server.js
"""
        df = parse(dockerfile)
        findings = lint(df)
        # Should catch: latest tag, root user, apt-get, curl|sh, secret, no healthcheck
        rule_ids = {f.rule_id for f in findings}
        self.assertIn("DG003", rule_ids)  # secret
        self.assertIn("DG004", rule_ids)  # latest
        self.assertIn("DG005", rule_ids)  # apt-get
        self.assertIn("DG006", rule_ids)  # curl|sh
        self.assertIn("DG001", rule_ids)  # no user

    def test_secure_dockerfile(self):
        dockerfile = """FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist /app/dist
USER node
EXPOSE 3000
HEALTHCHECK CMD wget -q --spider http://localhost:3000 || exit 1
CMD ["node", "server.js"]
"""
        df = parse(dockerfile)
        findings = lint(df)
        errors = [f for f in findings if f.severity == "error"]
        self.assertEqual(len(errors), 0, f"Unexpected errors: {errors}")


if __name__ == "__main__":
    unittest.main()