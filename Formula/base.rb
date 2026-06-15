class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "a242333a096ef2f7f4b9608be8a309b8e3ed66c849d570d9fab3fd95d3377315"
  license "AGPL-3.0-or-later"
  head "https://github.com/codeforester/base.git", branch: "master"

  bottle do
    root_url "https://github.com/codeforester/homebrew-base/releases/download/base-v1.0.1"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7fa7246fefab3a00c1110462420454ecd99a65d8820cd66ada139e49f2d2a979"
    sha256 cellar: :any_skip_relocation, sequoia:       "fb760e4ef8ebfe02cf344a8519afee4106fe04fe68a19d23494b9d4dcc122ea5"
  end

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
    bash_completion.install libexec/"lib/shell/completions/basectl_completion.sh" => "basectl"
    zsh_completion.install libexec/"lib/shell/completions/basectl_completion.zsh" => "_basectl"
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
    assert_path_exists bash_completion/"basectl"
    assert_path_exists zsh_completion/"_basectl"
  end
end
