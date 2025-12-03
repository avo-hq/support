# Avo support files & buddy CLI

This repo is going to help us out to set up and continue working with Avo's multi-repo setup.

See [this](https://avo-hq.notion.site/Avo-Dev-wiki-1bb5cfb19ef1444daee277a57d82d3b8) document to get started with Avo.

## Initial Setup

#### Prerequisites

1. You must have Ruby installed on your computer
2. You must have PostgreSQL installed and running

#### Setup

To download and setup all the repos, create a `gems` directory somewhere in your work dir and run this command from there. All the other gems will be cloned in their own directories in the same path you are running the command.

```bash
curl -O https://raw.githubusercontent.com/avo-hq/support/main/scripts/setup
chmod +x ./setup
./setup
```

This will first install the `support` repo, add it to `~/bin`, then it will run the `bud setup` command which will clone all the repos, run `bundle install` and `yarn install`.

Next, you can go into `testy` and run `bin/dev` to start the app.

## How to use the `bud` helper

### Overview

Most commands can be run inside a gem directory (`avo`, `avo-dynamic_filters`, etc.) and it will know to run it on that gem, or from any other directory with the `--gem` (or `-g`) argument and it will `cd` into the proper directory.
Ex: `bud bump --gem avo-dynamic_filters`, `bud release -g avo-dashboards`.

You can leave out the `avo-` prefix and it will add it.
Ex: `bud bump -g dashboards`

It will spit out quite some output. The output in yellow with this `=>` prefix is output from `bud`. The rest is output from the commands we run.

### Commands

#### `bud version`

Print the current version of the `bud` CLI.

**Aliases:** `v`, `-v`, `--version`

---

#### `bud bump`

Bump the gem version number. You can pass the level to bump it by.

**Arguments:**
- `level` - The version level to bump: `major`, `minor`, `patch`, or `pre` (default: `minor`)

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on

**Examples:**
```bash
bud bump patch
bud bump minor --gem avo-dashboards
```

---

#### `bud build`

Build the gem. This will generate a file in the gem's `pkg` directory.

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on
- `--all` - Build the gem in all gems

---

#### `bud build_assets`

Build assets. This will:
1. Clean the `app/assets/builds` directory if it exists
2. Run `yarn` and the build script if `package.json` exists

**Options:**
- `--gem`, `-g` - The gem where you want to build the assets on

---

#### `bud bundle`

Run `bundle install` and `bundle exec appraisal` on a gem.

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on

---

#### `bud commit`

Add the new version number to the repo, create a tag, and push to the repo. This will trigger GitHub Actions to create a new release with the latest release notes.

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on
- `--tag` - Tag the version (default: `true`, use `--no-tag` to disable)
- `--origin` - The origin branch to push to (default: `main`)

---

#### `bud push`

Push the `pkg` file to the rubygems server. `avo` gems are pushed to rubygems.org, while other gems are pushed to the GitHub packages registry.

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on

---

#### `bud release`

This is the main release command. It runs commands in this order: `bump`, `bundle`, `build_assets`, `encrypt`, `build`, `cleanup_encrypted`, `push`, and `commit`.
We run `commit` last so we are sure that the build went through successfully.

**Arguments:**
- `level` - The version level to bump: `major`, `minor`, `patch`, or `pre` (default: `patch`)

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on
- `--skip_bump`, `-sb` - Skip bumping the version
- `--all` - Release all gems (will prompt for Avo 3 or 4)

**Examples:**
```bash
bud release patch --gem avo-dashboards
bud release minor --all
bud release patch --skip_bump -g avo
```

**Warning:** `bud` does check that all commands executed successfully, however, you should keep an eye on the logs.

---

#### `bud encrypt`

Encrypt gem files using holder's key and loaders. This is used for paid gems before building.

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on

**Note:** Only runs on specific gems: `avo-dashboards`, `avo-menu`, `avo-pro`, `avo-dynamic_filters`, `avo-advanced`, `avo-licensing` or any specified on the `GEMS_TO_ENCRYPT` constant.

---

#### `bud cleanup_encrypted`

Remove `.enc` files and restore originals after building the gem.

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on

---

#### `bud run`

A helper command to run something in one or all gem directories.

**Arguments:**
- `command` - The command you'd like to run (default: `bundle install`)

**Options:**
- `--gem`, `-g` - The gem where you want to run the command on
- `--all` - Run the command in all gems

**Examples:**
```bash
bud run "bundle install" --all     # Run in all repos
bud run "yarn install" --gem dynamic_filters  # Run in avo-dynamic_filters
bud run "git status" -g dashboards
```

`bud` knows where all the gems are from the `support/gems.yml` file which we should manually update.

---

#### `bud setup`

Helps with the initial setup and adding new repos locally. It clones all repos, runs `bundle install`, and `yarn install` on each one.

## Working with the multi repo setup

For each new repository go to settings and set "Automatically delete head branches" to `true`.

This is a good setting to remove the merged git branches.

```bash
git config --global fetch.prune true
```
