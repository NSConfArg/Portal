# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Run SwiftLint
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = 'bin/swiftlint/swiftlint'
swiftlint.lint_files

# Runs a linter with all styles, on modified and added markdown files in this PR
prose.lint_files

# Xcode summary
xcode_summary.report 'xcodebuild.json'

# Profile Swift compilation time
xcprofiler.report 'Portal'
