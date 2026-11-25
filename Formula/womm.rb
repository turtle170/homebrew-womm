class Womm < Formula
  desc "Enterprise-grade declarative executable synthesis (works on my machine)"
  homepage "https://github.com/turtle170/WorksOnMyMachine"
  url "https://github.com/turtle170/WorksOnMyMachine/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "a353f10837da7bd13c53374a85b9ccf6cc8e873d966d1fa57a04c86c4085f5af"
  license "MIT"
  head "https://github.com/turtle170/WorksOnMyMachine.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "--release", "--locked"
    # womm looks for its package store next to itself, so they live together in libexec.
    libexec.install "target/release/womm"
    system libexec/"womm", "pack-store", buildpath/"packages", buildpath/"packages.tar"
    libexec.install "packages.tar"
    bin.install_symlink libexec/"womm"
  end

  def caveats
    <<~EOS
      womm was compiled from source on this machine, so it works on your machine.
      This is the first time that has been true. Please do not tell anyone.

      The package store is at:
        #{opt_libexec}/packages.tar
      There is no command that lists its packages. That is on purpose.

      After `brew upgrade womm`, ship your packages again.
    EOS
  end

  test do
    ENV["WOMM_HOME"] = testpath/"home"
    ENV["WOMM_FAST"] = "1"
    assert_match "NoNet v0", shell_output("#{bin}/womm --version")
    (testpath/"plan.womm").write "Ship it\nThen ship it again\n"
    system bin/"womm", "parse", "plan.womm"
    system bin/"womm", "build", "plan.kludged"
    system bin/"womm", "parsy-builder", "plan.womm.md"
    assert_match(/program complete/i, shell_output("./plan"))
  end
end
