class Pilgrims < Formula
  desc "PILGRIMS v17.0 — Ultimate Security Framework"
  homepage "https://github.com/afiqandico13/pilgrims-v17"
  url "https://github.com/afiqandico13/pilgrims-v17/archive/refs/tags/v17.0.0.tar.gz"
  sha256 "REPLACE_WITH_REAL_SHA256_AT_RELEASE"
  license "MIT"
  version "17.0.0"

  depends_on "bash"
  depends_on "coreutils"
  depends_on "nmap"
  depends_on "jq"
  depends_on "openssl"
  depends_on "python@3.11"

  def install
    # Install all files to libexec, symlink main script
    libexec.install Dir["*"]
    bin.install_symlink libexec/"pilgrims.sh" => "pilgrims"

    # Bash completion (optional)
    # bash_completion.install "completions/pilgrims.bash" => "pilgrims"
  end

  test do
    assert_match "PILGRIMS v17.0", shell_output("#{bin}/pilgrims --help", 0)
    assert_match "web", shell_output("#{bin}/pilgrims --modules", 0)
  end
end
