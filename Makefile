.PHONY: test
test:
	bundle exec rspec

.PHONY: publish
publish:
	rake build
	rake release
	git push --tags
