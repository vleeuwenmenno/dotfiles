#!/usr/bin/env python3

import requests
import os
import json
from datetime import datetime

def get_weather():
    response = requests.get("https://wttr.in/beverwijk?n")
    return response.text.strip()

def get_moon_phase():
    response = requests.get("https://wttr.in/moon?format=F")
    return response.text.strip()

def read_prompt(file_path):
    with open(file_path, 'r') as file:
        return file.read()

def get_hostname():
    with open("/etc/hostname", 'r') as file:
        return file.read().strip()
    
def replace_wildcards(prompt, weather, moon_phase, time, date, hostname):
    prompt = prompt.replace("$TIME", time)
    prompt = prompt.replace("$DATE", date)
    prompt = prompt.replace("$HOSTNAME", hostname)
    prompt = prompt.replace("$WEATHER", weather)
    prompt = prompt.replace("$MOON_PHASE", moon_phase)
    return prompt

def main():
    home_directory = os.path.expanduser('~')
    AI_ENDPOINT = "https://api.openai.com/v1/chat/completions"
    OPENAI_API_KEY = ""
    PROMPT_FILE_PATH = home_directory + "/dotfiles/bin/resources/welcome_prompt.txt"

    # Load api key from disk
    with open(home_directory + "/dotfiles/secrets/openai_api_key.secret", 'r') as file:
        OPENAI_API_KEY = file.read().strip()
    
    weather = get_weather()
    moon_phase = get_moon_phase()
    hostname = get_hostname()
    time = datetime.now().strftime("%H:%M")
    date = datetime.now().strftime("%A, %d %B %Y")
    
    openai_prompt = read_prompt(PROMPT_FILE_PATH)
    prompt = replace_wildcards(openai_prompt, weather, moon_phase, time, date, hostname)
    
    data = {
        "max_tokens": 200,
        "messages": [
            {"role": "system", "content": prompt},
        ],
        "model": "gpt-4o-mini",
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {OPENAI_API_KEY}"
    }
    
    response = requests.post(AI_ENDPOINT, headers=headers, data=json.dumps(data))
    response_data = response.json()
    
    completion = response_data['choices'][0]['message']['content']
    
    print(completion)

if __name__ == "__main__":
    main()
