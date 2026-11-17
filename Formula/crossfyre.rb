class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.44/crossfyre-v0.1.44-darwin-aarch64.tar.gz"
    sha256 "48818131120f91d9b426c1ea2ecd60290260659ef71e3c7bf4ba8248ee220b88"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.44/crossfyre-v0.1.44-darwin-x86_64.tar.gz"
    sha256 "009b95da8bf899f82a616ac3e0d480704b6e678d0387012897f30c04e34b57f7"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.44/crossfyre-v0.1.44-linux-aarch64.tar.gz"
    sha256 "4d1dcc34b2868297663786970999dc05304a4e940aeec2b8ac94f49e55cbda95"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.44/crossfyre-v0.1.44-linux-x86_64.tar.gz"
    sha256 "03f1bd83e3f4a8300004f2750be1921158b6eb1ce309c8ac897fd45da784ca08"
  end
  version "0.1.44"
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
