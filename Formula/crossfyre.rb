class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.37/crossfyre-v0.1.37-darwin-aarch64.tar.gz"
    sha256 "bbeb3f67efd9ba7a6ce461d4380582a93297911abe67b4a980eb7b3aae882481"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.37/crossfyre-v0.1.37-darwin-x86_64.tar.gz"
    sha256 "13db8b1e12022136ff82b841718d7ba9007c3958237a7fdf626776ed549a222d"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.37/crossfyre-v0.1.37-linux-aarch64.tar.gz"
    sha256 "cbd08d896937ef43d22f86b2be3514eea92c3025e7d7421ca9d4930ba0d4e894"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.37/crossfyre-v0.1.37-linux-x86_64.tar.gz"
    sha256 "1552e938184b7e63ba6c24674361367e25aa645e3cc13fee0fb7eca7fbaa6d69"
  end
  version "0.1.37"
  # Apache-2.0 for the open source parts, and BINARY-LICENCE.txt, which SPDX has no
  # identifier for, for the binary as a whole.
  license all_of: ["Apache-2.0", :cannot_represent]

  livecheck do
    url "https://bins.crossfyre.io/crossfyre/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  # The CLI unpacks the engines it fetches with unzip, which macOS has of its own.
  on_linux do
    depends_on "unzip"
  end

  def install
    libexec.install "crossfyre"
    bin.install_symlink libexec/"crossfyre"

    # Tells crossfyre that Homebrew owns the CLI, so `crossfyre update` leaves it
    # to `brew upgrade`. cli_path is the name that survives an upgrade, unlike the
    # versioned path in the Cellar. crossfyre ignores the file if its directory is
    # writable by group or others, as a umask of 002 would leave it.
    (lib/"crossfyre/packaging.json").write <<~JSON
      {"manager": "brew", "owns": ["crossfyre"], "cli_path": "#{opt_bin}/crossfyre"}
    JSON
    chmod 0755, lib/"crossfyre"

    prefix.install "LICENSE", "BINARY-LICENCE.txt", "THIRD-PARTY-NOTICES"
  end

  def caveats
    <<~EOS
      crossfyre from Homebrew runs as your own user. To run this machine as a
      Crossfyre node, install crossfyre with the installer or apt instead:
        https://crossfyre.io/docs/install
    EOS
  end

  test do
    assert_equal "crossfyre #{version}", shell_output("#{bin}/crossfyre --version").strip
  end
end
