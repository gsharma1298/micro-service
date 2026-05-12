FROM python:3.10.8-slim

WORKDIR /email_server

ENV PYTHONUNBUFFERED=1
ENV ENABLE_PROFILER=1

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "email_server.py"]
