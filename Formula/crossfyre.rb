class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.40/crossfyre-v0.1.40-darwin-aarch64.tar.gz"
    sha256 "806b8b2849f47c2a6797591a507f0ceb668553b7260ab02c84ad1a5c705a7b04"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.40/crossfyre-v0.1.40-darwin-x86_64.tar.gz"
    sha256 "c968b3eebc9c751b9dd3c3e8fb0f18628dc6f44f15e6c66c98038cde85885bc5"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.40/crossfyre-v0.1.40-linux-aarch64.tar.gz"
    sha256 "ebb8435612876895d3c97a69b93275de69008558ff485718aa902b95e5526326"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.40/crossfyre-v0.1.40-linux-x86_64.tar.gz"
    sha256 "201467ddea1aa8e27a090337af1fc26a77bcce7d994b43982b6639bbeaaf520f"
  end
  version "0.1.40"
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
