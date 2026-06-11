class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "66ac09a7d75b45850373d107a8fccc205bd6f2972c1eb861a437cf210996590d"
  version "0.4.2"
  license "MIT"
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
  end
end
