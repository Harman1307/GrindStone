#!/bin/bash

DATA_FILE="$HOME/.grindstone/data.json"
HISTORY_FILE="$HOME/.grindstone/history.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

BAR_FULL="■"
BAR_EMPTY="□"

init() {
    mkdir -p "$HOME/.grindstone"
    if [[ ! -f "$DATA_FILE" ]]; then
        echo '{
            "coins": 0,
            "coding": 0,
            "math": 0,
            "physical": 0,
            "academics": 0,
            "social": 0
        }' > "$DATA_FILE"
    fi
}

get_stat() {
    jq -r ".$1" "$DATA_FILE"
}

add_points() {
    local stat=$1
    local points=$2
    local current=$(get_stat "$stat")
    local new=$((current + points))
    
    jq ".$stat = $new" "$DATA_FILE" > tmp.json && mv tmp.json "$DATA_FILE"
    
    local coins=$(get_stat "coins")
    local new_coins=$((coins + points))
    jq ".coins = $new_coins" "$DATA_FILE" > tmp.json && mv tmp.json "$DATA_FILE"
    
    echo "$(date '+%Y-%m-%d %H:%M') | +$points $stat" >> "$HISTORY_FILE"
}

spend_coins() {
    local cost=$1
    local coins=$(get_stat "coins")
    if [[ $coins -ge $cost ]]; then
        local new=$((coins - cost))
        jq ".coins = $new" "$DATA_FILE" > tmp.json && mv tmp.json "$DATA_FILE"
        echo "$(date '+%Y-%m-%d %H:%M') | -$cost coins (reward)" >> "$HISTORY_FILE"
        return 0
    else
        return 1
    fi
}

draw_bar() {
    local name=$1
    local current=$2
    local max=$3
    local color=$4
    local width=20
    
    local pct=$((current * 100 / max))
    local filled=$((current * width / max))
    if [[ $filled -gt $width ]]; then
        filled=$width
    fi
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="$BAR_FULL"; done
    for ((i=0; i<empty; i++)); do bar+="$BAR_EMPTY"; done
    
    printf "  ${color}${BOLD}%-10s${NC} %s ${WHITE}%3d%%${NC} ${GRAY}(%d/%d)${NC}\n" "$name" "$bar" "$pct" "$current" "$max"
}

draw_stats() {
    local coding=$(get_stat "coding")
    local math=$(get_stat "math")
    local physical=$(get_stat "physical")
    local academics=$(get_stat "academics")
    local social=$(get_stat "social")
    local coins=$(get_stat "coins")
    
    echo ""
    echo -e "  ${BOLD}${WHITE}══════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}${WHITE}  GRINDSTONE${NC}                      💰 ${GREEN}${BOLD}${coins}${NC}"
    echo -e "  ${BOLD}${WHITE}══════════════════════════════════════════${NC}"
    echo ""
    
    draw_bar "CODING" $coding 10000 "$CYAN"
    draw_bar "MATH" $math 6000 "$GREEN"
    draw_bar "PHYSICAL" $physical 5000 "$RED"
    draw_bar "ACADEMICS" $academics 4000 "$YELLOW"
    draw_bar "SOCIAL" $social 3000 "$PURPLE"
    
    echo ""
    echo -e "  ${BOLD}${WHITE}══════════════════════════════════════════${NC}"
}

quick_log() {
    clear
    echo ""
    echo -e "  ${BOLD}${WHITE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BOLD}${WHITE}║${NC}  ${BOLD}LOG YOUR DAY${NC}                                                 ${BOLD}${WHITE}║${NC}"
    echo -e "  ${BOLD}${WHITE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GRAY}Enter numbers separated by spaces (e.g. 2 2 13 15 21)${NC}"
    echo ""
    echo -e "  ${CYAN}┌───────────────────────────────┐${NC}  ${GREEN}┌───────────────────────────────┐${NC}"
    echo -e "  ${CYAN}│${NC}  ${CYAN}${BOLD}CODING${NC}                       ${CYAN}│${NC}  ${GREEN}│${NC}  ${GREEN}${BOLD}MATH${NC}                         ${GREEN}│${NC}"
    echo -e "  ${CYAN}├───────────────────────────────┤${NC}  ${GREEN}├───────────────────────────────┤${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}1${NC}   LC Easy          ${GRAY}+10${NC}     ${CYAN}│${NC}  ${GREEN}│${NC}  ${WHITE}9${NC}   Video            ${GRAY}+10${NC}     ${GREEN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}2${NC}   LC Medium        ${GRAY}+25${NC}     ${CYAN}│${NC}  ${GREEN}│${NC}  ${WHITE}10${NC}  Problems         ${GRAY}+20${NC}     ${GREEN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}3${NC}   LC Hard          ${GRAY}+50${NC}     ${CYAN}│${NC}  ${GREEN}│${NC}  ${WHITE}11${NC}  Topic Done       ${GRAY}+50${NC}     ${GREEN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}4${NC}   Practice         ${GRAY}+15${NC}     ${CYAN}│${NC}  ${GREEN}│${NC}  ${WHITE}12${NC}  Hard Problem     ${GRAY}+40${NC}     ${GREEN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}5${NC}   Learned New      ${GRAY}+20${NC}     ${CYAN}│${NC}  ${GREEN}└───────────────────────────────┘${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}6${NC}   Project Small    ${GRAY}+20${NC}     ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}7${NC}   Project Big      ${GRAY}+50${NC}     ${CYAN}│${NC}  ${YELLOW}┌───────────────────────────────┐${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}8${NC}   Shipped          ${GRAY}+200${NC}    ${CYAN}│${NC}  ${YELLOW}│${NC}  ${YELLOW}${BOLD}ACADEMICS${NC}                    ${YELLOW}│${NC}"
    echo -e "  ${CYAN}└───────────────────────────────┘${NC}  ${YELLOW}├───────────────────────────────┤${NC}"
    echo -e "                                     ${YELLOW}│${NC}  ${WHITE}21${NC}  Studied          ${GRAY}+20${NC}     ${YELLOW}│${NC}"
    echo -e "  ${RED}┌───────────────────────────────┐${NC}  ${YELLOW}│${NC}  ${WHITE}22${NC}  Chapter Done     ${GRAY}+40${NC}     ${YELLOW}│${NC}"
    echo -e "  ${RED}│${NC}  ${RED}${BOLD}PHYSICAL${NC}                     ${RED}│${NC}  ${YELLOW}│${NC}  ${WHITE}23${NC}  Homework         ${GRAY}+15${NC}     ${YELLOW}│${NC}"
    echo -e "  ${RED}├───────────────────────────────┤${NC}  ${YELLOW}│${NC}  ${WHITE}24${NC}  Mock Test        ${GRAY}+50${NC}     ${YELLOW}│${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}13${NC}  Workout          ${GRAY}+40${NC}     ${RED}│${NC}  ${YELLOW}└───────────────────────────────┘${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}14${NC}  Long Workout     ${GRAY}+60${NC}     ${RED}│${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}15${NC}  Slept 8hrs       ${GRAY}+15${NC}     ${RED}│${NC}  ${PURPLE}┌───────────────────────────────┐${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}16${NC}  Ate Well         ${GRAY}+10${NC}     ${RED}│${NC}  ${PURPLE}│${NC}  ${PURPLE}${BOLD}SOCIAL${NC}                       ${PURPLE}│${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}17${NC}  No Junk          ${GRAY}+10${NC}     ${RED}│${NC}  ${PURPLE}├───────────────────────────────┤${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}18${NC}  Went Outside     ${GRAY}+10${NC}     ${RED}│${NC}  ${PURPLE}│${NC}  ${WHITE}25${NC}  Talked           ${GRAY}+20${NC}     ${PURPLE}│${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}19${NC}  Walk/Run         ${GRAY}+20${NC}     ${RED}│${NC}  ${PURPLE}│${NC}  ${WHITE}26${NC}  Helped           ${GRAY}+25${NC}     ${PURPLE}│${NC}"
    echo -e "  ${RED}│${NC}  ${WHITE}20${NC}  Stretched        ${GRAY}+10${NC}     ${RED}│${NC}  ${PURPLE}│${NC}  ${WHITE}27${NC}  Hung Out         ${GRAY}+30${NC}     ${PURPLE}│${NC}"
    echo -e "  ${RED}└───────────────────────────────┘${NC}  ${PURPLE}│${NC}  ${WHITE}28${NC}  New Friend       ${GRAY}+50${NC}     ${PURPLE}│${NC}"
    echo -e "                                     ${PURPLE}│${NC}  ${WHITE}29${NC}  Posted           ${GRAY}+10${NC}     ${PURPLE}│${NC}"
    echo -e "                                     ${PURPLE}│${NC}  ${WHITE}30${NC}  Recognition      ${GRAY}+40${NC}     ${PURPLE}│${NC}"
    echo -e "                                     ${PURPLE}└───────────────────────────────┘${NC}"
    echo ""
    echo -ne "  ${BOLD}❯${NC} "
    read -a choices
    
    local total=0
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) add_points "coding" 10; ((total+=10)) ;;
            2) add_points "coding" 25; ((total+=25)) ;;
            3) add_points "coding" 50; ((total+=50)) ;;
            4) add_points "coding" 15; ((total+=15)) ;;
            5) add_points "coding" 20; ((total+=20)) ;;
            6) add_points "coding" 20; ((total+=20)) ;;
            7) add_points "coding" 50; ((total+=50)) ;;
            8) add_points "coding" 200; ((total+=200)) ;;
            9) add_points "math" 10; ((total+=10)) ;;
            10) add_points "math" 20; ((total+=20)) ;;
            11) add_points "math" 50; ((total+=50)) ;;
            12) add_points "math" 40; ((total+=40)) ;;
            13) add_points "physical" 40; ((total+=40)) ;;
            14) add_points "physical" 60; ((total+=60)) ;;
            15) add_points "physical" 15; ((total+=15)) ;;
            16) add_points "physical" 10; ((total+=10)) ;;
            17) add_points "physical" 10; ((total+=10)) ;;
            18) add_points "physical" 10; ((total+=10)) ;;
            19) add_points "physical" 20; ((total+=20)) ;;
            20) add_points "physical" 10; ((total+=10)) ;;
            21) add_points "academics" 20; ((total+=20)) ;;
            22) add_points "academics" 40; ((total+=40)) ;;
            23) add_points "academics" 15; ((total+=15)) ;;
            24) add_points "academics" 50; ((total+=50)) ;;
            25) add_points "social" 20; ((total+=20)) ;;
            26) add_points "social" 25; ((total+=25)) ;;
            27) add_points "social" 30; ((total+=30)) ;;
            28) add_points "social" 50; ((total+=50)) ;;
            29) add_points "social" 10; ((total+=10)) ;;
            30) add_points "social" 40; ((total+=40)) ;;
        esac
    done
    
    if [[ $total -gt 0 ]]; then
        echo ""
        echo -e "  ${GREEN}${BOLD}✓ +${total} points earned!${NC}"
        sleep 1.5
    fi
}

rewards_menu() {
    clear
    local coins=$(get_stat "coins")
    echo ""
    echo -e "  ${BOLD}${WHITE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BOLD}${WHITE}║${NC}  ${BOLD}REWARDS${NC}                                     ${GREEN}${BOLD}${coins} coins${NC}     ${BOLD}${WHITE}║${NC}"
    echo -e "  ${BOLD}${WHITE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}${BOLD}QUICK DOPAMINE${NC}"
    echo -e "    ${WHITE}1${NC}   15 min reels           ${GRAY}-30 coins${NC}"
    echo -e "    ${WHITE}2${NC}   30 min YouTube         ${GRAY}-60 coins${NC}"
    echo ""
    echo -e "  ${GREEN}${BOLD}ENTERTAINMENT${NC}"
    echo -e "    ${WHITE}3${NC}   1 anime episode        ${GRAY}-100 coins${NC}"
    echo -e "    ${WHITE}4${NC}   1 hour gaming          ${GRAY}-150 coins${NC}"
    echo -e "    ${WHITE}5${NC}   Movie                  ${GRAY}-250 coins${NC}"
    echo -e "    ${WHITE}6${NC}   Unlock new anime       ${GRAY}-300 coins${NC}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}FOOD & COMFORT${NC}"
    echo -e "    ${WHITE}7${NC}   Cheat snack            ${GRAY}-100 coins${NC}"
    echo -e "    ${WHITE}8${NC}   Order food (<Rs.300)   ${GRAY}-400 coins${NC}"
    echo -e "    ${WHITE}9${NC}   Order food (>Rs.300)   ${GRAY}-500 coins${NC}"
    echo ""
    echo -e "  ${PURPLE}${BOLD}FREEDOM${NC}"
    echo -e "    ${WHITE}10${NC}  Skip workout (guilt-free)  ${GRAY}-200 coins${NC}"
    echo -e "    ${WHITE}11${NC}  Full day break             ${GRAY}-600 coins${NC}"
    echo -e "    ${WHITE}12${NC}  Weekend off                ${GRAY}-1000 coins${NC}"
    echo ""
    echo -e "  ${RED}${BOLD}BIG PURCHASES${NC}"
    echo -e "    ${WHITE}13${NC}  Buy something (Rs.500)     ${GRAY}-1500 coins${NC}"
    echo -e "    ${WHITE}14${NC}  Buy something (Rs.1000)    ${GRAY}-3000 coins${NC}"
    echo ""
    echo -e "    ${WHITE}0${NC}   Back"
    echo ""
    echo -e "  ${BOLD}${WHITE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -ne "  ${BOLD}>${NC} "
    read choice
    
    local cost=0
    local reward=""
    
    case $choice in
        1) cost=30; reward="15 min reels" ;;
        2) cost=60; reward="30 min YouTube" ;;
        3) cost=100; reward="anime episode" ;;
        4) cost=150; reward="1 hour gaming" ;;
        5) cost=250; reward="movie" ;;
        6) cost=300; reward="new anime unlock" ;;
        7) cost=100; reward="cheat snack" ;;
        8) cost=400; reward="food order" ;;
        9) cost=500; reward="pizza/burger" ;;
        10) cost=200; reward="workout skip" ;;
        11) cost=600; reward="full day break" ;;
        12) cost=1000; reward="weekend off" ;;
        13) cost=1500; reward="Rs.500 purchase" ;;
        14) cost=3000; reward="Rs.1000 purchase" ;;
        0) return ;;
        *) return ;;
    esac
    
    if [[ $cost -gt 0 ]]; then
        if spend_coins $cost; then
            echo ""
            echo -e "  ${GREEN}${BOLD}Enjoy your ${reward}!${NC}"
        else
            echo ""
            echo -e "  ${RED}Need ${cost} coins. You have ${coins}.${NC}"
        fi
        sleep 1.5
    fi
}

show_history() {
    clear
    echo ""
    echo -e "  ${BOLD}${WHITE}══════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}${WHITE}  HISTORY${NC}"
    echo -e "  ${BOLD}${WHITE}══════════════════════════════════════════${NC}"
    echo ""
    if [[ -f "$HISTORY_FILE" ]]; then
        tail -15 "$HISTORY_FILE" | while read line; do
            echo -e "    ${GRAY}$line${NC}"
        done
    else
        echo -e "    ${GRAY}No history yet.${NC}"
    fi
    echo ""
    echo -e "  ${BOLD}${WHITE}══════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GRAY}Press enter...${NC}"
    read
}

main_menu() {
    while true; do
        clear
        draw_stats
        echo ""
        echo -e "    ${WHITE}L${NC} Log    ${WHITE}R${NC} Rewards    ${WHITE}H${NC} History    ${WHITE}Q${NC} Quit"
        echo ""
        echo -ne "  ${BOLD}>${NC} "
        read -n1 choice
        echo ""
        
        case $choice in
            l|L) quick_log ;;
            r|R) rewards_menu ;;
            h|H) show_history ;;
            q|Q) clear; exit 0 ;;
        esac
    done
}

init
main_menu