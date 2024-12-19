#!/bin/bash

# 设置 GPU 卡列表
GPUS=(0 1 2 3)

# 设置环境和对应的 target_sample 参数
ENVIRONMENTS=("Ant-v3" "HalfCheetah-v3" "Hopper-v3" "Humanoid-v3" "Walker2d-v3")
TARGET_SAMPLES=(2 4 1 2 2)

# 设置随机种子范围
SEEDS=(0 1 2 3 4)

# 遍历所有环境
for i in "${!ENVIRONMENTS[@]}"; do
    ENV=${ENVIRONMENTS[$i]}
    TARGET=${TARGET_SAMPLES[$i]}
    
    # 遍历所有种子值
    for SEED in "${SEEDS[@]}"; do
        # 选择 GPU 卡，循环使用 0 1 2 3
        GPU=${GPUS[$(( (SEED + i) % ${#GPUS[@]} ))]}
        
        # 日志文件名
        cmd="cd ~/DRL/qvpo; source ~/.bashrc; conda init; conda activate baseRL; export WANDB_API_KEY=c92617587866adffa38fa0ef2ecee09dd08652b2; CUDA_VISIBLE_DEVICES=${GPU} python main.py --env_name ${ENV} --weighted --aug --target_sample ${TARGET} --seed ${SEED}"

        LOG_FILE="logs/${ENV}_seed${SEED}.log"
        mkdir -p logs  # 创建日志文件夹

        echo "Running experiment on $ENV with seed=$SEED, target_sample=$TARGET using GPU=$GPU"
        
        nohup bash -c "${cmd}" > "${LOG_FILE}" 2>&1 &

        # 执行 Python 脚本，后台运行并保存输出日志
        nohup  > $LOG_FILE 2>&1 &

        # 打印当前后台任务信息
        echo "Experiment running in background. Log: $LOG_FILE"
        
        # 短暂延迟，避免资源冲突（可选）
        sleep 4
    done
done

echo "All experiments started in the background!"
