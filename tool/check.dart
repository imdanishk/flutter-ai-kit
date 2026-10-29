// Repository checks used by CI and before a release:
//   dart tool/check.dart [--tag v0.1.0]
// Fails (exit 1) when skills, versions or the changelog are inconsistent.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final errors = <String>[];
  final root = File.fromUri(Platform.script).parent.parent;
  String p(String rel) => '${root.path}${Platform.pathSeparator}${rel.replaceAll('/', Platform.pathSeparator)}';

  // Version agreement.
  final plugin = jsonDecode(File(p('.claude-plugin/plugin.json')).readAsStringSync()) as Map<String, dynamic>;
  final version = plugin['version'] as String;
  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) errors.add('plugin.json version is not MAJOR.MINOR.PATCH: $version');
  final market = jsonDecode(File(p('.claude-plugin/marketplace.json')).readAsStringSync()) as Map<String, dynamic>;
  for (final entry in (market['plugins'] as List).cast<Map<String, dynamic>>()) {
    if (entry.containsKey('version')) errors.add('Set the version in plugin.json only, not in marketplace.json');
  }
  final changelog = File(p('CHANGELOG.md')).readAsStringSync();
  if (!changelog.contains('## [$version]')) errors.add('CHANGELOG.md has no "## [$version]" section');
  final tagIndex = args.indexOf('--tag');
  if (tagIndex >= 0 && tagIndex + 1 < args.length) {
    final tag = args[tagIndex + 1];
    if (tag != 'v$version') errors.add('Tag $tag does not match plugin.json version v$version');
  }

  // Skills.
  final skillsDir = Directory(p('skills'));
  for (final dir in skillsDir.listSync().whereType<Directory>()) {
    final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final file = File('${dir.path}${Platform.pathSeparator}SKILL.md');
    if (!file.existsSync()) {
      errors.add('skills/$name has no SKILL.md');
      continue;
    }
    final lines = file.readAsLinesSync();
    if (lines.length > 500) errors.add('skills/$name/SKILL.md is ${lines.length} lines (limit 500)');
    final declared = RegExp(r'^name:\s*(\S+)\s*$', multiLine: true).firstMatch(file.readAsStringSync())?.group(1);
    if (declared != name) errors.add('skills/$name/SKILL.md declares name "$declared"');
    if (!file.readAsStringSync().contains(RegExp(r'^description:\s*\S', multiLine: true))) {
      errors.add('skills/$name/SKILL.md has no description');
    }
  }

  // The always-on block must stay tiny.
  final block = File(p('templates/AGENTS.block.md')).readAsLinesSync();
  if (block.length > 20) errors.add('templates/AGENTS.block.md is ${block.length} lines (limit 20)');

  if (errors.isEmpty) {
    stdout.writeln('OK: version $version, ${skillsDir.listSync().whereType<Directory>().length} skills');
  } else {
    errors.forEach(stderr.writeln);
    exit(1);
  }
}
