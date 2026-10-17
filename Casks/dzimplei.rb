cask "dzimplei" do
  version "0.7.86"
  sha256 "49989080ceb221ac3e7afa5aef94c6593b37c2a2c0001bb17594149c437f9602"

  url "https://github.com/t-shark-9/dzimplei/releases/download/v#{version}/dzimplei-mac-arm64.dmg"
  name "dzimplei"
  desc "Workspaces, agents and Claude Code sessions in one app"
  homepage "https://dzimplei.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app updates itself (electron-updater), so brew does not fight it.
  auto_updates true
  depends_on arch: :arm64

  app "dzimplei.app"

  # The app is signed with dzimplei's own certificate, not an Apple Developer
  # ID, so macOS would refuse the first launch of a quarantined copy. You chose
  # to install it with brew; this clears the quarantine flag on that copy only.
  # (Legacy postflight block: this tap is third-party, where Homebrew still
  # accepts it; the declarative postflight_steps has no way to run xattr.)
  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/dzimplei.app"],
                   must_succeed: false
  end

  # Caches and preferences only. Your workspaces and chats live in
  # ~/Library/Application Support/dzimplei and are never removed by brew.
  zap trash: [
    "~/Library/Caches/dzimplei-updater",
    "~/Library/Logs/dzimplei",
    "~/Library/Preferences/com.dzimplei.app.plist",
    "~/Library/Saved Application State/com.dzimplei.app.savedState",
  ]
end
