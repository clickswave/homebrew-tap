class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.38/crossfyre-v0.1.38-darwin-aarch64.tar.gz"
    sha256 "6e69a7f902057cfecc637ced8a4a34210aaa8fadda8a59bc483d87d503b784ad"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.38/crossfyre-v0.1.38-darwin-x86_64.tar.gz"
    sha256 "00e6428be61ec6dc1c115dcfc98aabc9b0c3e66bc1f920e0c86566c3205a4266"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.38/crossfyre-v0.1.38-linux-aarch64.tar.gz"
    sha256 "548ed279d4c649e85717e1aa498b915052bd1c3911c3eb56d29740ab80984dfc"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.38/crossfyre-v0.1.38-linux-x86_64.tar.gz"
    sha256 "e4db34bba3c45164835ba2c7698926937d959545b0f6d3531db0582c7bb959cb"
  end
  version "0.1.38"
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
