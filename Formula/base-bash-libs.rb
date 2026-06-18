class BaseBashLibs < Formula
  desc "Reusable Bash libraries extracted from Base"
  homepage "https://github.com/codeforester/base-bash-libs"
  url "https://github.com/codeforester/base-bash-libs/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "2a6407ec539310d3bc15db1b42a51e0a202ae4bdfe5dad36b95505867f75bf6a"
  license "AGPL-3.0-or-later"
  head "https://github.com/codeforester/base-bash-libs.git", branch: "master"

  bottle do
    root_url "https://github.com/codeforester/homebrew-base/releases/download/base-v1.0.5"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "30d0442edb928e35ecfce3fa20eeb86d4930041294a88cd43817d2a15b31c6b2"
    sha256 cellar: :any_skip_relocation, sequoia:       "8cf9a74a3b58cbabdbb12fba593fd31ca8aa4962dfe599e4a3b314b700f237b9"
  end

  depends_on "bash"

  def install
    libexec.install "lib"
    pkgshare.install "README.md", "CHANGELOG.md"
    pkgshare.install "examples"
  end

  def caveats
    <<~EOS
      Source the Bash stdlib with:
        source "#{opt_libexec}/lib/bash/std/lib_std.sh"

      Companion libraries live under:
        #{opt_libexec}/lib/bash
    EOS
  end

  test do
    assert_path_exists libexec/"lib/bash/std/lib_std.sh"
    assert_path_exists libexec/"lib/bash/file/lib_file.sh"
    assert_path_exists libexec/"lib/bash/git/lib_git.sh"

    (testpath/"smoke.sh").write <<~EOS
      source "#{libexec}/lib/bash/std/lib_std.sh"
      import "#{libexec}/lib/bash/file/lib_file.sh"
      import "#{libexec}/lib/bash/git/lib_git.sh"
      printf '%s\\n' "$(type -t run)" "$(type -t update_file_section)" "$(type -t git_get_current_branch)"
    EOS

    bash = Formula["bash"].opt_bin/"bash"
    assert_equal "function\nfunction\nfunction\n", shell_output("#{bash} #{testpath}/smoke.sh")
  end
end
