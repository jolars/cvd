local support = dofile("tests/lua/support.lua")

local tests = {
	{
		name = "process_pdf_image_content transforms RG with newline prefix",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0 1 0 RG \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_not_equal(out, input, "newline-prefixed RG token was not transformed")
			support.assert_match(out, "RG%s*$", "transformed stream should still end in RG operator")
		end,
	},
	{
		name = "process_pdf_image_content leaves CMYK operator unchanged",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0 0 0 1 k \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_equal(out, input, "CMYK k operator should remain unchanged")
		end,
	},
	{
		name = "process_pdf_image_content leaves start-of-stream rgb unchanged",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "1 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_equal(out, input, "start-of-stream rgb should remain unchanged with current matcher")
		end,
	},
	{
		name = "process_pdf_image_content handles tab whitespace",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0\t1\t0 RG \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_not_equal(out, input, "tab-separated RG token was not transformed")
			support.assert_match(out, "RG%s*$", "tab-whitespace case should keep RG operator")
		end,
	},
	{
		name = "process_pdf_image_content keeps malformed floats unchanged",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n1..2 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_equal(out, input, "malformed float stream should remain unchanged")
		end,
	},
	{
		name = "transform_current_color only transforms first rgb triple",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("1 0 0 rg 0 1 0 RG")
			support.assert_match(out, "0 1 0 RG$", "stroke rgb triple should remain unchanged")
		end,
	},
}

support.run_tests(tests)
