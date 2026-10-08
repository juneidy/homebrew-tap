# Personal copy of the homebrew/cask "alacritty" cask, which Homebrew disabled
# on 2026-09-01 because the upstream app is ad-hoc signed and not notarized
# (fails_gatekeeper_check). Differences from the official cask: no `disable!`,
# a `postflight_steps` block that removes the quarantine attribute, and caveats.
cask "alacritty" do
  version "0.17.0"
  sha256 "ad8d7de35fb38e43184776cac6dfee05ca325caa0b6639a06a55e54e4b026620"

  url "https://github.com/alacritty/alacritty/releases/download/v#{version}/Alacritty-v#{version}.dmg"
  name "Alacritty"
  desc "GPU-accelerated terminal emulator"
  homepage "https://github.com/alacritty/alacritty/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Alacritty.app"
  binary "#{appdir}/Alacritty.app/Contents/MacOS/alacritty"
  binary "#{appdir}/Alacritty.app/Contents/Resources/61/alacritty",
         target: "#{ENV.fetch("TERMINFO", "~/.terminfo")}/61/alacritty"
  binary "#{appdir}/Alacritty.app/Contents/Resources/61/alacritty-direct",
         target: "#{ENV.fetch("TERMINFO", "~/.terminfo")}/61/alacritty-direct"
  manpage "#{appdir}/Alacritty.app/Contents/Resources/alacritty.1.gz"
  manpage "#{appdir}/Alacritty.app/Contents/Resources/alacritty.5.gz"
  manpage "#{appdir}/Alacritty.app/Contents/Resources/alacritty-msg.1.gz"
  manpage "#{appdir}/Alacritty.app/Contents/Resources/alacritty-bindings.5.gz"
  bash_completion "#{appdir}/Alacritty.app/Contents/Resources/completions/alacritty.bash"
  zsh_completion "#{appdir}/Alacritty.app/Contents/Resources/completions/_alacritty"
  fish_completion "#{appdir}/Alacritty.app/Contents/Resources/completions/alacritty.fish"

  # Homebrew quarantines every cask download, and Gatekeeper refuses to open a
  # quarantined app that is ad-hoc signed and not notarized. Remove the
  # attribute from the whole bundle after every install, reinstall and upgrade.
  # `must_succeed: false` keeps a working install if xattr fails (for example,
  # if the sandbox refuses it). xattr's error is still printed, and the caveats
  # give the manual fix.
  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/Alacritty.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/org.alacritty.plist",
    "~/Library/Saved Application State/org.alacritty.savedState",
  ]

  caveats <<~EOS
    Alacritty is ad-hoc signed and not notarized by Apple, so it fails the
    macOS Gatekeeper check. This cask removes the com.apple.quarantine
    attribute from Alacritty.app after every install and upgrade.

    If macOS still blocks Alacritty, check the attribute:
      xattr -p com.apple.quarantine "#{appdir}/Alacritty.app"
    "No such xattr" means it is gone; any other output means it is still set.
    Remove it with:
      xattr -dr com.apple.quarantine "#{appdir}/Alacritty.app"
    System Settings > Privacy & Security may offer Open Anyway after a blocked
    launch, but for an ad-hoc signed app macOS may only offer Move to Trash.
  EOS
end
