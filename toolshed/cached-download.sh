#!/usr/bin/env bash
# +----------------------------------------------------------+
# | BASH : Modifying Shell Behaviour
# |    (https://www.gnu.org/software/bash/manual)
# +----------------------------------------------------------+
# Exit immediately if a pipeline returns a non-zero status.
set -o errexit

# If set, the return value of a pipeline is the value of the
# last (rightmost) command to exit with a non-zero status, or
# zero if all commands in the pipeline exit successfully.
set -o pipefail

# +----------------------------------------------------------+
# | Command Line Arguments
# +----------------------------------------------------------+
# Usage: cached-download.sh [OPTIONS]
# Generate usage message
echo_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "  -c, --cache-target DIR          Docker cache mount point"
    echo "  -d, --download-url URL          URL to download"
    echo "  -f, --download-to-file NAME     The filename to output the download to"
    echo "  -s, --checksums FILE            Checksums file"
    echo "  -u, --unpack-dir DIR            Unpack directory"
    echo "  -t, --tar-args ARGS (optional)  Additional arguments for (un)tar command"
    echo "  -h, --help                      Show help message"
}

# Check if any required option is unset (except help)
check_options() {
    if [[ -z $cache_target || -z $download_url || -z $download_to_file || -z $checksums_file || -z $unpack_dir ]]; then
        echo "Error: Missing required options"
        echo_usage
        exit 1
    fi
}

tar_args=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--cache-target)
        cache_target="$2"
        shift
        shift
        ;;
        -d|--download-url)
        download_url="$2"
        shift
        shift
        ;;
        -f|--download-to-file)
        download_to_file="$2"
        shift
        shift
        ;;
        -s|--checksums)
        checksums_file="$2"
        shift
        shift
        ;;
        -u|--unpack-dir)
        unpack_dir="$2"
        shift
        shift
        ;;
        -t|--tar-args)
        tar_args="$2"
        shift
        shift
        ;;
        -h|--help)
        echo_usage
        exit 0
        ;;
        *)
        echo "Unknown option: $1"
        echo_usage
        exit 1
        ;;
    esac
done

# Check if any required option is unset (except help)
check_options

cd "$cache_target"
wget --no-config --show-progress --progress=bar:noscroll:force -O "$download_to_file" "$download_url"
sha512sum -c "$checksums_file"
tar -xvf "$download_to_file" $tar_args -C "$unpack_dir"
