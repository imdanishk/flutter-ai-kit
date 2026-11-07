# Pure version helpers used by the Fastfiles. No Fastlane calls here, so they can be tested
# with plain Ruby (see tool/test_versioning.rb in the kit repository).
# Copy this file next to each Fastfile (android/fastlane and ios/fastlane).
module KitVersioning
  VERSION_NAME = /\A(\d+)\.(\d+)\.(\d+)\z/

  # Returns [version_name, build_number] for the next upload.
  # latest_name: "1.4.2", or nil/"" when the store has nothing yet (fallback_name is used)
  # latest_build: the highest build number the store knows, or nil
  # release: nil, "" or "none" keeps the name; "patch", "minor" or "major" bumps it
  def self.next_version(latest_name, latest_build, release = nil, fallback_name: "1.0.0")
    name = latest_name.to_s.strip
    name = fallback_name if name.empty?
    match = VERSION_NAME.match(name)
    raise ArgumentError, "Version name must look like 1.2.3, got #{name.inspect}" unless match

    major, minor, patch = match.captures.map(&:to_i)
    case release.to_s
    when "", "none"
      # keep the version name
    when "major"
      major += 1
      minor = 0
      patch = 0
    when "minor"
      minor += 1
      patch = 0
    when "patch"
      patch += 1
    else
      raise ArgumentError, "release must be none, patch, minor or major, got #{release.inspect}"
    end
    ["#{major}.#{minor}.#{patch}", latest_build.to_i + 1]
  end

  # The [name, build] to bump from. The name is the higher of the store's and pubspec's, so a developer
  # who raises the version in pubspec.yaml gets that version; on a tie, or when either name does not look
  # like 1.2.3, the store's name is kept. The build is the higher of the store's and pubspec's, so the
  # next upload is never below either one.
  def self.base_version(store_name, store_build, pubspec_name, pubspec_build)
    store = store_name.to_s.strip
    pub = pubspec_name.to_s.strip
    name = if store.empty? then pub
           elsif pub.empty? then store
           else higher_name(store, pub)
           end
    [name, [store_build.to_i, pubspec_build.to_i].max]
  end

  # The higher of two version names; the first one when they tie or either is not 1.2.3-shaped.
  def self.higher_name(first, second)
    a = VERSION_NAME.match(first)
    b = VERSION_NAME.match(second)
    return first unless a && b
    (b.captures.map(&:to_i) <=> a.captures.map(&:to_i)) > 0 ? second : first
  end

  # Highest build number in any number of lists (nil-safe). nil when there are none.
  def self.highest(*lists)
    lists.flatten.compact.map(&:to_i).max
  end

  # "27 (1.4.0)" -> ["1.4.0", 27]; anything else -> [nil, nil]
  def self.parse_release_name(text)
    match = /\A\s*(\d+)\s*\((\d+\.\d+\.\d+)\)\s*\z/.match(text.to_s)
    match ? [match[2], match[1].to_i] : [nil, nil]
  end

  # pubspec.yaml text -> [version_name, build_number]; build_number is 0 when there is no "+".
  def self.pubspec_version(text)
    match = /^version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?\s*$/.match(text.to_s)
    raise ArgumentError, "No 'version: x.y.z+n' line found in pubspec.yaml" unless match

    [match[1], match[2].to_i]
  end
end
