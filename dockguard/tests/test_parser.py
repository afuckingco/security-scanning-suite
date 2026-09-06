"""Tests for Dockerfile parser."""
import unittest
from dockguard.parser import parse


class TestParser(unittest.TestCase):
    def test_basic_from_run(self):
        df = parse("FROM ubuntu:22.04\nRUN apt-get update")
        self.assertEqual(len(df.instructions), 2)
        self.assertEqual(df.instructions[0].cmd, "FROM")
        self.assertEqual(df.instructions[0].value, "ubuntu:22.04")
        self.assertEqual(df.instructions[1].cmd, "RUN")
        self.assertEqual(df.instructions[1].value, "apt-get update")

    def test_empty_lines_and_comments(self):
        df = parse("\n# Comment\nFROM alpine\n\nRUN echo hi\n")
        self.assertEqual(len(df.instructions), 2)

    def test_continuation(self):
        df = parse("RUN apt-get install \\\n    -y \\\n    curl")
        self.assertEqual(len(df.instructions), 1)
        self.assertIn("apt-get install", df.instructions[0].value)
        self.assertIn("curl", df.instructions[0].value)

    def test_multi_stage(self):
        df = parse("FROM golang:1.21 AS builder\nFROM alpine\nCOPY --from=builder /app /app")
        self.assertEqual(len(df.stages), 2)
        self.assertEqual(df.stages[0], "golang:1.21")
        self.assertEqual(df.stages[1], "alpine")

    def test_line_numbers(self):
        df = parse("FROM ubuntu\n\nRUN echo hi")
        self.assertEqual(df.instructions[0].line_number, 1)
        self.assertEqual(df.instructions[1].line_number, 3)

    def test_env_arg(self):
        df = parse("ARG VERSION=1.0\nENV PATH=/usr/local/bin:$PATH")
        self.assertEqual(df.instructions[0].cmd, "ARG")
        self.assertEqual(df.instructions[1].cmd, "ENV")

    def test_complex_dockerfile(self):
        src = """FROM node:20-alpine
WORKDIR /app

# Install deps
COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
"""
        df = parse(src)
        self.assertEqual(len(df.instructions), 7)
        cmds = [i.cmd for i in df.instructions]
        self.assertEqual(cmds[0], "FROM")
        self.assertEqual(cmds[-1], "CMD")

    def test_lowercase_cmd(self):
        # Docker accepts both, but we uppercase
        df = parse("from ubuntu\nrun echo hi")
        self.assertEqual(df.instructions[0].cmd, "FROM")
        self.assertEqual(df.instructions[1].cmd, "RUN")


if __name__ == "__main__":
    unittest.main()