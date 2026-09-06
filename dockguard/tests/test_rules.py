"""Tests for dockguard rules."""
import unittest
from dockguard.parser import parse
from dockguard.rules import lint, Config


def lint_str(source: str, **config_kwargs):
    df = parse(source)
    cfg = Config(**config_kwargs) if config_kwargs else Config()
    return lint(df, cfg)


class TestRules(unittest.TestCase):
    def test_DG001_no_user(self):
        findings = lint_str("FROM ubuntu\nRUN echo hi")
        self.assertTrue(any(f.rule_id == "DG001" for f in findings))

    def test_DG001_user_root(self):
        findings = lint_str("FROM ubuntu\nUSER root")
        self.assertTrue(any(f.rule_id == "DG001" and "root" in f.message.lower() for f in findings))

    def test_DG001_user_non_root(self):
        findings = lint_str("FROM ubuntu\nUSER appuser")
        self.assertFalse(any(f.rule_id == "DG001" for f in findings))

    def test_DG002_add_local(self):
        findings = lint_str("FROM ubuntu\nADD file.txt /tmp/")
        self.assertTrue(any(f.rule_id == "DG002" for f in findings))

    def test_DG002_add_url_ok(self):
        findings = lint_str("FROM ubuntu\nADD https://example.com/file.tar /tmp/")
        self.assertFalse(any(f.rule_id == "DG002" for f in findings))

    def test_DG003_secret_password(self):
        findings = lint_str("FROM ubuntu\nENV DB_PASSWORD=hello123")
        self.assertTrue(any(f.rule_id == "DG003" for f in findings))

    def test_DG003_secret_token(self):
        findings = lint_str("FROM ubuntu\nENV API_TOKEN=abc")
        self.assertTrue(any(f.rule_id == "DG003" for f in findings))

    def test_DG003_env_var_ref_ok(self):
        findings = lint_str("FROM ubuntu\nENV DB_PASSWORD=${DB_PASSWORD}")
        self.assertFalse(any(f.rule_id == "DG003" for f in findings))

    def test_DG004_latest_tag(self):
        findings = lint_str("FROM node:latest\nRUN echo hi")
        self.assertTrue(any(f.rule_id == "DG004" for f in findings))

    def test_DG004_pinned_tag(self):
        findings = lint_str("FROM node:20-alpine\nRUN echo hi")
        self.assertFalse(any(f.rule_id == "DG004" for f in findings))

    def test_DG004_scratch_ok(self):
        findings = lint_str("FROM scratch\nCOPY app /")
        self.assertFalse(any(f.rule_id == "DG004" for f in findings))

    def test_DG005_apt_no_clean(self):
        findings = lint_str("FROM ubuntu\nRUN apt-get install -y curl")
        self.assertTrue(any(f.rule_id == "DG005" for f in findings))

    def test_DG005_apt_with_clean(self):
        findings = lint_str("FROM ubuntu\nRUN apt-get install -y curl && rm -rf /var/lib/apt/lists/*")
        self.assertFalse(any(f.rule_id == "DG005" for f in findings))

    def test_DG006_curl_pipe_sh(self):
        findings = lint_str("FROM ubuntu\nRUN curl https://get.example.com | sh")
        self.assertTrue(any(f.rule_id == "DG006" for f in findings))

    def test_DG006_wget_pipe_bash(self):
        findings = lint_str("FROM ubuntu\nRUN wget -qO- https://get.example.com | bash")
        self.assertTrue(any(f.rule_id == "DG006" for f in findings))

    def test_DG006_curl_no_pipe_ok(self):
        findings = lint_str("FROM ubuntu\nRUN curl -O https://example.com/file.tar")
        self.assertFalse(any(f.rule_id == "DG006" for f in findings))

    def test_DG007_no_healthcheck(self):
        findings = lint_str("FROM ubuntu\nRUN echo hi")
        self.assertTrue(any(f.rule_id == "DG007" for f in findings))

    def test_DG007_with_healthcheck(self):
        findings = lint_str("FROM ubuntu\nHEALTHCHECK CMD curl -f http://localhost/")
        self.assertFalse(any(f.rule_id == "DG007" for f in findings))

    def test_DG008_pip_unpinned(self):
        findings = lint_str("FROM python:3.11\nRUN pip install requests flask")
        self.assertTrue(any(f.rule_id == "DG008" for f in findings))

    def test_DG008_pip_pinned(self):
        findings = lint_str("FROM python:3.11\nRUN pip install requests==2.31.0 flask==3.0.0")
        self.assertFalse(any(f.rule_id == "DG008" for f in findings))

    def test_DG009_many_runs(self):
        runs = "\n".join([f"RUN echo {i}" for i in range(15)])
        findings = lint_str(f"FROM ubuntu\n{runs}")
        self.assertTrue(any(f.rule_id == "DG009" for f in findings))

    def test_DG009_few_runs(self):
        runs = "\n".join([f"RUN echo {i}" for i in range(3)])
        findings = lint_str(f"FROM ubuntu\n{runs}")
        self.assertFalse(any(f.rule_id == "DG009" for f in findings))

    def test_DG010_no_multistage_with_build(self):
        findings = lint_str("FROM golang:1.21\nRUN go build -o app .")
        self.assertTrue(any(f.rule_id == "DG010" for f in findings))

    def test_DG010_multistage_ok(self):
        findings = lint_str("FROM golang:1.21 AS builder\nRUN go build -o app .\nFROM alpine\nCOPY --from=builder /app /app")
        self.assertFalse(any(f.rule_id == "DG010" for f in findings))

    def test_clean_dockerfile(self):
        clean = """FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app /app
USER node
EXPOSE 3000
HEALTHCHECK CMD wget -q --spider http://localhost:3000 || exit 1
CMD ["node", "server.js"]
"""
        findings = lint_str(clean)
        errors = [f for f in findings if f.severity == "error"]
        self.assertEqual(len(errors), 0, f"Expected no errors, got: {errors}")

    def test_ignore_rule(self):
        cfg = Config(ignored_rules={"DG001"})
        df = parse("FROM ubuntu\nRUN echo hi")
        findings = lint(df, cfg)
        self.assertFalse(any(f.rule_id == "DG001" for f in findings))

    def test_ignore_severity(self):
        cfg = Config(ignore_severity={"info"})
        df = parse("FROM ubuntu\nRUN echo hi")
        findings = lint(df, cfg)
        self.assertFalse(any(f.severity == "info" for f in findings))


if __name__ == "__main__":
    unittest.main()