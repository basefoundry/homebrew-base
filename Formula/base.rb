class Base < Formula
  desc "Workspace bootstrap and project environment orchestration tool"
  homepage "https://github.com/codeforester/base"
  url "https://github.com/codeforester/base/archive/refs/tags/v0.4.4.tar.gz"
  sha256 "2aca5e6f38d412269808edf1114cb7c25e3662b4fa276e7878a1b562ecd407d9"
  version "0.4.4"
  license "MIT"
  head "https://github.com/codeforester/base.git", branch: "master"

  bottle do
    root_url "https://github.com/codeforester/homebrew-base/releases/download/base-v0.4.4"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7e484453f9c757d099609322ee75c984a321c43209107c7e5381a8507f32a16f"
    sha256 cellar: :any_skip_relocation, sequoia:       "5d0552a8326026ca54d1f7dfd918ae422ae63e16a7f816dbbeeef8b1c738f456"
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
