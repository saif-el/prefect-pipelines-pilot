import os
import time

from prefect import flow, task
from prefect.deployments import run_deployment
from prefect.filesystems import S3
from prefect.serializers import JSONSerializer
from prefect.task_runners import ConcurrentTaskRunner, SequentialTaskRunner

os.environ["AWS_ACCESS_KEY_ID"] = "ASIAXRH5YCHGXYNPFDNG"
os.environ["AWS_SECRET_ACCESS_KEY"] = "4OibcGogu9DZ8sVM+QqdhA8ZF5wsUAuxwmE2Kouz"
os.environ[
    "AWS_SESSION_TOKEN"] = \
    "IQoJb3JpZ2luX2VjEEgaDmFwLXNvdXRoZWFzdC0xIkYwRAIgD6ecaJVP7I" \
    "/9VSrY49WyQPbMzRWrIKULTTlWQ80LErkCIGOQTLPDyRZwwBlJ3LMTeZZPhK2M/5gh" \
    "/UIGWz3OkW3KKqMDCKH" \
    "//////////wEQAhoMNTE4MDc1NzE2MDQ1IgyXqxKNMiB2iHw7IWYq9wJHa5349erlXJMEdfKNIbCiPbaN/4kjRbJlyakJONXtDUDcKy31TS/Hm9HjaCGbemCi+SOGXd0FyxjcaANgTLsG+YLXFpTrRjhxqZeOvinjhZX+pmvGy8soKXezOkkXTCTDFfITUZmGNGMMasbDvne+PaTbUIJmokTlM9BB5QrqesNM/iOZKLyAEKl4aeIsJcTABQbKdE+UC4H8Ymh1IRDvBQVVZ/DGXdCD+OOagHVaDiVdFNPt6HxbeLnJl5grnyoEDdbzF3ljz2DZgRc1jJUS1xWiibSY4C8kMbX27nnHb8sUmnrS/qbBTah/UicnqpV9casZQ5/JZOSWdZ3hBF/1IH9dXApHP29WJ5doOcypsDKSPQW/jiELyJ8sL8JOuNwH1ca48vzNi2bIC0I6j4ORenBQr6PJPK/Fy6UUdAaanwUypJWryyEOh5j4sXQ2bLQQLHuPC+eMnrBJXtRO5z1iro8qtx67HRWTwNqqoaLcmLVh0p4btrww68HFpAY6pwGKW7r4BGdYEtdyCmhLE/mg0NjTThtXQ3SlPe3EL8CsADewGB2JORejyd1SyHurDkOecBaBVQ0H05+AYxvE4R8yAu2yi6q4eFaba9//TmuJah8uroJlIu8qsfjbGKgiVF5FKNAVMUZ7bScE1Nm+OmD2lBKiMfu1eZAYAyhCAnnOsRlrVII7wPbg/0Xi0MAuFwrUNcSXLw70sPFwmhkIt1mrzjQnBA977w=="


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


@flow(
    task_runner=ConcurrentTaskRunner(),
    persist_result=True,
    result_storage=S3(bucket_path="prefect-play-data/results"),
    result_serializer=JSONSerializer()
)
def transform_numbers(magic_number_one, magic_number_two):
    x = times_four.submit(magic_number_two).result()
    y = times_two.submit(magic_number_one).result()
    return x, y


@flow(task_runner=SequentialTaskRunner())
def play(subject, object, magic_number_one, magic_number_two):
    subflow_run = run_deployment(
        name=f"transform-numbers/transform_numbers",
        parameters={
            "magic_number_one": magic_number_one,
            "magic_number_two": magic_number_two
        }
    )
    x, y = subflow_run.state.result()
    value = add(x, y)
    result = generate_result(subject, object, value)
    print(result)


if __name__ == "__main__":
    play("meaning", "life", 11, 5)
