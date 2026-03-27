#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const src = __dirname;
const dest = process.cwd();

const pkgDest = path.join(dest, '.claude', 'skills', 'frontend-agent-skills');
const rulesDest = path.join(pkgDest, 'rules');

fs.mkdirSync(rulesDest, { recursive: true });

// Install SKILL.md
fs.copyFileSync(
  path.join(src, 'SKILL.md'),
  path.join(pkgDest, 'SKILL.md')
);

// Install rules/
for (const file of fs.readdirSync(path.join(src, 'rules'))) {
  if (file.endsWith('.md')) {
    fs.copyFileSync(
      path.join(src, 'rules', file),
      path.join(rulesDest, file)
    );
  }
}

console.log('Installed frontend-agent-skills to .claude/skills/frontend-agent-skills/');
