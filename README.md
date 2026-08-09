<p align="center">
  <img src="assets/logo.svg" alt="ClinMPO logo" width="520">
</p>

<h1 align="center">ClinMPO</h1>

<p align="center">
  Evidence-guided reward optimization for psychiatric reasoning in small language models
</p>

> **Repository scope:** This release contains the public prompt resources, three environment-configurable training entry scripts, and the VERL source tree used by the policy-optimization entry points, including the ClinMPO reward function. It does not include study datasets, model weights, checkpoints, or a complete runtime environment.

## Overview

Psychiatric reasoning requires the integration of symptom narratives, mental-state findings, comorbidities, psychosocial context, and treatment history. Small language models may offer practical advantages for institutionally governed and privacy-sensitive settings, but domain adaptation is constrained by limited specialist time and the cost of response-level annotation.

ClinMPO is an evidence-guided reward-optimization framework for improving psychiatric reasoning in small language models. It uses ClinRM, a generative reward model trained to apply the psychiatrist-defined Clinical Psychiatry Thinking Strategy (CPTS):

- **C1 - Clinical accuracy and completeness:** pathogenesis, symptom identification, examination interpretation, differential diagnosis, and treatment planning.
- **C2 - Clarity and concision:** clear and focused clinical language.
- **C3 - Organization and logical coherence:** structured and clinically consistent reasoning.

During policy optimization, ClinMPO combines criterion-resolved ClinRM scores with a clinical-consistency signal. This repository provides reference entry scripts for SFT, GRPO, and ClinMPO experiments, together with the ClinMPO reward integration for VERL. The complete ClinRM training implementation and pretrained artifacts are not included.

## Experimental design

<p align="center">
  <img src="assets/figure1.svg" alt="ClinMPO experimental design" width="850">
</p>

<p align="center"><em>Figure 1. Experimental design of the ClinMPO study.</em></p>

## Data generation workflow

The study used two complementary data pathways.

<p align="center">
  <img src="assets/figure5.svg" alt="ClinMPO data generation workflow" width="1000">
</p>

<p align="center"><em>Figure 5. Data generation and preparation workflow.</em></p>

### Public QA Dataset

The Public QA Dataset was derived from CMB, MedBullets/MedBulletsQA, MedMCQA, MedQA, MedXpertQA, and MMLU-Pro. The reported workflow included psychiatric-relevance screening, format standardization, ClinicalBERT-based semantic deduplication at a 90% similarity threshold, expert quality control, difficulty-based partitioning, and clinical categorization.

The prompt resources currently included in this repository cover:

1. Binary psychiatric-relevance screening.
2. Classification into 12 Psychiatric Practice Competencies.
3. ICD-11-aligned classification into a major category and a specific diagnosis.

The study reports 8,849 retained questions, including 7,112 questions used for post-training and 1,737 difficult questions reserved for evaluation. These records are not redistributed here.

### Evidence QA Dataset

The Evidence QA Dataset was constructed from psychiatry literature identified through OpenAlex and Europe PMC. The paper reports 18,569 question-answer pairs derived from 4,474 psychiatry publications and evaluated under CPTS criteria. The documented evidence-based multiple-choice question generation prompt is included; generated Evidence QA records are not redistributed.

## Repository structure

```text
.
├── assets/
│   ├── figure1.svg
│   ├── figure5.svg
│   └── logo.svg
├── prompts/
│   ├── categorization.md
│   ├── evidence_qa_generation.md
│   ├── psychiatry_relevance_filter.md
│   └── test_set_evaluation.md
├── train/
│   ├── train_clinmpo.sh
│   ├── train_grpo.sh
│   └── train_sft.sh
├── verl/
│   ├── docs/
│   ├── examples/
│   ├── tests/
│   └── verl/utils/reward_score/clinm.py
├── .gitignore
├── LICENSE
└── README.md
```

The `verl/` directory contains the VERL framework source used by the reinforcement-learning scripts. Only the ClinMPO-specific reward module is highlighted above; the directory also retains the framework files required by VERL.

## Prompt usage

The `prompts/` directory contains the English templates used for the following tasks:

- `psychiatry_relevance_filter.md`: binary screening for psychiatry-related questions.
- `categorization.md`: Psychiatric Practice Competency and ICD-11-aligned classification.
- `evidence_qa_generation.md`: evidence-based multiple-choice question generation from source articles.
- `test_set_evaluation.md`: standardized multiple-choice inference for the held-out test set.

The first three files organize prompt content documented in the data-preparation materials and Supplementary Information. The test-set prompt is a repository-provided evaluation template and is not presented as a verbatim manuscript prompt.

Before use:

- Replace `{question}`, `{options}`, `{answer}`, `{option_label}`, and `{full_article_content}` with the corresponding source fields.
- Keep API credentials in environment variables or an approved secret manager.
- Record the provider, model identifier, date, prompt revision, and inference settings.
- Treat automated labels as provisional until expert review is complete.
- Never provide the reference answer to the model during test-set inference.
- Never submit protected health information, identifiable participant data, or confidential clinical text to an external API.

No data-generation API client, study source dataset, generated study record, or automated preprocessing pipeline is included. Users are responsible for implementing provider-specific prompt inference and validating all generated or assigned labels.

## Training entry points

The `train/` directory contains reference entry points for the three study conditions:

- `train_sft.sh`: LoRA-based cold-start supervised fine-tuning with LLaMA-Factory.
- `train_grpo.sh`: standard GRPO with VERL.
- `train_clinmpo.sh`: GRPO with the included ClinMPO reward function.

Machine-specific paths, GPU assignments, dataset locations, output locations, and the custom reward path are supplied through environment variables. The scripts do not contain credentials, datasets, or local infrastructure paths.

The defaults intentionally limit update magnitude: SFT uses a `1e-5` learning rate and the policy-optimization scripts use `1e-7`, one PPO epoch, a `0.1` PPO clipping range, a `0.5` gradient-norm cap, KL regularization, and GRPO group-advantage normalization. These are conservative starting points rather than universally optimal settings. Batch sizes, precision, parallelism, offloading, sequence lengths, learning rates, clipping values, and KL coefficients must be validated and adjusted for the actual model, dataset, GPU topology, and software environment.

Install the framework required by the selected entry point before running it: LLaMA-Factory for SFT and the dependencies documented in [`verl/docs/start/install.rst`](verl/docs/start/install.rst) for GRPO or ClinMPO. Required values can then be supplied without editing the scripts. For example:

```bash
BASE_MODEL_PATH=/path/to/model \
DATASET_DIR=/path/to/llamafactory/data \
DATASET_NAME=dataset_name \
OUTPUT_DIR=/path/to/output \
bash train/train_sft.sh
```

For GRPO and ClinMPO, set `VERL_ROOT`, `MODEL_PATH`, `TRAIN_FILE`, `VAL_FILE`, and `OUTPUT_DIR`. ClinMPO additionally requires `CUSTOM_REWARD_PATH`; for this repository layout, set it to `verl/verl/utils/reward_score/clinm.py`. The reward function expects an OpenAI-compatible reward-model endpoint, configured in that module. Review the endpoint, model name, scoring constants, and every training default before launching a job.

Example ClinMPO invocation from the repository root:

```bash
VERL_ROOT="$PWD/verl" \
MODEL_PATH=/path/to/policy-model \
TRAIN_FILE=/path/to/train.parquet \
VAL_FILE=/path/to/validation.parquet \
OUTPUT_DIR=/path/to/output \
CUSTOM_REWARD_PATH="$PWD/verl/verl/utils/reward_score/clinm.py" \
bash train/train_clinmpo.sh
```

## Data and model availability

No patient records, participant responses, generated study datasets, model checkpoints, or model weights are included.

The source QA datasets remain governed by their original licenses and terms:

- [CMB](https://github.com/FreedomIntelligence/CMB)
- [MedBullets/MedBulletsQA](https://huggingface.co/datasets/LangAGI-Lab/medbullets)
- [MedMCQA](https://github.com/medmcqa/medmcqa)
- [MedQA](https://github.com/jind11/MedQA)
- [MedXpertQA](https://github.com/TsinghuaC3I/MedXpertQA)
- [MMLU-Pro](https://github.com/TIGER-AI-Lab/MMLU-Pro)

### External evaluation datasets

The external datasets used for downstream task evaluation are publicly available from their original maintainers. They are not redistributed in this repository.

| Evaluation resource | Use in the study | Official source | License and reuse terms |
| --- | --- | --- | --- |
| MTS-Dialog | The 200-item test set used for section summarization | [GitHub](https://github.com/abachaa/MTS-Dialog) and [Hugging Face](https://huggingface.co/datasets/abachaa/mts_dialog) | [CC BY 4.0](https://github.com/abachaa/MTS-Dialog/blob/main/LICENSE.txt); attribution to the dataset creators is required. |
| MEDIQA-Chat-2023 Task B | Task definition and evaluation resources for full dialogue-to-note generation | [GitHub](https://github.com/abachaa/MEDIQA-Chat-2023) | The task repository does not currently provide a repository-level license file. Its README identifies ACI-Bench as the Task B dataset; the ACI-Bench data license applies to that data, but should not be assumed to license all MEDIQA-Chat code or evaluation resources. |
| ACI-Bench | The 40-item `TEST1` full-dialogue test set used for MEDIQA-Chat-2023 Task B | [GitHub](https://github.com/wyim/aci-bench) | [CC BY 4.0](https://github.com/wyim/aci-bench#license); attribution and citation of the ACI-Bench paper are requested by the maintainers. |
| HealthCareMagic-100k Chat Format | Medical question answering; 1,000 examples sampled with random seed 42 | [Hugging Face](https://huggingface.co/datasets/RafaelMPereira/HealthCareMagic-100k-Chat-Format-en) | The dataset card declares [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). Users must also review the dataset card and any rights associated with the underlying content before reuse. |

The manuscript reports dataset-level BERTScore recall, ROUGE-1, ROUGE-L, and ROUGE-Lsum for both evaluated models in Table 2. The identifiers for the sampled HealthCareMagic examples, evaluation sample identifiers, and metric source data accompany the paper and remain subject to the original dataset licenses. These evaluation datasets and records are not included in this code repository.

The included source and scripts are reference materials, not a complete reproduction environment. ClinRM and ClinMPO model artifacts are not currently available through this repository.

## Citation

The manuscript is under review. Until a final bibliographic record is available, cite the manuscript version accompanying this repository:

```bibtex
@article{lin2026clinmpo,
  title   = {Evidence-guided reinforcement learning improves psychiatric reasoning in small language models},
  author  = {Lin, Xinxin and Dai, Guangxin and Zhong, Yi and Li, Xiang and others},
  year    = {2026},
  note    = {Manuscript under review}
}
```

## Medical disclaimer

ClinMPO and these prompt resources are provided for research and reproducibility purposes only. They are not medical devices and are not intended for diagnosis, treatment, triage, crisis intervention, or direct patient care. Outputs may be incomplete, incorrect, biased, or unsafe and must not replace evaluation by qualified healthcare professionals or independent clinical judgment. Any clinical or institutional use requires separate validation, safety controls, privacy review, regulatory assessment, and appropriate human oversight.

## License

The original ClinMPO repository materials are released under the [MIT License](LICENSE). The bundled VERL source retains its own license and notices in [`verl/LICENSE`](verl/LICENSE) and [`verl/Notice.txt`](verl/Notice.txt). These licenses do not apply to third-party datasets, publication content, model outputs, or trademarks.
