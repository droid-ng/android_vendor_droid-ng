# Extra stuff for config.mk goes here

# used by SdkLite library
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ng.build.version.plat.sdk=1

ifeq ($(TARGET_BUILD_VARIANT),user)
# NOTE: enabling this on user builds causes adbd crashes
# because the SEPolicy for "su" domain is missing. A commit
# like this is STRICTLY required for it to work!!!
# https://github.com/droidng/android_system_sepolicy/commit/b491a953db739aa2daffabc13c9b153d329013ee
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
        ro.debuggablr=0
else
# P.S.: debuggablr is not a typo
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
        ro.debuggablr=1
endif

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/droid-ng/build/security/ng

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += \
    vendor/droid-ng/overlay/branding \
    vendor/droid-ng/overlay/translations \
    vendor/droid-ng/overlay/wallpapers_1080p \
    vendor/droid-ng/overlay/wallpapers_1440p

PRODUCT_PACKAGE_OVERLAYS += \
    vendor/droid-ng/overlay/branding \
    vendor/droid-ng/overlay/common \
    vendor/droid-ng/overlay/translations

ifeq ($(shell test $(TARGET_SCREEN_WIDTH) -gt 1080; echo $$?),0)
PRODUCT_PACKAGE_OVERLAYS += vendor/droid-ng/overlay/wallpapers_1440p
else
PRODUCT_PACKAGE_OVERLAYS += vendor/droid-ng/overlay/wallpapers_1080p
endif

PRODUCT_PACKAGES += \
    NgParts
