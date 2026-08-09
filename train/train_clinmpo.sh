#!/usr/bin/env bash
set -euo pipefail

# Set these paths for your training environment.
: "${VERL_ROOT:?Set VERL_ROOT}"
: "${MODEL_PATH:?Set MODEL_PATH}"
: "${TRAIN_FILE:?Set TRAIN_FILE}"
: "${VAL_FILE:?Set VAL_FILE}"
: "${OUTPUT_DIR:?Set OUTPUT_DIR}"
: "${CUSTOM_REWARD_PATH:?Set CUSTOM_REWARD_PATH}"

# Adjust hardware settings for your training environment.
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
export PYTHONPATH="${VERL_ROOT}:${PYTHONPATH:-}"
GPU_COUNT="${GPU_COUNT:-1}"
TENSOR_PARALLEL_SIZE="${TENSOR_PARALLEL_SIZE:-1}"
GPU_MEMORY_UTILIZATION="${GPU_MEMORY_UTILIZATION:-0.6}"

# Conservative defaults minimize policy updates; tune for your data and hardware.
LEARNING_RATE="${LEARNING_RATE:-1.0e-7}"
MAX_GRAD_NORM="${MAX_GRAD_NORM:-0.5}"
PPO_CLIP_RATIO="${PPO_CLIP_RATIO:-0.1}"
KL_LOSS_COEF="${KL_LOSS_COEF:-0.01}"
TRAIN_BATCH_SIZE="${TRAIN_BATCH_SIZE:-16}"
PPO_MINI_BATCH_SIZE="${PPO_MINI_BATCH_SIZE:-16}"
PPO_MICRO_BATCH_SIZE="${PPO_MICRO_BATCH_SIZE:-1}"
ROLLOUT_COUNT="${ROLLOUT_COUNT:-2}"
TRAIN_EPOCHS="${TRAIN_EPOCHS:-3}"
MAX_PROMPT_LENGTH="${MAX_PROMPT_LENGTH:-1024}"
MAX_RESPONSE_LENGTH="${MAX_RESPONSE_LENGTH:-1024}"

python3 -m verl.trainer.main_ppo \
  algorithm.adv_estimator=grpo \
  algorithm.norm_adv_by_std_in_grpo=True \
  algorithm.use_kl_in_reward=False \
  "data.train_files=${TRAIN_FILE}" \
  "data.val_files=${VAL_FILE}" \
  data.train_batch_size="${TRAIN_BATCH_SIZE}" \
  data.max_prompt_length="${MAX_PROMPT_LENGTH}" \
  data.max_response_length="${MAX_RESPONSE_LENGTH}" \
  data.filter_overlong_prompts=True \
  data.truncation=error \
  "custom_reward_function.path=${CUSTOM_REWARD_PATH}" \
  custom_reward_function.name=compute_score \
  "actor_rollout_ref.model.path=${MODEL_PATH}" \
  actor_rollout_ref.model.use_remove_padding=True \
  actor_rollout_ref.model.enable_gradient_checkpointing=True \
  actor_rollout_ref.actor.optim.lr="${LEARNING_RATE}" \
  actor_rollout_ref.actor.optim.clip_grad="${MAX_GRAD_NORM}" \
  actor_rollout_ref.actor.ppo_mini_batch_size="${PPO_MINI_BATCH_SIZE}" \
  actor_rollout_ref.actor.ppo_micro_batch_size_per_gpu="${PPO_MICRO_BATCH_SIZE}" \
  actor_rollout_ref.actor.ppo_epochs=1 \
  actor_rollout_ref.actor.clip_ratio="${PPO_CLIP_RATIO}" \
  actor_rollout_ref.actor.clip_ratio_low="${PPO_CLIP_RATIO}" \
  actor_rollout_ref.actor.clip_ratio_high="${PPO_CLIP_RATIO}" \
  actor_rollout_ref.actor.use_kl_loss=True \
  actor_rollout_ref.actor.kl_loss_coef="${KL_LOSS_COEF}" \
  actor_rollout_ref.actor.kl_loss_type=low_var_kl \
  actor_rollout_ref.actor.entropy_coeff=0 \
  actor_rollout_ref.actor.fsdp_config.param_offload=True \
  actor_rollout_ref.actor.fsdp_config.optimizer_offload=True \
  actor_rollout_ref.rollout.log_prob_micro_batch_size_per_gpu="${PPO_MICRO_BATCH_SIZE}" \
  actor_rollout_ref.rollout.tensor_model_parallel_size="${TENSOR_PARALLEL_SIZE}" \
  actor_rollout_ref.rollout.name=vllm \
  actor_rollout_ref.rollout.gpu_memory_utilization="${GPU_MEMORY_UTILIZATION}" \
  actor_rollout_ref.rollout.n="${ROLLOUT_COUNT}" \
  actor_rollout_ref.ref.log_prob_micro_batch_size_per_gpu="${PPO_MICRO_BATCH_SIZE}" \
  actor_rollout_ref.ref.fsdp_config.param_offload=True \
  trainer.critic_warmup=0 \
  trainer.logger='["console"]' \
  trainer.project_name=clinmpo \
  trainer.experiment_name=clinmpo \
  trainer.n_gpus_per_node="${GPU_COUNT}" \
  trainer.nnodes=1 \
  trainer.save_freq=20 \
  trainer.test_freq=5 \
  trainer.total_epochs="${TRAIN_EPOCHS}" \
  "trainer.default_local_dir=${OUTPUT_DIR}"
