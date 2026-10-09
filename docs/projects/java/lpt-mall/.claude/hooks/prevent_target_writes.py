#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PreToolUse 钩子：拦截对构建产物 / 生成代码 / 本地个人配置的写入。

触发事件：PreToolUse（matcher: Edit|Write|MultiEdit）
输入：stdin 收到 JSON，包含 tool_name 与 tool_input.file_path。
输出：当目标路径命中红线时，打印 deny 决策 JSON，阻止写入；否则静默放行。

红线（与 CLAUDE.md / rules 一致）：
  - target/ 目录（Maven 构建产物）
  - generated-sources / generated-test-sources（注解处理器生成代码）
  - .flattened-pom.xml（flatten-maven-plugin 产物）
  - *.class 字节码
  - .settings/（Eclipse 项目元数据）
  - .claude/settings.local.json（本地个人配置，已 gitignore）
"""
import json
import os
import sys


def _norm(path):
    return os.path.normpath(path).replace("\\", "/")


def is_forbidden(path):
    if not path:
        return None
    p = _norm(path)
    checks = [
        (lambda s: "/target/" in s or s.endswith("/target"), "target/ 是 Maven 构建产物，禁止编辑"),
        (lambda s: "generated-sources" in s or "generated-test-sources" in s, "generated-sources 是注解处理器生成代码，禁止编辑"),
        (lambda s: s.endswith(".flattened-pom.xml"), ".flattened-pom.xml 是 flatten-maven-plugin 产物，禁止编辑"),
        (lambda s: s.endswith(".class"), "*.class 是编译字节码，禁止编辑"),
        (lambda s: "/.settings/" in s or s.endswith("/.settings"), ".settings/ 是 IDE 元数据，禁止编辑"),
        (lambda s: s.endswith(".claude/settings.local.json"), "settings.local.json 是本地个人配置，禁止覆盖"),
    ]
    for pred, reason in checks:
        if pred(p):
            return reason
    return None


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except Exception:
        return 0
    tool_input = payload.get("tool_input") or {}
    path = tool_input.get("file_path") or tool_input.get("path") or ""
    reason = is_forbidden(path)
    if reason:
        decision = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "[yudao] " + reason + "（路径：" + str(path) + "）。如确需修改，请手动执行或临时禁用该钩子。",
            }
        }
        print(json.dumps(decision, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
