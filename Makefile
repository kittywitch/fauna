mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
root_dir := $(shell dirname $(mkfile_path))
assets := $(root_dir)/assets

sass:
	sass $(assets)/scss/main.scss $(assets)/css/stylesheet.css
run:
	gleam run $(project_dir)
#run:
#	watchexec -rc clear -e gleam,scss -- make run-single
