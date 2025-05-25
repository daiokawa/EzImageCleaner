#!/bin/bash
# EzImageCleaner v2 - Enhanced Mac OS Image Viewer & Cleaner
# Author: Koichi Okawa
# Description: Advanced image management tool with improved features

# Default configuration
declare -A CONFIG=(
    [MIN_SIZE]="300k"
    [CACHE_DURATION]="3600"
    [PREVIEW_DELAY]="0.7"
    [PAGE_SIZE]="10"
)

# Configuration file path
CONFIG_FILE="$HOME/.ezimagecleaner/config"

# Supported image extensions
EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "tiff" "webp" "heic" "avif")

# Global variables
CACHE_FILE="/tmp/ezimagecleaner_folders_$$.txt"
STATS_FILE="/tmp/ezimagecleaner_stats_$$.txt"
UNDO_FILE="/tmp/ezimagecleaner_undo_$$.txt"
TOTAL_DELETED=0
TOTAL_KEPT=0
TOTAL_SIZE_DELETED=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Initialize configuration
init_config() {
    if [[ ! -d "$HOME/.ezimagecleaner" ]]; then
        mkdir -p "$HOME/.ezimagecleaner"
    fi
    
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ -n "$key" && -n "$value" ]] && CONFIG[$key]="$value"
        done < "$CONFIG_FILE"
    else
        save_config
    fi
}

# Save configuration
save_config() {
    for key in "${!CONFIG[@]}"; do
        echo "$key=${CONFIG[$key]}"
    done > "$CONFIG_FILE"
}

# Cleanup function
cleanup() {
    echo -e "\n${CYAN}Session Statistics:${NC}"
    echo -e "Images deleted: ${RED}$TOTAL_DELETED${NC}"
    echo -e "Images kept: ${GREEN}$TOTAL_KEPT${NC}"
    echo -e "Space freed: ${YELLOW}$(format_size $TOTAL_SIZE_DELETED)${NC}"
    
    osascript -e 'tell application "Preview" to quit' &>/dev/null
    rm -f "$CACHE_FILE" "$STATS_FILE" "$UNDO_FILE"
    exit 0
}

# Signal handlers
trap cleanup SIGINT SIGTERM

# Format file size
format_size() {
    local size=$1
    if (( size >= 1073741824 )); then
        echo "$(bc <<< "scale=2; $size/1073741824")GB"
    elif (( size >= 1048576 )); then
        echo "$(bc <<< "scale=2; $size/1048576")MB"
    else
        echo "$(bc <<< "scale=2; $size/1024")KB"
    fi
}

# Get file info
get_file_info() {
    local file="$1"
    local size=$(stat -f%z "$file" 2>/dev/null || echo 0)
    local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || echo "Unknown")
    local dimensions=""
    
    # Try to get image dimensions
    if command -v sips &>/dev/null; then
        dimensions=$(sips -g pixelHeight -g pixelWidth "$file" 2>/dev/null | 
                    awk '/pixelHeight:|pixelWidth:/ {print $2}' | 
                    paste -sd 'x' -)
    fi
    
    echo "Size: $(format_size $size) | Modified: $modified | Dimensions: ${dimensions:-Unknown}"
}

# Display progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=30
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%$((width - filled))s" | tr ' ' '-'
    printf "] %3d%% (%d/%d)" $percent $current $total
}

# Open image with enhanced error handling
open_image() {
    local filepath="$1"
    local abs_path
    
    if [[ "$filepath" = /* ]]; then
        abs_path="$filepath"
    else
        abs_path="$(cd "$(dirname "$filepath")" 2>/dev/null && pwd)/$(basename "$filepath")"
    fi
    
    if [[ ! -f "$abs_path" ]]; then
        echo -e "${RED}Error: File not found${NC}"
        return 1
    fi
    
    # Close Preview quietly
    osascript -e 'tell application "Preview" to quit' &>/dev/null
    sleep 0.3
    
    # Display file info
    echo -e "\n${CYAN}Opening: $(basename "$abs_path")${NC}"
    echo -e "${BLUE}$(get_file_info "$abs_path")${NC}"
    
    # Open in Preview
    open -a Preview "$abs_path" 2>/dev/null
    
    # Immediately return focus to Terminal (faster)
    sleep 0.1
    osascript -e 'tell application "Terminal" to activate' &>/dev/null
    osascript -e 'tell application "System Events" to tell process "Terminal" to set frontmost to true' &>/dev/null
    
    # Small delay for Preview to fully load
    sleep 0.4
    return 0
}

# Undo last deletion
undo_deletion() {
    if [[ -f "$UNDO_FILE" && -s "$UNDO_FILE" ]]; then
        local last_deleted=$(tail -1 "$UNDO_FILE")
        if [[ -n "$last_deleted" ]]; then
            osascript -e "tell application \"Finder\" to move (first item of trash whose name is \"$(basename "$last_deleted")\") to POSIX file \"$(dirname "$last_deleted")\"" &>/dev/null
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}Restored: $(basename "$last_deleted")${NC}"
                sed -i '' '$ d' "$UNDO_FILE"
                ((TOTAL_DELETED--))
                return 0
            fi
        fi
    fi
    echo -e "${RED}Nothing to undo${NC}"
    return 1
}

# Process images in folder with enhanced features
process_folder() {
    local folder="$1"
    cd "$folder" || return 1
    
    echo -e "\n${CYAN}Processing: $folder${NC}"
    echo "Scanning for images..."
    
    local image_files=()
    local pattern_list=""
    
    # Build find pattern
    for ext in "${EXTENSIONS[@]}"; do
        pattern_list+=" -o -iname '*.$ext'"
    done
    pattern_list=${pattern_list# -o }
    
    # Find images
    while IFS= read -r -d '' file; do
        image_files+=("$file")
    done < <(eval "find . -maxdepth 1 -type f -size +${CONFIG[MIN_SIZE]} \( $pattern_list \) -print0")
    
    if [[ ${#image_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No images larger than ${CONFIG[MIN_SIZE]} found${NC}"
        return 0
    fi
    
    echo -e "${GREEN}Found ${#image_files[@]} images${NC}"
    echo -e "\n${CYAN}Controls:${NC}"
    echo "Y: Delete | N: Keep | U: Undo | R: Redisplay | S: Skip folder | Q: Quit"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local index=0
    local total=${#image_files[@]}
    
    while [[ $index -lt $total ]]; do
        current_file="${image_files[$index]}"
        show_progress $((index + 1)) $total
        
        if open_image "$current_file"; then
            local size_before=$(stat -f%z "$current_file" 2>/dev/null || echo 0)
            
            while true; do
                read -r -n 1 -p $'\nAction: ' response
                echo
                
                case "$(echo "$response" | tr '[:upper:]' '[:lower:]')" in
                    y)
                        abs_path="$(cd "$(dirname "$current_file")" && pwd)/$(basename "$current_file")"
                        echo "$abs_path" >> "$UNDO_FILE"
                        
                        osascript -e "tell application \"Finder\" to delete POSIX file \"$abs_path\"" &>/dev/null
                        if [[ $? -eq 0 ]]; then
                            echo -e "${RED}✗ Deleted${NC}"
                            ((TOTAL_DELETED++))
                            ((TOTAL_SIZE_DELETED += size_before))
                        else
                            echo -e "${RED}Failed to delete${NC}"
                        fi
                        ((index++))
                        break
                        ;;
                    n)
                        echo -e "${GREEN}✓ Kept${NC}"
                        ((TOTAL_KEPT++))
                        ((index++))
                        break
                        ;;
                    u)
                        undo_deletion
                        ;;
                    r)
                        echo "Redisplaying..."
                        open_image "$current_file"
                        ;;
                    s)
                        echo -e "${YELLOW}Skipping folder${NC}"
                        return 0
                        ;;
                    q)
                        cleanup
                        ;;
                    *)
                        echo -e "${RED}Invalid input. Use Y/N/U/R/S/Q${NC}"
                        ;;
                esac
            done
        else
            echo -e "${RED}Skipping invalid file${NC}"
            ((index++))
        fi
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    done
    
    echo -e "\n${GREEN}Completed processing $folder${NC}"
}

# Enhanced folder search with exclusions
search_folders() {
    echo -e "${CYAN}Searching for images...${NC}"
    > "$CACHE_FILE"
    
    local search_dirs=(
        "$HOME/Pictures"
        "$HOME/Downloads"
        "$HOME/Desktop"
        "$HOME/Documents"
        "$HOME/Screenshots"
    )
    
    # Add custom directories from config
    if [[ -f "$HOME/.ezimagecleaner/directories" ]]; then
        while IFS= read -r dir; do
            [[ -d "$dir" ]] && search_dirs+=("$dir")
        done < "$HOME/.ezimagecleaner/directories"
    fi
    
    local temp_file="/tmp/ezimagecleaner_temp_$$.txt"
    > "$temp_file"
    
    # Exclusions
    local exclude_patterns=(
        "*/Library/*"
        "*/.Trash/*"
        "*/node_modules/*"
        "*/.git/*"
    )
    
    # Build find command with exclusions
    local exclude_args=""
    for pattern in "${exclude_patterns[@]}"; do
        exclude_args+=" -not -path '$pattern'"
    done
    
    # Search for images
    for dir in "${search_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -ne "\rSearching in: $(basename "$dir")...          "
            
            for ext in "${EXTENSIONS[@]}"; do
                eval "find '$dir' -type f -size +${CONFIG[MIN_SIZE]} \
                    \( -iname '*.$ext' \) \
                    $exclude_args \
                    -print 2>/dev/null" >> "$temp_file"
            done
        fi
    done
    
    # Process results
    echo -ne "\rProcessing results...                    "
    
    awk -F'/' '{NF--; print}' OFS='/' "$temp_file" | 
    sort -u > "$CACHE_FILE"
    
    local count=$(wc -l < "$CACHE_FILE" | tr -d ' ')
    rm -f "$temp_file"
    
    echo -e "\r${GREEN}Found $count folders with images${NC}     "
}

# Display folders with enhanced UI
display_folders() {
    local -a folders=("$@")
    local total=${#folders[@]}
    local page=0
    local per_page=${CONFIG[PAGE_SIZE]}
    local total_pages=$(( (total + per_page - 1) / per_page ))
    
    while true; do
        clear
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║          EzImageCleaner v2 - Folder Selection         ║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo -e "Page ${YELLOW}$((page + 1))/${total_pages}${NC} | Total folders: ${GREEN}$total${NC}"
        echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        local start=$((page * per_page))
        local end=$((start + per_page))
        [[ $end -gt $total ]] && end=$total
        
        for ((i = start; i < end; i++)); do
            printf "${GREEN}%2d${NC}: %-50s\n" "$((i + 1))" "${folders[$i]}"
        done
        
        echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${CYAN}Commands:${NC} [number] Select | [N]ext | [P]rev | [C]ustom | [Q]uit"
        
        read -r choice
        
        # Check if it's a single letter command (no Enter needed)
        if [[ ${#choice} -eq 1 ]] && [[ ! "$choice" =~ ^[0-9]$ ]]; then
            case "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" in
                n)
                    [[ $((page + 1)) -lt $total_pages ]] && ((page++))
                    ;;
                p)
                    [[ $page -gt 0 ]] && ((page--))
                    ;;
                c)
                    read -r -p "Enter custom path: " custom_path
                    if [[ -d "$custom_path" ]]; then
                        process_folder "$custom_path"
                    else
                        echo -e "${RED}Invalid directory${NC}"
                        sleep 1
                    fi
                    ;;
                q)
                    cleanup
                    ;;
                *)
                    echo -e "${RED}Invalid command${NC}"
                    sleep 1
                    ;;
            esac
        elif [[ "$choice" =~ ^[0-9]+$ ]]; then
            # Number selection (needs Enter)
            if [[ $choice -ge 1 ]] && [[ $choice -le $total ]]; then
                process_folder "${folders[$((choice - 1))]}"
            else
                echo -e "${RED}Invalid number${NC}"
                sleep 1
            fi
        else
            echo -e "${RED}Invalid input${NC}"
            sleep 1
        fi
    done
}

# Main program
main() {
    init_config
    
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      EzImageCleaner v2 - Enhanced Image Manager       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo -e "Minimum size: ${YELLOW}${CONFIG[MIN_SIZE]}${NC}"
    
    # Check cache
    if [[ -f "$CACHE_FILE" ]] && 
       [[ $(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) )) -lt ${CONFIG[CACHE_DURATION]} ]]; then
        echo -e "${GREEN}Using cached results${NC}"
    else
        search_folders
    fi
    
    # Load folders
    local image_folders=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && image_folders+=("$line")
    done < "$CACHE_FILE"
    
    if [[ ${#image_folders[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No folders found. Try a custom path.${NC}"
        read -r -p "Enter path (or Q to quit): " custom_path
        [[ "${custom_path,,}" == "q" ]] && cleanup
        [[ -d "$custom_path" ]] && process_folder "$custom_path"
    else
        display_folders "${image_folders[@]}"
    fi
}

# Run main program
main