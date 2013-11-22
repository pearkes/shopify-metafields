#!/usr/bin/env bash

# Fail fast
set -e

# Override echo to provide colored and helpful output
function echo_pretty(){ builtin echo -e '\E[36m'$(basename $0 .sh): '\E[33m'$1; }

echo_pretty "Starting provisioner..."

# Update apt
echo_pretty "Updating apt..."
apt-get update

# Install packages that are necessary:
#
#    If you need something on the VM in the future, add it here and
#    write a note about what it's for below.
#
#     - build-essential: need this to do anything with compilation
#     - curl: for accessing remote things
#     - openjdk-7-jre-headless: Java things for threaded things.
#     - libssl-dev: Need to work with SSL in dev
#     - pkg-config: Used to compile things, helper lib.
#     - htop: Useful ops tool. Try running `htop` from your shell.
#     - git-core: Need git for some bundle activity.

echo_pretty "Installing basic dependencies..."

apt-get install -y \
    build-essential \
    curl \
    openjdk-7-jre-headless \
    libssl-dev \
    pkg-config \
    htop \
    git-core \

# Install RVM so we can manage rubies.
#
#   Because we might already have provisioned, we first check to see if
#   a default ruby exists in RVM - if not, we probably need to
#   install / reinstall it.
#

echo_pretty "Installing RVM..."

# Check to see if we have RVM and correct Ruby already
if [ ! -d "/home/vagrant/.rvm/rubies/default/" ]; then
    echo_pretty "Installing RVM requirements..."
    # These requirements are necessary to install RVM.
    apt-get install -y \
        libreadline6-dev \
        libsqlite3-dev \
        sqlite3 \
        libxml2-dev \
        libxslt1-dev \
        autoconf \
        libgdbm-dev \
        libncurses5-dev \
        automake \
        libtool \
        bison \
        libffi-dev \
        libyaml-dev \
        gawk

    if grep -q rvm /etc/group; then
       echo_pretty "RVM group already exists."
    else
       echo_pretty "Creating the RVM group..."
       groupadd rvm
    fi

    echo_pretty "Adding the vagrant user to RVM group..."
    # Add the vagrant user to the RVM group
    usermod -a -G rvm vagrant

    echo_pretty "Downloading and installing RVM..."
    # Install RVM
    su -l -c 'curl -L https://get.rvm.io | bash -s stable' vagrant

    echo_pretty "Installing Ruby 1.9.3..."
    # Install Ruby
    su -l -c 'rvm install 1.9.3' vagrant
    su -l -c 'rvm --default use 1.9.3' vagrant

    # Output the Ruby version
    #
    #   We do this to let a developer know what version of ruby is
    #   being automatically installed and provisioned on the VM.
    #
    echo_pretty "Ruby version: `su -l -c 'ruby --version' vagrant`"
else
    echo_pretty "Looks like RVM exists. Assuming RVM installation with ruby version: `su -l -c 'ruby --version' vagrant`..."
fi

# Install foreman to start / stop various web and backend services.
su -l -c \
    'JRUBY_OPTS="-Xcext.enabled=true" rvm all do gem install foreman --no-ri --no-rdoc' vagrant

# Nokogiri dependencies
#
#   HTML / XML parser.
#
apt-get install -y \
    libxslt-dev \
    libxml2-dev

# Compile node.js
#
#   This is sadly required to compile Javascripts in the asset pipeline.
#   Sigh.
#
echo_pretty "Installing Node..."

if [ ! -f "/usr/local/bin/node" ]; then
    echo_pretty "Downloading Node..."
    pushd /tmp
    wget --quiet http://nodejs.org/dist/v0.8.19/node-v0.8.19.tar.gz
    tar xvzf node-v0.8.19.tar.gz
    cd node*
    echo_pretty "Configuring and installing Node..."
    ./configure
    make V=""
    make V="" install
    popd
    # Clean up
    rm -rf node*
else
    echo_pretty "Looks like Node exists. Assuming Node installation..."
fi

# Install Postgres
echo_pretty "Installing Postgres..."

if [ ! -f "/usr/bin/psql" ]; then
    apt-get install -y  \
            postgresql \
            libpq-dev \
            postgresql-client

    # Insure that the locale is properly set for postgres
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8

    sudo -u postgres createuser -s metafields_development
    sudo -u postgres psql -c "ALTER USER metafields_development WITH PASSWORD 'metafields_development'"
else
    echo_pretty "Looks like Postgres exists. Assuming Postgres installation..."
fi

echo_pretty "Installing Forego..."

if [ ! -f "/usr/local/bin/forego" ]; then
    curl https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego -o /usr/local/bin/forego
    chmod +x /usr/local/bin/forego
else
    echo_pretty "Looks like forego exists. Assuming Forego installation..."
fi
# Automatically move into the shared folder, but only add the command
# if it's not already there.
touch /home/vagrant/.bash_profile
grep -q 'cd /vagrant' /home/vagrant/.bash_profile || echo 'cd /vagrant' >> /home/vagrant/.bash_profile

echo_pretty "Provisioning complete!"
