FROM --platform=linux/amd64 python:3.10.2

WORKDIR /usr/src/app

RUN python3 -m pip install --upgrade pip

COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

COPY . /usr/src/app/

CMD ["flask", "run"]

EXPOSE 8080