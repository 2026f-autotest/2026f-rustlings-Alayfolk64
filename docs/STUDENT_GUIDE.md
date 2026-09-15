# 导学阶段-Rust 语言基础：提交作业

1. 加入 [OpenCamp 秋冬季训练营](https://opencamp.cn/os2edu/camp/2026fall)，并绑定自己的 GitHub 账号。
2. 点击[领取作业仓库](https://github.com/2026f-autotest/enroll/issues/new?template=rustlings.yml)，提交申请并接受机器人回复中的仓库邀请。
3. 安装 Git，克隆回复中的仓库，进入仓库目录。
4. 首次使用时完成下面的环境配置，之后运行 `cargo run -- watch`，按照提示完成 `exercises/` 中的题目。
5. 执行 `git add exercises` 保存练习改动，执行 `git commit -m "Complete Rustlings exercises"` 创建提交，再执行 `git push origin main` 推送。
6. 在仓库 Actions 查看评测和成绩上传结果，在 [OpenCamp 本阶段](https://opencamp.cn/os2edu/camp/2026fall/stage/2) 查看排行榜。

OpenCamp 绑定的账号、领取仓库的账号和推送使用的 GitHub 账号应一致。可以完成部分题目后提交，成绩为本次实际通过题数，总分 110 分。

## 首次配置环境

进入自己的作业仓库目录，按照操作系统执行一次配置命令。

**Windows（64 位 Intel / AMD）**：在 PowerShell 中运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

此命令在独立的 PowerShell 进程中执行配置脚本；`-NoProfile` 跳过个人配置，`-ExecutionPolicy Bypass` 只在该进程中允许脚本运行，`-File` 指定脚本。

**macOS / Linux**：在终端中运行：

```sh
bash setup.sh
```

此命令使用 Bash 执行配置脚本。macOS 需要先安装 Command Line Tools，Linux 需要系统 C 编译器。

脚本会准备课程需要的 Rust 环境，并直接启动练习。按照终端提示修改题目，完成后移除对应的 `I AM NOT DONE` 注释。输入 `quit` 退出。

## 以后继续练习

重新打开终端，进入作业仓库目录，运行：

```sh
cargo run -- watch
```

此命令启动练习检查器，保存题目后自动重新检查。
