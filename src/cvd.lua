-- cvd.lua
-- Color Vision Deficiency simulation for LuaLaTeX

local M = {}

-- Brettel matrices (Brettel, Viénot & Mollon 1997)
-- Simple, fast, full dichromacy only
M.brettel_matrices = {
	protanopia = {
		{ 0.56667, 0.43333, 0.00000 },
		{ 0.55833, 0.44167, 0.00000 },
		{ 0.00000, 0.24167, 0.75833 },
	},
	deuteranopia = {
		{ 0.625, 0.375, 0.000 },
		{ 0.700, 0.300, 0.000 },
		{ 0.000, 0.300, 0.700 },
	},
	tritanopia = {
		{ 0.95, 0.05, 0.000 },
		{ 0.00, 0.43, 0.567 },
		{ 0.00, 0.48, 0.525 },
	},
}

-- Machado matrices (Machado, Oliveira & Fernandes 2009)
-- Physiologically accurate, supports severity levels 0.0-1.0
M.machado_matrices = {
	protanopia = {
		{ { 1.000000, 0.000000, 0.000000 }, { 0.000000, 1.000000, 0.000000 }, { 0.000000, 0.000000, 1.000000 } },
		{ { 0.856167, 0.182038, -0.038205 }, { 0.029342, 0.955115, 0.015544 }, { -0.002880, -0.001563, 1.004443 } },
		{ { 0.734766, 0.334872, -0.069637 }, { 0.051840, 0.919198, 0.028963 }, { -0.004928, -0.004209, 1.009137 } },
		{ { 0.630323, 0.465641, -0.095964 }, { 0.069181, 0.890046, 0.040773 }, { -0.006308, -0.007724, 1.014032 } },
		{ { 0.539009, 0.579343, -0.118352 }, { 0.082546, 0.866121, 0.051332 }, { -0.007136, -0.011959, 1.019095 } },
		{ { 0.458064, 0.679578, -0.137642 }, { 0.092785, 0.846313, 0.060902 }, { -0.007494, -0.016807, 1.024301 } },
		{ { 0.385450, 0.769005, -0.154455 }, { 0.100526, 0.829802, 0.069673 }, { -0.007442, -0.022190, 1.029632 } },
		{ { 0.319627, 0.849633, -0.169261 }, { 0.106241, 0.815969, 0.077790 }, { -0.007025, -0.028051, 1.035076 } },
		{ { 0.259411, 0.923008, -0.182420 }, { 0.110296, 0.804340, 0.085364 }, { -0.006276, -0.034346, 1.040622 } },
		{ { 0.203876, 0.990338, -0.194214 }, { 0.112975, 0.794542, 0.092483 }, { -0.005222, -0.041043, 1.046265 } },
		{ { 0.152286, 1.052583, -0.204868 }, { 0.114503, 0.786281, 0.099216 }, { -0.003882, -0.048116, 1.051998 } },
	},
	deuteranopia = {
		{ { 1.000000, 0.000000, 0.000000 }, { 0.000000, 1.000000, 0.000000 }, { 0.000000, 0.000000, 1.000000 } },
		{ { 0.866435, 0.177704, -0.044139 }, { 0.049567, 0.939063, 0.011370 }, { -0.003453, 0.007233, 0.996220 } },
		{ { 0.760729, 0.319078, -0.079807 }, { 0.090568, 0.889315, 0.020117 }, { -0.006027, 0.013325, 0.992702 } },
		{ { 0.675425, 0.433850, -0.109275 }, { 0.125303, 0.847755, 0.026942 }, { -0.007950, 0.018572, 0.989378 } },
		{ { 0.605511, 0.528560, -0.134071 }, { 0.155318, 0.812366, 0.032316 }, { -0.009376, 0.023176, 0.986200 } },
		{ { 0.547494, 0.607765, -0.155259 }, { 0.181692, 0.781742, 0.036566 }, { -0.010410, 0.027275, 0.983136 } },
		{ { 0.498864, 0.674741, -0.173604 }, { 0.205199, 0.754872, 0.039929 }, { -0.011131, 0.030969, 0.980162 } },
		{ { 0.457771, 0.731899, -0.189670 }, { 0.226409, 0.731012, 0.042579 }, { -0.011595, 0.034333, 0.977261 } },
		{ { 0.422823, 0.781057, -0.203881 }, { 0.245752, 0.709602, 0.044646 }, { -0.011843, 0.037423, 0.974421 } },
		{ { 0.392952, 0.823610, -0.216562 }, { 0.263559, 0.690210, 0.046232 }, { -0.011910, 0.040281, 0.971630 } },
		{ { 0.367322, 0.860646, -0.227968 }, { 0.280085, 0.672501, 0.047413 }, { -0.011820, 0.042940, 0.968881 } },
	},
	tritanopia = {
		{ { 1.000000, 0.000000, 0.000000 }, { 0.000000, 1.000000, 0.000000 }, { 0.000000, 0.000000, 1.000000 } },
		{ { 0.926670, 0.092514, -0.019184 }, { 0.021191, 0.964503, 0.014306 }, { 0.008437, 0.054813, 0.936750 } },
		{ { 0.895720, 0.133330, -0.029050 }, { 0.029997, 0.945400, 0.024603 }, { 0.013027, 0.104707, 0.882266 } },
		{ { 0.905871, 0.127791, -0.033662 }, { 0.026856, 0.941251, 0.031893 }, { 0.013410, 0.148296, 0.838294 } },
		{ { 0.948035, 0.089490, -0.037526 }, { 0.014364, 0.946792, 0.038844 }, { 0.010853, 0.193991, 0.795156 } },
		{ { 1.017277, 0.027029, -0.044306 }, { -0.006113, 0.958479, 0.047634 }, { 0.006379, 0.248708, 0.744913 } },
		{ { 1.104996, -0.046633, -0.058363 }, { -0.032137, 0.971635, 0.060503 }, { 0.001336, 0.317922, 0.680742 } },
		{ { 1.193214, -0.109812, -0.083402 }, { -0.058496, 0.979410, 0.079086 }, { -0.002346, 0.403492, 0.598854 } },
		{ { 1.257728, -0.139648, -0.118081 }, { -0.078003, 0.975409, 0.102594 }, { -0.003316, 0.501214, 0.502102 } },
		{ { 1.278864, -0.125333, -0.153531 }, { -0.084748, 0.957674, 0.127074 }, { -0.000989, 0.601151, 0.399838 } },
		{ { 1.255528, -0.076749, -0.178779 }, { -0.078411, 0.930809, 0.147602 }, { 0.004733, 0.691367, 0.303900 } },
	},
}

-- Current simulation state
M.current_type = nil
M.current_severity = 1.0
M.enabled = false
M.algorithm = "machado" -- "brettel" or "machado"

-- Clamp value to [0,1] range
local function clamp(value)
	if value < 0 then
		return 0
	end
	if value > 1 then
		return 1
	end
	return value
end

-- Get interpolated matrix for Machado algorithm
local function get_machado_matrix(cvd_type, severity)
	local matrices = M.machado_matrices[cvd_type]
	if not matrices then
		return nil
	end

	-- Scale severity to 0-10 range
	local scaled = severity * 10
	local fl = math.floor(scaled)
	local ce = math.ceil(scaled)

	-- Clamp to valid range
	fl = math.max(0, math.min(10, fl))
	ce = math.max(0, math.min(10, ce))

	local mat_lo = matrices[fl + 1] -- Lua arrays are 1-indexed
	local mat_hi = matrices[ce + 1]

	-- Interpolate between matrices
	local t = scaled - fl
	local result = {}
	for i = 1, 3 do
		result[i] = {}
		for j = 1, 3 do
			result[i][j] = mat_lo[i][j] + (mat_hi[i][j] - mat_lo[i][j]) * t
		end
	end

	return result
end

-- Apply CVD transformation matrix to RGB triple
function M.transform(r, g, b)
	if not M.enabled or M.current_type == nil then
		return r, g, b
	end

	local matrix

	if M.algorithm == "machado" then
		-- Machado: interpolate pre-calculated severity matrices
		matrix = get_machado_matrix(M.current_type, M.current_severity)
		if not matrix then
			texio.write_nl("CVD Warning: Unknown deficiency type '" .. tostring(M.current_type) .. "'")
			return r, g, b
		end

		-- Apply matrix transformation directly
		local r_new = matrix[1][1] * r + matrix[1][2] * g + matrix[1][3] * b
		local g_new = matrix[2][1] * r + matrix[2][2] * g + matrix[2][3] * b
		local b_new = matrix[3][1] * r + matrix[3][2] * g + matrix[3][3] * b

		return clamp(r_new), clamp(g_new), clamp(b_new)
	else
		-- Brettel: use fixed matrix and interpolate result
		matrix = M.brettel_matrices[M.current_type]
		if not matrix then
			texio.write_nl("CVD Warning: Unknown deficiency type '" .. tostring(M.current_type) .. "'")
			return r, g, b
		end

		-- Apply matrix transformation
		local r_new = matrix[1][1] * r + matrix[1][2] * g + matrix[1][3] * b
		local g_new = matrix[2][1] * r + matrix[2][2] * g + matrix[2][3] * b
		local b_new = matrix[3][1] * r + matrix[3][2] * g + matrix[3][3] * b

		-- Apply severity (interpolate between original and transformed)
		local severity = M.current_severity
		r_new = r * (1 - severity) + r_new * severity
		g_new = g * (1 - severity) + g_new * severity
		b_new = b * (1 - severity) + b_new * severity

		return clamp(r_new), clamp(g_new), clamp(b_new)
	end
end

-- Set deficiency type
function M.set_type(deficiency_type)
	local matrices = M.algorithm == "machado" and M.machado_matrices or M.brettel_matrices
	if matrices[deficiency_type] then
		M.current_type = deficiency_type
		M.enabled = true
	else
		local error_msg = string.format("Unknown CVD type '%s'. Valid types: protanopia, deuteranopia, tritanopia", deficiency_type)
		tex.error(error_msg)
	end
end

-- Set severity level (0.0 = normal, 1.0 = full simulation)
function M.set_severity(severity)
	severity = tonumber(severity)
	if severity and severity >= 0 and severity <= 1 then
		M.current_severity = severity
	else
		texio.write_nl("CVD Error: Severity must be between 0 and 1")
	end
end

-- Set algorithm (brettel or machado)
function M.set_algorithm(algorithm)
	if algorithm == "brettel" or algorithm == "machado" then
		M.algorithm = algorithm
	else
		texio.write_nl("CVD Error: Unknown algorithm '" .. algorithm .. "'")
		texio.write_nl("Available algorithms: brettel, machado")
	end
end

-- Enable simulation
function M.enable()
	M.enabled = true
end

-- Disable simulation
function M.disable()
	M.enabled = false
end

-- Apply CVD transformation to current color
function M.transform_current_color(color_str)
	-- \current@color contains PDF color operators like "1 0 0 rg 1 0 0 RG"
	-- Extract just the RGB values (first 3 numbers)
	local r, g, b = string.match(color_str, "^([%d.]+) +([%d.]+) +([%d.]+)")
	if r and g and b and M.enabled and M.current_type then
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		local r_new, g_new, b_new = M.transform(r, g, b)
		-- Replace the RGB values in the original string
		local transformed =
			string.gsub(color_str, "^[%d.]+ +[%d.]+ +[%d.]+", string.format("%.6f %.6f %.6f", r_new, g_new, b_new), 1)
		return transformed
	end
	return color_str
end

-- Transform RGB color operators in PDF page content streams
function M.process_pdf_image_content(stream)
	if not M.enabled or not M.current_type then
		return stream
	end
	
	-- Transform RGB fill colors (rg operator)
	stream = string.gsub(stream, "([%d.]+) +([%d.]+) +([%d.]+) +rg", function(r, g, b)
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		local r_new, g_new, b_new = M.transform(r, g, b)
		return string.format("%.6f %.6f %.6f rg", r_new, g_new, b_new)
	end)
	
	-- Transform RGB stroke colors (RG operator)
	stream = string.gsub(stream, "([%d.]+) +([%d.]+) +([%d.]+) +RG", function(r, g, b)
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		local r_new, g_new, b_new = M.transform(r, g, b)
		return string.format("%.6f %.6f %.6f RG", r_new, g_new, b_new)
	end)
	
	-- Transform RGB colors in scn/SCN operators (used with /DeviceRGB color space)
	stream = string.gsub(stream, "([%d.]+) +([%d.]+) +([%d.]+) +scn", function(r, g, b)
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		local r_new, g_new, b_new = M.transform(r, g, b)
		return string.format("%.6f %.6f %.6f scn", r_new, g_new, b_new)
	end)
	
	stream = string.gsub(stream, "([%d.]+) +([%d.]+) +([%d.]+) +SCN", function(r, g, b)
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		local r_new, g_new, b_new = M.transform(r, g, b)
		return string.format("%.6f %.6f %.6f SCN", r_new, g_new, b_new)
	end)
	
	return stream
end

-- Install the PDF image content hook
function M.install_pdf_image_hook()
	-- Enable PDF stream recompression (required for the callback to work)
	pdf.setrecompress(1)
	
	-- Register the callback using luatexbase for LaTeX compatibility
	luatexbase.add_to_callback("process_pdf_image_content", M.process_pdf_image_content, "cvd_pdf_transform")
end

-- Check if ImageMagick is available
M.imagemagick_available = nil
M.imagemagick_warning_shown = false

function M.check_imagemagick()
	if M.imagemagick_available ~= nil then
		return M.imagemagick_available
	end
	
	-- Check for shell escape
	local shell_escape = status.shell_escape
	if shell_escape == 0 then
		if not M.imagemagick_warning_shown then
			texio.write_nl("CVD Warning: Shell escape disabled. Raster image transformation unavailable.")
			texio.write_nl("            Compile with: lualatex --shell-escape")
			M.imagemagick_warning_shown = true
		end
		M.imagemagick_available = false
		return false
	end
	
	-- Try to run ImageMagick
	local check_cmd = "magick -version 2>&1 || convert -version 2>&1"
	local handle = io.popen(check_cmd)
	if not handle then
		M.imagemagick_available = false
		return false
	end
	
	local result = handle:read("*a")
	handle:close()
	
	M.imagemagick_available = (result and result:match("ImageMagick")) ~= nil
	
	if not M.imagemagick_available and not M.imagemagick_warning_shown then
		texio.write_nl("CVD Warning: ImageMagick not found. Raster image transformation unavailable.")
		texio.write_nl("            Install with: apt install imagemagick (or brew install imagemagick)")
		M.imagemagick_warning_shown = true
	end
	
	return M.imagemagick_available
end

-- Get the CVD transformation matrix as ImageMagick format
function M.get_imagemagick_matrix()
	if not M.enabled or not M.current_type then
		return nil
	end
	
	local matrix
	if M.algorithm == "machado" then
		matrix = get_machado_matrix(M.current_type, M.current_severity)
	else
		matrix = M.brettel_matrices[M.current_type]
	end
	
	if not matrix then
		return nil
	end
	
	-- ImageMagick color-matrix format: R1,G1,B1,R2,G2,B2,R3,G3,B3
	return string.format("%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f",
		matrix[1][1], matrix[1][2], matrix[1][3],
		matrix[2][1], matrix[2][2], matrix[2][3],
		matrix[3][1], matrix[3][2], matrix[3][3])
end

-- Transform a raster image file
function M.transform_raster_image(input_file, output_file)
	if not M.check_imagemagick() then
		return false
	end
	
	local matrix = M.get_imagemagick_matrix()
	if not matrix then
		return false
	end
	
	-- Escape filenames for shell
	local input_esc = input_file:gsub('"', '\\"')
	local output_esc = output_file:gsub('"', '\\"')
	
	-- Try magick command first (IMv7), then convert (IMv6)
	local cmd = string.format('magick "%s" -color-matrix "%s" "%s" 2>&1 || convert "%s" -color-matrix "%s" "%s" 2>&1',
		input_esc, matrix, output_esc,
		input_esc, matrix, output_esc)
	
	texio.write_nl("CVD: Transforming " .. input_file .. " -> " .. output_file)
	
	local handle = io.popen(cmd)
	if not handle then
		return false
	end
	
	local result = handle:read("*a")
	local success = handle:close()
	
	if not success and result and result ~= "" then
		texio.write_nl("CVD Warning: ImageMagick error: " .. result)
		return false
	end
	
	return true
end

-- Get the (possibly transformed) image path for includegraphics
function M.get_image_path(img_path)
	-- Check if it's a raster image that needs transformation
	local ext = img_path:match("%.([^.]+)$") or ""
	ext = ext:lower()
	
	local is_raster = (ext == "png" or ext == "jpg" or ext == "jpeg")
	
	if not (is_raster and M.enabled and M.current_type) then
		return img_path
	end
	
	-- Find the actual file with kpse
	local full_path = kpse.find_file(img_path)
	if not full_path then
		full_path = img_path
	end
	
	-- Respect -output-directory if set
	local output_dir = status.output_directory
	local base_dir = output_dir or "."
	
	-- Create cache directory if it doesn't exist
	local cache_dir = base_dir .. "/.cvd-cache"
	local cache_stat = lfs.attributes(cache_dir)
	if not cache_stat then
		-- Create output_dir first if it doesn't exist
		if output_dir and not lfs.attributes(output_dir) then
			lfs.mkdir(output_dir)
		end
		lfs.mkdir(cache_dir)
	end
	
	-- Generate transformed filename with severity in cache directory
	local base = img_path:match("([^/\\]+)$") or img_path -- extract just the filename
	local name_only = base:match("(.+)%.[^.]+$") or base  -- remove extension
	local severity_str = string.format("%.1f", M.current_severity)
	local transformed = cache_dir .. "/" .. name_only .. "-cvd-" .. M.current_type .. "-" .. severity_str .. "." .. ext
	
	-- Check if we need to transform (file doesn't exist or is older)
	local need_transform = true
	local orig_stat = lfs.attributes(full_path)
	local trans_stat = lfs.attributes(transformed)
	
	if trans_stat and orig_stat then
		need_transform = trans_stat.modification < orig_stat.modification
	end
	
	if need_transform then
		if M.transform_raster_image(full_path, transformed) then
			return transformed
		else
			return img_path
		end
	else
		return transformed
	end
end

-- Get interpolated Machado matrix formatted for ImageMagick
-- Returns a comma-separated string suitable for ImageMagick's -color-matrix
function M.get_machado_matrix_for_imagemagick(cvd_type, severity)
	local matrix = get_machado_matrix(cvd_type, severity)
	if not matrix then
		return nil
	end
	
	-- Format as comma-separated row-major order
	local parts = {}
	for i = 1, 3 do
		for j = 1, 3 do
			table.insert(parts, string.format("%.6f", matrix[i][j]))
		end
	end
	
	return table.concat(parts, ",")
end

return M
