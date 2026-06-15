from __future__ import annotations

import re
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


class BottleWorkflowTests(unittest.TestCase):
    def test_bottle_workflow_builds_uploads_and_merges_bottles(self) -> None:
        workflow = REPO_ROOT / ".github" / "workflows" / "build-bottles.yml"
        content = workflow.read_text(encoding="utf-8")

        self.assertIn("workflow_dispatch:", content)
        self.assertIn("macos-15-intel", content)
        self.assertIn("macos-15", content)
        self.assertIn("brew install --build-bottle codeforester/base/base", content)
        self.assertIn("brew --prefix codeforester/base/base", content)
        self.assertIn('"$basectl_path" --version', content)
        self.assertIn("brew bottle --json --root-url", content)
        self.assertIn("for path in *.bottle*.tar.gz *.bottle*.json; do", content)
        self.assertNotIn("for path in *.bottle.* *.json; do", content)
        self.assertIn("remote_filename = tag.fetch(\"filename\")", content)
        self.assertIn("local_filename = tag.fetch(\"local_filename\")", content)
        self.assertIn("FileUtils.mv(local_filename, remote_filename)", content)
        self.assertIn("gh release upload", content)
        self.assertIn("brew bottle --merge --write --no-commit", content)
        self.assertIn("brew --repo codeforester/base", content)
        self.assertIn('"$tap_path/Formula/base.rb" Formula/base.rb', content)
        self.assertIn("github.ref_name == 'master'", content)
        self.assertIn("url_version=", content)
        self.assertIn("Unable to read Formula/base.rb version from version line or URL", content)

    def test_readme_documents_bottle_release_flow(self) -> None:
        readme = (REPO_ROOT / "README.md").read_text(encoding="utf-8")

        self.assertIn("Build Bottles", readme)
        self.assertIn("base-vX.Y.Z", readme)
        self.assertIn("brew install --force-bottle codeforester/base/base", readme)

    def test_generated_bottle_artifacts_are_ignored(self) -> None:
        ignore = (REPO_ROOT / ".gitignore").read_text(encoding="utf-8")

        self.assertIn("*.bottle*.tar.gz", ignore)
        self.assertIn("*.bottle.json", ignore)
        self.assertIn("bottle-output/", ignore)

    def test_formula_omits_redundant_explicit_version(self) -> None:
        formula = (REPO_ROOT / "Formula" / "base.rb").read_text(encoding="utf-8")

        self.assertIn('url "https://github.com/codeforester/base/archive/refs/tags/v', formula)
        self.assertNotRegex(formula, re.compile(r"^[ \t]*version ", re.MULTILINE))

    def test_formula_installs_shell_completions(self) -> None:
        formula = (REPO_ROOT / "Formula" / "base.rb").read_text(encoding="utf-8")

        self.assertIn(
            'bash_completion.install libexec/"lib/shell/completions/basectl_completion.sh" => "basectl"',
            formula,
        )
        self.assertIn(
            'zsh_completion.install libexec/"lib/shell/completions/basectl_completion.zsh" => "_basectl"',
            formula,
        )


if __name__ == "__main__":
    unittest.main()
