# Plain-Ruby checks for skills/flutter-release/assets/fastlane/versioning.rb.
# Run: ruby tool/test_versioning.rb
require_relative "../skills/flutter-release/assets/fastlane/versioning"

$failures = 0
def check(label, actual, expected)
  return if actual == expected
  $failures += 1
  warn "FAIL #{label}: expected #{expected.inspect}, got #{actual.inspect}"
end

def raises(label)
  yield
  $failures += 1
  warn "FAIL #{label}: expected an error"
rescue ArgumentError
  nil
end

V = KitVersioning
check "build only", V.next_version("1.4.2", 27), ["1.4.2", 28]
check "patch", V.next_version("1.4.2", 27, "patch"), ["1.4.3", 28]
check "minor resets patch", V.next_version("1.4.2", 27, "minor"), ["1.5.0", 28]
check "major resets minor and patch", V.next_version("1.4.2", 27, "major"), ["2.0.0", 28]
check "empty store uses fallback", V.next_version(nil, nil), ["1.0.0", 1]
check "empty release string keeps name", V.next_version("2.0.0", 3, ""), ["2.0.0", 4]
check "build number given as string", V.next_version("1.0.0", "9"), ["1.0.0", 10]
raises("bad name") { V.next_version("1.4", 1) }
raises("bad release") { V.next_version("1.4.2", 1, "huge") }
check "highest across lists", V.highest([3, 9], [], nil, [12, 1]), 12
check "highest none", V.highest([], nil), nil
check "release name", V.parse_release_name("27 (1.4.0)"), ["1.4.0", 27]
check "release name other text", V.parse_release_name("Release notes"), [nil, nil]
check "pubspec with build", V.pubspec_version("name: app\nversion: 1.4.0+27\n"), ["1.4.0", 27]
check "pubspec without build", V.pubspec_version("version: 2.1.0\n"), ["2.1.0", 0]
raises("pubspec missing") { V.pubspec_version("name: app\n") }

if $failures.zero?
  puts "OK: versioning helpers"
else
  exit 1
end
