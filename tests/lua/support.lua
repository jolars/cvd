local M = {}

function M.install_tex_stubs()
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

function M.load_cvd()
	M.install_tex_stubs()
	return dofile("src/cvd.lua")
end

function M.assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assert_equal failed") .. string.format("\nexpected: %q\nactual:   %q", expected, actual), 0)
	end
end

function M.assert_match(value, pattern, message)
	if not string.match(value, pattern) then
		error((message or "assert_match failed") .. string.format("\npattern: %q\nvalue:   %q", pattern, value), 0)
	end
end

function M.assert_not_equal(actual, unexpected, message)
	if actual == unexpected then
		error((message or "assert_not_equal failed") .. string.format("\nvalue: %q", actual), 0)
	end
end

function M.assert_not_match(value, pattern, message)
	if string.match(value, pattern) then
		error((message or "assert_not_match failed") .. string.format("\npattern: %q\nvalue:   %q", pattern, value), 0)
	end
end

function M.assert_unchanged(input, output, message)
	M.assert_equal(output, input, message or "value should be unchanged")
end

function M.assert_changed(input, output, message)
	M.assert_not_equal(output, input, message or "value should be changed")
end

function M.with_cvd(options, callback)
	local cvd = M.load_cvd()

	if options.type then
		cvd.set_type(options.type)
	end

	if options.severity ~= nil then
		cvd.set_severity(options.severity)
	end

	if options.enabled == false then
		cvd.disable()
	else
		cvd.enable()
	end

	return callback(cvd)
end

function M.make_case_tests(cases, runner)
	local tests = {}
	for _, case in ipairs(cases) do
		tests[#tests + 1] = {
			name = case.name,
			run = function()
				runner(case)
			end,
		}
	end

	return tests
end

function M.run_tests(tests)
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
end

return M
