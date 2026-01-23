-- convert-filter.lua
-- External filter for transforming raster images using ImageMagick

local M = {}

-- CVD color transformation matrices
local function get_matrix(cvd_type, severity)
    -- Simplified for demo - use full Machado matrices in production
    local matrices = {
        protanopia = {
            {0.152286, 0.114503, -0.003882},
            {0.114503, 0.786281, -0.048116},
            {-0.003882, -0.048116, 1.051998}
        },
        deuteranopia = {
            {0.367322, 0.860646, -0.227968},
            {0.280085, 0.672501, 0.047413},
            {-0.011820, 0.042940, 0.968881}
        }
    }
    return matrices[cvd_type]
end

-- Generate ImageMagick color matrix string
function M.generate_color_matrix(cvd_type, severity)
    local matrix = get_matrix(cvd_type, severity)
    if not matrix then return nil end
    
    -- ImageMagick format: -color-matrix "R1 G1 B1 R2 G2 B2 R3 G3 B3"
    return string.format("%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f",
        matrix[1][1], matrix[1][2], matrix[1][3],
        matrix[2][1], matrix[2][2], matrix[2][3],
        matrix[3][1], matrix[3][2], matrix[3][3])
end

-- Check if ImageMagick is available
function M.check_imagemagick()
    local handle = io.popen("convert -version 2>&1")
    local result = handle:read("*a")
    handle:close()
    return result:match("ImageMagick") ~= nil
end

-- Transform an image file
function M.transform_image(input, output, cvd_type, severity)
    if not M.check_imagemagick() then
        texio.write_nl("Warning: ImageMagick not found, skipping image transformation")
        return false
    end
    
    local matrix_str = M.generate_color_matrix(cvd_type, severity)
    if not matrix_str then
        texio.write_nl("Warning: Unknown CVD type: " .. tostring(cvd_type))
        return false
    end
    
    -- Build ImageMagick command
    local cmd = string.format(
        'convert "%s" -color-matrix "%s" "%s"',
        input, matrix_str, output
    )
    
    texio.write_nl("CVD: Transforming " .. input .. " -> " .. output)
    
    local result = os.execute(cmd)
    return result == 0 or result == true
end

return M
