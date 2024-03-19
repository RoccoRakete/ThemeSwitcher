
using Gtk;
using Json;

public class ThemeSwitcher : Gtk.Application {
	public ThemeSwitcher () {
		GLib.Object (application_id: "com.RoccoRakete.ThemeSwitcher");
	}

	protected override void activate () {
		var window = new ApplicationWindow (this);
		window.default_width = 800;
		window.default_height = 600;

		string home_dir = GLib.Environment.get_home_dir ();
		string config_file_path = home_dir + "/.config/themeswitcher/config.jsonc";
		string styling_file_path = home_dir + "/.config/themeswitcher/styles.css";

		var titleparser = new Json.Parser ();
		string title = "";
		string name = "";
		try {
			titleparser.load_from_file (config_file_path);
			var root = titleparser.get_root ().get_object ();
			title = root.get_string_member ("title");
			name = root.get_string_member ("name");
			window.set_title (title);
		} catch (Error e) {
			print ("Error reading JSON file: %s\n", e.message);
		}

		var titleLabel = new Label (title);
		titleLabel.set_css_classes ({ "title-label" });
		titleLabel.show ();

		var nameLabel = new Label (name);
		nameLabel.set_css_classes ({ "name-label" });

		var titleBox = new Box (Orientation.VERTICAL, 0);
		titleBox.append (titleLabel);
		titleBox.show ();

		var grid = new Grid ();
		grid.hexpand = false;
		grid.vexpand = true;
		grid.halign = Gtk.Align.START;
		grid.set_column_spacing (10);
		grid.set_row_spacing (6);
		grid.show ();

		var gridBox = new Box (Orientation.VERTICAL, 0);
		grid.set_css_classes ({ "menu-bar" });
		gridBox.append (grid);
		gridBox.show ();

		var vbox = new Box (Orientation.VERTICAL, 0);
		vbox.append (titleBox);
		vbox.append (gridBox);
		vbox.show ();

		window.set_child (vbox);

		var parser = new Json.Parser ();
		try {
			parser.load_from_file (config_file_path);
			var root = parser.get_root ().get_object ();
			var menus = root.get_array_member ("menus");

			int row = 0;
			for (var i = 0; i < menus.get_length (); i++) {
				var menu_node = menus.get_element (i);
				var menu = menu_node.get_object ();
				var menu_name = menu.get_string_member ("name");
				var options = menu.get_array_member ("options");
				var commands = menu.get_array_member ("commands");

				var label = new Label (menu_name);
				label.add_css_class ("menu-label");
				grid.attach (label, 0, row, 1, 1);

				string[] options_array = new string[options.get_length () + 1];
				options_array[0] = "none";
				for (var j = 0; j < options.get_length (); j++) {
					options_array[j + 1] = options.get_element (j).get_string ();
				}

				var dropdown = new DropDown.from_strings (options_array);
				dropdown.selected = -1;
				dropdown.add_css_class ("menu-dropdown");
				grid.attach (dropdown, 0, row + 1, 1, 1);

				dropdown.notify["selected"].connect (() => {
					var selected_index = dropdown.selected;
					if (selected_index != 0 && selected_index != -1) {
						var command_array = commands.get_element (selected_index - 1).get_array ();
						string[] commands_to_execute = new string[command_array.get_length ()];
						for (int j = 0; j < command_array.get_length (); j++) {
							commands_to_execute[j] = command_array.get_element (j).get_string ();
						}
						execute_commands (commands_to_execute);
					}
				});

				row += 2;
			}
		} catch (Error e) {
			print ("Error reading JSON file: %s\n", e.message);
		}

		window.set_child (grid);
		window.present ();

		var provider = new CssProvider ();
		provider.load_from_path (styling_file_path);
		Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
	}

	private void execute_commands (string[] commands) {
		foreach (var command in commands) {
			try {
				string stdout;
				string stderr;
				int exit_status;
				Process.spawn_command_line_sync (command, out stdout, out stderr, out exit_status);
				print ("Command executed successfully: %s\n", command);
			} catch (Error e) {
				print ("Error executing command: %s\n", e.message);
			}
		}
	}

	public static int main (string[] args) {
		var app = new ThemeSwitcher ();
		return app.run (args);
	}
}
