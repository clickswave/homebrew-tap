class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.36/crossfyre-v0.1.36-darwin-aarch64.tar.gz"
    sha256 "70d75aead4f7c0f9e67b808b115ef9833e6a333fac5eba3ca3c234dcfeafd208"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.36/crossfyre-v0.1.36-darwin-x86_64.tar.gz"
    sha256 "411f668e33d4daf0ebcd2d1b3baf95b699f8dc258250bde40afdd232bc1d19a0"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.36/crossfyre-v0.1.36-linux-aarch64.tar.gz"
    sha256 "41203852ff1f8d5d63c04e3224415c03c13663a50cd79f97ec7d3947cb8ffc2d"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.36/crossfyre-v0.1.36-linux-x86_64.tar.gz"
    sha256 "ab7768d0e1b1e9c37eaa57c6e810ec990de94dd18ac04e78f1587d5362ef7f8f"
  end
  version "0.1.36"
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
