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
		name = "process_pdf_image_content transforms RG with newline prefix",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0 1 0 RG \n"
			local out = cvd.process_pdf_image_content(input)
			assert_not_equal(out, input, "newline-prefixed RG token was not transformed")
			assert_match(out, "RG%s*$", "transformed stream should still end in RG operator")
		end,
	},
	{
		name = "process_pdf_image_content leaves CMYK operator unchanged",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0 0 0 1 k \n"
			local out = cvd.process_pdf_image_content(input)
			assert_equal(out, input, "CMYK k operator should remain unchanged")
		end,
	},
	{
		name = "process_pdf_image_content leaves start-of-stream rgb unchanged",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "1 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			assert_equal(out, input, "start-of-stream rgb should remain unchanged with current matcher")
		end,
	},
	{
		name = "process_pdf_image_content handles tab whitespace",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0\t1\t0 RG \n"
			local out = cvd.process_pdf_image_content(input)
			assert_not_equal(out, input, "tab-separated RG token was not transformed")
			assert_match(out, "RG%s*$", "tab-whitespace case should keep RG operator")
		end,
	},
	{
		name = "process_pdf_image_content keeps malformed floats unchanged",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n1..2 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			assert_equal(out, input, "malformed float stream should remain unchanged")
		end,
	},
	{
		name = "transform_current_color only transforms first rgb triple",
		run = function()
			local cvd = load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("1 0 0 rg 0 1 0 RG")
			assert_match(out, "0 1 0 RG$", "stroke rgb triple should remain unchanged")
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

io.write(string.format("1..%d\n", #tests))

if failed > 0 then
	os.exit(1)
end
