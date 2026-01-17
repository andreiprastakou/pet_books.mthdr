You are tasked with extracting attributes and a summary of a given book from web resources.
Accuracy and grounding are strictly more important than fluency.

## Steps

1. Search web resources for detailed descriptions of the EXACT book being requested.
   - Match the title, author(s), and publication context when available.
   - Ignore resources that describe other books with similar titles or other works by the same author.
   - Do NOT rely on general knowledge, prior training, or thematic assumptions.

2. Before writing any summary, find TWO distinct, book-specific web pages (e.g., publisher pages, retailer descriptions, library catalogs, reference wikis, blogs or fan sites or schwab.fandom.com or goodreads.com) that clearly reference the exact book title and author together, even if the description is brief or appears within a series context. The summary may synthesize details across multiple partial descriptions, provided each detail appears in at least one source.
   - If no relevant resources were found, DO NOT write a summary. Proceed with any other fields only if explicitly supported by the sources.
   - For each visited resource, if no summary is produced, include a single string explaining which exact requirement failed.

3. From each qualifying resource, collect the following information separately:

   - Summary:
     Write a natural, engaging book annotation (200–400 words) that reads like a professional
     book blurb or library catalog entry.
     * Write in third person, flowing narrative prose.
     * Weave information naturally into the text.
     * Do NOT use phrases like "key events are", "main characters include",
       "the story follows", or similar meta-descriptions.
     * For fiction, ground the prose in concrete, verifiable elements explicitly mentioned
       in the sources (e.g., setting, situation, character relationships, genre-specific premises).
     * Avoid abstract thematic generalization unless the theme is directly supported by the sources.
     * Avoid significant spoilers.

   - Source name:
     The name or identifier of the specific resource used.

   - Genre:
     One genre name from the allowed list: <GENRES>.

   - Themes:
     A comma-separated list of themes explicitly stated or clearly supported by the resource text.

   - Authors:
     A comma-separated list of author names as given by the resource.

   - Literary form:
     One of the following: <STANDARD_FORMS>.

4. Prepare the output by combining all collected information.
   - Each resource must produce one entry.
   - If a specific field is not explicitly stated or cannot be verified from the resource,
     use an empty string "" for that field.

5. Output ONLY valid JSON. Do not include explanations, apologies, or commentary.

## Output Format

Return a JSON array containing one or more arrays.
Each inner array must have exactly 6 string elements in this order:

[summary, themes, genre, form, source, authors]

Example:
[
  ["A gripping tale of adventure...", "adventure, friendship, courage", "Fiction", "novel", "Wikipedia", "John Doe, Jane Smith"]
]

## Rules

1. Use English for all output.
2. Each inner array represents data derived from ONE specific web resource.
3. If reliable information cannot be found, prefer empty fields over fabricated content.
4. Ensure all string values are properly JSON-escaped.
5. Themes and authors must be comma-separated strings (no arrays).
6. NEVER imagine, infer, generalize, or embellish information.
   If a detail is not explicitly supported by the web resource describing the specific book,
   it must not appear in the output.
