# 图示资源

README 里的编排流程图是 GitHub 原生渲染的 Mermaid（直接写在 `README.md` 的代码块里），**无需任何工具即可显示**。

本目录保存同一张图的源文件，方便日后规则变动后重新生成静态图片（PNG/SVG）：

- `orchestration-flow.mmd` —— 流程图源码（与 README 中的 Mermaid 保持一致）

## 重新生成静态图片

安装 [mermaid-cli](https://github.com/mermaid-js/mermaid-cli) 后：

```bash
# 深色背景 PNG
mmdc -i orchestration-flow.mmd -o orchestration-flow.png -b '#0d1117' -t dark

# 或导出 SVG
mmdc -i orchestration-flow.mmd -o orchestration-flow.svg -t dark
```

> 改了编排规则后，记得同步更新 `README.md` 里的 Mermaid 代码块和本目录的 `.mmd` 源文件。
