class GitStageLines < Formula
  desc "Stage selected line ranges from Git diffs"
  homepage "https://github.com/aleclarson/git-stage-lines"
  url "https://github.com/aleclarson/git-stage-lines/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "39e145201634ff43ef0fe59598d1568a67103c06c2c1c193d6fb536f5ff2dd8c"
  license "MIT"

  depends_on "zig" => :build
  depends_on "git"

  def install
    ENV["ZIG_LOCAL_CACHE_DIR"] = buildpath/".zig-cache"
    ENV["ZIG_GLOBAL_CACHE_DIR"] = buildpath/".cache/zig"

    system "zig", "build", "-Doptimize=ReleaseSafe"
    bin.install "zig-out/bin/git-stage-lines"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/git-stage-lines --version")

    system "git", "init"
    system "git", "config", "user.email", "brew-test@example.com"
    system "git", "config", "user.name", "Homebrew Test"

    (testpath/"sample.txt").write <<~EOS
      one
      two
      three
      four
    EOS
    system "git", "add", "sample.txt"
    system "git", "commit", "-m", "baseline"

    File.write testpath/"sample.txt", <<~EOS
      one
      TWO
      three
      FOUR
    EOS
    system "git", "stage-lines", "sample.txt", "2"

    staged = shell_output("git diff --cached -- sample.txt")
    assert_match "+TWO", staged
    refute_match "+FOUR", staged

    unstaged = shell_output("git diff -- sample.txt")
    assert_match "+FOUR", unstaged
    refute_match "+TWO", unstaged
  end
end
