#!/bin/bash

# 必要なロケールを生成
sudo locale-gen en_US.UTF-8

# システムのロケール設定を更新
sudo update-locale LANG=en_US.UTF-8 LANGUAGE="en_US:en" LC_ALL=en_US.UTF-8

# ロケールの設定を確認
locale