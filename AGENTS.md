# Agent Skills Repository

## Scope

- `skills/`: one directory per skill.
- `skills/<skill>/SKILL.md`: frontmatter, trigger description, workflow, reference index, sources supporting its own guidance.
- `skills/<skill>/references/`: focused topic pages.
- `skills/<skill>/agents/openai.yaml`: display name, short description, default prompt.
- `.claude-plugin/plugin.json`: Claude Code plugin manifest; `name` namespaces every skill as `<name>:<skill>`.
- `.claude-plugin/marketplace.json`: Claude Code marketplace manifest; its single plugin entry `source` is the repository root.
- `README.md`: skill index.

## Authoring

- Avoid prose.
- Prefer bullets, tables, short directives, and code blocks.
- Keep each fact in one location; link to it elsewhere.
- Keep examples abstract: neutral names, minimal domain assumptions, no project-specific fixtures.
- Keep example code correct for its stated language, API, and context.
- Match existing Markdown and YAML conventions.
- Keep `SKILL.md` concise; move detail to indexed reference pages.

## Sources

- Use authoritative, current documentation.
- List every document used to create or materially update guidance under `## References` on the page it supports.
- Do not duplicate nested-page sources in `SKILL.md`; link to the topic pages instead.
- Use descriptive Markdown links to the source pages.
- Prefer direct documentation pages over home pages, search results, or secondary summaries.

## Completion

- Check frontmatter fields: `name`, `description`.
- Check every relative Markdown link.
- Check every external source link.
- Check examples for syntax and API correctness.
- Update `README.md` when adding or renaming a skill.
- Run `claude plugin validate . --strict`.

## Commits and Pull Requests

- Use descriptive branch names without AI harness prefixes (such as `codex/`, `claude/`, `cursor/`, or `junie/`).
- Keep commits focused and use short, imperative commit subjects.
- Do not add a `Co-Authored-By` trailer.
- PR descriptions should explain the problem, the changes made, and the resulting behavior. Include compatibility impacts, remaining limitations, and links to related issues when relevant. Do not include checks performed, validation commands, or validation results.
