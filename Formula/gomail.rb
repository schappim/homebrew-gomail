class Gomail < Formula
  desc "Command-line Gmail client: search, read, download, draft and send mail"
  homepage "https://github.com/schappim/gomail"
  url "https://github.com/schappim/gomail/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0cff8a0689620d6a2f0fba940851e23cc1ac55b836b6d24c7004ae5bd6a45f55"
  license "MIT"
  head "https://github.com/schappim/gomail.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/gomail"
    generate_completions_from_executable(bin/"gomail", "completion")
    pkgshare.install "skills"
  end

  def caveats
    <<~EOS
      Add an account (needs a Google app password, https://myaccount.google.com/apppasswords):
        gomail profile add personal --email you@gmail.com --name "Your Name"
        gomail profile test

      An Agent Skills skill that teaches AI coding agents to use gomail is in:
        #{opt_pkgshare}/skills/gomail
      Link it for every agent that reads ~/.agents/skills:
        ln -s #{opt_pkgshare}/skills/gomail ~/.agents/skills/gomail
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gomail --version")

    # Everything below uses a throwaway config and never touches the network
    # or a real ~/.config/gomail.
    config = testpath/"config.yaml"
    ENV["GOMAIL_CONFIG"] = config.to_s
    ENV.delete("GOMAIL_PROFILE")

    # The app password comes from stdin, is stored without the spaces Google
    # shows it with, and the file holding it is owner-only.
    pipe_output("#{bin}/gomail profile add test --email test@example.com " \
                "--name 'Test User' --password-stdin", "abcd efgh ijkl mnop\n", 0)
    assert_match "password: abcdefghijklmnop", config.read
    assert_equal "600", format("%o", config.stat.mode & 0777)

    # Several signatures per account: the default is used unless one is picked.
    system bin/"gomail", "signature", "set", "full", "--text", "Test User\n+61 400 000 000", "--default"
    system bin/"gomail", "signature", "set", "no-phone", "--text", "Test User"

    # preview builds the exact message without connecting to anything.
    md = JSON.parse(shell_output("#{bin}/gomail preview --to a@example.com -s Hi -m '**bold**' --json"))
    assert_equal "full", md["signature"]
    assert_equal "multipart/alternative(text/plain,text/html)", md["structure"]
    assert_match "<strong>bold</strong>", md["html"]
    assert_match "+61 400 000 000", md["text"]

    plain = JSON.parse(shell_output("#{bin}/gomail preview --to a@example.com -s Hi -b hello -S no-phone --json"))
    assert_equal "text/plain", plain["structure"]
    refute_match "+61", plain["text"]

    # Without a terminal, nothing is sent unless --yes is given.
    assert_match "refusing to send without --yes",
                 shell_output("#{bin}/gomail send --to a@example.com -s Hi -b x 2>&1", 1)
  end
end
