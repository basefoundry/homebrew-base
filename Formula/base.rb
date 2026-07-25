class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/basefoundry/base"
  url "https://github.com/basefoundry/base/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "cf37d7f907ce0883f609d03a423628c9838f89fa5b4b98f2992ff77ac3a70c1a"
  license "AGPL-3.0-or-later"
  head "https://github.com/basefoundry/base.git", branch: "main"

  bottle do
    root_url "https://github.com/basefoundry/homebrew-base/releases/download/base-v1.7.0"
    rebuild 4
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cbf60da29165904bafe1299032603b79672556ddfd0c4a2812d43f07d3c456fb"
    sha256 cellar: :any_skip_relocation, sequoia:       "bcd82650e5c29792e816e252d6084a3c5869caefbcfc62666bb217ab0547f25d"
  end

  depends_on "base-bash-libs"
  depends_on "bash"
  depends_on "python@3.13"

  def install
    stable_base_home = opt_libexec

    inreplace "bin/basectl",
              /^basectl_base_home\(\) \{.*?^\}/m,
              <<~EOS
                basectl_base_home() {
                    printf '%s\\n' "#{stable_base_home}"
                }
              EOS

    inreplace "bin/base-wrapper",
              /^base_wrapper_base_home\(\) \{.*?^\}/m,
              <<~EOS
                base_wrapper_base_home() {
                    printf '%s\\n' "#{stable_base_home}"
                }
              EOS

    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/basectl"
    bin.install_symlink libexec/"bin/base-wrapper"
    bash_completion.install_symlink libexec/"lib/shell/completions/basectl_completion.sh" => "basectl"
    zsh_completion.install_symlink libexec/"lib/shell/completions/basectl_completion.zsh" => "_basectl"
  end

  def caveats
    <<~EOS
      Finish Base setup with:
        basectl setup
        basectl update-profile
        exec "$SHELL" -l

      When installed through Homebrew, update Base with:
        brew upgrade --no-ask basefoundry/base/base
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/basectl --version")
    assert_path_exists libexec/"lib/shell/completions/basectl_completion.sh"
    assert_path_exists libexec/"lib/shell/completions/basectl_completion.zsh"
    assert_path_exists bash_completion/"basectl"
    assert_path_exists zsh_completion/"_basectl"

    bash = formula_opt_bin("bash")/"bash"
    bash_libs_dir = formula_opt_libexec("base-bash-libs")/"lib/bash"
    assert_path_exists bash_libs_dir/"std/lib_std.sh"

    (testpath/"bash-libs-dir.sh").write <<~EOS
      BASE_HOME="#{libexec}"
      source "#{libexec}/base_init.sh"
      printf '%s\\n' "$BASE_BASH_LIBS_DIR"
    EOS

    assert_equal "#{bash_libs_dir}\n",
                 shell_output("env -u BASE_HOME -u BASE_BASH_LIBS_DIR #{bash} #{testpath}/bash-libs-dir.sh")
  end
end
