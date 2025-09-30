# 使用 Ubuntu 作为基础镜像
FROM ubuntu:24.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置工作目录
WORKDIR /app

RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list




# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    gnupg \
    software-properties-common \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 设置 Flutter 环境变量
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

# 安装 Flutter
RUN git clone https://gitee.com/mirrors/Flutter.git $FLUTTER_HOME -b stable 
# 设置 Flutter 版本
RUN cd $FLUTTER_HOME && git checkout 3.27.0
RUN flutter doctor \
    && flutter --version \
    && flutter precache --force \
    && flutter doctor --android-licenses



# 设置 Android SDK 环境变量
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# 安装 Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O android-sdk.zip && \
    unzip -q android-sdk.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm android-sdk.zip

# 接受许可
RUN yes | sdkmanager --licenses

# 安装必要的 Android SDK 组件
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" \
    "platforms;android-34" "build-tools;34.0.0" \
    "platforms;android-35" "build-tools;35.0.0"

# 复制项目文件
COPY . .
ENV PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
ENV FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
# 获取 Flutter 依赖
RUN flutter pub get

# 构建脚本
COPY build-apk.sh /app/build-apk.sh
RUN chmod +x /app/build-apk.sh

# 设置入口点
ENTRYPOINT ["/app/build-apk.sh"]