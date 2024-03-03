#!/usr/bin/env just --justfile

set dotenv-load

project_dir := absolute_path("src")
packages_dir := absolute_path("Packages")
test_project := "test.project.json"

tmpdir := `mktemp -d`
global_defs_path := tmpdir / "globalTypes.d.lua"
sourcemap_path := tmpdir / "sourcemap.json"

default:
  @just --list

build:
	rojo build packages.project.json -o MatterReplication.rbxm

build-example:
	rojo build example/default.project.json -o MatterReplicationExample.rbxl

lint:
	selene {{ project_dir }}
	stylua --check {{ project_dir }}

wally-install:
	wally install
	rojo sourcemap {{ test_project }} -o {{ sourcemap_path }}
	wally-package-types --sourcemap {{ sourcemap_path }} {{ packages_dir }}

init:
	foreman install
	just wally-install

analyze:
	curl -s -o {{ global_defs_path }} \
		-O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

	rojo sourcemap {{ test_project }} -o {{ sourcemap_path }}

	luau-lsp analyze --sourcemap={{ sourcemap_path }} \
		--defs={{ global_defs_path }} \
		--settings="./.vscode/settings.json" \
		--ignore=**/_Index/** \
		{{ project_dir }}

