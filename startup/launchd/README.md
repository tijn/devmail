# How to install

Compile devmail and copy to

    brew install crystal-lang
    crystal build src/devmail.cr
    cp devmail /usr/local/bin/

Copy the plist to /Library/LaunchDaemons/

    sudo cp startup/launchd/local.devmail.plist /Library/LaunchDaemons/

Load it

    sudo launchctl load -w /Library/LaunchDaemons/local.devmail.plist
