-- cvd.lua
-- Color Vision Deficiency simulation for LuaLaTeX

local M = {}

-- Machado matrices (Machado, Oliveira & Fernandes 2009)
-- Physiologically accurate, supports severity levels 0.0-1.0
M.machado_matrices_rgb = {
	protanopia = {
		{ { 1.000000, -0.000000, 0.000000 }, { -0.000000, 1.000000, 0.000000 }, { 0.000000, -0.000000, 1.000000 } },
		{ { 0.911599, 0.056681, 0.031720 }, { 0.020794, 0.986365, -0.007159 }, { -0.000861, 0.000744, 1.000117 } },
		{ { 0.823455, 0.113194, 0.063350 }, { 0.041477, 0.972802, -0.014279 }, { -0.001717, 0.001485, 1.000232 } },
		{ { 0.735568, 0.169541, 0.094890 }, { 0.062049, 0.959311, -0.021360 }, { -0.002567, 0.002221, 1.000346 } },
		{ { 0.647935, 0.225723, 0.126341 }, { 0.082510, 0.945892, -0.028403 }, { -0.003411, 0.002954, 1.000457 } },
		{ { 0.560556, 0.281741, 0.157704 }, { 0.102862, 0.932544, -0.035406 }, { -0.004250, 0.003683, 1.000567 } },
		{ { 0.473427, 0.337595, 0.188978 }, { 0.123105, 0.919267, -0.042372 }, { -0.005083, 0.004408, 1.000675 } },
		{ { 0.386549, 0.393287, 0.220164 }, { 0.143240, 0.906060, -0.049299 }, { -0.005911, 0.005129, 1.000782 } },
		{ { 0.299919, 0.448817, 0.251264 }, { 0.163267, 0.892922, -0.056189 }, { -0.006733, 0.005847, 1.000886 } },
		{ { 0.213537, 0.504187, 0.282277 }, { 0.183186, 0.879855, -0.063041 }, { -0.007550, 0.006561, 1.000989 } },
		{ { 0.127399, 0.559397, 0.313203 }, { 0.203000, 0.866856, -0.069856 }, { -0.008362, 0.007272, 1.001090 } },
	},
	deuteranopia = {
		{ { 1.000000, -0.000000, 0.000000 }, { -0.000000, 1.000000, 0.000000 }, { 0.000000, -0.000000, 1.000000 } },
		{ { 0.924223, 0.049660, 0.026117 }, { 0.043016, 0.972174, -0.015189 }, { -0.002848, 0.001797, 1.001051 } },
		{ { 0.848967, 0.098982, 0.052051 }, { 0.085811, 0.944490, -0.030301 }, { -0.005678, 0.003582, 1.002096 } },
		{ { 0.774227, 0.147968, 0.077805 }, { 0.128388, 0.916948, -0.045336 }, { -0.008490, 0.005356, 1.003134 } },
		{ { 0.699999, 0.196622, 0.103379 }, { 0.170749, 0.889547, -0.060296 }, { -0.011284, 0.007117, 1.004167 } },
		{ { 0.626278, 0.244947, 0.128775 }, { 0.212895, 0.862285, -0.075180 }, { -0.014060, 0.008867, 1.005193 } },
		{ { 0.553060, 0.292945, 0.153995 }, { 0.254829, 0.835161, -0.089990 }, { -0.016818, 0.010605, 1.006212 } },
		{ { 0.480341, 0.340619, 0.179040 }, { 0.296551, 0.808174, -0.104725 }, { -0.019558, 0.012332, 1.007226 } },
		{ { 0.408117, 0.387971, 0.203912 }, { 0.338065, 0.781323, -0.119388 }, { -0.022281, 0.014048, 1.008233 } },
		{ { 0.336383, 0.435006, 0.228612 }, { 0.379371, 0.754606, -0.133977 }, { -0.024987, 0.015752, 1.009235 } },
		{ { 0.265135, 0.481724, 0.253141 }, { 0.420471, 0.728023, -0.148494 }, { -0.027676, 0.017445, 1.010231 } },
	},
}
M.machado_matrices_cmy = {
	protanopia = {
		{ { 1.000000, 0.000000, -0.000000 }, { -0.000000, 1.000000, -0.000000 }, { 0.000000, 0.000000, 1.000000 } },
		{ { 0.916672, 0.213620, -0.130292 }, { 0.475033, 0.109426, 0.415541 }, { -0.129617, 0.234059, 0.895558 } },
		{ { 0.951325, 0.204963, -0.156287 }, { 0.460442, 0.160070, 0.379488 }, { -0.127041, 0.212999, 0.914042 } },
		{ { 0.983548, 0.205664, -0.189212 }, { 0.465349, 0.174996, 0.359654 }, { -0.130106, 0.201158, 0.928948 } },
		{ { 1.017021, 0.209303, -0.226325 }, { 0.475408, 0.181963, 0.342629 }, { -0.134994, 0.190973, 0.944022 } },
		{ { 1.052674, 0.214865, -0.267539 }, { 0.488104, 0.186067, 0.325829 }, { -0.141104, 0.181001, 0.960103 } },
		{ { 1.091077, 0.222182, -0.313259 }, { 0.502724, 0.188997, 0.308279 }, { -0.148337, 0.170711, 0.977626 } },
		{ { 1.132762, 0.231361, -0.364123 }, { 0.519076, 0.191520, 0.289404 }, { -0.156760, 0.159808, 0.996952 } },
		{ { 1.178322, 0.242658, -0.420980 }, { 0.537181, 0.194078, 0.268741 }, { -0.166523, 0.148059, 1.018464 } },
		{ { 1.228467, 0.256448, -0.484915 }, { 0.557184, 0.196996, 0.245819 }, { -0.177852, 0.135244, 1.042609 } },
		{ { 1.284075, 0.273240, -0.557316 }, { 0.579334, 0.200561, 0.220105 }, { -0.191050, 0.121113, 1.069937 } },
	},
	deuteranopia = {
		{ { 1.000000, 0.000000, -0.000000 }, { -0.000000, 1.000000, -0.000000 }, { 0.000000, 0.000000, 1.000000 } },
		{ { 0.880169, 0.204117, -0.084286 }, { 0.440304, 0.144221, 0.415475 }, { -0.119691, 0.235566, 0.884125 } },
		{ { 0.870938, 0.196801, -0.067739 }, { 0.415775, 0.180892, 0.403333 }, { -0.113607, 0.229506, 0.884101 } },
		{ { 0.859162, 0.195164, -0.054325 }, { 0.403793, 0.193793, 0.402414 }, { -0.110938, 0.229779, 0.881159 } },
		{ { 0.847065, 0.194895, -0.041960 }, { 0.394885, 0.201090, 0.404025 }, { -0.109117, 0.231471, 0.877646 } },
		{ { 0.835053, 0.195183, -0.030236 }, { 0.387271, 0.206187, 0.406542 }, { -0.107661, 0.233666, 0.873995 } },
		{ { 0.823247, 0.195762, -0.019008 }, { 0.380367, 0.210189, 0.409444 }, { -0.106410, 0.236068, 0.870342 } },
		{ { 0.811689, 0.196517, -0.008206 }, { 0.373927, 0.213562, 0.412512 }, { -0.105296, 0.238554, 0.866741 } },
		{ { 0.800394, 0.197391, 0.002215 }, { 0.367822, 0.216535, 0.415642 }, { -0.104282, 0.241067, 0.863215 } },
		{ { 0.789366, 0.198349, 0.012285 }, { 0.361982, 0.219238, 0.418780 }, { -0.103348, 0.243573, 0.859775 } },
		{ { 0.778601, 0.199372, 0.022027 }, { 0.356362, 0.221745, 0.421893 }, { -0.102482, 0.246057, 0.856425 } },
	},
}

-- Current simulation state
M.current_type = nil
M.current_severity = 1.0
M.enabled = false
M.graphics_hook_enabled = true -- Hook into PDF graphics by default
M.graphics_convert_enabled = false -- Don't auto-convert raster graphics by default

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
local function get_machado_matrix(color_model, cvd_type, severity)
	local matrices = nil
	if color_model == "rgb" then
		matrices = M.machado_matrices_rgb[cvd_type]
	elseif color_model == "cmy" then
		matrices = M.machado_matrices_cmy[cvd_type]
	end
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

-- Apply CVD transformation matrix to RGB or CMY triple
function M.transform(color_model, c1, c2, c3)
	if not M.enabled or M.current_type == nil then
		return c1, c2, c3
	end

	-- Get interpolated Machado matrix
	local matrix = get_machado_matrix(color_model, M.current_type, M.current_severity)
	if not matrix then
		texio.write_nl("CVD Warning: Unknown deficiency type '" .. tostring(M.current_type) .. "'")
		return c1, c2, c3
	end

	-- Apply matrix transformation
	local c1_new = matrix[1][1] * c1 + matrix[1][2] * c2 + matrix[1][3] * c3
	local c2_new = matrix[2][1] * c1 + matrix[2][2] * c2 + matrix[2][3] * c3
	local c3_new = matrix[3][1] * c1 + matrix[3][2] * c2 + matrix[3][3] * c3

	return clamp(c1_new), clamp(c2_new), clamp(c3_new)
end

-- Set deficiency type
function M.set_type(deficiency_type)
	if M.machado_matrices_rgb[deficiency_type] then
		M.current_type = deficiency_type
		M.enabled = true
	else
		local error_msg = string.format("Unknown CVD type '%s'. Valid types: protanopia, deuteranopia", deficiency_type)
		tex.error(error_msg)
	end
end

-- Set severity level (0.0 = normal, 1.0 = full simulation)
function M.set_severity(severity)
	severity = tonumber(severity)
	if severity and severity >= 0 and severity <= 1 then
		M.current_severity = severity
	else
		tex.error(string.format("Invalid severity '%s'. Must be between 0.0 and 1.0", tostring(severity)))
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

-- Enable graphics hook (PDF transformation via callback)
function M.enable_graphics_hook()
	M.graphics_hook_enabled = true
end

-- Disable graphics hook (PDF transformation via callback)
function M.disable_graphics_hook()
	M.graphics_hook_enabled = false
end

-- Enable graphics convert (raster image external conversion)
function M.enable_graphics_convert()
	M.graphics_convert_enabled = true
end

-- Disable graphics convert (raster image external conversion)
function M.disable_graphics_convert()
	M.graphics_convert_enabled = false
end

-- Apply CVD transformation to current color
function M.transform_current_color(color_str)
	-- \current@color contains PDF color operators like
	-- "1 0 0 rg 1 0 0 RG" in RGB or "1 0 0 0 k 1 0 0 0 K" in CMYK
	-- Extract just the color model ("rgb" or "cmy") and the corresponding
	-- channel values R G B or C M Y (denoted c1, c2, c3)
	local color_model = string.match(color_str, "rg") or string.match(color_str, "k")
	if color_model == "rg" then
		color_model = "rgb"
	elseif color_model == "k" then
		color_model = "cmy"
	end

	local c1, c2, c3 = string.match(color_str, "^([%d.]+) +([%d.]+) +([%d.]+)")
	if c1 and c2 and c3 and M.enabled and M.current_type then
		c1, c2, c3 = tonumber(c1), tonumber(c2), tonumber(c3)
		local c1_new, c2_new, c3_new = M.transform(color_model, c1, c2, c3)
		-- Replace the color (RGB or CMY) values in the original string
		local transformed = string.gsub(
			color_str,
			"^[%d.]+ +[%d.]+ +[%d.]+",
			string.format("%.6f %.6f %.6f", c1_new, c2_new, c3_new),
			1
		)
		return transformed
	end
	return color_str
end

-- Transform RGB color operators in PDF page content streams
-- NOTE: This function modifies the uncompressed PDF stream content. Due to limitations
-- in LuaTeX's process_pdf_image_content callback, the stream length may not always be
-- correctly updated, which can cause truncation if the stream grows significantly.
-- To mitigate this, we:
-- 1. Preserve original number format when colors don't change
-- 2. Use minimal precision (4 decimal places) and strip trailing zeros
-- 3. Warn if stream grows by more than 100 bytes
-- For PDFs with many color transformations, consider using \cvdincludegraphics with
-- raster image formats (PNG/JPG) instead, which are processed externally.
function M.process_pdf_image_content(stream)
	if not M.enabled or not M.current_type or not M.graphics_hook_enabled then
		return stream
	end

	local original_length = #stream

	-- Helper function to format numbers with minimal digits
	local function format_short(v)
		local s = string.format("%.4f", v)
		s = s:gsub("0+$", ""):gsub("%.$", "")
		return s
	end

	-- Transform RGB fill colors (rg operator)
	-- Match at line start, require non-letter after operator to avoid matching 'rg' in words
	stream = string.gsub(stream, "\n([%d.]+)%s+([%d.]+)%s+([%d.]+)%s+rg([^a-zA-Z])", function(r, g, b, term)
		local r_str, g_str, b_str = r, g, b
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		if r and g and b and r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then
			local r_new, g_new, b_new = M.transform(r, g, b)
			-- Keep original format if values haven't changed significantly
			if math.abs(r_new - r) < 0.000001 and math.abs(g_new - g) < 0.000001 and math.abs(b_new - b) < 0.000001 then
				return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " rg" .. term
			end
			-- Use shortest possible format: strip trailing zeros and decimal point if integer
			return string.format("\n%s %s %s rg%s", format_short(r_new), format_short(g_new), format_short(b_new), term)
		end
		return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " rg" .. term
	end)

	-- Transform RGB stroke colors (RG operator)
	stream = string.gsub(stream, "\n([%d.]+)%s+([%d.]+)%s+([%d.]+)%s+RG([^a-zA-Z])", function(r, g, b, term)
		local r_str, g_str, b_str = r, g, b
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		if r and g and b and r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then
			local r_new, g_new, b_new = M.transform(r, g, b)
			if math.abs(r_new - r) < 0.000001 and math.abs(g_new - g) < 0.000001 and math.abs(b_new - b) < 0.000001 then
				return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " RG" .. term
			end
			return string.format("\n%s %s %s RG%s", format_short(r_new), format_short(g_new), format_short(b_new), term)
		end
		return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " RG" .. term
	end)

	-- Transform RGB colors in scn/SCN operators (used with /DeviceRGB color space)
	stream = string.gsub(stream, "\n([%d.]+)%s+([%d.]+)%s+([%d.]+)%s+scn([^a-zA-Z])", function(r, g, b, term)
		local r_str, g_str, b_str = r, g, b
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		if r and g and b and r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then
			local r_new, g_new, b_new = M.transform(r, g, b)
			if math.abs(r_new - r) < 0.000001 and math.abs(g_new - g) < 0.000001 and math.abs(b_new - b) < 0.000001 then
				return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " scn" .. term
			end
			return string.format(
				"\n%s %s %s scn%s",
				format_short(r_new),
				format_short(g_new),
				format_short(b_new),
				term
			)
		end
		return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " scn" .. term
	end)

	stream = string.gsub(stream, "\n([%d.]+)%s+([%d.]+)%s+([%d.]+)%s+SCN([^a-zA-Z])", function(r, g, b, term)
		local r_str, g_str, b_str = r, g, b
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		if r and g and b and r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then
			local r_new, g_new, b_new = M.transform(r, g, b)
			if math.abs(r_new - r) < 0.000001 and math.abs(g_new - g) < 0.000001 and math.abs(b_new - b) < 0.000001 then
				return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " SCN" .. term
			end
			return string.format(
				"\n%s %s %s SCN%s",
				format_short(r_new),
				format_short(g_new),
				format_short(b_new),
				term
			)
		end
		return "\n" .. r_str .. " " .. g_str .. " " .. b_str .. " SCN" .. term
	end)

	local new_length = #stream
	local growth = new_length - original_length

	-- Warn if stream grew significantly (may cause issues with some PDF readers)
	if growth > 100 then
		texio.write_nl(
			string.format(
				"CVD Warning: PDF stream grew by %d bytes. This may cause rendering issues in some viewers.",
				growth
			)
		)
	end

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

	local matrix = get_machado_matrix("rgb", M.current_type, M.current_severity)
	if not matrix then
		return nil
	end

	-- ImageMagick color-matrix format: R1,G1,B1,R2,G2,B2,R3,G3,B3
	return string.format(
		"%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f",
		matrix[1][1],
		matrix[1][2],
		matrix[1][3],
		matrix[2][1],
		matrix[2][2],
		matrix[2][3],
		matrix[3][1],
		matrix[3][2],
		matrix[3][3]
	)
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
	local cmd = string.format(
		'magick "%s" -color-matrix "%s" "%s" 2>&1 || convert "%s" -color-matrix "%s" "%s" 2>&1',
		input_esc,
		matrix,
		output_esc,
		input_esc,
		matrix,
		output_esc
	)

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
	local name_only = base:match("(.+)%.[^.]+$") or base -- remove extension
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
	local matrix = get_machado_matrix("rgb", cvd_type, severity)
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
