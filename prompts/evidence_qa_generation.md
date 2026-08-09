# Evidence-Based Multiple-Choice Question Generation

## User prompt

You are a senior clinical medical educator. Carefully read the following psychiatric article and generate three high-quality, independent multiple-choice questions (MCQs) that assess clinical reasoning and medical knowledge.

Requirements:

1. Each question must be independent and self-contained. Include all information required to answer it, including relevant patient background, clinical course, laboratory or imaging findings and treatment details.
2. Do not use phrases such as "this patient" or "the above case" that create dependencies between questions.
3. Provide four medically plausible options (A-D), with one correct answer.
4. Mark the correct answer and provide a professional explanation of no more than 100 words.
5. Questions may address clinical background, pathogenesis, diagnosis, differential diagnosis, investigations, treatment or prognosis.
6. Return only a JSON array in the following structure:

```json
[
  {
    "question": "{self-contained question}",
    "options": {
      "A": "{option A}",
      "B": "{option B}",
      "C": "{option C}",
      "D": "{option D}"
    },
    "answer": "{correct option label}",
    "explanation": "{clinical rationale, <=100 words}"
  }
]
```

```text
Source article:
{full_article_content}
```
