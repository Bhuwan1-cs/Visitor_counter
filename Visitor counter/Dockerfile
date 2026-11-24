FROM python:3.10

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

ENV REDIS_HOST=redis \
    REDIS_PORT=6379 \
    STUDENT_NAME="Bhuwan Kumar" \
    STUDENT_ROLL="2410030358"

CMD ["python", "app.py"]
