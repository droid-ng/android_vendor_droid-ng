# Additional help function
# Print extra information when user types "hmm"
__customer_help() {
cat <<EOF
Additional droid-ng functions:
- ngremote:        Add git remote for droid-ng GitHub.
- lineageremote:   Add git remote for LineageOS GitHub.
- ghfork:          Fork repo from LibreMobileOS, or if branch-repo combo doesn't exist, create one.
- eatwrp:          eat, but for TWRP.
- lmofetch:        Fetch current repo from LibreMobileOS (or LineageOS or AOSP).
- losfetch:        Fetch current repo from LineageOS (or AOSP).
- aospfetch:       Fetch current repo from AOSP.
- push:            Push new commits to droid-ng github.
- merge:           Merge current repo with upstream.
- pull:            Pull new commits from droid-ng github.
- pushall:         Push new commits from all repos to droid-ng github.
- mergeall:        Merge all repos with LMODroid.
- pullall:         Pull all repos' commits from droid-ng github.
EOF
}

# Customer build prefix
# If undefined, customer can provide custom __customer_check_product
# If empty, prefix is disabled
# Advantage: support multiple configurations in one build.
# Disadvantage: does not support CTS test.
# Default: lmodroid_
# export CUSTOMER_BUILD_PREFIX=lmodroid_
__customer_check_product() {
if (echo -n $1 | grep -q -e "^ng_") ; then
    echo -n $1 | sed -e 's/^ng_//g'
else
if (echo -n $1 | grep -q -e "^lmodroid_") ; then
    echo -n $1 | sed -e 's/^lmodroid_//g'
fi
fi
}

# active branch
if [ -z "$NG_BRANCH" ]; then
    NG_BRANCH=ng-v4
fi

# device branch
if [ -z "$DEV_BRANCH" ]; then
    DEV_BRANCH=ng-v4
fi

# lmodroid branch
if [ -z "$LMO_BRANCH" ]; then
    LMO_BRANCH=thirteen
fi

# lineage branch
if [ -z "$LOS_BRANCH" ]; then
    LOS_BRANCH=lineage-20.0
fi
if [ -z "$LOS_BRANCH2" ]; then
    LOS_BRANCH2=lineage-20
fi

# aosp tag
if [ -z "$AOSP_TAG" ]; then
    AOSP_TAG=$(python3 $ANDROID_BUILD_TOP/vendor/droid-ng/tools/get-aosp-tag.py)
fi

function lmoremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm lmogerrit 2> /dev/null
    local REMOTE=$(git config --get remote.lmodroid.projectname)
    local LMODROID="true"
    local LINEAGE="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.lineage.projectname)
        LMODROID="false"
    else
        LINEAGE="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.aosp.projectname)
        LMODROID="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.clo.projectname)
        LMODROID="false"
    fi

    if [ $LINEAGE = "true" ]
    then
        local PFX="LMODroid/"
        local PROJECT=$(echo $REMOTE | sed -e "s#android_#platform_#g")
    else
       if [ $LMODROID = "false" ]
        then
            local PROJECT=$(echo $REMOTE | sed -e "s#/#_#g")
            local PFX="LMODroid/"
        else
            local PROJECT=$REMOTE
        fi
    fi

    local LMO_USER=$(git config --get review.gerrit.libremobileos.com.username)
    if [ -z "$LMO_USER" ]
    then
        git remote add lmogerrit ssh://gerrit.libremobileos.com:29418/$PFX$PROJECT
    else
        git remote add lmogerrit ssh://$LMO_USER@gerrit.libremobileos.com:29418/$PFX$PROJECT
    fi
    echo "Remote 'lmogerrit' created"
}

function ngremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm ng 2> /dev/null
    local REMOTE=$(git config --get remote.lmodroid.projectname)
    local LMODROID="true"
    local LINEAGE="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.lineage.projectname)
        LMODROID="false"
    else
        LINEAGE="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.clo.projectname)
        LMODROID="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.aosp.projectname)
        LMODROID="false"
    fi
    if [ -z "$REMOTE" ]
    then
        echo "Failed to find repo name."
        return 1
    fi

    if [ $LMODROID = "false" ]
    then
        local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")
    else
        if [ $LINEAGE = "true" ]
        then
            local PROJECT=$REMOTE
        else
            local PROJECT=$(echo $REMOTE | sed -e "s#LMODroid/##g; s#platform_#android_#g")
        fi
    fi
    local ORG=droid-ng
    local PFX="$ORG/"

    git remote add ng ssh://git@github.com/$PFX$PROJECT
    echo "Remote 'ng' created"
}

function lineageremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm lineage 2> /dev/null
    local REMOTE=$(git config --get remote.lmodroid.projectname)
    local LMODROID="true"
    local NG="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.ng.url | sed -e 's#.*[:/]droid-ng/##g')
        LMODROID="false"
    else
        NG="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.clo.projectname)
        LMODROID="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.aosp.projectname)
        LMODROID="false"
    fi
    if [ -z "$REMOTE" ]
    then
        echo "Failed to find repo name."
        return 1
    fi

    if [ $LMODROID = "false" ]
    then
        local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")
    else
        if [ $NG = "true" ]
        then
            local PROJECT=$REMOTE
        else
        	local PROJECT=$(echo $REMOTE | sed -e "s#LMODroid/##g; s#platform_#android_#g")
        fi
    fi
    local ORG=LineageOS
    local PFX="$ORG/"

    git remote add lineage ssh://git@github.com/$PFX$PROJECT
    echo "Remote 'lineage' created"
}

function mfrebase()
{
    cd $ANDROID_BUILD_TOP/manifest
    git checkout ng-v4-githubmirror
    git reset --hard ng-v4
    git cherry-pick HEAD@{1}
    git checkout ng-v4
}

function ghfork()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    local REMOTE=$(git config --get remote.lmodroid.projectname)
    local LMODROID="true"
    local LINEAGE="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.lineage.projectname)
        LMODROID="false"
    else
        LINEAGE="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.aosp.projectname)
        LMODROID="false"
    fi
    if [ -z "$REMOTE" ]
    then
	echo "Failed to find repo name."
	return 1
    fi
    git remote rm ng 2> /dev/null
    local ORG=droid-ng
    local PFX="$ORG/"
    if [ $LMODROID = "false" ] && [ $LINEAGE = "false" ]
    then
        local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")
        local REPO=$PFX$PROJECT
        gh repo create --public --disable-wiki --disable-issues $ORG/"$PROJECT"
    else
        if [ $LINEAGE = "true" ]
        then
            local PROJECT=$REMOTE
            local FORG=LineageOS
            local FNAME=$PROJECT
        else
            local PROJECT=$(echo $REMOTE | sed -e "s#LMODroid/##g")
            local FNAME=$(echo $PROJECT | sed -e "s#platform_#android_#g")
            local FORG=LMODroid
        fi
        local REPO=$PFX$FNAME
        gh repo fork --org=$ORG --remote=false --clone=false --fork-name="$FNAME" "$FORG"/"$PROJECT"
    fi
    git remote add ng ssh://git@github.com/"$REPO"
    sleep 1
    git push ng HEAD:refs/heads/"$NG_BRANCH"
    gh repo edit "$REPO" --default-branch="$NG_BRANCH"
    cd "$ANDROID_BUILD_TOP/manifest"
    for branch in $(git ls-remote --heads ssh://git@github.com/"$REPO" | cut -f2); do 
        if [ "$branch" != "refs/heads/$NG_BRANCH" ]; then
            echo Deleting "$branch"
            git push --delete ssh://git@github.com/"$REPO" "$branch"
        fi
    done
    cd -

    echo -n "Repo '$REPO' created"
    if [ $LMODROID = "true" ]
    then
        echo -n " (forked from 'LMODroid/$PROJECT')"
    fi
    echo ", pushed HEAD as '$NG_BRANCH', set it to default branch, created remote 'ng' and deleted all irrelevant branches from remote."
}

function eatwrp()
{
    if [ "$OUT" ] ; then
        ZIPPATH=`ls -tr "$OUT"/droid-ng-*.zip | tail -1`
        if [ ! -f $ZIPPATH ] ; then
            echo "Nothing to eat"
            return 1
        fi
        if [[ "$(adb get-state)" != sideload ]]
        then
            echo "Waiting for device..."
            adb wait-for-device-recovery
            echo "Found device"
            if ! (adb shell getprop ro.lmodroid.device | grep -q "$LMODROID_BUILD"); then
                echo "The connected device does not appear to be $LMODROID_BUILD, run away!"
                return 1
            else
                echo "Please reboot to recovery and start sideload for install"
            fi
        fi
        adb wait-for-sideload
        adb sideload $ZIPPATH
        adb wait-for-recovery
        adb shell twrp reboot
        return $?
    else
        echo "Nothing to eat"
        return 1
    fi
}

function lmofetch() {
    local REMOTE=$(git config --get remote.ng.url)
    if [ -z "$REMOTE" ]
    then
        if [ -z "$ngtext" ]
        then
            echo "Is this an droid-ng repo?"
        fi
        return 1
    fi
    echo -n "$ngtext"
    local REMOTE=$(git config --get remote.lmogerrit.url)
    if [ -z "$REMOTE" ]
    then
        lmoremote
    fi
    local REMOTE=$(git config --get remote.lmogerrit.url)
    if ! git ls-remote --heads "$REMOTE" 2>/dev/null | cut -f2 | grep -q "$LMO_BRANCH"; then
        echo -n "LMO has no branch for this repo, fetching from LOS"
        ngtext="\n" losfetch
        return 0
    fi
    git fetch lmodroid "$LMO_BRANCH"
}

function losfetch() {
    local REMOTE=$(git config --get remote.ng.url)
    if [ -z "$REMOTE" ]
    then
        if [ -z "$ngtext" ]
        then
            echo "Is this an droid-ng repo?"
        fi
        return 1
    fi
    echo -n "$ngtext"
    local REMOTE=$(git config --get remote.lineage.url)
    if [ -z "$REMOTE" ]
    then
        lineageremote
    fi
    local REMOTE=$(git config --get remote.lineage.url)
    local BRNCH="$LOS_BRANCH"
    if ! git ls-remote --heads "$REMOTE" 2>/dev/null | cut -f2 | grep -q "$BRNCH"; then
        BRNCH="$LOS_BRANCH2"
        if ! git ls-remote --heads "$REMOTE" 2>/dev/null | cut -f2 | grep -q "$BRNCH"; then
            echo -n "LOS has no branch for this repo, fetching from AOSP"
            ngtext="\n" aospfetch
            return 0
        fi
    fi
    git fetch lineage "$BRNCH"
}

function aospfetch() {
    local REMOTE=$(git config --get remote.ng.url)
    if [ -z "$REMOTE" ]
    then
        if [ -z "$ngtext" ]
        then
            echo "Is this an droid-ng repo?"
        fi
    	return 1
    fi
    echo -n "$ngtext"
    local REMOTE=$(git config --get remote.aosp.url)
    if [ -z "$REMOTE" ]
    then
        aospremote
    fi
    local REMOTE=$(git config --get remote.aosp.url)
    local AOSP_TAG=$(python3 $ANDROID_BUILD_TOP/vendor/droid-ng/tools/get-aosp-tag.py)
    git fetch aosp "$AOSP_TAG"
}

function merge() {
    lmofetch || return 0
    git merge FETCH_HEAD || $SHELL
}

function push() {
    local REMOTE=$(git config --get remote.ng.url)
    local RH=ng
    local BRNCH=$NG_BRANCH
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.devices.projectname)
        RH=devices
        BRNCH=$DEV_BRANCH
    fi
    if [ -z "$REMOTE" ]
    then
        if [ -z "$ngtext" ]
        then
            echo "Is this an droid-ng repo?"
        fi
        return 1
    fi
    echo -n "$ngtext"
    git push "$RH" HEAD:"$BRNCH" $@
    if git show-ref --quiet refs/heads/ng-v4-githubmirror; then
        git push ng ng-v4-githubmirror >/dev/null 2>&1 || git push ng ng-v4-githubmirror -f
        git branch -D ng-v4-githubmirror
    fi
}

function pull() {
    local REMOTE=$(git config --get remote.ng.url)
    local RH=ng
    local BRNCH=$NG_BRANCH
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.devices.url)
        RH=devices
        BRNCH=$DEV_BRANCH
    fi
    if [ -z "$REMOTE" ]
    then
        if [ -z "$ngtext" ]
        then
        	echo "Is this an droid-ng repo?"
        fi
        return 1
    fi
    echo -n "$ngtext"
    git pull "$RH" "$BRNCH" $@
}

function mergeall() {
    for i in $(repo forall -c pwd); do  # For every repo project..
    if [[ "$i" != "$ANDROID_BUILD_TOP/ng/"* ]] && # except ng/*...
        [[ "$i" != "$ANDROID_BUILD_TOP/vendor/droid-ng"* ]]; then  # and droid-ng vendor...
        # which are no forks..
        cd $i; ngtext="$(pwd | cut -b $((${#ANDROID_BUILD_TOP} + 2))- ): " lmomerge $@; cd - 1>/dev/null # merge from LMODroid.
    fi; done
}

function pushall() {
    for i in $(repo forall -c pwd); do  # For every repo project..
        cd $i; ngtext="$(pwd | cut -b $((${#ANDROID_BUILD_TOP} + 2))- ): " push $@; cd - 1>/dev/null # push
    done
}

function pullall() {
    for i in $(repo forall -c pwd); do  # For every repo project..
        cd $i; ngtext="$(pwd | cut -b $((${#ANDROID_BUILD_TOP} + 2))- ): " pull $@; cd - 1>/dev/null # pull
    done
}
