class BaseBashLibs < Formula
  desc "Reusable Bash libraries extracted from Base"
  homepage "https://github.com/basefoundry/base-bash-libs"
  url "https://github.com/basefoundry/base-bash-libs/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "663ca852474948c4c6d27f1bc00786d03ab56a4a136acefa5f80f77382eba1ee"
  license "Apache-2.0"
  head "https://github.com/basefoundry/base-bash-libs.git", branch: "master"

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
    assert_equal "0.2.1\nfunction\nfunction\nfunction\nfunction\n", shell_output("#{bash} #{testpath}/smoke.sh")
  end
end
