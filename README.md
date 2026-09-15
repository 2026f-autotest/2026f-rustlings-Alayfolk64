# 导学阶段-Rust 语言基础

基于 [LearningOS 2026s Rustlings 课程模板](https://github.com/LearningOS/2026s-rustling-classroom-template)，共 **110 题，每题 1 分，总分 110 分**。

## 使用流程

1. 加入 [OpenCamp 秋冬季训练营](https://opencamp.cn/os2edu/camp/2026fall)，并绑定自己的 GitHub 账号。
2. 点击[领取作业仓库](https://github.com/2026f-autotest/enroll/issues/new?template=rustlings.yml)，点击 **Create** 提交申请；等待机器人回复，然后接受仓库邀请。
3. 克隆分配的仓库，在 `main` 分支完成 `exercises/` 中的练习。
4. 提交并 push，在仓库 **Actions** 查看评测和上传结果，在 [OpenCamp 本阶段排行榜](https://opencamp.cn/os2edu/camp/2026fall/stage/2) 查看成绩。

本地安装 Git 和 [Rust](https://www.rust-lang.org/tools/install) 后，在自己的作业仓库中运行：

```sh
cargo run --locked -- watch
```

此命令使用仓库固定的依赖启动练习；按照终端提示修改题目，完成后移除该题的 `I AM NOT DONE` 注释。

完成一部分练习后提交：

```sh
git add exercises
git commit -m "Complete Rustlings exercises"
git push origin main
```

三条命令依次保存练习改动、创建提交、推送到 `main` 并触发自动评测。

## 计分规则

每次提交都会重新运行全部题目，以本次实际通过题数计分。编译、运行或测试失败及超时的题目记 0 分；其他已通过题目正常计分并上传。计分不按提交次数累加，也不只检查注释是否删除。

评测覆盖上游的编译运行、单元测试、Clippy 和构建脚本四类题目。单题限时 20 秒；评测工具构建失败或结果不完整时不上传成绩。

Actions 中 **Test exercises and calculate score** 变红表示还有未完成的题目；**Save measured score and upload to OpenCamp** 成功表示成绩同步成功。每道题的原始日志和成绩明细保存在该次运行的附件中。

[学员指南](docs/STUDENT_GUIDE.md) · [维护说明](docs/MAINTAINER.md) · [上游原始说明](docs/UPSTREAM-2026s.md)
