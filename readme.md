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
4. You must have Docker installed and running

#### Setup

To download and setup all the repos, create a `gems` directory somewhere in your work dir and run this command from there. All the other gems will be cloned in their own directories in the same path you are running the command.

```bash
curl -O https://raw.githubusercontent.com/avo-hq/support/main/scripts/setup
chmod +x ./setup
./setup
```

This will first install the `support` repo, add it to `~/bin`, then it will run the `bud setup` command which will clone all the repos, run `bundle install` and `yarn install`.

#### Avo-3 temporary solution

This script will clone the `avo` repo, not `avo-3`. You need to run these commands to make it work.

```bash
rm -rf avo
git clone git@github.com:avo-hq/avo-3.git avo
bud run yarn -g avo
```

Next, you can go into `prommy` and run `bin/dev` to start the app.

## How to use the `bud` helper

### Overview

Most commands can be run inside a gem directory (`avo`, `avo_filters`, etc.) and it will know to run it on that gem, or from the `prommy` app with the `--gem` (or `-g`) argument and it will `cd` into the proper directory.
Ex: `bud bump -g avo_filters`, `bud release -g dashboards`.

You can leave out the `avo_` prefix and it will add it.
Ex: `bud bump -g dashboards`

It will spit out quite some output. The output in yellow with this `=>` prefix is output from `bud`. The rest is output from the commands we run.

### `bud bump`

This will bump the version number. You can pass the level to bump it by (`minor` or `patch`).

### `bud build`

This will build the gem.
This uses `docker` behind the scenes. It will create containers in which it will build the gems and then and extract a `GEM_NAME.pkg` file in the gems `pkg` directory. We'll use that `pkg` file to push to our rubygems server.

### `bud commit`

Adds the new version number to the repo, creates a tag and pushes it to the repo. This will trigger GitHub Actions to create a new release with the latest release notes.

### `bud push`

Pushes the `pkg` file to the private rubygems server (github).

### `bud release`

This is the big finalle. It runs commands in this order `bump`, `build`, `push`, and `commit`.
We run `commit` last so we are sure that the build went through successfully.

**Warning** `bud` doesn't yet check that the `build`, or `push` commands executed successfully. You should keep an eye on the logs.

### `bud run`

This is a helper command to run something in one or all gem directories.

```bash
# Examples
bud run "bundle install" --all # it will run the command in all repos
bud run "yarn install" --gem filters # it will run the command in the avo_filters repo
```

`bud` knows where all the gems are from the `support/gems.yml` file which we should manually update.

### `bud setup`

This helps us do the initial setup and probably to add new repos locally when we add them on GH.
It basically does a `git clone`, `bundle install`, and `yarn install` on each one.


## Working with the multi repo seetup

For each new repository go to settings and set "Automatically delete head branches" to `true`.

This is a good setting to remove the merged git branches.

```bash
git config --global fetch.prune true
```
