/*
 * Copyright (C) 2012 The CyanogenMod Project
 *               2017-2019,2021 The LineageOS project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.eu.droid_ng.ngparts;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivitySettingsManager;
import android.os.Process;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class BootReceiver extends BroadcastReceiver {

    private static final String TAG = "BootReceiver";

    private static final String[] allPkgNames = new String[] {
            "com.google.android.apps.restore", "com.google.android.tts", "com.google.android.feedback",
            "com.google.android.syncadapters.contacts", "com.google.android.gms", "com.android.vending",
            "com.google.android.partnersetup", "com.google.android.syncadapters.calendar",
            "com.google.android.googlequicksearchbox", "com.google.android.setupwizard",
            "com.google.android.projection.gearhead", "com.google.android.marvin.talkback"
    };

    private static final String[] restrictedPerms = new String[] {
            "android.permission.SEND_SMS", "android.permission.RECEIVE_SMS", "android.permission.READ_SMS",
            "android.permission.RECEIVE_WAP_PUSH", "android.permission.RECEIVE_MMS", "android.permission.READ_CELL_BROADCASTS",
            "android.permission.ACCESS_BACKGROUND_LOCATION", "android.permission.READ_CALL_LOG",
            "android.permission.WRITE_CALL_LOG", "android.permission.PROCESS_OUTGOING_CALLS"
    };

    private static final String[] restrictedPkgNames = new String[] {
            "com.google.android.gms", "com.android.vending", "com.google.android.googlequicksearchbox",
            "com.google.android.setupwizard", "com.google.android.projection.gearhead", "com.google.android.apps.restore"
    };

    @Override
    public void onReceive(Context ctx, Intent intent) {
        Log.i("NgParts", "BootReciever: welcome to droid-ng!");
        /* gms feature */
        if (needWhitelist(ctx)) {
            Log.i("NgParts", "GmsFeature: setting up google features");
            addAllUids(ctx, getUidsForPkgNames(ctx));
            setupPermissions(ctx);
        } else {
            Log.i("NgParts", "GmsFeature: skipped setting up google features");
        }
    }

    @SuppressLint("NewApi")
    private static void setupPermissions(Context ctx) {
        PackageManager pm = ctx.getPackageManager();

        for (String pkg : restrictedPkgNames) {
            for (String perm : restrictedPerms) {
                try {
                    pm.addWhitelistedRestrictedPermission(pkg, perm, PackageManager.FLAG_PERMISSION_WHITELIST_SYSTEM);
                } catch (SecurityException | IllegalArgumentException | IllegalStateException e) {
                    e.printStackTrace();
                }
            }
        }

        // Recommened default permissions
        grantPermissions(pm, "com.google.android.gms", new String[] {
                "android.permission.SEND_SMS", "android.permission.RECEIVE_SMS", "android.permission.READ_SMS",
                "android.permission.RECEIVE_WAP_PUSH", "android.permission.RECEIVE_MMS",
                "android.permission.READ_CELL_BROADCASTS", "android.permission.ACCESS_BACKGROUND_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.ACTIVITY_RECOGNITION", "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "android.permission.BODY_SENSORS", "android.permission.CAMERA",
                "android.permission.RECORD_AUDIO", "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE",
                "android.permission.ACCESS_MEDIA_LOCATION", "android.permission.FAKE_PACKAGE_SIGNATURE", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.gsf", new String[] {
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "com.google.android.providers.talk.permission.READ_ONLY",
                "com.google.android.providers.talk.permission.WRITE_ONLY"
        });
        grantPermissions(pm, "com.google.android.googlequicksearchbox", new String[] {
                "android.permission.SEND_SMS", "android.permission.RECEIVE_SMS", "android.permission.READ_SMS",
                "android.permission.RECEIVE_WAP_PUSH", "android.permission.RECEIVE_MMS",
                "android.permission.READ_CELL_BROADCASTS", "android.permission.ACCESS_BACKGROUND_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.ACTIVITY_RECOGNITION", "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "android.permission.CAMERA", "android.permission.READ_CALENDAR",
                "android.permission.RECORD_AUDIO", "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE",
                "android.permission.ACCESS_MEDIA_LOCATION","android.permission.WRITE_CALENDAR", "android.permission.ACCESS_FINE_LOCATION",
                "android.permission.ACCESS_COARSE_LOCATION", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.android.vending", new String[] {
                "android.permission.SEND_SMS", "android.permission.RECEIVE_SMS", "android.permission.READ_SMS",
                "android.permission.RECEIVE_WAP_PUSH", "android.permission.RECEIVE_MMS",
                "android.permission.READ_CELL_BROADCASTS", "android.permission.ACCESS_BACKGROUND_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE",
                "android.permission.ACCESS_MEDIA_LOCATION", "android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION",
                "android.permission.FAKE_PACKAGE_SIGNATURE", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.setupwizard", new String[] {
                "android.permission.ACCESS_BACKGROUND_LOCATION", "android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "android.permission.CAMERA", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.marvin.talkback", new String[] {
                "android.permission.ACCESS_BACKGROUND_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.CAMERA", "android.permission.RECORD_AUDIO",
                "android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.syncadapters.calendar", new String[]{
                "android.permission.READ_CALENDAR", "android.permission.WRITE_CALENDAR", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.syncadapters.contacts", new String[]{
                "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS", "android.permission.GET_ACCOUNTS", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.tts", new String[] {
                "android.permission.RECORD_AUDIO", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.markup", new String[] {
                "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE",
                "android.permission.ACCESS_MEDIA_LOCATION"
        });
        grantPermissions(pm, "com.google.android.apps.restore", new String[] {
                "android.permission.ACCESS_BACKGROUND_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.POST_NOTIFICATIONS"
        });
        grantPermissions(pm, "com.google.android.projection.gearhead", new String[] {
                "android.permission.SEND_SMS", "android.permission.RECEIVE_SMS", "android.permission.READ_SMS",
                "android.permission.RECEIVE_WAP_PUSH", "android.permission.RECEIVE_MMS",
                "android.permission.READ_CELL_BROADCASTS", "android.permission.ACCESS_BACKGROUND_LOCATION",
                "android.permission.READ_CALL_LOG", "android.permission.WRITE_CALL_LOG",
                "android.permission.PROCESS_OUTGOING_CALLS", "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING", "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE", "android.permission.ADD_VOICEMAIL", "android.permission.USE_SIP",
                "android.permission.READ_CONTACTS", "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS", "android.permission.READ_CALENDAR",
                "android.permission.RECORD_AUDIO", "android.permission.WRITE_CALENDAR", "android.permission.ACCESS_FINE_LOCATION",
                "android.permission.ACCESS_COARSE_LOCATION", "android.permission.POST_NOTIFICATIONS"
        });
    }

    private static void grantPermissions(PackageManager pm, String pkg, String[] perms) {
        for (String perm : perms) {
            grantPermission(pm, pkg, perm);
        }
    }

    private static void grantPermission(PackageManager pm, String pkg, String perm) {
        try {
            pm.grantRuntimePermission(pkg, perm, Process.myUserHandle());
            pm.updatePermissionFlags(perm, pkg, PackageManager.FLAG_PERMISSION_GRANTED_BY_DEFAULT,
                    PackageManager.FLAG_PERMISSION_GRANTED_BY_DEFAULT, Process.myUserHandle());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private static boolean needWhitelist(Context ctx) {
        PackageManager pm = ctx.getPackageManager();

        Set<Integer> uids =
                ConnectivitySettingsManager.getUidsAllowedOnRestrictedNetworks(
                        ctx);
        try {
            return !uids.contains(getUidForPkgName(pm, "com.google.android.gms"));
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private static List<Integer> getUidsForPkgNames(Context ctx) {
        PackageManager pm = ctx.getPackageManager();
        ArrayList<Integer> u = new ArrayList<>();
        for (String pkgName : BootReceiver.allPkgNames) {
            try {
                u.add(getUidForPkgName(pm, pkgName));
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        }
        return u.stream().distinct().collect(Collectors.toList());
    }

    private static int getUidForPkgName(PackageManager pm, String pkgName) throws PackageManager.NameNotFoundException {
        return pm.getApplicationInfo(pkgName, 0).uid;
    }

    private static void addAllUids(Context ctx, List<Integer> uid) {
        Set<Integer> uids =
                ConnectivitySettingsManager.getUidsAllowedOnRestrictedNetworks(
                        ctx);
        uids.addAll(uid);
        ConnectivitySettingsManager.setUidsAllowedOnRestrictedNetworks(ctx,
                uids);
    }

}
