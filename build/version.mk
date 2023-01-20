# Copyright (C) 2020 The PixelExperience Project
# Copyright (C) 2020 The LibreMobileOS Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Customer version settings

# Customer version variable name
# Default: LMODROID_BUILD_VERSION
CUSTOMER_VERSION_VAR_NAME := NG_BUILD_VERSION

# Customer specific code below

# Set NG_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat
ifndef NG_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "NG_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^NG_||g')
        NG_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif
NG_BUILDTYPE ?= $(LMODROID_BUILDTYPE)

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY WEEKLY EXPERIMENTAL,$(NG_BUILDTYPE)),)
    NG_BUILDTYPE := UNOFFICIAL
endif

DATE_YEAR := $(shell date -u +%Y)
DATE_MONTH := $(shell date -u +%m)
DATE_DAY := $(shell date -u +%d)
ifeq ($(filter UNOFFICIAL,$(NG_BUILDTYPE)),)
    BUILD_DATE := $(DATE_YEAR)$(DATE_MONTH)$(DATE_DAY)
else
    DATE_HOUR := $(shell date -u +%H)
    DATE_MINUTE := $(shell date -u +%M)
    BUILD_DATE := $(DATE_YEAR)$(DATE_MONTH)$(DATE_DAY)-$(DATE_HOUR)$(DATE_MINUTE)
endif

NG_VERSION ?= 4.0
NG_NAME ?= droid-ng
PRODUCT_BRAND := droid-ng
NG_BUILD_VERSION := $(NG_NAME)-$(NG_VERSION)-$(BUILD_DATE)-$(NG_BUILDTYPE)-$(LMODROID_BUILD)

LMODROID_PROPERTIES := \
    ro.lmodroid.build_name=$(NG_BUILD_NAME) \
    ro.lmodroid.build_date=$(BUILD_DATE) \
    ro.lmodroid.build_type=$(NG_BUILDTYPE) \
    ro.lmodroid.version=$(NG_VERSION)
