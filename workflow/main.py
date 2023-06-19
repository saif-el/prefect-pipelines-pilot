import time

from prefect import flow, task
from prefect.task_runners import ConcurrentTaskRunner, SequentialTaskRunner


@task
def times_two(num):
    time.sleep(5.0)
    return num * 2


@task
def times_four(num):
    time.sleep(5.0)
    return num * 4


@task
def add(x, y):
    time.sleep(5.0)
    return x + y


@task
def generate_result(subject, object, value):
    time.sleep(10.0)
    return f"The {subject} of {object} is {value}"


@flow(task_runner=ConcurrentTaskRunner())
def transform_numbers(magic_number_one, magic_number_two):
    x = times_four.submit(magic_number_two)
    y = times_two.submit(magic_number_one)
    return x, y


@flow(task_runner=SequentialTaskRunner())
def play(subject, object, magic_number_one, magic_number_two):
    x, y = transform_numbers(magic_number_one, magic_number_two)
    value = add(x, y)
    result = generate_result(subject, object, value)
    print(result)


if __name__ == "__main__":
    play("meaning", "life", 11, 5)
