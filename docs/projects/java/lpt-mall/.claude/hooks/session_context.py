#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SessionStart 钩子：会话启动时向 Claude 注入项目上下文摘要。

触发事件：SessionStart
stdout 内容会作为上下文展示给 Claude。exit 0。
"""
import json
import os
import sys


def main():
    raw = sys.stdin.read()
    cwd = os.getcwd()
    source = "startup"
    try:
        payload = json.loads(raw) if raw.strip() else {}
        cwd = payload.get("cwd") or cwd
        source = payload.get("source") or source
    except Exception:
        pass

    # 统计参与编译的业务模块（根 pom 中未注释的 yudao-module-*）
    modules = []
    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    if os.path.isdir(root):
        for name in sorted(os.listdir(root)):
            if name.startswith("yudao-module-") and os.path.isdir(os.path.join(root, name)):
                modules.append(name)

    lines = [
        "## 芋道（ruoyi-vue-pro）项目上下文",
        "- 项目：yudao（cn.iocoder.boot），Java 8 + Spring Boot 2.7.18，Maven 多模块。",
        "- 启动配置：`mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles=local`，默认端口 48080。",
        "- 业务模块（已启用/存在）：" + "、".join(modules) if modules else "- 业务模块：见根 pom.xml <modules>。",
        "- 核心红线：**不做任何数据库操作**（不连库、不执行 DDL/DML）；只读 `target/`、`generated-sources/`、`*.class` 等构建产物，禁止编辑。",
        "- 详细约定见 `CLAUDE.md` 与 `.claude/rules/`；脚手架可用 `.claude/skills/` 与 `.claude/commands/`。",
        "- 会话来源：" + source,
    ]
    # 去掉空行干扰
    print("\n".join(x for x in lines if x))
    return 0


if __name__ == "__main__":
    sys.exit(main())
