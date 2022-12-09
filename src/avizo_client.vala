using Gtk;

[DBus (name = "org.danb.avizo.service")]
interface AvizoService : GLib.Object
{
	public abstract string image_path { owned get; set; }
	public abstract string image_resource { owned get; set; }
	public abstract double image_opacity { owned get; set; }
	public abstract double progress { owned get; set; }
	public abstract int width { owned get; set; }
	public abstract int height { owned get; set; }
	public abstract int border_radius { owned get; set; }
	public abstract int border_width { owned get; set; }
	public abstract int padding { owned get; set; }
	public abstract double y_offset { owned get; set; }
	public abstract int block_height { owned get; set; }
	public abstract int block_spacing { owned get; set; }
	public abstract int block_count { owned get; set; }
	public abstract double fade_in { owned get; set; }
	public abstract double fade_out { owned get; set; }
	public abstract Gdk.RGBA background { owned get; set; }
	public abstract Gdk.RGBA border_color { owned get; set; }
	public abstract Gdk.RGBA bar_fg_color { owned get; set; }
	public abstract Gdk.RGBA bar_bg_color { owned get; set; }

	public abstract void show(double seconds) throws DBusError, IOError;
}

public class AvizoClient : GLib.Application
{
	private AvizoService _service = null;

	private static bool _show_version = false;
	private static bool _list_resources = false;
	private static string _image_base_dir = @"$(Environment.get_user_data_dir())/avizo";
	private static string _image_path = "";
	private static string _image_resource = "volume_muted";
	private static double _image_opacity = 1.0;
	private static double _progress = 0.0;
	private static int _width = 248;
	private static int _height = 232;
	private static double _y_offset = 0.75;
	private static int _padding = 24;
	private static int _border_radius = 16;
	private static int _border_width = 1;
	private static int _block_height = 10;
	private static int _block_spacing = 2;
	private static int _block_count = 20;
	private static double _fade_in = 0.2;
	private static double _fade_out = 0.5;
	private static string _background = "";
	private static string _border_color = "";
	private static string _bar_fg_color = "";
	private static string _bar_bg_color = "";

	private static double _time = 5.0;

	private const GLib.OptionEntry[] options = {
		{ "version", 0, 0, OptionArg.NONE, ref _show_version, "Display version number", null },
		{ "list-resources", 0, 0, OptionArg.NONE, ref _list_resources, "Lists the resource ids available", null },
		{ "image-base-dir", 0, 0, OptionArg.STRING, ref _image_base_dir, "The base directory to resolve relative image-path against (default is $XDG_DATA_HOME/avizo)", "PATH" },
		{ "image-path", 0, 0, OptionArg.STRING, ref _image_path, "Use the image specified by the path", "PATH" },
		{ "image-resource", 0, 0, OptionArg.STRING, ref _image_resource, "Use the image specified by the image resource id", "RESOURCE_ID" },
		{ "image-opacity", 0, 0, OptionArg.DOUBLE, ref _image_opacity, "Sets the image opacity, allowed values range from 0 (transparent) to 1.0 (opaque)", "DOUBLE" },
		{ "progress", 0, 0, OptionArg.DOUBLE, ref _progress, "Sets the progress in the notification, allowed values range from 0 to 1", "DOUBLE" },
		{ "width", 0, 0, OptionArg.INT, ref _width, "Sets the width of the notification", "INT" },
		{ "height", 0, 0, OptionArg.INT, ref _height, "Sets the height of the notification", "INT" },
		{ "y-offset", 0, 0, OptionArg.DOUBLE, ref _y_offset, "Sets relative offset of the notification to the top of the screen, allowed values range from 0 (top) to 1.0 (bottom)", "DOUBLE" },
		{ "padding", 0, 0, OptionArg.INT, ref _padding, "Sets the inner padding of the notification", "INT" },
		{ "border-radius", 0, 0, OptionArg.INT, ref _border_radius, "Sets the border radius of the notification in px", "INT" },
		{ "border-width", 0, 0, OptionArg.INT, ref _border_width, "Sets the border width of the notification in px", "INT" },
		{ "block-height", 0, 0, OptionArg.INT, ref _block_height, "Sets the block height of the progress indicator", "INT" },
		{ "block-spacing", 0, 0, OptionArg.INT, ref _block_spacing, "Sets the spacing between blocks in the progress indicator", "INT" },
		{ "block-count", 0, 0, OptionArg.INT, ref _block_count, "Sets the amount of blocks in the progress indicator", "INT" },
		{ "fade-in", 0, 0, OptionArg.DOUBLE, ref _fade_in, "Sets the fade in animation duration in seconds", "DOUBLE" },
		{ "fade-out", 0, 0, OptionArg.DOUBLE, ref _fade_out, "Sets the fade out animation duration in seconds", "DOUBLE" },
		{ "background", 0, 0, OptionArg.STRING, ref _background, "Sets the color of the notification background in format rgba([0, 255], [0, 255], [0, 255], [0, 1])", "STRING" },
		{ "border-color", 0, 0, OptionArg.STRING, ref _border_color, "Sets the color of the notification border in format rgba([0, 255], [0, 255], [0, 255], [0, 1])", "STRING" },
		{ "foreground", 0, 0, OptionArg.STRING, ref _bar_fg_color, "Deprecated alias for --bar-fg-color", "STRING" },
		{ "bar-fg-color", 0, 0, OptionArg.STRING, ref _bar_fg_color, "Sets the color of the filled bar blocks in format rgba([0, 255], [0, 255], [0, 255], [0, 1])", "STRING" },
		{ "bar-bg-color", 0, 0, OptionArg.STRING, ref _bar_bg_color, "Sets the color of the unfilled bar blocks in format rgba([0, 255], [0, 255], [0, 255], [0, 1])", "STRING" },
		{ "time", 0, 0, OptionArg.DOUBLE, ref _time, "Sets the time to show the notification, default is 5", "DOUBLE" },
		{ null }
	};

	public AvizoClient()
	{
		Object(application_id: "org.danb.avizo.client",
		       flags: ApplicationFlags.HANDLES_COMMAND_LINE);

		_service = Bus.get_proxy_sync(BusType.SESSION, "org.danb.avizo.service",
		                                             "/org/danb/avizo/service");
	}

	public override int command_line(ApplicationCommandLine command_line)
	{
		try
		{
			load_config();
		}
		catch (Error e)
		{
			if (!(e is KeyFileError.NOT_FOUND))
			{
				stderr.printf(@"avizo: Failed to load configuration file: $(e.message)\n");
				return 1;
			}
		}

		// this is an ugly workaround to deal with args being owned
		string[] args = command_line.get_arguments();
		string[] _args = new string[args.length];
		unowned string[] tmp = _args;
		for (int i = 0; i < args.length; i++)
		{
			_args[i] = args[i];
		}

		try
		{
			var opt_context = new OptionContext("- Run avizo-client");
			opt_context.set_help_enabled(true);
			opt_context.add_main_entries(options, null);

			opt_context.parse(ref tmp);
		}
		catch (OptionError e)
		{
			stderr.printf(@"avizo: $(e.message)\n");
			stderr.printf(@"Run '$(args[0]) --help' to see a full list of available command line options.\n");

			return 1;
		}

		if (_show_version)
		{
			print(@"avizo-client $(Config.VERSION)\n");

			return 0;
		}

		if (_list_resources)
		{
			print("Available resources:\n");
			print("  volume_muted\n");
			print("  volume_low\n");
			print("  volume_medium\n");
			print("  volume_high\n");
			print("  mic_muted\n");
			print("  mic_unmuted\n");
			print("  brightness_low\n");
			print("  brightness_medium\n");
			print("  brightness_high\n");

			return 0;
		}

		if (_image_path != "")
		{
			_service.image_path = Filename.canonicalize(_image_path, _image_base_dir);
		}
		else
		{
			_service.image_resource = _image_resource;
		}

		_service.image_opacity = _image_opacity;
		_service.progress = _progress;
		_service.width = _width;
		_service.height = _height;
		_service.padding = _padding;
		_service.y_offset = _y_offset;
		_service.border_radius = _border_radius;
		_service.border_width = _border_width;
		_service.block_height = _block_height;
		_service.block_spacing = _block_spacing;
		_service.block_count = _block_count;

		_service.fade_in = _fade_in;
		_service.fade_out = _fade_out;

		if (_background != "")
		{
			var color = parse_rgba(_background);
			_service.background = color;

			if (_bar_bg_color == "")
			{
				var bar_color = color.copy();
				bar_color.red /= 1.5;
				bar_color.green /= 1.5;
				bar_color.blue /= 1.5;
				_service.bar_bg_color = bar_color;
			}
		}

		if (_border_color != "")
		{
			_service.border_color = parse_rgba(_border_color);
		}

		if (_bar_bg_color != "")
		{
			_service.bar_bg_color = parse_rgba(_bar_bg_color);
		}

		if (_bar_fg_color != "")
		{
			_service.bar_fg_color = parse_rgba(_bar_fg_color);
		}

		_service.show(_time);

		return 0;
	}

	private void load_config() throws KeyFileError, FileError
	{
		string[] search_dirs = {};
		search_dirs += Environment.get_user_config_dir();
		foreach (var dir in Environment.get_system_config_dirs())
		{
			search_dirs += dir;
		}

		string config_path;
		var conf = new KeyFile();
		conf.load_from_dirs("avizo/config.ini", search_dirs, out config_path, KeyFileFlags.NONE);

		debug("Loading configuration from %s", config_path);

		var group = conf.get_start_group();

		// Copy key values from the config file into static variables of this class
		// (e.g. `_width`) according to the mapping specified in the options array.
		foreach (var entry in options)
		{
			if (entry.long_name == null || !conf.has_key(group, entry.long_name))
			{
				continue;
			}
			switch (entry.arg)
			{
				case OptionArg.DOUBLE:
					*((double*) entry.arg_data) = conf.get_double(group, entry.long_name);
					break;
				case OptionArg.INT:
					*((int*) entry.arg_data) = conf.get_integer(group, entry.long_name);
					break;
				case OptionArg.STRING:
					var value = conf.get_string(group, entry.long_name);
					*((void**) entry.arg_data) = (owned) value;
					break;
				default:
					break;
			}
		}
	}
}

Gdk.RGBA parse_rgba(string value)
{
	var color = Gdk.RGBA();
	if (!color.parse(value))
	{
		// Note: This terminates the process!
		error("Invalid RGBA color value: %s", value);
	}

	return color;
}

public void main(string[] args)
{
	AvizoClient client = new AvizoClient();
	client.run(args);
}
