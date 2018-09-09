# -*- mode: makefile -*-
#
# The files implements the release pipeline interface
# It defines a target for each task executed during the release pipeline
#

BUILD_IMAGE=mikanolab/release-gradle:latest

#This wraps the execution of yarn task into docker for local emulation of ci context
exec = docker run --rm -it -v ${PWD}:/data/release/pipelines $(BUILD_IMAGE)

ifeq ($(CI),true)
	exec =
endif

.DEFAULT_GOAL := list-tasks

tasks.list:	##@ List available tasks on this project
	@grep -E '^[a-zA-Z\.\-]+:.*?##@ .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



#target naming structure. object_noun.verbe_applied
#examples:
# unit.test: unit is name of the object, test is the verb applied on object unit
# release.fingerprint: release is the object, fingerprint is the verb


#installing all dependencies and compiling project
code-compile: ##@ compile and install dependencies
	$(exec) gradlew assemble

#checkstyles analysis
code-lint: ##@ static analysis for code style violations
	$(exec) gradlew check

#unit testing
test-unit: ##@ run unit test suite against source
	$(exec) gradlew test

release-tag: ##@ create a versionned release package
	$(exec) tar -czvf $(package_name).tar.gz src vars resources doc

doc.update: ##@ update documentation
	doc/aggregate-doc.sh || true
	@echo "<sup> `date --utc`: `git show HEAD | head -n1 | sed -e 's/commit //g'` ($(context) - desktop) </sup>" >> doc/jarvis-api.md

doc.publish: ##@ publish updated documentation
	git add doc/jarvis-api.md
	git commit -am 'update docucmentation'
	git push origin HEAD:master
