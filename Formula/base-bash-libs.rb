class BaseBashLibs < Formula
  desc "Reusable Bash libraries extracted from Base"
  homepage "https://github.com/basefoundry/base-bash-libs"
  url "https://github.com/basefoundry/base-bash-libs/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "161ea8ae71d605df86c55aeb444340aa6e09dba74b69acf541a8720a72748f38"
  license "Apache-2.0"
  head "https://github.com/basefoundry/base-bash-libs.git", branch: "main"

  depends_on "bash"

  def install
    bin.install "bin/base-bash"
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

      Run standalone scripts with the stdlib preloaded:
        #!/usr/bin/env base-bash
    EOS
  end

  test do
    assert_path_exists libexec/"lib/bash/std/lib_std.sh"
    assert_path_exists libexec/"lib/bash/file/lib_file.sh"
    assert_path_exists libexec/"lib/bash/git/lib_git.sh"
    assert_path_exists bin/"base-bash"
    assert_path_exists pkgshare/"LICENSE"
    assert_path_exists pkgshare/"NOTICE"

    (testpath/"smoke.sh").write <<~EOS
      source "#{libexec}/lib/bash/std/lib_std.sh"
      import "#{libexec}/lib/bash/file/lib_file.sh"
      import "#{libexec}/lib/bash/git/lib_git.sh"
      printf '%s\\n' "$BASE_BASH_LIBS_VERSION" "$(type -t std_run)" "$(type -t run)" "$(type -t update_file_section)" "$(type -t git_get_current_branch)"
    EOS

    bash = Formula["bash"].opt_bin/"bash"
    assert_equal "2.0.0\nfunction\nfunction\nfunction\nfunction\n", shell_output("#{bash} #{testpath}/smoke.sh")

    (testpath/"launcher.sh").write <<~EOS
      #!/usr/bin/env base-bash

      import_base_bash_lib str/lib_str.sh

      main() {
        local value="  launcher  "
        str_trim value
        printf '%s\\n' "$BASE_BASH_LIBS_VERSION" "$BASE_BASH_LIBS_STDLIB_LOADED" "$value" "$#"
      }
    EOS
    chmod 0755, testpath/"launcher.sh"

    assert_equal "2.0.0\n1\nlauncher\n1\n", shell_output("PATH=#{bin}:$PATH #{testpath}/launcher.sh arg")
  end
end
