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

require "groonga"
require "gtk2"

module Groonga
  module DatabaseViewerGtk
    class Table < Gtk::TreeView
      ID_COLUMN_INDEX = 0
      KEY_COLUMN_INDEX = 1

      attr_reader :updated
      attr_reader :grn_table

      def initialize(grn_table, db_path)
        super()
        @grn_table = grn_table
        @db_path = db_path
        @updated = false
        @threads = []
        signal_connect("destroy") do
          @threads.each do |thread|
            thread.kill
          end
        end
        create_tree_view
      end

      def create_tree_view
        self.rules_hint = true

        create_column("_id", ID_COLUMN_INDEX)
        create_column("_key", KEY_COLUMN_INDEX)

        @grn_table.columns.each_with_index do |grn_column, i|
          create_column(grn_column.local_name, i + 2)
        end
      end

      def create_column(name, index)
        gtk_column = Gtk::TreeViewColumn.new
        gtk_column.title = name.gsub(/_/, "__")
        gtk_column.resizable = true
        gtk_column.set_sort_column_id(index)
        append_column(gtk_column)

        renderer = Gtk::CellRendererText.new
        gtk_column.pack_start(renderer, :expand => false)
        gtk_column.add_attribute(renderer, :text, index)
      end

      def update_model(limit, query=nil)
        @threads.reject! do |thread|
          thread.kill
          true
        end

        column_types = @grn_table.columns.collect do |column|
                         # TODO
                         String
                       end
        column_types.unshift(String)   # _key
        column_types.unshift(Integer)  # _id

        model = Gtk::ListStore.new(*column_types)
        self.model = model

        thread = Thread.new do
          each_records(limit, query).each do |grn_record|
            load_record(model, grn_record)
          end
        end
        @threads << thread

        @updated = true
      end

      def load_record(model, grn_record)
        iter = model.append
        iter.set_value(ID_COLUMN_INDEX, grn_record._id)
        iter.set_value(KEY_COLUMN_INDEX, grn_record._key) if grn_record.respond_to?(:_key)
        @grn_table.columns.each_with_index do |grn_column, i|
          value = nil
          if grn_column.index?
            ids = grn_column.search(grn_record._id).records.collect {|record| record._id}
            value = "#{ids.size}, #{ids.to_s}"
          else
            value = grn_record[grn_column.local_name].to_s
          end
          iter.set_value(2 + i, value)
          GC.start if i % 100 == 0
        end
      end

      def each_records(limit, query=nil)
        grn_records = Groonga[@grn_table.name]
        if query
          grn_records = grn_records.select(query)
        end
        if block_given?
          grn_records.take(limit).each do |grn_record|
            yield(grn_record)
          end
        else
          grn_records.take(limit)
        end
      end
    end
  end
end
