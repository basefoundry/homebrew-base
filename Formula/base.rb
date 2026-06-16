class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "296fa4c0fca25a2cc453ac1d4c2fbd8cca6bf201af70ef29ce11e7b81b5d55f1"
  license "AGPL-3.0-or-later"
  head "https://github.com/codeforester/base.git", branch: "master"

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
        brew upgrade codeforester/base/base
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/basectl --version")
    assert_path_exists libexec/"lib/shell/completions/basectl_completion.sh"
    assert_path_exists libexec/"lib/shell/completions/basectl_completion.zsh"
    assert_path_exists bash_completion/"basectl"
    assert_path_exists zsh_completion/"_basectl"
  end
end
