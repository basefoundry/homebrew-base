class BaseBashLibs < Formula
  desc "Reusable Bash libraries extracted from Base"
  homepage "https://github.com/basefoundry/base-bash-libs"
  url "https://github.com/basefoundry/base-bash-libs/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "1a3e1ac86868cdda305e5eb314a434de2e1d904de6a733829a688f1c4bd82171"
  license "Apache-2.0"
  head "https://github.com/basefoundry/base-bash-libs.git", branch: "main"

  bottle do
    root_url "https://github.com/basefoundry/homebrew-base/releases/download/base-v1.1.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9e70232286b7f447d455333425d53ed8d657c9b9d783b4b829f959a6ae20ec34"
    sha256 cellar: :any_skip_relocation, sequoia:       "6db726da89a61f28c7cdc060baef94717008c84b76ad20ecdbe46e494bddf83c"
  end

  depends_on "bash"

  def install
    libexec.install "lib"
    libexec.install "VERSION"
    pkgshare.install "README.md", "CHANGELOG.md", "LICENSE", "NOTICE"
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
    assert_path_exists pkgshare/"LICENSE"
    assert_path_exists pkgshare/"NOTICE"

    (testpath/"smoke.sh").write <<~EOS
      source "#{libexec}/lib/bash/std/lib_std.sh"
      import "#{libexec}/lib/bash/file/lib_file.sh"
      import "#{libexec}/lib/bash/git/lib_git.sh"
      printf '%s\\n' "$BASE_BASH_LIBS_VERSION" "$(type -t std_run)" "$(type -t run)" "$(type -t update_file_section)" "$(type -t git_get_current_branch)"
    EOS

    bash = Formula["bash"].opt_bin/"bash"
    assert_equal "1.0.0\nfunction\nfunction\nfunction\nfunction\n", shell_output("#{bash} #{testpath}/smoke.sh")
  end
end
