import json
import re

from openai import OpenAI

DEFAULT_BASE_URL = "http://localhost:1500/v1"  # Local vLLM reward endpoint.
DEFAULT_MODEL = "reward"  # Model name exposed by the vLLM endpoint.
VLLM_API_KEY = "EMPTY"  # vLLM requires no real API credential.
MODEL_TEMPERATURE = 0.0  # Deterministic scoring reduces reward noise.
KNOWLEDGE_WEIGHT = 2.0  # Positive clinical knowledge scores count twice.
LANGUAGE_WEIGHT = 1.0  # Keep language quality secondary to knowledge.
STRUCTURE_WEIGHT = 1.0  # Keep structure quality secondary to knowledge.
MIN_RAW_REWARD = 0.0  # Prevent negative rewards from reaching GRPO.


def _calculate_reward(evaluation):
    """Convert criterion scores into a non-negative raw reward."""
    knowledge_scores = evaluation.get("Scientificity and Accuracy of Knowledge", {})

    # Only positive knowledge scores contribute to the reward.
    # Negative scores can also be used, but may cause gradient explosion; use them with caution.
    knowledge_total = sum(
        value * KNOWLEDGE_WEIGHT for value in knowledge_scores.values() if isinstance(value, (int, float)) and value > 0
    )

    language_score = evaluation.get("Plainness and Conciseness of Language", 0)
    structure_score = evaluation.get("Orderliness and Logicality of Structure", 0)
    language_score = language_score if isinstance(language_score, (int, float)) else 0
    structure_score = structure_score if isinstance(structure_score, (int, float)) else 0

    raw_reward = knowledge_total + language_score * LANGUAGE_WEIGHT + structure_score * STRUCTURE_WEIGHT
    return max(MIN_RAW_REWARD, raw_reward)


def evaluate_with_model(question, cot, base_url=DEFAULT_BASE_URL, model=DEFAULT_MODEL):
    """Score a chain of thought with the local reward model."""
    client = OpenAI(
        base_url=base_url,
        api_key=VLLM_API_KEY,
    )

    # Keep the prompt aligned with reward-model training.
    prompt = f"""/no_think Please evaluate the quality of the chain-of-thought reasoning for the following question.
Do not request any additional information. Refrain from drawing on medical diagnostic findings.
Assess each step of the reasoning process exclusively. You must provide a score.

The evaluation should be conducted along the dimensions below:

1. Scientificity and Accuracy of Knowledge  
   This dimension includes the following five aspects:
   - Incorrect Pathogenesis  
   - Misidentification of Symptoms  
   - Misinterpretation of Examinations  
   - Errors in Differential Diagnosis  
   - Incorrect Treatment Plans  

   Scoring rules for each aspect:
   - Assign **1 point** if the aspect is explicitly addressed and the reasoning is correct.
   - Assign **0 points** if the aspect is not addressed.
   - Assign **−1 point** if the aspect is addressed but contains errors.

2. Plainness and Conciseness of Language  
   - Assign **1 point** if the language is clear and concise.
   - Assign **−1 point** if the language is unclear, verbose, or confusing.

3. Orderliness and Logicality of Structure  
   - Assign **1 point** if the reasoning is well-structured and logically coherent.
   - Assign **−1 point** if the structure is disorganized or logically inconsistent.

4. If the answer is garbled, completely unrelated to the options, or does not address the question,
   all of the above items will be scored -1 point.

Please output the evaluation strictly in the following JSON format:
{{
  "Scientificity and Accuracy of Knowledge": {{
    "Incorrect Pathogenesis": 0,
    "Misidentification of Symptoms": 0,
    "Misinterpretation of Examinations": 0,
    "Errors in Differential Diagnosis": 0,
    "Incorrect Treatment Plans": 0
  }},
  "Plainness and Conciseness of Language": 0,
  "Orderliness and Logicality of Structure": 0
}}
{question} {cot}"""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            temperature=MODEL_TEMPERATURE,
        )

        response_text = response.choices[0].message.content

        # Remove hidden reasoning before parsing the JSON score.
        cleaned_text = re.sub(r"<think>.*?</think>", "", response_text, flags=re.DOTALL).strip()

        json_match = re.search(
            r'\{[^{}]*"Scientificity and Accuracy of Knowledge"[^{}]*\{[^{}]*\}[^{}]*\}',
            cleaned_text,
            re.DOTALL,
        )

        if json_match:
            json_str = json_match.group(0)
            evaluation = json.loads(json_str)
            return _calculate_reward(evaluation)

        print(f"Warning: Could not extract JSON from response: {cleaned_text}")
        return 0.0

    except Exception as error:
        print(f"Error calling model: {error}")
        return 0.0


def compute_score(
    data_source,
    extra_info,
    solution_str,
    ground_truth,
    method="strict",
    format_score=0.0,
    score=1.0,
):
    """Compute the non-negative model-based reward."""
    # These arguments are retained for the standard VERL reward-function interface.
    _ = data_source, ground_truth, method, format_score, score

    question = extra_info.get("question", "")

    if not question:
        print("Warning: question is empty")
        return 0.0

    return evaluate_with_model(
        question=question,
        cot=solution_str,
        base_url=DEFAULT_BASE_URL,
        model=DEFAULT_MODEL,
    )
