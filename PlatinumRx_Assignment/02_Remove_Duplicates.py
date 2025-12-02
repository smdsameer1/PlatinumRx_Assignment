def remove_duplicates(s):
    result = ""
    for ch in s:           # loop through each character
        if ch not in result:
            result += ch   # add if not already present
    return result


# -------- MAIN PROGRAM ---------
if __name__ == "__main__":
    user_input = input("Enter a string: ")
    unique_string = remove_duplicates(user_input)
    print("Unique string:", unique_string)
