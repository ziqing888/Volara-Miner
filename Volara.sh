#!/bin/bash

# 自动化脚本：Volara-Miner 安装和启动

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# 定义图标
INFO_ICON="ℹ️"
SUCCESS_ICON="✅"
WARNING_ICON="⚠️"
ERROR_ICON="❌"

# 信息显示函数
log_info() {
  echo -e "${CYAN}${INFO_ICON} ${1}${RESET}"
}

log_success() {
  echo -e "${GREEN}${SUCCESS_ICON} ${1}${RESET}"
}

log_warning() {
  echo -e "${YELLOW}${WARNING_ICON} ${1}${RESET}"
}

log_error() {
  echo -e "${RED}${ERROR_ICON} ${1}${RESET}"
}

# 函数：更新和升级系统
update_system() {
  log_info "正在更新和升级系统..."
  sudo apt update -y && sudo apt upgrade -y
}

# 函数：安装 Docker
install_docker() {
  log_info "正在安装 Docker 及其依赖..."
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update -y && sudo apt upgrade -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo chmod +x /usr/local/bin/docker-compose

  docker --version &> /dev/null
  if [[ $? -eq 0 ]]; then
    log_success "Docker 安装成功。"
  else
    log_error "Docker 安装失败。"
    exit 1
  fi
}

# 函数：启动 Volara-Miner
start_miner() {
  log_info "请确保你的 Vana 网络钱包有足够的测试代币。访问水龙头：https://faucet.vana.org/moksha 领取测试代币。"
  echo -e "${YELLOW}提示：请检查你的 Vana 网络余额。领取 Moksha 测试代币后继续。${RESET}"
  
  read -sp "$(echo -e "${YELLOW}请输入你的 Metamask 私钥（不会显示在屏幕上）：${RESET}")" VANA_PRIVATE_KEY
  export VANA_PRIVATE_KEY

  if [[ -z "$VANA_PRIVATE_KEY" ]]; then
    log_error "Metamask 私钥不能为空。请重新运行脚本并输入有效的私钥。"
    exit 1
  fi

  log_info "正在拉取 Volara-Miner Docker 镜像..."
  docker pull volara/miner
  if [[ $? -eq 0 ]]; then
    log_success "Volara-Miner Docker 镜像拉取成功。"
  else
    log_error "拉取 Volara-Miner Docker 镜像失败。"
    exit 1
  fi

  log_info "正在创建 Screen 会话..."
  screen -S volara -m bash -c "docker run -it -e VANA_PRIVATE_KEY=${VANA_PRIVATE_KEY} volara/miner"

  log_info "请手动连接到 Screen 会话：screen -r volara"
  log_info "在 Screen 会话中，请按照屏幕上的指示完成 Google 认证和 X 账户登录。"

  log_success "设置完成！你可以通过访问 https://volara.xyz/ 查看你的挖矿积分。"
}

# 函数：查看 Volara-Miner 日志
view_miner_logs() {
  clear
  log_info "显示 Volara-Miner 运行的日志..."
  docker ps --filter "ancestor=volara/miner" --format "{{.Names}}" | while read container_name
  do
    echo "日志来自容器: $container_name"
    docker logs --tail 20 "$container_name"
    echo "--------------------------------------"
  done
}

# 主菜单函数
show_menu() {
  clear
  # 每次显示菜单时加载并显示 logo，增加 5 秒超时
  curl -m 5 -s https://raw.githubusercontent.com/ziqing888/logo.sh/refs/heads/main/logo.sh | bash
  echo -e "\n${BOLD}${BLUE}==================== Volara-Miner 设置 ====================${RESET}"
  echo "1. 更新和升级系统"
  echo "2. 安装 Docker"
  echo "3. 启动 Volara-Miner"
  echo "4. 查看 Volara-Miner 运行日志"
  echo "5. 退出"
  echo -e "${BOLD}===========================================================${RESET}"
  echo -n "请选择一个选项 [1-5]："
}

# 主循环
while true; do
  show_menu
  read -r choice
  case $choice in
    1)
      update_system
      ;;
    2)
      install_docker
      ;;
    3)
      start_miner
      ;;
    4)
      view_miner_logs
      ;;
    5)
      log_info "正在退出脚本，再见！"
      exit 0
      ;;
    *)
      log_warning "无效的选择。请选择一个有效的选项。"
      ;;
  esac
done

