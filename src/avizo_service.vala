using Gtk;
using GtkLayerShell;

[CCode (cname = "gdk_wayland_display_get_type")]
extern Type get_wayland_type();

[GtkTemplate (ui = "/org/danb/avizo/ui/avizo.ui")]
public class AvizoWindow : Gtk.Window
{
	public string image_path
	{
		set
		{
			if (value != "")
			{
				image.set_from_file(value);
			}
		}
	}

	public string image_resource
	{
		set
		{
			if (value != "")
			{
				image.set_from_resource(@"/org/danb/avizo/data/images/$(value).png");
			}
		}
	}

	public double image_opacity {
		get
		{
			return image.opacity;
		}
		set
		{
			image.opacity = value;
		}
	}

	public double progress { get; set; }

	private int _width = 248;
	public int width
	{
		get
		{
			return _width;
		}

		set
		{
			_width = value;

			set_size_request(_width, _height);
		}
	}

	private int _height = 232;
	public int height
	{
		get
		{
			return _height;
		}

		set
		{
			_height = value;

			set_size_request(_width, _height);
		}
	}

	public int padding { get; set; }
	public int border_radius { get; set; }
	public new int border_width { get; set; }

	public int block_height { get; set; }
	public int block_spacing { get; set; }
	public int block_count { get; set; }

	public double fade_in { get; set; }
	public double fade_out { get; set; }

	public Gdk.RGBA background { get; set; default = Gdk.RGBA(); }
	public Gdk.RGBA border_color { get; set; default = Gdk.RGBA(); }
	public Gdk.RGBA bar_fg_color { get; set; default = Gdk.RGBA(); }
	public Gdk.RGBA bar_bg_color { get; set; default = Gdk.RGBA(); }

	private new double opacity = 0;
	private bool is_fade_in = true;
	private int64 prev_frame_time = 0;
	private uint prev_callback_id = 0;

	[GtkChild]
	private unowned Gtk.Image image;

	public AvizoWindow()
	{
		var screen = get_screen();
		var visual = screen.get_rgba_visual();
		if (visual != null && screen.is_composited())
		{
			set_visual(visual);
		}

		draw.connect(on_draw);
	}

	public void show_animated()
	{
		remove_tick_callback(prev_callback_id);
		is_fade_in = true;
		prev_callback_id = add_tick_callback(animation_tick);
		show();
	}

	public void hide_animated()
	{
		remove_tick_callback(prev_callback_id);
		is_fade_in = false;
		prev_callback_id = add_tick_callback(animation_tick);
	}

	private bool animation_tick(Gtk.Widget widget, Gdk.FrameClock frame_clock)
	{
		frame_clock.begin_updating();
		int64 animation_us_elapsed;
		if (prev_frame_time == 0)
		{
			animation_us_elapsed = 0;
		}
		else {

			animation_us_elapsed = (frame_clock.get_frame_time() - prev_frame_time);
		}
		prev_frame_time = frame_clock.get_frame_time();
		var animation_sec_elapsed = (double)animation_us_elapsed / 1000000;
		//var animation_sec_elapsed = (double)us_elapsed(frame_clock) / 1000000;
		//print("ms elapsed: %lld, sec elapsed: %f, fade in : %f, fade out: %f\n", animation_us_elapsed / 1000, animation_sec_elapsed, fade_in, fade_out);
		if (is_fade_in)
		{
			if (opacity >= 1)
			{
				prev_frame_time = 0;
				frame_clock.end_updating();
				return false;
			}
			opacity += animation_sec_elapsed/fade_in;
			if (opacity > 1) opacity = 1;
			print("Fade in: %f\n", opacity);
			widget.set_opacity(opacity);
		}
		else
		{
			if (opacity <= 0)
			{
				hide();
				prev_frame_time = 0;
				frame_clock.end_updating();
				return false;
			}
			opacity -= animation_sec_elapsed/fade_out;
			if (opacity < 0) opacity = 0;
			print("Fade out: %f\n", opacity);
			widget.set_opacity(opacity);
		}

		frame_clock.end_updating();
		return true; // Keep going
	}

	private bool on_draw(Gtk.Widget widget, Cairo.Context ctx)
	{
		double block_width = (_width - 2 * padding - 2 * border_width -
		                      (double) ((block_count - 1) * block_spacing)) / block_count;

		double blocks_x = padding + border_width;
		double blocks_y = _height - padding - border_width - block_height;

		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();

		ctx.set_operator(Cairo.Operator.CLEAR);
		draw_rect(ctx, 0, 0, _width, _height);

		ctx.set_operator(Cairo.Operator.SOURCE);
		Gdk.cairo_set_source_rgba(ctx, border_color);
		draw_round_rect(ctx, 0, 0, _width, _height, border_radius);

		Gdk.cairo_set_source_rgba(ctx, background);
		draw_round_rect(ctx, border_width, border_width, _width - 2 * border_width, _height - 2 * border_width, border_radius - border_width);

		Gdk.cairo_set_source_rgba(ctx, bar_bg_color);

		for (int i = 0; i < block_count; i++)
		{
			draw_rect(ctx, blocks_x + (block_width + block_spacing) * i,
			               blocks_y,
			               block_width,
			               block_height);
		}

		Gdk.cairo_set_source_rgba(ctx, bar_fg_color);

		if (block_spacing > 0)
		{
			for (int i = 0; i < (int) (block_count * progress); i++)
			{
				draw_rect(ctx, blocks_x + (block_width + block_spacing) * i,
							blocks_y,
							block_width,
							block_height);
			}
		}
		else {
			var width = block_width * block_count * progress;
			var height = block_height;
			draw_rect(ctx, blocks_x,
						blocks_y,
						width,
						height);
		}

		ctx.set_operator(Cairo.Operator.OVER);

		return false;
	}

	private void draw_rect(Cairo.Context ctx, double x, double y, double w, double h)
	{
		ctx.line_to(x, y);
		ctx.line_to(x + w, y);
		ctx.line_to(x + w, y + h);
		ctx.line_to(x, y + h);
		ctx.close_path();
		ctx.fill();
	}

	private void draw_round_rect(Cairo.Context ctx, double x, double y, double w, double h, double r)
	{
		ctx.move_to(x + r, y);
		ctx.line_to(x + w - r, y);

		ctx.arc(x + w - r, y + r, r, -Math.PI / 2, 0);

		ctx.line_to(x + w, y + h - r);

		ctx.arc(x + w - r, y + h - r, r, 0, Math.PI / 2);

		ctx.line_to(x + r, y + h);

		ctx.arc(x + r, y + h - r, r, Math.PI / 2, Math.PI);

		ctx.line_to(x, y + r);

		ctx.arc(x + r, y + r, r, Math.PI, 3 * Math.PI / 2);

		ctx.close_path();
		ctx.fill();
	}
}


[DBus (name = "org.danb.avizo.service")]
public class AvizoService : GLib.Object
{
	private static string[] props = {
		"image_path", "image_resource", "image_opacity", "progress", "width", "height", "padding",
		"border_radius", "border_width", "block_height", "block_spacing", "block_count", "fade_in", "fade_out", "background", "border_color",
		"bar_fg_color", "bar_bg_color",
	};

	public string image_path { get; set; default = ""; }
	public string image_resource { get; set; default = "volume_muted"; }
	public double image_opacity { get; set; default = 1.0; }
	public double progress { get; set; default = 0.0; }
	public int width { get; set; default = 248; }
	public int height { get; set; default = 232; }
	public int padding { get; set; default = 24; }
	public double y_offset { get; set; default = 0.75; }
	public int border_radius { get; set; default = 16; }
	public int border_width { get; set; default = 1; }
	public int block_height { get; set; default = 10; }
	public int block_spacing { get; set; default = 2; }
	public int block_count { get; set; default = 20; }
	public double fade_in { get; set; default = 0.2; }
	public double fade_out { get; set; default = 0.5; }
	public Gdk.RGBA background { get; set; default = rgba(160, 160, 160, 0.8); }
	public Gdk.RGBA border_color { get; set; default = rgba(90, 90, 90, 0.8); }
	public Gdk.RGBA bar_fg_color { get; set; default = rgba(0, 0, 0, 0.8); }
	public Gdk.RGBA bar_bg_color { get; set; default = rgba(106, 106, 106, 0.8); }

	private Array<AvizoWindow> _windows = new Array<AvizoWindow>();
	private int _open_timeouts = 0;

	public void show(double seconds) throws DBusError, IOError
	{
		var display = Gdk.Display.get_default();
		var monitors = display.get_n_monitors();

		if (_windows.length < monitors)
		{
			_windows.set_size(monitors);
		}

		for (int i = 0; i < monitors; i++)
		{
			var window = _windows.index(i);
			if (window == null)
			{
				window = create_window(display);
				_windows.insert_val(i, window);
			}
			show_window(window, display.get_monitor(i));
		}

		_open_timeouts++;
		Timeout.add((int) (seconds * 1000), () =>
		{
			_open_timeouts--;

			if (_open_timeouts == 0)
			{
				for (int i = 0; i < monitors; i++) {
					_windows.index(i).hide_animated();
				}
			}

			return false;
		});
	}

	private AvizoWindow create_window(Gdk.Display display)
	{
		var window = new AvizoWindow();

		foreach (var prop_name in props)
		{
			bind_property(prop_name, window, prop_name, BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
		}

		if (is_wayland(display))
		{
		  GtkLayerShell.init_for_window(window);
		  GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY);
		  GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, true);
		  GtkLayerShell.set_exclusive_zone(window, -1);
#if HAVE_LATEST_GTK_LAYER_SHELL
		  GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE);
#else
		  GtkLayerShell.set_keyboard_interactivity(window, false);
#endif
    }

		return window;
	}

	private void show_window(AvizoWindow window, Gdk.Monitor monitor)
	{
		var margin = (int) Math.lround((monitor.workarea.height - height) * y_offset);

		if (is_wayland(monitor.get_display()))
		{
			GtkLayerShell.set_monitor(window, monitor);
			GtkLayerShell.set_margin(window, GtkLayerShell.Edge.TOP, margin);
		}
		else
		{
			int x, _y;
			window.set_position(Gtk.WindowPosition.CENTER);
			window.get_position(out x, out _y);
			window.move(x, margin);
			window.set_type_hint(Gdk.WindowTypeHint.NOTIFICATION);
			window.set_accept_focus(false);
		}

		window.show_animated();
		window.queue_draw();
	}
}

bool is_wayland(Gdk.Display? display)
{
	return display != null && display.get_type().is_a(get_wayland_type());
}

Gdk.RGBA rgba(int red, int green, int blue, double alpha)
{
	var o = Gdk.RGBA();
	o.red = red / 255.0;
	o.green = green / 255.0;
	o.blue = blue / 255.0;
	o.alpha = alpha;
	return o;
}

void on_bus_aquired(DBusConnection conn)
{
	try
	{
		conn.register_object("/org/danb/avizo/service", new AvizoService());
	}
	catch (IOError e)
	{
		stderr.printf("Could not register service\n");
	}
}

public void main(string[] args)
{
	Gtk.init(ref args);

	Bus.own_name(BusType.SESSION, "org.danb.avizo.service", BusNameOwnerFlags.NONE,
	             on_bus_aquired,
	             () => {},
	             () => stderr.printf("Could not acquire name\n"));

	new AvizoService();

	Gtk.main();
}
