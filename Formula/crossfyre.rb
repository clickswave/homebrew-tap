class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.43/crossfyre-v0.1.43-darwin-aarch64.tar.gz"
    sha256 "7aab02e82ac594d060f5fe225d4a5b524ef9ae85714d8b0b0619ff292b06fc6e"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.43/crossfyre-v0.1.43-darwin-x86_64.tar.gz"
    sha256 "88ab39ecd269c942eb2db496887c8926f1a576f4cf80f46b4fa548e18359f500"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.43/crossfyre-v0.1.43-linux-aarch64.tar.gz"
    sha256 "bd79a9d02b8a1bba4c62dd0c5be6d6c0de026845e629f25c6c782770dc5c47e5"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.43/crossfyre-v0.1.43-linux-x86_64.tar.gz"
    sha256 "97f2fcc32c53036966f92380fb7ddcb2b8f0bc733706df630a59f12e7e29efe7"
  end
  version "0.1.43"
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
