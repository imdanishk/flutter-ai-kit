// Installs the Flutter AI kit into a Flutter project.
//
//   dart tool/install.dart --target <project> [--claude] [--copilot] [--dry-run]
//
// Uses only the Dart SDK (no packages). Safe to run again: it replaces the kit's
// own skill folders and the managed block in AGENTS.md, and leaves everything
// else in the project alone.
import 'dart:convert';
import 'dart:io';
const startMarker = '<!-- flutter-ai-kit:start';
const endMarker = '<!-- flutter-ai-kit:end -->';

void main(List<String> args) {
  var target = '';
  var claude = false;
  var copilot = false;
  var dryRun = false;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--target':
        if (i + 1 >= args.length) _fail('--target needs a path');
        target = args[++i];
      case '--claude':
        claude = true;
      case '--copilot':
        copilot = true;
      case '--dry-run':
        dryRun = true;
      case '-h' || '--help':
        _usage();
        return;
      default:
        _fail('Unknown option: ${args[i]}');
    }
  }
  if (target.isEmpty) {
    _usage();
    exit(64);
  }

  final kit = File.fromUri(Platform.script).parent.parent;
  final version = _kitVersion(kit);
  final skillsDir = Directory(_join(kit.path, 'skills'));
  final blockFile = File(_join(kit.path, 'templates', 'AGENTS.block.md'));
  if (!skillsDir.existsSync() || !blockFile.existsSync()) {
    _fail('Run this from the kit folder: skills/ and templates/ not found next to tool/.');
  }

  final project = Directory(target);
  if (!project.existsSync()) _fail('Target folder does not exist: $target');
  if (!File(_join(project.path, 'pubspec.yaml')).existsSync()) {
    stderr.writeln('Warning: no pubspec.yaml in $target. Is this a Flutter project?');
  }

  final skills = skillsDir
      .listSync()
      .whereType<Directory>()
      .where((d) => File(_join(d.path, 'SKILL.md')).existsSync())
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final destinations = <String>['.agents/skills'];
  if (claude) destinations.add('.claude/skills');
  if (copilot) destinations.add('.github/skills');

  for (final dest in destinations) {
    for (final skill in skills) {
      final name = skill.uri.pathSegments.where((s) => s.isNotEmpty).last;
      final to = Directory([project.path, ...dest.split('/'), name].join(Platform.pathSeparator));
      _log(dryRun, 'skill  ${dest}/$name');
      if (dryRun) continue;
      if (to.existsSync()) to.deleteSync(recursive: true);
      _copyDir(skill, to);
    }
  }

  // AGENTS.md managed block.
  final block = blockFile.readAsStringSync().replaceAll('__VERSION__', version).trimRight();
  final agents = File(_join(project.path, 'AGENTS.md'));
  final current = agents.existsSync() ? agents.readAsStringSync() : '';
  final updated = _withBlock(current, block);
  _log(dryRun, 'file   AGENTS.md (${current.isEmpty ? 'create' : 'update managed block'})');
  if (!dryRun && updated != current) agents.writeAsStringSync(updated);

  // Claude Code reads CLAUDE.md, not AGENTS.md.
  if (claude) {
    final claudeMd = File(_join(project.path, 'CLAUDE.md'));
    final text = claudeMd.existsSync() ? claudeMd.readAsStringSync() : '';
    if (!text.contains('@AGENTS.md')) {
      _log(dryRun, 'file   CLAUDE.md (add @AGENTS.md)');
      if (!dryRun) {
        final prefix = text.isEmpty ? '' : '${text.trimRight()}\n\n';
        claudeMd.writeAsStringSync('$prefix@AGENTS.md\n');
      }
    }
  }

  stdout.writeln(dryRun
      ? '\nDry run only. Nothing was written.'
      : '\nInstalled Flutter AI kit $version into ${project.path}');
  stdout.writeln('Next: open the project in your agent and ask it to "run the flutter-project-profile skill".');
}

/// The single source of truth for the version is .claude-plugin/plugin.json.
String _kitVersion(Directory kit) {
  final manifest = File(_join(kit.path, '.claude-plugin', 'plugin.json'));
  if (!manifest.existsSync()) return 'unknown';
  final data = jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>;
  return data['version'] as String? ?? 'unknown';
}

String _withBlock(String current, String block) {
  final start = current.indexOf(startMarker);
  final end = current.indexOf(endMarker);
  if (start >= 0 && end > start) {
    return '${current.substring(0, start)}$block${current.substring(end + endMarker.length)}';
  }
  if (current.trim().isEmpty) return '$block\n';
  return '${current.trimRight()}\n\n$block\n';
}

void _copyDir(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entity in from.listSync(followLinks: false)) {
    final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (entity is Directory) {
      _copyDir(entity, Directory(_join(to.path, name)));
    } else if (entity is File) {
      entity.copySync(_join(to.path, name));
    }
  }
}

String _join(String a, [String? b, String? c, String? d, String? e]) {
  final parts = [a, b, c, d, e].whereType<String>();
  return parts.join(Platform.pathSeparator);
}

void _log(bool dry, String message) => stdout.writeln('${dry ? '[dry] ' : ''}$message');

void _usage() => stdout.writeln('''
Flutter AI kit

Usage: dart tool/install.dart --target <flutter project> [options]

  --claude    also copy skills to .claude/skills and add @AGENTS.md to CLAUDE.md
  --copilot   also copy skills to .github/skills (VS Code Copilot)
  --dry-run   show what would change, write nothing

Skills always go to .agents/skills (read by OpenCode, Codex, Cursor, Gemini CLI,
Antigravity and others).''');

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
