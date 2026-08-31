# Agent Skills Repository

## Scope

- `skills/`: one directory per skill.
- `skills/<skill>/SKILL.md`: frontmatter, trigger description, workflow, reference index, complete source-documentation list.
- `skills/<skill>/references/`: focused topic pages.
- `skills/<skill>/agents/openai.yaml`: display name, short description, default prompt.
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
- Add `## References` to every `SKILL.md`.
- List every document used to create or materially update the skill.
- Use descriptive Markdown links to the source pages.
- Add page-specific source links to each reference page.
- Prefer direct documentation pages over home pages, search results, or secondary summaries.

## Completion

- Check frontmatter fields: `name`, `description`.
- Check every relative Markdown link.
- Check every external source link.
- Check examples for syntax and API correctness.
- Update `README.md` when adding or renaming a skill.
