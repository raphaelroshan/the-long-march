#!/usr/bin/env python3
"""Validate repository-local Codex skills and their internal references."""
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS_ROOT = ROOT / ".codex" / "skills"
EXPECTED_SKILLS = {
    "long-march-writer": {
        "references/voice-and-world.md",
        "references/content-shapes.md",
    },
    "long-march-content-reviewer": {
        "references/review-rubric.md",
        "references/continuity-checklist.md",
    },
    "long-march-visual-reviewer": {
        "references/screen-review-grid.md",
    },
    "long-march-playtest-triage": {
        "references/evidence-and-severity.md",
    },
}
CANONICAL_SOURCES = (
    "AGENTS.md",
    "design/design_prompt.md",
    "design/gameplay_framework.md",
    "design/characters_factions_and_campaign.md",
    "design/map_regions_and_settlements.md",
    "content/content_manifest.json",
    "content/people_promises.json",
    "content/campaign_memory.json",
    "src/core/fortress_state.gd",
)


def frontmatter(markdown: str) -> dict[str, str]:
    match = re.match(r"^---\n(.*?)\n---\n", markdown, re.DOTALL)
    if match is None:
        return {}
    values: dict[str, str] = {}
    for line in match.group(1).splitlines():
        key, separator, value = line.partition(":")
        if separator:
            values[key.strip()] = value.strip().strip('"')
    return values


def main() -> int:
    errors: list[str] = []
    for relative_path in CANONICAL_SOURCES:
        if not (ROOT / relative_path).is_file():
            errors.append(f"missing canonical skill source: {relative_path}")

    for skill_name, expected_references in EXPECTED_SKILLS.items():
        skill_dir = SKILLS_ROOT / skill_name
        skill_file = skill_dir / "SKILL.md"
        agent_file = skill_dir / "agents" / "openai.yaml"
        if not skill_file.is_file():
            errors.append(f"missing skill instructions: {skill_name}/SKILL.md")
            continue
        if not agent_file.is_file():
            errors.append(f"missing skill interface metadata: {skill_name}/agents/openai.yaml")
            continue

        skill_text = skill_file.read_text(encoding="utf-8")
        metadata = frontmatter(skill_text)
        if metadata.get("name") != skill_name:
            errors.append(f"{skill_name}: frontmatter name does not match directory")
        description = metadata.get("description", "")
        if len(description) < 80:
            errors.append(f"{skill_name}: description does not explain scope and triggers")
        if "TODO" in skill_text:
            errors.append(f"{skill_name}: placeholder TODO remains")

        linked_references = set(re.findall(r"\]\((references/[^)]+\.md)\)", skill_text))
        if linked_references != expected_references:
            errors.append(
                f"{skill_name}: linked references {sorted(linked_references)} "
                f"do not match expected {sorted(expected_references)}"
            )
        for reference in expected_references:
            reference_path = skill_dir / reference
            if not reference_path.is_file():
                errors.append(f"{skill_name}: missing linked reference {reference}")
            elif "TODO" in reference_path.read_text(encoding="utf-8"):
                errors.append(f"{skill_name}: placeholder TODO remains in {reference}")

        agent_text = agent_file.read_text(encoding="utf-8")
        if f"${skill_name}" not in agent_text:
            errors.append(f"{skill_name}: default prompt must invoke ${skill_name}")
        if 'allow_implicit_invocation: false' in agent_text:
            errors.append(f"{skill_name}: implicit invocation should remain enabled")

    if errors:
        print(f"repository Codex skills: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"repository Codex skills: PASS ({len(EXPECTED_SKILLS)} skills)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
