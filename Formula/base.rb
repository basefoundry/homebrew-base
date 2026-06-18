class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "986b488c27afcefc0adc9b70a15bd141fcdd38df3489849242b04cb6be2e8954"
  license "AGPL-3.0-or-later"
  head "https://github.com/codeforester/base.git", branch: "master"

  depends_on "bash"
  depends_on "base-bash-libs"
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
        brew upgrade codeforester/base/base
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/basectl --version")
    assert_path_exists libexec/"lib/shell/completions/basectl_completion.sh"
    assert_path_exists libexec/"lib/shell/completions/basectl_completion.zsh"
    assert_path_exists bash_completion/"basectl"
    assert_path_exists zsh_completion/"_basectl"

    bash = Formula["bash"].opt_bin/"bash"
    bash_libs_dir = Formula["base-bash-libs"].opt_libexec/"lib/bash"
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
