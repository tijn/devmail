# devmail

                   SMTP                POP3     
    Your app(s) ----------> devmail ----------> Thunderbird/Mail.app/Outlook/...
    

SMTP and POP3 server with no storage. It keeps all the mails in memory until they are fetched or until you shut down the program). It is meant for development. You can send emails to it and "pop" them with an e-mail client like Thunderbird or Mail.app on OS X. It is comparable to [Letter Opener](https://github.com/ryanb/letter_opener).

This is a port of [Blue Rail's Post Office](https://github.com/bluerail/post_office) to Crystal-lang.

## MacOs

Please read startup/launchd/README.md

## Linux (SystemD)

Please read startup/systemd/README.md
