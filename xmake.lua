set_project("nethack")
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

task("nhsetup")
    set_menu {
        usage = "xmake nhsetup",
        description = "Initialize submodules and generate native Makefiles",
    }
    on_run(function ()
        if is_host("windows") then
            print("Initializing submodules...")
            os.exec("git submodule update --init submodules/lua submodules/pdcursesmod")
            print("Running nhsetup.bat...")
            os.exec(path.join("sys", "windows", "nhsetup.bat"))
        elseif is_host("linux") then
            print("Running setup.sh...")
            os.exec("sh sys/unix/setup.sh sys/unix/hints/linux.500")
            print("Fetching Lua...")
            os.exec("make fetch-lua")
        end
    end)

task("nhbuild")
    set_menu {
        usage = "xmake nhbuild",
        description = "Build NetHack (tty + curses) via native toolchain",
    }
    on_run(function ()
        if is_host("windows") then
            print("Building with nmake (tty + curses)...")
            local old = os.cd("src")
            os.exec("nmake")
            os.cd(old)
        elseif is_host("linux") then
            print("Building with make...")
            os.exec("make -j$(nproc) WANT_WIN_CURSES=1 WANT_DEFAULT=curses")
        end
    end)

task("nhclean")
    set_menu {
        usage = "xmake nhclean",
        description = "Clean build artifacts via native toolchain",
    }
    on_run(function ()
        if is_host("windows") then
            local old = os.cd("src")
            os.exec("nmake clean")
            os.cd(old)
        elseif is_host("linux") then
            os.exec("make clean")
        end
    end)
