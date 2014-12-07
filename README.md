# README

[![Gem Version](https://badge.fury.io/rb/groonga-database-viewer-gtk.svg)](http://badge.fury.io/rb/groonga-database-viewer-gtk)
[![Build Status](https://travis-ci.org/myokoym/groonga-database-viewer-gtk.png?branch=master)](https://travis-ci.org/myokoym/groonga-database-viewer-gtk)

## Name

groonga-database-viewer-gtk

## Description

a graphical database viewer for [Groonga][] by [GTK+][] with [Ruby][].

[Groonga]:http://groonga.org/
[GTK+]:http://www.gtk.org/
[Ruby]:https://www.ruby-lang.org/

## Install

    $ gem install groonga-database-viewer-gtk

## Usage

    $ groonga-database-viewer-gtk DB_PATH

### Options

    $ groonga-database-viewer-gtk -h
    Usage: groonga-database-viewer-gtk [OPTIONS] DB_PATH
            --wrap_width=WIDTH           Set wrap width to columns

### For example

    $ groonga-database-viewer-gtk --wrap_width=320 ~/.milkode/db/milkode.db

## Authors

* Masafumi Yokoyama `<myokoym@gmail.com>`

## License

LGPLv2.1 or later.

See LICENSE.txt or http://www.gnu.org/licenses/lgpl-2.1 for details.
