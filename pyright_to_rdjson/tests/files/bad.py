def count_three(one: str, two: int, three: int) -> int:
    return one + two + three


def bad() -> str:
    list: str = ["this is not a string type"]

    count = count_three(list, 2, 3)
    return count
