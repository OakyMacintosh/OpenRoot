LOCAL_PATH := $(call my-dir)

ROOTD_PATH := ./rootd

include $(CLEAR_VARS)
LOCAL_MODULE    := rootd
LOCAL_SRC_FILES := rootd.cc
include $(BUILD_SHARED_LIBRARY)
