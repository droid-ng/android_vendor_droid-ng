# Extra stuff for config.mk goes here

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/droid-ng/build/security/ng

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += \
    vendor/droid-ng/overlay/branding \
    vendor/droid-ng/overlay/translations

PRODUCT_PACKAGE_OVERLAYS += \
    vendor/droid-ng/overlay/branding \
    vendor/droid-ng/overlay/common \
    vendor/droid-ng/overlay/translations
