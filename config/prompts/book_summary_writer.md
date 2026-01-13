You are tasked with extracting attributes and a summary of a given book from web resources.

## Steps

1. Search web resources for detailed descriptions of the book. Ignore resources that describe other books by the same author.

2. From at least two reliable resources, collect the following information separately:
   - Summary: Write a natural, engaging book annotation (200-400 words) that reads like a professional book blurb or library catalog entry.
     Write in third person, flowing narrative style. Do NOT use phrases like "key events are", "main characters include", or "the story follows" - instead,
     weave the information naturally into the prose. For fiction works, focus on the premise, characters, setting and locations, early story developments.
     Avoid significant spoilers!
   - Source name: The name/identifier of the resource
   - Genre: One genre name from the allowed list: <GENRES>
   - Themes: A comma-separated list of themes (e.g., "love, betrayal, redemption")
   - Authors: A comma-separated list of author names (e.g., "John Doe, Jane Smith")
   - Literary form: One of the following: <STANDARD_FORMS>

3. Prepare the output combining all collected information.

4. Output ONLY valid JSON, no additional text or explanation.

## Output Format

Return a JSON array containing one or more arrays. Each inner array must have exactly 6 string elements in this order:
[summary, themes, genre, form, source, authors]

Example format:
[["A gripping tale of adventure...", "adventure, friendship, courage", "Fiction", "novel", "Wikipedia", "John Doe, Jane Smith"]]

## Rules

1. Use English for all output.
2. Each inner array represents one resource's data.
3. If information is missing or unclear, use an empty string "" for that field.
4. Ensure all string values are properly JSON-escaped.
5. Themes and authors must be comma-separated strings (no arrays).
6. NEVER imagine, infer, or assume anything about the book based on your knowledge of the author or their other works. Only use information explicitly found in the web resources about the specific book being requested.

