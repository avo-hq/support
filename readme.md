# Avo support files & buddy CLI

This repo is going to help us out to set up and continue working with Avo's multi-repo setup.

```bash
ln -s $PWD/support/bin/bud ~/bin/bud
```

## Initial Setup

#### Prerequisites

1. The `~/bin` directory must be added to `$PATH`. Add this `export PATH="$PATH:$HOME/bin"` to your `.bashrc`, or `.bash_profile` to have that available.
2. You must have Ruby 3.1 installed on your computer
3. You must have PostgreSQL installed and running (`brew install postgresql@14`)

#### Setup

To download and setup all the repos, create a `gems` directory somewhere in your work dir and run this command from there. All the other gems will be cloned in their own directories in the same path you are running the command.

```bash
curl -O https://raw.githubusercontent.com/avo-hq/support/main/scripts/setup
chmod +x ./setup
./setup
```

This will first install the `support` repo, add it to `~/bin`, then it will run the `bud setup` command which will clone all the repos, run `bundle install` and `yarn install`.

Next, you can go into `prommy` and run `bin/dev` to start the app.