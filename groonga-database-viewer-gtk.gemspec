# -*- mode: ruby; coding: utf-8 -*-
#
# Copyright (C) 2014  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

base_dir = File.dirname(__FILE__)
lib_dir = File.join(base_dir, "lib")

$LOAD_PATH.unshift(lib_dir)
require "groonga/database-viewer-gtk/version"

Gem::Specification.new do |spec|
  spec.name = "groonga-database-viewer-gtk"
  spec.version = Groonga::DatabaseViewerGtk::VERSION

  spec.authors = ["Masafumi Yokoyama"]
  spec.email = ["myokoym@gmail.com"]

  spec.summary = %q{a graphical database viewer for Groonga by GTK+ with Ruby.}
  spec.description = spec.summary

  spec.files = ["README.md", "Rakefile", "Gemfile", "#{spec.name}.gemspec"]
  spec.files += "NEWS.md"
  spec.files += Dir.glob("lib/**/*.rb")
  spec.test_files += Dir.glob("test/**/*")
  Dir.chdir("bin") do
    spec.executables = Dir.glob("*")
  end

  spec.homepage = "https://github.com/myokoym/groonga-database-viewer-gtk"
  spec.licenses = ["LGPLv2+"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rroonga")
  spec.add_runtime_dependency("gtk2")

  spec.add_development_dependency("test-unit", ">= 3.0.0")
  spec.add_development_dependency("test-unit-notify")
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
