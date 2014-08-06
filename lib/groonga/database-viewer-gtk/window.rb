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

require "groonga/database-viewer-gtk/table"

module Groonga
  module DatabaseViewerGtk
    class Window < Gtk::Window
      def initialize(db_path)
        super()
        self.title = db_path
        set_default_size(640, 480)
        @grn_database = Database.open(db_path)
        signal_connect("destroy") do
          @grn_database.close unless @grn_database.closed?
          Gtk.main_quit
        end

        vbox = Gtk::VBox.new
        add(vbox)

        search_hbox = create_search_hbox
        vbox.pack_start(search_hbox, false, false, 4)

        @notebook = create_notebook
        vbox.pack_start(@notebook, true, true, 0)
      end

      def run
        show_all
        Gtk.main
      end

      private
      def init_view(page_num)
        target = get_tree_view(page_num)
        return unless target
        return if target.updated
        limit = @limit_combo.active_text.delete(",").to_i
        target.update_model(limit)
      end

      def select(column, word)
        if word.empty?
          query = nil
        elsif column == "_id"
          query = "#{column}:#{word}"
        else
          query = "#{column}:@#{word}"
        end
        target = get_tree_view(@notebook.page)
        return unless target
        limit = @limit_combo.active_text.delete(",").to_i
        target.update_model(limit, query)
      end

      def get_tree_view(page_num)
        page_widget = @notebook.children[page_num]
        if page_widget.is_a?(Gtk::ScrolledWindow)
          page_widget.each do |child|
            if child.is_a?(Table)
              return child
            end
          end
        end
        return nil
      end

      def create_search_hbox
        hbox = Gtk::HBox.new

        @combo_box = Gtk::ComboBox.new
        hbox.pack_start(@combo_box, false, false, 4)

        @entry = Gtk::Entry.new
        @entry.signal_connect("activate") do |_entry|
          select(@combo_box.active_text, _entry.text)
        end
        hbox.pack_start(@entry, false, false, 0)

        @search_button = Gtk::Button.new("Search")
        @search_button.signal_connect("clicked") do
          select(@combo_box.active_text, @entry.text)
        end
        hbox.pack_start(@search_button, false, false, 0)

        @limit_combo = Gtk::ComboBox.new
        9.times do |i|
          text = (10 ** i).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
          @limit_combo.append_text(text)
        end
        @limit_combo.append_text("268,435,455")
        @limit_combo.active = 0
        hbox.pack_end(@limit_combo, false, false, 4)

        label = Gtk::Label.new("Limit:")
        hbox.pack_end(label, false, false, 0)

        hbox
      end

      def update_combo_box(page_num)
        # TODO
        100.times do
          @combo_box.remove_text(0)
        end
        target = get_tree_view(page_num)
        if target
          @combo_box.append_text("_id")
          @combo_box.append_text("_key")
          target.grn_table.columns.each do |column|
            @combo_box.append_text(column.local_name)
          end
          @combo_box.active = 1
        end
      end

      def create_notebook
        notebook = Gtk::Notebook.new

        #label = Gtk::Label.new("Groonga")
        #notebook.append_page(Gtk::Label.new, label)

        @grn_database.tables.each do |grn_table|
          scrolled_window = Gtk::ScrolledWindow.new
          scrolled_window.set_policy(:automatic, :automatic)

          table = Table.new(grn_table, @grn_database.path)
          scrolled_window.add(table)

          label = Gtk::Label.new(grn_table.name)
          notebook.append_page(scrolled_window, label)
        end

        notebook.signal_connect("switch-page") do |_notebook, page, page_num|
          init_view(page_num)
          update_combo_box(page_num)
        end

        notebook
      end
    end
  end
end
