gateway-updater
=======

Bash script for updating "[connector-client](https://gitlab.wifa.uni-leipzig.de/fg-seits/connector-client)" gateways via git and pip.

-------

+ [Requirements](#requirements)
+ [Installation](#installation)
    + [Dictionary Structure](#dictionary-structure)
    + [Autostart](#autostart)
+ [Usage / Configuration](#usage-configuration)
    + [gupfiles](#gupfiles)
    + [Deploy Keys](#deploy-key)

-------

Requirements
----

+ Your gateways reside in local git repositories and have remote origins. 
+ A `.gitignore` file for ignoring files created during run-time by the gateways. 
+ [Pyenv](https://github.com/pyenv/pyenv) and [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) are installed and there's a virtualenv bearing the same name as the gateway dictionary for every gateway (see [Installation](#installation) for more information). 
+ Read only access to `gitlab.wifa.uni-leipzig.de/fg-seits` (see [Deploy Keys](#deploy-key) for more information).
+ The `wget` package is installed.


Installation
----

In the dictionary containing your gateways execute the following command:

`git clone git@gitlab.wifa.uni-leipzig.de:fg-seits/gateway-updater.git gateway-updater`

For gateway-updater to detect your gateways place a `gupfile` in the root of your gateway dictionary.
Create a virtualenv via `pyenv virtualenv` for each gateway and make sure to use the same name as the gateway dictionary.
The resulting dictionary structur should look something like this:

    .pyenv/versions/
        your-gateway-a/
        your-gateway-b/
    
    your-gateway-a/
        .git/
        gupfile
    
    your-gateway-b/
        .git/
        gupfile
    
    gateway-updater/
        .git/
        README.md
        gup.log
        logger.sh
        run.sh
        updater.sh

---

#### Autostart

Use cron ...

execute `./run.sh`

run.sh will check for internet access and update "gateway-updater" before starting it.

Usage / Configuration
----

#### gupfiles

By providing a `gupfile` the gateway-updater can determine that a gateway is present in the dictionary. The `gupfile` contains a list of Python packages the gateway depends on and the desired version of theses packages. Please use the following format `<python package>,<version>` and see the below `gupfile` example for further explanation:

    sepl-connector-client,3.0.3
    paho-mqtt,1.3.1
    pycryptodome,3.6.3
    pyserial,3.4
    

**Don't forget to provide a blank line at the end of the `gupfile`!**

---

#### Deploy Keys

...