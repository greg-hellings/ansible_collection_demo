#!/bin/bash

set -e -x -o pipefail

# Concatenate together the AUTHORS files
cat AUTHORS $(find roles -name AUTHORS) | sort -u > AUTHORS.tmp
mv AUTHORS.tmp AUTHORS
find roles -name AUTHORS -delete

# Get rid of individual .ansible-lint files
find roles -name ".ansible-lint" -delete

# Remove git directories and the like
find roles -name '.git*' -print0 -exec rm -r '{}' \;
find roles -name 'LICENSE' -delete

# Get rid of old test files
find roles -name Jenkinsfile -delete
find roles -name .travis.yml -delete

# Get rid of yamllint config files, which are now stored globally
for d in $(find roles -name tests); do
	if [ -e "${d}/yamllint.yml" ]; then
		rm -r "${d}"
	fi
done
