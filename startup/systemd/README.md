     

    sudo cp devmail /usr/local/bin/
    cp startup/systemd/user/devmail.service ~/.config/systemd/user/
    systemctl --user enable devmail.service
