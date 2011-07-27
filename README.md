# Knife Ninefold

## Description

Knife plugin for ninefold

## Installation

This plugin is distributed as a Ruby Gem. To install:

    gem install knife-ninefold

## Configuration

The following parameters need to be set in your knife.rb:

    knife[:ninefold_compute_key]  = "Your Ninefold compute API key"
    knife[:ninefold_compute_secret] = "Your Ninefold compute API secret"

or added to the command line in the -K and -S parameters

## Subcommands

### knife ninefold flavor list

### knife ninefold image list

### knife ninefold server create

Creates a server. By default, a 1.7gb running Ubuntu

### knife ninefold server list

### knife ninefold server delete

## Development

Run knife through bundler - this will load the in development gem
