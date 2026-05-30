local support = dofile("tests/lua/support.lua")

local tests = {
	{
		name = "transform_current_color transforms rgb when enabled",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("1 0 0 rg")
			support.assert_equal(out, "0.265135 0.420471 0.000000 rg", "unexpected transformed rgb value")
		end,
	},
	{
		name = "transform_current_color keeps malformed floats unchanged",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "1..2 0 0 rg"
			local out = cvd.transform_current_color(input)
			support.assert_equal(out, input, "malformed float input should not be transformed")
		end,
	},
	{
		name = "process_pdf_image_content transforms newline-prefixed rgb",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("protanopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n1 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_not_equal(out, input, "newline-prefixed rgb token was not transformed")
			support.assert_match(out, "rg%s*$", "transformed stream should still end in rg operator")
		end,
	},
	{
		name = "process_pdf_image_content preserves black formatting",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\n0 0 0 rg \n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_equal(out, input, "black rgb should preserve original number formatting")
		end,
	},
	{
		name = "process_pdf_image_content does not touch text operators",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local input = "\nBT /F1 12 Tf (rg is text) Tj ET\n"
			local out = cvd.process_pdf_image_content(input)
			support.assert_equal(out, input, "text content should remain untouched")
		end,
	},
	{
		name = "transform_current_color transforms cmyk when enabled",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("0 1 0 k")
			support.assert_equal(out, "0.256394 0.174226 0.160300 k", "unexpected transformed cmyk value")
		end,
	},
	{
		name = "transform_current_color transforms cmyk with K operator",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("1 0 0 K")
			support.assert_equal(out, "0.998143 0.074525 0.000000 K", "unexpected transformed CMYK value with uppercase K")
		end,
	},
	{
		name = "transform_current_color preserves K value in cmyk",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local out = cvd.transform_current_color("0 1 0 0.5 k")
			support.assert_match(out, "0%.256394 0%.174226 0%.160300 0.5 k$", "K value should be preserved")
		end,
	},
	{
		name = "transform_current_color transforms both fill and stroke cmyk triples",
		run = function()
			local cvd = support.load_cvd()
			cvd.set_type("deuteranopia")
			cvd.set_severity(1.0)
			cvd.enable()

			local output = cvd.transform_current_color("0 1 0 k 1 0 0 K")
			support.assert_match(output, "0%.256394 0%.174226 0%.160300 k 0%.998143 0%.074525 0%.000000 K$", "both fill and stroke CMYK triples should be transformed")
		end,
	},
}

support.run_tests(tests)
