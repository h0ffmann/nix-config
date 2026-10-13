from shout import shout


def greet(name):
    return shout(f"hello, {name}")


if __name__ == "__main__":
    print(greet("viz"))
