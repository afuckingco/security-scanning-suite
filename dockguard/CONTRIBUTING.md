# Contributing to dockguard

Thanks for your interest in making Dockerfile linting better.

## Quick start

```bash
git clone https://github.com/afiqandico13/dockguard.git
cd dockguard
python -m unittest discover tests -v
python -m dockguard path/to/Dockerfile
```

No dependencies to install — pure Python stdlib.

## Project structure

```
dockguard/
├── __init__.py
├── __main__.py        # CLI entry point
├── parser.py          # Dockerfile parser
├── rules.py           # 10 lint rules
└── reporter.py        # output formatters
tests/
├── test_parser.py     # 8 tests
├── test_rules.py      # 22 tests
└── test_reporter.py   # 12 tests
```

## Adding a new rule

Each rule is a function in `rules.py`:

```python
def rule_DG011_my_check(df: Dockerfile, cfg: Config) -> List[Finding]:
    """DG011: Short description for users."""
    findings = []
    for instr in get_instructions_by_cmd(df, "MY_CMD"):
        if bad_condition:
            findings.append(Finding(
                rule_id="DG011",
                severity="warning",  # "error" | "warning" | "info"
                message="What's wrong",
                line_number=instr.line_number,
                suggestion="How to fix",
            ))
    return findings
```

Then register it:

```python
RULES["DG011"] = rule_DG011_my_check
```

Add tests in `tests/test_rules.py`:

```python
def test_DG011_my_check(self):
    df = parse("MY_CMD bad_value")
    findings = lint(df)
    rule_ids = {f.rule_id for f in findings}
    self.assertIn("DG011", rule_ids)
```

## Code style

- Pure Python stdlib (no external dependencies for the lib)
- Type hints encouraged but not required
- Functions prefer early-return over nested conditionals
- Docstrings for every public function

## Commit messages

Use conventional commits:

```
feat: add rule for LABEL MAINTAINER deprecation
fix: handle multi-line RUN with continuation
docs: add example for GitHub Actions
test: add coverage for empty Dockerfile
```

## Pull request process

1. Fork the repo
2. Create a branch (`git checkout -b add-rule-DG011`)
3. Add your rule + tests
4. Run `python -m unittest discover tests -v` — all must pass
5. Update CHANGELOG.md under "Unreleased"
6. Open a PR with a clear description

## License

By contributing, you agree that your contributions will be licensed under
the project's MIT license.