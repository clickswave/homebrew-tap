class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.41/crossfyre-v0.1.41-darwin-aarch64.tar.gz"
    sha256 "8f842418ef15ef3d3446a3c318441407e30b2ac54b40efc2dcef96d81ed9e6a0"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.41/crossfyre-v0.1.41-darwin-x86_64.tar.gz"
    sha256 "99183dcafd1d91d17bd9af562c481cc31f4b6f356e5d25269b3aad4f6e0462e5"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.41/crossfyre-v0.1.41-linux-aarch64.tar.gz"
    sha256 "6167b45a7b704f48c23733ab331e467e32b020fe67d275f83290043fd1012ef9"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.41/crossfyre-v0.1.41-linux-x86_64.tar.gz"
    sha256 "090d6366ae509f14a7dca0bfd29d7a6c6de817d6b7fffe370cbec6317760b73b"
  end
  version "0.1.41"
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
