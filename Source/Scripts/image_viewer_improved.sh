#!/bin/bash
# EzImageCleaner - Mac OS Image Viewer & Cleaner
# Author: Koichi Okawa
# Description: View and clean large images (>300KB) in selected folders

# Supported image extensions
extensions=("jpg" "jpeg" "png" "gif" "bmp" "tiff" "webp" "heic")

# Temporary file for folder cache with process ID and expiration
cache_file="/tmp/ezimagecleaner_folders_$$.txt"
cache_duration=$((60 * 60))  # 1 hour in seconds

# Cleanup function
cleanup() {
    echo "Exiting..."
    osascript -e 'tell application "Preview" to quit' &>/dev/null
    [ -f "$cache_file" ] && rm -f "$cache_file"  # Remove cache file on exit
    exit 0
}

# Signal handler
trap cleanup SIGINT SIGTERM

# Function to open an image
open_image() {
    local filepath="$1"
    local abs_path
    if [[ "$filepath" = /* ]]; then
        abs_path="$filepath"
    else
        abs_path="$(cd "$(dirname "$filepath")" && pwd)/$(basename "$filepath")"
    fi
    if [ ! -f "$abs_path" ]; then
        echo "Error: File '$abs_path' not found."
        return 1
    fi
    osascript -e 'tell application "Preview" to quit' &>/dev/null
    sleep 0.3
    echo "Opening in Preview: $abs_path (Size: $(stat -f "%.2f MB" "$abs_path" | awk '{print $1}') MB)"
    open -a Preview "$abs_path"
    sleep 0.5
    # Position Preview window to the right side of the screen with error handling
    osascript << 'END' 2>/dev/null
try
    tell application "Preview"
        if (count of windows) > 0 then
            tell window 1
                set bounds to {800, 50, 1400, 900}
            end tell
        end if
    end tell
end try
try
    tell application "Terminal"
        activate
        if (count of windows) > 0 then
            tell window 1
                set bounds to {50, 50, 750, 900}
            end tell
        end if
    end tell
end try
END
    return 0
}

# Function to process images in a folder
process_folder() {
    local folder="$1"
    cd "$folder" || return 1
    echo "Processing images in: $folder"
    local image_files=()
    for ext in "${extensions[@]}"; do
        while IFS= read -r file; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                image_files+=("$file")
            fi
        done < <(find . -maxdepth 1 -type f -size +300k \( -name "*.$ext" -o -name "*.$(echo "$ext" | tr '[:lower:]' '[:upper:]')" \) -print | sed 's|^\./||')
    done

    if [ ${#image_files[@]} -eq 0 ]; then
        echo "No large image files (>300KB) found in $folder."
        return 0
    fi

    echo "Found ${#image_files[@]} large images."
    echo "Y: Delete | N: Next | R: Redisplay | Q: Back to folder selection"
    echo "------------------------------------"

    local index=0
    local total=${#image_files[@]}
    while [ $index -lt $total ]; do
        current_file="${image_files[$index]}"
        echo "[$((index+1))/$total] $current_file"
        if open_image "$current_file"; then
            read -r -n 1 -p "Delete? (Y/N/R/Q): " response
            echo ""
            case "$response" in
                [Yy])
                    abs_path="$(cd "$(dirname "$current_file")" && pwd)/$(basename "$current_file")"
                    echo "Deleting $current_file..."
                    osascript -e "tell application \"Finder\" to delete POSIX file \"$abs_path\"" &>/dev/null
                    echo "Moved to Trash."
                    ((index++))
                    ;;
                [Nn])
                    echo "Keeping $current_file."
                    ((index++))
                    ;;
                [Rr])
                    echo "Redisplaying..."
                    ;;
                [Qq])
                    echo "Returning to folder selection..."
                    return 0
                    ;;
                *)
                    echo "Invalid input. Use Y/N/R/Q."
                    ;;
            esac
        else
            echo "Skipping $current_file."
            ((index++))
        fi
        echo "------------------------------------"
    done
    echo "Finished processing $folder."
}

# Function to display folders with pagination
display_folders() {
    local -a folders=("$@")
    local total_folders=${#folders[@]}
    local per_page=10
    local page=0
    local total_pages=$(( (total_folders + per_page - 1) / per_page ))

    while true; do
        clear
        echo "Folders with large images (>300KB) - Page $((page + 1)) of $total_pages"
        echo "------------------------------------"
        local start=$((page * per_page))
        local end=$((start + per_page))
        [ $end -gt $total_folders ] && end=$total_folders
        for ((i = start; i < end; i++)); do
            printf "%2d: %-50s\n" "$((i + 1))" "${folders[$i]}"
        done
        echo "------------------------------------"
        echo "Enter number to select folder, N for next page, P for previous, Q to quit"
        read -r -p "Choice: " choice
        case "$choice" in
            [0-9]*)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "$total_folders" ] && [ "$choice" -gt 0 ]; then
                    process_folder "${folders[$((choice - 1))]}"
                else
                    echo "Invalid number. Press Enter to continue."
                    read -r
                fi
                ;;
            [Nn])
                if [ $((page + 1)) -lt $total_pages ]; then
                    ((page++))
                else
                    echo "Last page reached. Press Enter to continue."
                    read -r
                fi
                ;;
            [Pp])
                if [ $page -gt 0 ]; then
                    ((page--))
                else
                    echo "First page reached. Press Enter to continue."
                    read -r
                fi
                ;;
            [Qq])
                cleanup
                ;;
            *)
                echo "Invalid input. Press Enter to continue."
                read -r
                ;;
        esac
    done
}

# Function to search folders with progress and error handling
search_folders() {
    echo "Searching for folders with large images (>300KB) in common directories..."
    true > "$cache_file"
    local folder_count=0
    local search_dirs=("$HOME/Pictures" "$HOME/Downloads" "$HOME/Desktop" "$HOME/Documents")
    local temp_file="/tmp/ezimagecleaner_temp_$$.txt"
    true > "$temp_file"

    # First, collect all matching files into a temporary file
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            for ext in "${extensions[@]}"; do
                find "$dir" -type f -size +300k \( -name "*.$ext" -o -name "*.$(echo "$ext" | tr '[:lower:]' '[:upper:]')" \) -print 2>/dev/null >> "$temp_file"
            done
        else
            echo "Warning: Directory $dir not found, skipping."
        fi
    done

    # Process the temporary file to get unique folders
    while IFS= read -r file; do
        folder=$(dirname "$file")
        if ! grep -Fxq "$folder" "$cache_file"; then
            echo "$folder" >> "$cache_file"
            ((folder_count++))
            echo -ne "Found $folder_count folders so far...\r"
        fi
    done < "$temp_file"

    rm -f "$temp_file"
    echo ""  # New line after progress
    if [ ! -s "$cache_file" ]; then
        echo "Warning: No folders found. Check permissions or try a custom path."
    fi
}

# Main loop
while true; do
    clear
    echo "EzImageCleaner - Large Image Viewer & Cleaner (>300KB)"
    echo "------------------------------------"

    # Check for cached folder list
    if [ -f "$cache_file" ] && [ $(( $(date +%s) - $(stat -f %m "$cache_file") )) -lt $cache_duration ] && [ -s "$cache_file" ]; then
        echo "Using cached folder list (valid for 1 hour)..."
        image_folders=()
        while IFS= read -r line; do
            image_folders+=("$line")
        done < "$cache_file"
    else
        search_folders
        image_folders=()
        while IFS= read -r line; do
            image_folders+=("$line")
        done < "$cache_file"
        if [ ${#image_folders[@]} -eq 0 ]; then
            echo "Error: No valid folders found after search."
        fi
    fi

    echo "Found ${#image_folders[@]} folders with large images."
    if [ ${#image_folders[@]} -eq 0 ]; then
        echo "No folders with large images (>300KB) found."
        read -r -p "Enter a custom path or press Q to quit: " custom_path
        if [[ "$custom_path" =~ ^[Qq]$ ]]; then
            cleanup
        elif [ -d "$custom_path" ]; then
            process_folder "$custom_path"
        else
            echo "Invalid directory. Press Enter to retry."
            read -r
        fi
    else
        display_folders "${image_folders[@]}"
    fi
done