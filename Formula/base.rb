class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "07ec9edcf095fe17f6902fece88af00c398acb7fdd925497d477bdf6a41ed11e"
  version "1.0.0"
  license "MIT"
  head "https://github.com/codeforester/base.git", branch: "master"

  bottle do
    root_url "https://github.com/codeforester/homebrew-base/releases/download/base-v1.0.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dbdfc2f7d5c27329c39ea7791c8193760ffb248f92d65a1d17b3374c4d5d2b4b"
    sha256 cellar: :any_skip_relocation, sequoia:       "94961a237330e28f2b455fa7121733bd71bf967091f16b3513a85c833d34c818"
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
