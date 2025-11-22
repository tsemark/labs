FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

CMD ["pytest", "-v", "--tb=short", "--html=reports/report.html", "--self-contained-html", "--junitxml=test-results/junit.xml", "--cov=.", "--cov-report=html:reports/coverage", "--cov-report=term"]
