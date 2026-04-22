local function install_tex_stubs()
	_G.texio = {
		write_nl = function()
			return nil
		end,
	}

	_G.tex = {
		error = function(message)
			error(message, 0)
		end,
	}

	_G.status = { shell_escape = 0 }
	_G.luatexbase = {
		add_to_callback = function()
			return nil
		end,
	}
	_G.pdf = {
		setrecompress = function()
			return nil
		end,
	}
	_G.token = {
		set_macro = function()
			return nil
		end,
	}
end

local function load_cvd()
	install_tex_stubs()
	return dofile("src/cvd.lua")
end

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assert_equal failed") .. string.format("\nexpected: %q\nactual:   %q", expected, actual), 0)
	end
end

local function assert_match(value, pattern, message)
	if not string.match(value, pattern) then
		error((message or "assert_match failed") .. string.format("\npattern: %q\nvalue:   %q", pattern, value), 0)
	end
end

local function assert_not_equal(actual, unexpected, message)
	if actual == unexpected then
		error((message or "assert_not_equal failed") .. string.format("\nvalue: %q", actual), 0)
	end
end

local tests = {
	{
		name = "transform_current_color transforms rgb when enabled",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("1 0 0 rg")
			assert_equal(out, "0.265135 0.420471 0.000000 rg", "unexpected transformed rgb value")
		end,
	},
	{
		name = "transform_current_color keeps malformed floats unchanged",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "1..2 0 0 rg"
			local out = cvd.transform_current_color(input)
			assert_equal(out, input, "malformed float input should not be transformed")
		end,
	},
	{
		name = "process_pdf_image_content transforms newline-prefixed rgb",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n1 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			assert_not_equal(out, input, "newline-prefixed rgb token was not transformed")
			assert_match(out, "rg%s*$", "transformed stream should still end in rg operator")
		end,
	},
	{
		name = "process_pdf_image_content preserves black formatting",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			assert_equal(out, input, "black rgb should preserve original number formatting")
		end,
	},
	{
		name = "process_pdf_image_content does not touch text operators",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\nBT /F1 12 Tf (rg is text) Tj ET\n"
			local out = cvd.process_pdf_image_content(input)
			assert_equal(out, input, "text content should remain untouched")
		end,
	},
}

local failed = 0
for i, test in ipairs(tests) do
	local ok, err = pcall(test.run)
	if ok then
		io.write(string.format("ok %d - %s\n", i, test.name))
	else
		failed = failed + 1
		io.write(string.format("not ok %d - %s\n%s\n", i, test.name, err))
	end
end

if failed == 0 then
	io.write(string.format("1..%d\n", #tests))
	return
end

io.write(string.format("1..%d\n", #tests))
os.exit(1)
