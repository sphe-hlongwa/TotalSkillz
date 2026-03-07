import os

def find_emojis(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.html', '.js', '.css')):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        for i, line in enumerate(f, 1):
                            for char in line:
                                if ord(char) > 127 and ord(char) < 0x2700: # Broad brush for emojis/symbols
                                    # Specifically looking for emojis, ignoring common math/latin-1
                                    if ord(char) > 0x1F000 or (ord(char) >= 0x2600 and ord(char) <= 0x27BF):
                                        print(f"{path}:{i}: {line.strip()}")
                                        break
                except Exception as e:
                    print(f"Error reading {path}: {e}")

find_emojis('c:\\Users\\Wits student\\OneDrive\\Desktop\\prac\\MathGrade12\\MathGrade12\\public')
