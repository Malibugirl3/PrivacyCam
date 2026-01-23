# PrivacyCam - Invisible Cloak for Social Media

> Protect your photos from AI face recognition using adversarial perturbation technology.

## 🎯 Overview

PrivacyCam is a mobile application that adds an invisible "cloak" to your photos before sharing them on social media. Using adversarial perturbation technology, the app generates imperceptible noise that:

- **For Human Eyes**: Photos remain clear and beautiful
- **For Malicious AI**: Face recognition algorithms fail to identify or misclassify faces

## ✨ Features

- 📷 **Camera Integration** - Take photos directly within the app
- 🖼️ **Gallery Import** - Select existing photos from your album
- 🛡️ **Privacy Protection** - Apply adversarial perturbation to images
- 👁️ **Preview & Compare** - View before/after comparison
- 📤 **Easy Sharing** - Share directly to WeChat, Xiaohongshu, etc.
- ⚡ **Fast Processing** - Cloud-based or local processing options

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│       Presentation Layer            │
│   (Pages / Widgets / Providers)     │
├─────────────────────────────────────┤
│       Application Layer             │
│   (Controllers / Managers)          │
├─────────────────────────────────────┤
│         Domain Layer                │
│   (Services / Models - Interface)   │
├─────────────────────────────────────┤
│      Infrastructure Layer           │
│   (Cloud / Local Implementation)    │
└─────────────────────────────────────┘
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.16+ |
| Language | Dart 3.2+ |
| State Management | Riverpod |
| Routing | go_router |
| HTTP Client | Dio |
| Image Processing | image, image_picker |
| Permissions | permission_handler |
| Sharing | share_plus |

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/your-org/privacy_cam.git

# Navigate to project directory
cd privacy_cam

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration
├── presentation/             # UI Layer
│   ├── pages/               # Screen widgets
│   ├── widgets/             # Reusable components
│   └── providers/           # State providers
├── application/             # Business logic
├── domain/                  # Interfaces & models
├── infrastructure/          # Implementations
└── core/                    # Utilities & constants
```

## 🚀 Getting Started

1. Ensure Flutter 3.16+ is installed
2. Run `flutter doctor` to verify setup
3. Clone and run the project

## 📄 License

MIT License

---

# PrivacyCam - 朋友圈隐形衣

> 利用对抗扰动技术，保护你的照片免受 AI 人脸识别。

## 🎯 项目概述

PrivacyCam 是一款移动应用，在你分享照片到社交媒体之前，为照片添加一层"隐形衣"。利用对抗扰动技术，生成肉眼不可见的噪声：

- **对人眼**：照片依然清晰美观
- **对恶意AI**：人脸识别算法无法识别或会产生误判

## ✨ 功能特性

- 📷 **相机集成** - 直接在应用内拍照
- 🖼️ **相册导入** - 从相册选择已有照片
- 🛡️ **隐私保护** - 为图片添加对抗扰动
- 👁️ **预览对比** - 查看处理前后对比
- 📤 **便捷分享** - 直接分享到微信、小红书等
- ⚡ **快速处理** - 支持云端或本地处理

## 🏗️ 系统架构

```
┌─────────────────────────────────────┐
│          表现层                      │
│   (页面 / 组件 / 状态管理)           │
├─────────────────────────────────────┤
│          应用业务层                  │
│   (控制器 / 管理器)                  │
├─────────────────────────────────────┤
│          领域接口层                  │
│   (服务接口 / 数据模型)              │
├─────────────────────────────────────┤
│          基础设施层                  │
│   (云端实现 / 本地实现)              │
└─────────────────────────────────────┘
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.16+ |
| 语言 | Dart 3.2+ |
| 状态管理 | Riverpod |
| 路由管理 | go_router |
| 网络请求 | Dio |
| 图片处理 | image, image_picker |
| 权限管理 | permission_handler |
| 分享功能 | share_plus |

## 📦 安装指南

```bash
# 克隆仓库
git clone https://github.com/your-org/privacy_cam.git

# 进入项目目录
cd privacy_cam

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 📁 项目结构

```
lib/
├── main.dart                 # 入口文件
├── app.dart                  # 应用配置
├── presentation/             # 表现层
│   ├── pages/               # 页面
│   ├── widgets/             # 可复用组件
│   └── providers/           # 状态管理
├── application/             # 业务逻辑层
├── domain/                  # 领域层（接口与模型）
├── infrastructure/          # 实现层
└── core/                    # 工具与常量
```

## 🚀 快速开始

1. 确保已安装 Flutter 3.16+
2. 运行 `flutter doctor` 验证环境
3. 克隆并运行项目

## 👥 团队分工

| 角色 | 负责内容 |
|------|----------|
| 算法组 | 人脸隐私算法、像素扰动、水印技术 |
| 测试组 | 扰动效果测试、数据评估 |
| App组 | 移动端开发、UI/UX、接口对接 |

## 📄 开源协议

MIT License
