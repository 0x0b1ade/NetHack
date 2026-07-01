-- 仅用于生成 compile_commands.json
-- Only for generating compile_commands.json

set_languages("c99")
set_warnings("allextra", "pedantic")

add_includedirs("include")
add_includedirs("sys/share")
add_includedirs("win/tty")
add_includedirs("win/curses")
add_includedirs("win/share")
add_includedirs("submodules/lua")

add_cxflags(
    "-DNOTPARMDECL",
    "-DDLB",
    "-DSYSCF",
    "-DSECURE",
    "-DTIMED_DELAY",
    "-DDUMPLOG",
    "-DCONFIG_ERROR_SECURE=FALSE",
    "-DSELF_RECOVER",
    "-DNOSTATICFN",
    "-DCURSES_UNICODE",
    "-DCURSES_GRAPHICS",
    "-D_DEFAULT_SOURCE",
    "-D_XOPEN_SOURCE=600",
    "-include hack.h",
    "-Wno-deprecated-declarations",
    "-Wno-implicit-function-declaration",
    "-Wno-missing-field-initializers",
    "-Wno-implicit-int"
)

if is_plat("linux") then
    add_includedirs("sys/unix")
    add_ldflags("-rdynamic")
elseif is_plat("windows") or is_plat("mingw") then
    -- 如果要使用 mingw，只配置 set_toolchains("mingw") 即可
    -- 仅 set_toolchains 不 set_plat 是不好的，只用于生成数据库就无所谓了
    -- 如果要使用 LLVM，则同时需要 set_plat("mingw"), set_toolchains("llvm")
    -- 不然可能索引错误
    set_plat("mingw")
    set_toolchains("llvm")
    -- set_toolchains("mingw")
    add_includedirs("sys/windows")
    add_includedirs("lib/pdcursesmod")
    add_includedirs("submodules/pdcursesmod")
    add_cxflags(
        "-D_CONSOLE",
        "-DWIN32CON",
        "-D_CRT_SECURE_NO_DEPRECATE",
        "-D_CRT_NONSTDC_NO_DEPRECATE",
        "-DHAS_STDINT_H",
        "-DPDC_WIDE",
        "-DPDC_RGB",
        "-include curses.h"
    )
end

target("nethack")
    set_kind("binary")
    add_files("src/*.c")
    add_files("win/tty/getline.c")
    add_files("win/tty/topl.c")
    add_files("win/tty/wintty.c")
    add_files("win/curses/*.c")

    if is_plat("linux") then
        add_files("sys/unix/unixmain.c")
        add_files("sys/unix/unixunix.c")
        add_files("sys/unix/unixres.c")
        add_files("sys/share/ioctl.c")
        add_files("sys/share/unixtty.c")
        add_files("win/tty/termcap.c")
        add_links("m", "dl", "uuid", "ncursesw", "tinfo")
    elseif is_plat("windows") or is_plat("mingw") then
        add_files("sys/windows/windmain.c")
        add_files("sys/windows/windsys.c")
        add_files("sys/windows/win10.c")
        add_files("sys/windows/consoletty.c")
        add_links("kernel32", "user32", "advapi32", "winmm", "bcrypt")
    end
