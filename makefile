VERSION=$(shell grep -E '"version":.*?[^\\]",' package.json | sed 's/[^0-9\.]//g')

DEV_ANALYTICS=$(shell grep -E '"dev_analytics":.*?[^\\]",' package.json | sed 's/.*:[^\s][^.*]//g' | sed s/\",//g)
PROD_ANALYTICS=$(shell grep -E '"prod_analytics":.*?[^\\]",' package.json | sed 's/.*:[^\s][^.*]//g' | sed s/\",//g)

ERROR_TRACKING=$(shell grep -E '"error_tracking":.*?[^\\]",' package.json | sed 's/.*:[^\s][^.*]//g' | sed s/\",//g)

DEV_SITE_HOST=$(shell grep -E '"dev_site_host":.*?[^\\]",' package.json | sed 's/.*: [^.*]//g' | sed s/\",//g)
PROD_SITE_HOST=$(shell grep -E '"prod_site_host":.*?[^\\]"' package.json | sed 's/.*:[^\s][^.*]//g' | sed s/\",//g)

DEV_API_HOST=$(shell grep -E '"dev_api_host":.*?[^\\]",' package.json | sed 's/.*: [^.*]//g' | sed s/\",//g)
PROD_API_HOST=$(shell grep -E '"prod_api_host":.*?[^\\]"' package.json | sed 's/.*:[^\s][^.*]//g' | sed s/\"//g)

build:
	rm -fr build
	mkdir -p build
	coffee -c --map extension/scripts/
	cp -r extension/* build
	cake concat:templates
	cp node_modules/chrome-bootstrap/chrome-bootstrap.css build/styles/
	cp node_modules/backbone/backbone.js build/scripts/frameworks/
	cp node_modules/underscore/underscore.js build/scripts/frameworks/
	cp node_modules/mustache/mustache.js build/scripts/frameworks/
	cp node_modules/moment/moment.js build/scripts/frameworks/
	cake build:assets:dev
	sed -i '' 's/\$$VERSION\$$/${VERSION}/g' build/manifest.json
	sed -i '' 's/\$$LABEL\$$/ DEV/g' build/manifest.json
	sed -i '' 's/\$$ANALYTICS_ID\$$/${DEV_ANALYTICS}/g' build/scripts/frameworks/analytics.js
	sed -i '' 's/\$$ERROR_TRACKER_ID\$$/${ERROR_TRACKING}/g' build/scripts/trackers/error_tracker.js
	sed -i '' 's/\$$VERSION\$$/${VERSION}/g' build/scripts/trackers/error_tracker.js
	sed -i '' 's/\$$ENVIRONMENT\$$/development/g' build/scripts/trackers/error_tracker.js
	sed -i '' 's/\$$HOST\$$/${DEV_API_HOST}/g' build/scripts/persistence/share.js
	sed -i '' 's/\$$HOST\$$/${DEV_SITE_HOST}/g' build/scripts/views/tag_view.js

release: build
	coffee -c build/scripts/
	cp extension/scripts/frameworks/analytics.js build/scripts/frameworks/
	cp extension/manifest.json build/manifest.json
	sed -i '' 's/\$$VERSION\$$/${VERSION}/g' build/manifest.json
	sed -i '' 's/\$$LABEL\$$//g' build/manifest.json
	sed -i '' 's/\$$ANALYTICS_ID\$$/${PROD_ANALYTICS}/g' build/scripts/frameworks/analytics.js
	sed -i '' 's/\$$ERROR_TRACKER_ID\$$/${ERROR_TRACKING}/g' build/scripts/trackers/error_tracker.js
	sed -i '' 's/\$$VERSION\$$/${VERSION}/g' build/scripts/trackers/error_tracker.js
	sed -i '' 's/\$$ENVIRONMENT\$$/production/g' build/scripts/trackers/error_tracker.js
	sed -i '' 's/\$$HOST\$$/${PROD_API_HOST}/g' build/scripts/persistence/share.js
	sed -i '' 's/\$$HOST\$$/${PROD_SITE_HOST}/g' build/scripts/views/tag_view.js
	cake build:assets:prod
	./node_modules/uglify-js/bin/uglifyjs build/scripts.js -o build/scripts.js
	rm -f extension.zip

	# Do not exclude the scripts/ directory because some scripts
	# are sourced on the background page in the manifest
	zip -r extension.zip build -x '*.coffee' '*.map' '*styles/*' '*templates/*'

	# reset the build directory to dev state
	make build

.PHONY: build package
