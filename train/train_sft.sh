#!/usr/bin/env bash
set -euo pipefail

# Set these paths for your training environment.
: "${BASE_MODEL_PATH:?Set BASE_MODEL_PATH}"
: "${DATASET_DIR:?Set DATASET_DIR}"
: "${DATASET_NAME:?Set DATASET_NAME}"
: "${OUTPUT_DIR:?Set OUTPUT_DIR}"

# Adjust hardware settings for your training environment.
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
PREPROCESS_WORKERS="${PREPROCESS_WORKERS:-4}"
DATALOADER_WORKERS="${DATALOADER_WORKERS:-2}"
MODEL_TEMPLATE="${MODEL_TEMPLATE:-qwen3}"
USE_BF16="${USE_BF16:-true}"

# Conservative defaults minimize parameter updates; tune for your data and hardware.
LEARNING_RATE="${LEARNING_RATE:-1.0e-5}"
MAX_GRAD_NORM="${MAX_GRAD_NORM:-0.5}"
LORA_RANK="${LORA_RANK:-8}"
TRAIN_BATCH_SIZE="${TRAIN_BATCH_SIZE:-1}"
GRADIENT_ACCUMULATION_STEPS="${GRADIENT_ACCUMULATION_STEPS:-8}"
TRAIN_EPOCHS="${TRAIN_EPOCHS:-3.0}"
WARMUP_RATIO="${WARMUP_RATIO:-0.1}"

mkdir -p "${OUTPUT_DIR}"
config_path="${OUTPUT_DIR}/train_sft.generated.yaml"

cat >"${config_path}" <<EOF
model_name_or_path: "${BASE_MODEL_PATH}"
trust_remote_code: true

stage: sft
do_train: true
finetuning_type: lora
lora_rank: ${LORA_RANK}
lora_target: all

dataset_dir: "${DATASET_DIR}"
dataset: "${DATASET_NAME}"
template: "${MODEL_TEMPLATE}"
overwrite_cache: true
preprocessing_num_workers: ${PREPROCESS_WORKERS}
dataloader_num_workers: ${DATALOADER_WORKERS}

output_dir: "${OUTPUT_DIR}"
logging_steps: 10
save_steps: 500
plot_loss: true
overwrite_output_dir: false
save_only_model: false
report_to: none

per_device_train_batch_size: ${TRAIN_BATCH_SIZE}
gradient_accumulation_steps: ${GRADIENT_ACCUMULATION_STEPS}
learning_rate: ${LEARNING_RATE}
max_grad_norm: ${MAX_GRAD_NORM}
num_train_epochs: ${TRAIN_EPOCHS}
lr_scheduler_type: cosine
warmup_ratio: ${WARMUP_RATIO}
bf16: ${USE_BF16}
gradient_checkpointing: true
ddp_timeout: 180000000
resume_from_checkpoint: null
dataloader_pin_memory: true

val_size: 0.1
per_device_eval_batch_size: 1
eval_strategy: steps
eval_steps: 500
EOF

llamafactory-cli train "${config_path}"
