wget https://raw.githubusercontent.com/ziqing888/Volara-Miner/refs/heads/main/Volara.sh -O Volara.sh && chmod +x Volara.sh && ./Volara.sh

这是一份在 Ubuntu 上安装和运行 Rivalz CLI 的详细指南。请按照以下步骤进行操作：

第一步：准备服务器
首先，更新你的服务器并安装必要的软件包：

更新服务器：

bash
复制代码
apt update && apt upgrade -y
安装 curl：

bash
复制代码
apt install curl
安装 Node.js 20：

bash
复制代码
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
然后运行：

bash
复制代码
apt install -y nodejs
检查 Node.js 版本：

bash
复制代码
nodejs -v
安装 Rivalz CLI：

bash
复制代码
npm i -g rivalz-node-cli
第二步：运行 Rivalz
安装 screen：

bash
复制代码
apt install screen
在 screen 中创建一个新会话：

bash
复制代码
screen -S rivalz
更新并运行 Rivalz：

更新 Rivalz 版本：
bash
复制代码
rivalz update-version
运行 Rivalz：
bash
复制代码
rivalz run
输入配置信息：

输入你的钱包地址
选择要使用的 CPU 和 RAM
选择硬盘类型及分配的存储空间
如果安装成功，系统将显示类似“安装成功”的提示。
