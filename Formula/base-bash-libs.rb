class BaseBashLibs < Formula
  desc "Reusable Bash libraries extracted from Base"
  homepage "https://github.com/basefoundry/base-bash-libs"
  url "https://github.com/basefoundry/base-bash-libs/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "3c9e3ac0870d4d9728ce9d9c676cdfc64892c3bce2610623c5f664cd7ea01317"
  license "Apache-2.0"
  version_scheme 1
  head "https://github.com/basefoundry/base-bash-libs.git", branch: "main"

  bottle do
    root_url "https://github.com/basefoundry/homebrew-base/releases/download/base-v1.7.0"
    rebuild 3
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "329b799c18287fee76cfa4d96d76db1ee55eff18a15f84c127183acd749cd504"
    sha256 cellar: :any_skip_relocation, sequoia:       "279fd156dac7787774d5ba783848a880554283b9b01629fd27295af8eb7277d9"
  end

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
    assert_path_exists libexec/"lib/bash/gh/lib_gh.sh"
    assert_path_exists bin/"base-bash"
    assert_path_exists pkgshare/"LICENSE"
    assert_path_exists pkgshare/"NOTICE"

    (testpath/"smoke.sh").write <<~EOS
      source "#{libexec}/lib/bash/std/lib_std.sh"
      import "#{libexec}/lib/bash/file/lib_file.sh"
      import "#{libexec}/lib/bash/git/lib_git.sh"
      import "#{libexec}/lib/bash/gh/lib_gh.sh"
      printf '%s\\n' "$BASE_BASH_LIBS_VERSION" "$(type -t std_run)" "$(type -t update_file_section)" "$(type -t git_get_current_branch)" "$(type -t gh_run)"
    EOS

    bash = formula_opt_bin("bash")/"bash"
    assert_equal "1.4.0\nfunction\nfunction\nfunction\nfunction\n", shell_output("#{bash} #{testpath}/smoke.sh")

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

    assert_equal "1.4.0\n1\nlauncher\n1\n", shell_output("PATH=#{bin}:$PATH #{testpath}/launcher.sh arg")
  end
end
