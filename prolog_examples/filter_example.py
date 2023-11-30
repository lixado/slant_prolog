# this code is the same as filter_example.pro but written in python to try and explain prolog
def filter_func(input, result):
    if len(input) == 0:
        return

    if input[0] == ' ':
        return filter_func(input[1:], result)
    
    result += input[0]
    return filter_func(input[1:], result)


def main():
    result = []
    filter_func(['a', 'b', ' ', '_'], result)
    print(result)


if __name__ == "__main__":
    main()