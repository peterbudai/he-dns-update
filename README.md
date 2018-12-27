# Hurricane Electric dynamic DNS updater

This is a small Bash utility script that can be used to update your dynamic DNS entries if you use the [Free DNS service from Hurricane Electric](https://dns.he.net/).

It tries to remain minimal in terms of prerequisites to make it usable on various modern Linux distributions.

## Quick start guide

_Step 1._ Download the source code of the [latest release](https://github.com/peterbudai/he-dns-update/releases/latest).

_Step 2._ Unzip it.

    tar xzf he-dns-update-<version>.tar.gz

_Step 3._ Edit the provided example configuration file ([`dns-update.conf`](dns-update.conf)) and fill it with your hostnames and dynamic DNS entry keys.

_Step 4._ Run the utility.

    ./dns-update.sh

### Using Git

Alternatively, you can clone this repository directly via Git to obtain the latest version. So, instead of _Step 1 and 2_ above, run the following command.

    git clone git@github.com:peterbudai/he-dns-update.git

## Configuration

The configuration file should always be placed next to the script. It should bear the same file name, except the `.conf` extension. It has a very straightforward simple tabular format:

* Everything starting with a pound sign (`#`) is considered as comment and discarded.
* Each line describes a single dynamic DNS entry that you set up at HE.
* Each entry consists of 3 columns, separated with any number and kind of whitespace:
    1. IP protocol version: `4` (for A records) or `6` (for AAAA records). 
    2. The fully qualified hostname of the entry, eg. `test.example.org`
    3. The key for the dynamic DNS entry. I suggest generating one using the HE web form, it is usually a sequence of 16 alphanumeric characters, eg. `AbCd1234EfGh5678`.

## Running

### Manually

You can always run the script manually, which will immediately try to update all DNS records specified in the config file.

    ./dns-update.sh

You can use this option to test your configuration. To get more feedback in case of an error, specify the `-v` or `--verbose` flag when running.

    ./dns-update.sh -v

### Automatically

I suggest adding this script to your `crontab`. This way it will be run at regular intervals and will always keep your IP address up to date.

An example cron configuration that runs the update every 15 minutes would look like the following (in this case the script and the config file is copied to the `/etc/cron.d` directory).

    */15 * * * *    root    /etc/cron.d/dns-update

Alternatively, you can set up any kind of network interface hooks that will trigger running the DNS update. This is more advanced and depends heavily on the Linus distribution you use.

License
-------

This utility is distributed under the [MIT License](LICENSE.md).

Contributing
------------

Feel free to file an [issue](https://github.com/peterbudai/he-dns-update/issues) or open a [pull request](https://github.com/peterbudai/he-dns-update/pulls).

Acknowledgement
---------------

Inspired by [this Gist](https://gist.github.com/joemiller/9fcbf1c953a8ed1095e95fe4396cec4a) from [joe miller](https://github.com/joemiller).