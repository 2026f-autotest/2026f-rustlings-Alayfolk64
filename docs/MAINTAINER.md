# Rustlings 课程维护

模板：[2026f-autotest/2026f-rustlings](https://github.com/2026f-autotest/2026f-rustlings)。

课程配置保存在 `course.json`：课程编号 2084，组织 Secret 名称 `OSCAMP_2026F_RUSTLINGS_TOKEN`，共享范围为 Public repositories。领取入口读取 `enroll/courses.json`，使用 Issue 作者设置 `STUDENT_GITHUB`；正式仓库名为 `2026f-rustlings-GitHub登录名`。

上游为 `LearningOS/2026s-rustling-classroom-template`，源码提交 `ade06927b84603689356bde886616dd40d3265de`。保留全部 110 题、题目模式和每题 1 分规则；上游已有的示例代码一并保留。

## 修改说明

- 修改新学员看到的说明：编辑本模板的 `README.md` 和 `docs/STUDENT_GUIDE.md`，提交到 `main`。已有学员仓库不会自动更新。
- 修改领取标题、表单或机器人回复：编辑 [enroll 仓库](https://github.com/2026f-autotest/enroll) 的表单或 `enroll.py`。
- 助教备用建仓：在本模板运行 `python3 enroll.py GitHub登录名`。脚本使用维护者已有的 GitHub CLI 授权，完成检查后才发布正式仓库。

## 评测与上传

`.github/scripts/grade.py` 先构建固定依赖的 Rustlings 工具，再逐题执行上游 `rustlings --nocapture run 题目名`。顺序运行避免 Clippy 和构建脚本同时改写 Cargo.toml；每题限时 20 秒，原始输出保存至 `tmp/grade/`。

测试题及构建脚本题必须实际运行至少一个成功测试。编译运行和 Clippy 题必须命令成功且产生上游成功输出。课程清单缺项、改序或文件缺失都会中止，不上传不完整成绩。

评测作业不读取课程凭证。独立上传作业取得本次不可变附件、验证仓库和学员身份，将实测成绩保存到 `gh-pages`，收到 OpenCamp `result=1` 后记录 accepted。模板及 preparing 仓库不会上传。

临时文件与构建产物在仓库的 `tmp/` 中。评测工具使用 `tmp/target`，每轮练习使用独立 Cargo 产物目录，避免 Clippy 清理工具自身以及构建脚本时间戳缓存过期。Rust 工具链固定为 1.98.1，包含 Clippy。

## 检查和重跑

运行 `python3 -m unittest discover -s .github/tests -v` 检查身份、分数验证、上传状态与领取逻辑。运行 `python3 .github/scripts/grade.py` 执行全部真实题目评测；这一命令只生成本地成绩。

成绩上传失败时，在同一次 Actions 运行中重跑上传作业；已保留的实测结果会重新校验并上传。领取失败的维护流程见 [enroll 维护文档](https://github.com/2026f-autotest/enroll/blob/main/docs/MAINTAINER.md)。
