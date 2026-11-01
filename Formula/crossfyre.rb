class Crossfyre < Formula
  desc "Security testing platform client with a local capture proxy"
  homepage "https://crossfyre.io/toolchain"
  # One tarball per system and arch. on_intel and on_arm blocks cannot hold a url, so
  # this is the conditional Homebrew leaves to taps.
  if OS.mac? && Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.39/crossfyre-v0.1.39-darwin-aarch64.tar.gz"
    sha256 "e7c5586b259215e6a223fff56e1ef6867cf259bf7d5be37818611ed905d94aa3"
  elsif OS.mac?
    url "https://bins.crossfyre.io/crossfyre/v0.1.39/crossfyre-v0.1.39-darwin-x86_64.tar.gz"
    sha256 "a8d2e7684360fcf1698f75b888fa8f85c7f6b82843777b13a6c5490b7c309500"
  elsif Hardware::CPU.arm?
    url "https://bins.crossfyre.io/crossfyre/v0.1.39/crossfyre-v0.1.39-linux-aarch64.tar.gz"
    sha256 "78c9676d2ff7509d07e55add4ef947a814b277e206f0a9e3493a924a4fb9bf86"
  else
    url "https://bins.crossfyre.io/crossfyre/v0.1.39/crossfyre-v0.1.39-linux-x86_64.tar.gz"
    sha256 "093121ea137c3b3800d7644d7cf45d99e916a158b24376f6acd74c1dcc7bc8d8"
  end
  version "0.1.39"
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
