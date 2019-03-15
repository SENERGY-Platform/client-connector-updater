client-connector-updater
=======

Bash script for updating python client connector projects via git and pip.

-------

+ [Requirements](#requirements)
+ [Installation](#installation)
    + [Dictionary Structure](#dictionary-structure)
    + [Autostart](#autostart)
+ [Usage / Configuration](#usage-configuration)
    + [gupfiles](#gupfiles)
    + [Deploy Keys](#deploy-key)


Requirements
----

+ Your client connectors reside in local git repositories and have remote origins.
+ A `.gitignore` file for ignoring files created during run-time by the client connectors.
+ There's a virtualenv bearing the same name as the client connector dictionary for every client connector (see [Installation](#installation) for more information).
+ The `wget` package is installed.


Installation
----

In the dictionary containing your gateways execute the following command:

`git clone https://github.com/SENERGY-Platform/client-connector-updater.git client-connector-updater`

For client-connector-updater to detect your client connectors place a `gupfile` in the root of your client connector dictionary.
Create a virtualenv for each client connector and make sure to use the same name as the client connector dictionary.
The resulting dictionary structur should look something like this:

    .pyenv/
        your-client-connector-a/
        your-client-connector-b/

    your-client-connector-a/
        .git/
        gupfile

    your-client-connector-b/
        .git/
        gupfile

    client-connector-updater/
        .git/
        README.md
        gup.log
        logger.sh
        run.sh
        updater.sh


#### Autostart

Use cron to start the script at a desired time.

Execute `crontab -e` and add the following line: `0 2 * * *  bash /home/<your user>/client-connector-updater/run.sh &`

With the above line the script will run at 2 AM every day.


Usage / Configuration
----

Execute `./run.sh` to start the update process with a random delay (10-120s) or use `./run.sh now` if a delay is not desired. The client-connector-updater will first try to update itself and will then continue to check for client connector updates and dependency updates. Any output is logged to `gup.log`. After a successful update the client-connector-updater will initate a reboot. To override the reboot use the `now` argument.

---

#### gupfiles

By providing a `gupfile` the client-connector-updater can determine that a client connector is present in the dictionary. The `gupfile` contains a list of Python packages the client connector depends on, the desired version of theses packages and optionally the source of the dependency. Please use the following format `<python package>,<version>,<source>` and see the below `gupfile` example for further explanation:

    client-connector-lib,3.0.3,git+https://github.com/SENERGY-Platform/client-connector-lib.git
    paho-mqtt,1.3.1
    pycryptodome,3.6.3
    pyserial,3.4
    

**Don't forget to provide a blank line at the end of the `gupfile`!**
