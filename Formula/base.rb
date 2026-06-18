class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "f83f967f114330fd029fbcef51b79c8bdd568dab7db518bcdf4a74eb203cca92"
  license "AGPL-3.0-or-later"
  head "https://github.com/codeforester/base.git", branch: "master"

  bottle do
    root_url "https://github.com/codeforester/homebrew-base/releases/download/base-v1.0.5"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d1447694e52a684982fb9b5582f86feb6a46429e23a110640102eab6ba3deddd"
    sha256 cellar: :any_skip_relocation, sequoia:       "50aae7c34c532cd7d4dafd34f3c3b342a7fd05c774bbf3cc91be871d70a2dcc7"
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
        brew upgrade --no-ask codeforester/base/base
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
