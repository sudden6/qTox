#!/bin/bash
#
#    Copyright © 2017-2018 The qTox Project Contributors
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Create a `lzip` archive and make a detached GPG signature for it.
#
# When tag name is supplied, it's used to create archive. If there is no tag
# name supplied, latest tag is used.

# Requires:
#   * GPG
#   * git
#   * lzip

# use GPG_KEY_ID for selecting the GPG key to use
# GPG_KEY_ID can be a fingerprint like 0xDEADDEAD or an email address in the
# format <example@example.com>

# usage:
#   ./$script [GPG_KEY_ID]

readonly GPG_KEY_ID="$1"

# Fail as soon as error appears
set -eu -o pipefail

archive_from_tag() {
    git archive --format=tar "$1" \
    | lzip --best \
    > "$1".tar.lz
    echo "$@.tar.lz archive has been created."
}

sign_archive() {
    if [ -n "$2" ]
    then
        gpg \
        --armor \
        --detach-sign \
        --local-user "$2" \
        "$1".tar.lz
    else
        gpg \
        --armor \
        --detach-sign \
        "$1".tar.lz
    fi
    echo "$1.tar.lz.asc signature has been created."
}

get_tag() {
    git describe --abbrev=0
}

create_and_sign() {
    local TAG="$(get_tag)"
    archive_from_tag "$TAG"
    sign_archive "$TAG" "$1"
}



main() {
    create_and_sign "$1"
}
main "$GPG_KEY_ID"
