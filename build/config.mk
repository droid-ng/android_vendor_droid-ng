# Extra stuff for config.mk goes here

# used by SdkLite library
PRODUCT_PROPERTY_OVERRIDES += \
    ro.ng.build.version.plat.sdk=1

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
