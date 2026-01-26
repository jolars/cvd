---
title: "Main"
---

::: {.callout-note}

**Source file:**
[`src/cvd.dtx`](https://github.com/jolars/cvd/blob/main/src/cvd.dtx)

:::

## Package Dependencies

Load required packages.

```latex
\RequirePackage{iftex}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
```

## Engine Check

Currently only LuaTeX is fully supported.

```latex
\sys_if_engine_luatex:F
{
  \msg_error:nn { cvd } { luatex-required }
}
\msg_new:nnn { cvd } { luatex-required }
{
  LuaTeX~required.\\
  This~package~currently~only~works~with~LuaLaTeX.\\
  pdfLaTeX~support~is~under~development.
}
```

## Color Space Enforcement

Force RGB color model for consistent transformations.

```latex
\selectcolormodel{rgb}
```

## Load Lua Module

Next, load the Lua module that implements the CVD transformations. The
`install_pdf_image_hook` function registers a callback that transforms colors in
embedded PDF pages (vector graphics only). We also load the Lua File System
module for file timestamp checking.

```latex
\directlua{lfs = require("lfs"); cvd = require("cvd"); cvd.install_pdf_image_hook()}
```

## Hook into xcolor

Use `xcolor`'s hook to transform RGB values before display. This handles text
colors, color boxes, and other `xcolor`-based content.

```latex
\cs_set:Npn \XC@bcolor
{
  \directlua
  {
    token.set_macro("current@color",~
    cvd.transform_current_color("\luaescapestring{\current@color}"),~
    "global")
  }
}
```

## User Commands

### `\cvdtype`

Set the type of color vision deficiency to simulate.

```latex
\NewDocumentCommand \cvdtype { m }
{
  \directlua { cvd.set_type("#1") }
}
```

### `\cvdseverity`

Set the severity of the simulation (0.0 to 1.0).

```latex
\NewDocumentCommand \cvdseverity { m }
  {
    \directlua { cvd.set_severity(#1) }
  }
```

### `\cvdenable`

Enable CVD simulation.

```latex
\NewDocumentCommand \cvdenable { }
{
  \directlua { cvd.enable() }
}
```

### `\cvddisable`

Disable CVD simulation.

```latex
\NewDocumentCommand \cvddisable { }
{
  \directlua { cvd.disable() }
}
```

### `\cvdincludegraphics`

Include a graphics file with CVD transformation applied to raster images.

```latex
\tl_new:N \l__cvd_imgpath_tl
\NewDocumentCommand \cvdincludegraphics { O{} m }
{
  \tl_set:Nx \l__cvd_imgpath_tl
  {
    \directlua
    { tex.sprint(cvd.get_image_path("\luaescapestring{#2}")) }
  }
  \exp_args:NV \includegraphics [#1] \l__cvd_imgpath_tl
}
```

### `\cvddefinecolor`

Define a new color by applying CVD transformation to an existing color. Usage:

```latex
\tl_new:N \l__cvd_model_tl
\tl_new:N \l__cvd_values_tl

\NewDocumentCommand \cvddefinecolor { O{} m m }
{
  % Extract the original color
  \extractcolorspecs{#2}{\l__cvd_model_tl}{\l__cvd_values_tl}

  % Apply CVD transformation with specified settings
  \keys_set:nn { cvd } { #1 }
  \cvdenable

  % Transform the RGB values directly via Lua
  \directlua{
    local~values~=~"\luaescapestring{\l__cvd_values_tl}"
    local~r,~g,~b~=~values:match("([^,]+),([^,]+),([^,]+)")
    r,~g,~b~=~tonumber(r),~tonumber(g),~tonumber(b)
    r,~g,~b~=~cvd.transform(r,~g,~b)
    token.set_macro("l__cvd_values_tl",~string.format("\csstring\%.6f,\csstring\%.6f,\csstring\%.6f",~r,~g,~b))
  }

  % Define the color with transformed values
  \use:x { \definecolor {#3} { \exp_not:V \l__cvd_model_tl } { \exp_not:V \l__cvd_values_tl } }

  \cvddisable
}
```

## Package Configuration

Define keys for package configuration using . Keys are available both as package
load-time options and via the command.

```latex
\keys_define:nn { cvd }
  {
    type          .code:n = { \cvdtype{#1} } ,
    severity      .code:n = { \cvdseverity{#1} } ,
    protanopia    .code:n = { \cvdtype{protanopia} \cvdseverity{1.0} } ,
    deuteranopia  .code:n = { \cvdtype{deuteranopia} \cvdseverity{1.0} } ,
    tritanopia    .code:n = { \cvdtype{tritanopia} \cvdseverity{1.0} } ,
    protanomaly   .code:n = { \cvdtype{protanopia} \cvdseverity{0.5} } ,
    deuteranomaly .code:n = { \cvdtype{deuteranopia} \cvdseverity{0.5} } ,
    tritanomaly   .code:n = { \cvdtype{tritanopia} \cvdseverity{0.5} } ,
    unknown       .code:n =
      { \msg_warning:nnx { cvd } { unknown-option } { \l_keys_key_str } }
  }
\msg_new:nnn { cvd } { unknown-option }
  { Unknown~option~'#1'. }
\NewDocumentCommand \cvdset { m }
{
  \keys_set:nn { cvd } { #1 }
}
\ProcessKeyOptions [ cvd ]
```
