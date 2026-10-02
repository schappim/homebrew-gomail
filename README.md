# Homebrew Tap for gomail

The Homebrew tap for [gomail](https://github.com/schappim/gomail), a single Go
binary for working with several Gmail / Google Workspace accounts from the
command line over IMAP and SMTP with app passwords. It searches, reads,
downloads threads and attachments, previews, drafts, sends, replies and
forwards, with several named signatures per account.

## Installation

```bash
# Add the tap
brew tap schappim/gomail

# Install gomail
brew install gomail

# Upgrade to the latest version
brew upgrade gomail
```

## Quick Start

```bash
# 1. Turn on 2-Step Verification and create an app password:
#    https://myaccount.google.com/apppasswords
# 2. Add the account (you are prompted for the app password) and check it
gomail profile add personal --email you@gmail.com --name "Your Name" --default
gomail profile test

# Add a second account; pick one per command with -p
gomail profile add work --email you@company.example --password-env GOMAIL_WORK_PASSWORD
```

## Signatures

Each account can hold several named signatures, for example one with your
mobile number and one without for customers:

```bash
gomail signature set full --text $'Your Name\nExample Co\n+61 400 000 000' --default
gomail signature set no-phone --text $'Your Name\nExample Co' --description "for customers"
```

Use `-S NAME` to pick one when composing, or `--no-signature`.

## Usage

```bash
# Labels and folders
gomail labels --counts
gomail list                      # newest in the inbox
gomail list sent -n 10

# Search with Gmail syntax (All Mail by default)
gomail search from:supplier.example has:attachment newer_than:30d --snippets

# Read, follow threads, download
gomail read ID                   # --open shows the HTML version in a browser
gomail thread ID
gomail download ID -o ~/cases/supplier          # transcript, JSON, .eml, HTML, attachments
gomail attachments ID -o ~/Downloads --name '*.pdf'

# Compose: preview, draft, send (text, HTML or Markdown, with attachments)
gomail preview --to jane@example.com -s "Quote" -m "Quote **attached**" -a quote.pdf --open
gomail draft create --to jane@example.com -s "Quote" --markdown-file quote.md -a quote.pdf
gomail reply ID --all -m "Sounds good." -S no-phone --draft
gomail send --to jane@example.com -s "Quote" --body-file quote.txt -a quote.pdf   # asks to confirm

# Organise
gomail modify ID --read --add-label Clients/Acme --archive
gomail trash ID
```

Every command takes `--json` for scripting. Sending asks for confirmation;
without a terminal it requires `--yes`.

## AI agents

The formula installs an [Agent Skills](https://agentskills.io) skill that
teaches coding agents (Claude Code, Codex, Gemini CLI, Cursor, OpenCode…) to
use gomail safely, defaulting to drafts and confirming before anything is
sent:

```bash
ln -s "$(brew --prefix)/opt/gomail/share/gomail/skills/gomail" ~/.agents/skills/gomail
```

## Documentation

For complete documentation, see the [gomail README](https://github.com/schappim/gomail).

## License

MIT License
