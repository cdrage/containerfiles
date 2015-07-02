#!/bin/bash
set -e

# mutt config settings
sed -i "s,%MUTT_LOGIN%,$MUTT,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_NAME%,$MUTT_NAME,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_PASS%,$MUTT_PASS,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_FROM%,$MUTT_FROM,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_IMAP%,$MUTT_IMAP,g" "$HOME/.mutt/muttrc"


# sending mail
sed -i "s,%MUTT%,$MUTT,g" "$HOME/.msmtprc"
sed -i "s,%MUTT_PASS%,$MUTT_PASS,g" "$HOME/.msmtprc"

exec "$@"
