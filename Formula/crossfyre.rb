class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.42/crossfyre-v0.1.42-darwin-aarch64.tar.gz"
    sha256 "0babaa98a971aa071eb4cdc1517719909ec87570000fc0e4ad5cdc180bb37525"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.42/crossfyre-v0.1.42-darwin-x86_64.tar.gz"
    sha256 "1728faf1267b2f05ed36c6e01ba3cbc64b30446097a96e3043a52b557e206c73"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.42/crossfyre-v0.1.42-linux-aarch64.tar.gz"
    sha256 "11f8cd1d03a5f47041f30259f4775e4cc0dd2400a28ff51cf4585a7a1d7125a1"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.42/crossfyre-v0.1.42-linux-x86_64.tar.gz"
    sha256 "b12197cb2cfbcfd00ddadc0db17e86e988edacbd95a870ac28086c0497afca52"
  end
  version "0.1.42"
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
