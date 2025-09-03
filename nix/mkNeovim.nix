{
  lib,
  stdenv,
  pkgs,
  sqlite,
  git,
  neovim-unwrapped,
  wrapNeovimUnstable,
  neovimUtils,
}:
with lib;
  {
    appName ? "nvim",
    plugins ? [],
    extraPackages ? [],
    extraLuaPackages ? p: [],
    extraPython3Packages ? p: [],
    withPython3 ? true,
    withRuby ? false,
    withNodeJs ? false,
    withSqlite ? true,
    aliases ? [],
    autoconfigure ? false,
    wrapRc ? true,
  }: let
    isCustomAppName = appName != "nvim";

    sqliteLibPath =
      if withSqlite
      then "${sqlite.out}/lib/libsqlite3.so"
      else null;

    externalPackages = extraPackages ++ (optionals withSqlite [sqlite]);

    immutableconf = ./nvim;

    initLua = ''
      if vim.env.PROF then
        require("snacks.profiler").startup({
          startup = {
            event = "VimEnter", -- stop profiler on this event
            -- event = "UIEnter",
          },
        })
      end

      function cleanupRuntime()
        local vimPackDir = 'vim[-]pack[-]dir'
        local neovimRuntime = 'neovim[-]unwrapped'
        local packpath = vim.opt.packpath:get()
        local rtp = vim.opt.rtp:get()
        vim.opt.packpath = {}
        vim.opt.rtp = {}
        for _, v in pairs(packpath) do
          if string.match(v, vimPackDir) or string.match(v, neovimRuntime) then
            vim.opt.packpath:append(v)
          end
        end
        for _, v in pairs(rtp) do
          if string.match(v, vimPackDir) or string.match(v, neovimRuntime) then
            vim.opt.rtp:append(v)
          end
        end
      end
      cleanupRuntime()

      local home = os.getenv("HOME")
      local local_config = home .. "/.config/nvim"
      local immutable_config = "${immutableconf}"

      local function is_nonempty_dir(path)
        return vim.fn.isdirectory(path) == 1 and next(vim.fn.globpath(path, "*", false, true)) ~= nil
      end

      local function has_init_lua(path)
        local init_lua = path .. "/init.lua"
        return vim.fn.filereadable(init_lua) == 1
      end

      -- Check if local config exists and has init.lua
      if is_nonempty_dir(local_config) and has_init_lua(local_config) then
        -- Use local configuration
        vim.opt.rtp:prepend(local_config)
        vim.opt.rtp:append(local_config .. "/after")

        local init_lua = local_config .. "/init.lua"

        if vim.fn.filereadable(init_lua) == 1 then
          dofile(init_lua)
        end
      else
        -- Fall back to immutable configuration
        vim.opt.rtp:prepend(immutable_config)
        vim.opt.rtp:append(immutable_config .. "/after")

        local init_file = immutable_config .. "/init.lua"
        if vim.fn.filereadable(init_file) == 1 then
          dofile(init_file)
        end
      end
    '';

    neovimConfig = neovimUtils.makeNeovimConfig {
      inherit extraPython3Packages withPython3 withRuby withNodeJs plugins;
    };

    extraMakeWrapperArgs = builtins.concatStringsSep " " (
      optional isCustomAppName ''--set NVIM_APPNAME "${appName}"''
      ++ optional (externalPackages != [])
      ''--prefix PATH : "${makeBinPath externalPackages}"''
      ++ optional withSqlite
      ''--set LIBSQLITE_CLIB_PATH "${sqliteLibPath}"''
      ++ optional withSqlite
      ''--set LIBSQLITE "${sqliteLibPath}"''
    );

    luaPackages = neovim-unwrapped.lua.pkgs;
    resolvedExtraLuaPackages = extraLuaPackages luaPackages;

    # Native Lua libraries
    extraMakeWrapperLuaCArgs =
      optionalString (resolvedExtraLuaPackages != [])
      ''--suffix LUA_CPATH ";" "${concatMapStringsSep ";" luaPackages.getLuaCPath resolvedExtraLuaPackages}"'';

    # Lua libraries
    extraMakeWrapperLuaArgs =
      optionalString (resolvedExtraLuaPackages != [])
      ''--suffix LUA_PATH ";" "${concatMapStringsSep ";" luaPackages.getLuaPath resolvedExtraLuaPackages}"'';

    neovim-wrapped = wrapNeovimUnstable neovim-unwrapped (neovimConfig
      // {
        luaRcContent = initLua;
        wrapperArgs =
          escapeShellArgs neovimConfig.wrapperArgs
          + " "
          + extraMakeWrapperArgs
          + " "
          + extraMakeWrapperLuaCArgs
          + " "
          + extraMakeWrapperLuaArgs;
        wrapRc = wrapRc;
      });
  in
    neovim-wrapped.overrideAttrs (oa: {
      buildPhase =
        oa.buildPhase
        + optionalString isCustomAppName ''
          mv $out/bin/nvim $out/bin/${lib.escapeShellArg appName}
        '';
      meta.mainProgram =
        if isCustomAppName
        then appName
        else oa.meta.mainProgram;
      nativeBuildInputs = oa.nativeBuildInputs or [];
    })
