def minutes_to_human(total_minutes):
    hours = total_minutes // 60
    minutes = total_minutes % 60

    # Build output string:
    if hours > 0 and minutes > 0:
        return f"{hours} hrs {minutes} minutes"
    elif hours > 0 and minutes == 0:
        return f"{hours} hrs"
    elif hours == 0 and minutes > 0:
        return f"{minutes} minutes"
    else:
        return "0 minutes"


# Run the function (test cases)
if __name__ == "__main__":
    # You can change this value and test
    example_minutes = 130
    
    print(minutes_to_human(example_minutes))
    print(minutes_to_human(110))
    print(minutes_to_human(60))
    print(minutes_to_human(45))
    print(minutes_to_human(0))
