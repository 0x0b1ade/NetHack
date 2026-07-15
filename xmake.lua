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

add_defines(
    "NOTPARMDECL",
    "DLB",
    "SYSCF",
    "SECURE",
    "TIMED_DELAY",
    "DUMPLOG",
    "CONFIG_ERROR_SECURE=FALSE",
    "SELF_RECOVER",
    "NOSTATICFN",
    "CURSES_UNICODE",
    "CURSES_GRAPHICS",
    "_DEFAULT_SOURCE",
    "_XOPEN_SOURCE=600"
)

add_forceincludes("hack.h")

if is_plat("windows") then
    add_cxflags(
        "/TC",
        "/wd4996",
        "/wd4013",
        "/wd4431"
    )
else
    add_cxflags(
        "-Wno-deprecated-declarations",
        "-Wno-implicit-function-declaration",
        "-Wno-missing-field-initializers",
        "-Wno-implicit-int"
    )
end

if is_plat("linux") then
    add_includedirs("sys/unix")
    add_ldflags("-rdynamic")
elseif is_plat("windows") or is_plat("mingw") then
    if is_plat("mingw") then
        set_toolchains("clang")
    end
    add_includedirs("sys/windows")
    add_includedirs("lib/pdcursesmod")
    add_includedirs("submodules/pdcursesmod")
    add_defines(
        "_CONSOLE",
        "WIN32CON",
        "_CRT_SECURE_NO_DEPRECATE",
        "_CRT_NONSTDC_NO_DEPRECATE",
        "HAS_STDINT_H",
        "PDC_WIDE",
        "PDC_RGB"
    )
    add_forceincludes("curses.h")
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
