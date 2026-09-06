"""End-to-end smoke test."""
import subprocess
import sys
import os


def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True, cwd=os.path.dirname(os.path.abspath(__file__)) + "/..")
    return r.returncode, r.stdout, r.stderr


def test_cli_clean_dockerfile():
    dockerfile = """FROM node:20-alpine
USER node
HEALTHCHECK CMD wget -q --spider http://localhost:3000 || exit 1
CMD ["node", "server.js"]
"""
    test_path = "/tmp/_dockguard_test_clean.Dockerfile"
    with open(test_path, "w") as f:
        f.write(dockerfile)

    code, out, err = run(["python", "-m", "dockguard", "--format", "json", "--no-color", test_path])
    assert code == 0, f"Expected exit 0, got {code}\nstdout={out}\nstderr={err}"

    import json
    data = json.loads(out)
    assert data["summary"]["error"] == 0, f"Expected no errors, got: {data}"
    print("✓ Clean Dockerfile → exit 0, no errors")


def test_cli_dirty_dockerfile():
    dockerfile = """FROM node:latest
RUN curl https://get.example.com | sh
ENV PASSWORD=hello
"""
    test_path = "/tmp/_dockguard_test_dirty.Dockerfile"
    with open(test_path, "w") as f:
        f.write(dockerfile)

    code, out, err = run(["python", "-m", "dockguard", "--format", "json", "--no-color", test_path])
    assert code == 2, f"Expected exit 2 (errors), got {code}"

    import json
    data = json.loads(out)
    assert data["summary"]["error"] > 0, f"Expected errors, got: {data}"
    print(f"✓ Dirty Dockerfile → exit 2, {data['summary']['error']} errors, {data['summary']['warning']} warnings")


def test_cli_github_format():
    dockerfile = "FROM node:latest\n"
    test_path = "/tmp/_dockguard_test_gh.Dockerfile"
    with open(test_path, "w") as f:
        f.write(dockerfile)

    code, out, err = run(["python", "-m", "dockguard", "--format", "github", "--no-color", test_path])
    assert "::warning" in out, f"Expected GitHub annotation format, got: {out}"
    print("✓ GitHub format → annotations present")


def test_cli_quiet_mode():
    dockerfile = "FROM node:20-alpine\n"
    test_path = "/tmp/_dockguard_test_quiet.Dockerfile"
    with open(test_path, "w") as f:
        f.write(dockerfile)

    code, out, err = run(["python", "-m", "dockguard", "--quiet", test_path])
    assert code == 0
    assert out == "", f"Expected empty output in quiet mode, got: {out!r}"
    print("✓ Quiet mode → no output, exit code only")


def test_cli_missing_file():
    code, out, err = run(["python", "-m", "dockguard", "/nonexistent/Dockerfile"])
    assert code == 2, f"Expected exit 2 for missing file, got {code}"
    print("✓ Missing file → exit 2")


if __name__ == "__main__":
    test_cli_clean_dockerfile()
    test_cli_dirty_dockerfile()
    test_cli_github_format()
    test_cli_quiet_mode()
    test_cli_missing_file()
    print("\n✅ All CLI smoke tests passed")